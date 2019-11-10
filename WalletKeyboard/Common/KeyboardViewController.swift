//
//  KeyboardViewController.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 15/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import KeyboardKit
import RxSwift
import RxCocoa
import AlamofireImage
import PickerView

class KeyboardViewController: KeyboardInputViewController {

	// MARK: - Properties

	let width = UIScreen.main.bounds.width
	var isKeyboardReady = false
	var lastKeyboardType: UIKeyboardType?
	var bottomConstraint: NSLayoutConstraint?

	// MARK: - Dispose Bag

	var disposeBag = DisposeBag()

	// MARK: - ViewModel

	var viewModel: KeyboardViewModel!
	
	// MARK: - Computed Properties

	var isTurnedOn: Bool {
		return (self.viewModel?.output.isTurnedOn ?? false) && self.hasFullAccess
	}

	var keyboardSwitcherAction: KeyboardAction {
		return needsInputModeSwitchKey && !isTurnedOn ? .switchKeyboard : .none
	}

	var backgroundColor: UIColor {
		return isDarkAppearance()
			? Asset.Colors.darkBackground.color
			: Asset.Colors.lightBackground.color
	}

	var textColor: UIColor {
		return isDarkAppearance()
			? Asset.Colors.darkButtonText.color
			: Asset.Colors.lightButtonText.color
	}

	var isModernIPhone: Bool {
		switch UIScreen.main.nativeBounds.height {
		case 1136, 1334, 1920, 2208:
				return false
		case 2436, 2688, 1792:
				return true
		default:
				return true
		}
	}

	var nextKeyboardButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20)) {
		didSet {
			nextKeyboardButton.addTarget(self,
																	 action: #selector(UIInputViewController.handleInputModeList(from:with:)),
																	 for: .allTouchEvents)
		}
	}

	// MARK: - Configure

	func customize(viewModel: KeyboardViewModel) {
		self.viewModel = viewModel

		//Output
		viewModel.output.address.asDriver(onErrorJustReturn: "")
			.drive(onNext: { [weak self] (ttl) in
			self?.headerView?.addressButton.setTitle(ttl, for: .normal)
		}).disposed(by: disposeBag)

		if nil != self.sendView?.amountTextField {
			viewModel.output.amount.asDriver(onErrorJustReturn: "")
				.drive(self.sendView.amountTextField.rx.text).disposed(by: disposeBag)
		}

		viewModel.output.sendAddressImageURL
			.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] (url) in
				if let url = url {
					self?.sendView?.addressImageView?.af_setImage(withURL: url)
				} else {
					self?.sendView?.addressImageView?.image = nil
				}
		}).disposed(by: disposeBag)

		if nil != self.sendView?.addressTextField {
			viewModel.output.sendAddress.asDriver(onErrorJustReturn: nil)
				.drive(self.sendView.addressTextField.rx.text).disposed(by: disposeBag)
		}

		viewModel.output.showSentView
			.asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] (val) in
				self?.sentView.transactionLinkButton?.setTitle(val, for: .normal)
				self?.sentView.transactionLinkButton?.setTitle("🔗" + val, for: .normal)
				self?.showSentView()
		}).disposed(by: disposeBag)

		if nil != self.headerView.balanceLabel {
			viewModel.output.balance.asDriver(onErrorJustReturn: "0.0000")
				.drive(self.headerView.balanceLabel.rx.text).disposed(by: disposeBag)
		}

		viewModel.output.error.asDriver(onErrorJustReturn: "")
			.drive(onNext: { (val) in
			let alert = CDAlertView(title: "Error 🙊", message: val, type: .noImage)
			let closeAction = CDAlertViewAction(title: "Close")
			alert.add(action: closeAction)
			alert.show(in: self.view)
		}).disposed(by: disposeBag)

		viewModel.output.delegated.asDriver(onErrorJustReturn: "")
			.drive(self.headerView.delegateLabel.rx.text).disposed(by: disposeBag)

		viewModel.output.balances.subscribe(onNext: { [weak self] (balances) in
			self?.balances = balances.sorted()
		}).disposed(by: disposeBag)

		viewModel.output.selectedCoin.asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] (coin) in
			self?.sendView?.coinButton?.setTitle(coin, for: .normal)
		}).disposed(by: disposeBag)

		viewModel.output.coinImageURL.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] (url) in
			if let url = url {
				self?.sendView?.coinLogo?.af_setImage(withURL: url)
			}
		}).disposed(by: disposeBag)

		viewModel.output.isLoading
			.distinctUntilChanged().asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (val) in
			self?.sendView?.activityIndicator.alpha = val ? 1.0 : 0.0
			self?.sendView?.sendButton.isEnabled = !val
			if val {
				self?.sendView?.activityIndicator.startAnimating()
				self?.sendView?.sendButton.setTitle("", for: .normal)
			} else {
				self?.sendView?.activityIndicator.stopAnimating()
				self?.sendView?.sendButton.setTitle("SEND", for: .normal)
			}
		}).disposed(by: disposeBag)

		if nil != sendView?.coinAvailableLabel {
			viewModel.output.selectedCoinBalance.asDriver(onErrorJustReturn: "")
				.drive(sendView.coinAvailableLabel.rx.text).disposed(by: disposeBag)
		}

		viewModel.output.addressFieldHasError.distinctUntilChanged().asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (hasError) in
				if hasError {
					self?.sendView?.addressTextField?.superview?.layer.borderWidth = 1.0
					self?.sendView?.addressTextField?.superview?.layer.borderColor = UIColor(red: 0.77,
																																									 green: 0.14,
																																									 blue: 0.63,
																																									 alpha: 1).cgColor
				} else {
					self?.sendView?.addressTextField?.superview?.layer.borderWidth = 0.0
				}
		}).disposed(by: disposeBag)

		if nil != sendView?.feeLabel {
			viewModel.output.fee.asDriver(onErrorJustReturn: "")
				.drive(sendView.feeLabel.rx.text).disposed(by: disposeBag)
		}

		//Input
		self.sendView?.maxButton?.rx.tap.asDriver()
			.drive(viewModel.input.didTapMaxButton).disposed(by: disposeBag)
		self.sendView?.sendButton?.rx.tap.asObservable()
			.subscribe(viewModel.input.didTapSendButton).disposed(by: disposeBag)
		self.sendView?.addressTextField?.rx.text.asDriver()
			.drive(viewModel.input.address).disposed(by: disposeBag)
		self.sendView?.amountTextField?.rx.text.asDriver().map({ (str) -> String in
			return str ?? ""
		}).drive(viewModel.input.amount).disposed(by: disposeBag)
	}

	// MARK: - Lifecycle.

	override func viewDidLoad() {
		super.viewDidLoad()

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.setUpHeightConstraint()
			self.view.translatesAutoresizingMaskIntoConstraints = false

			let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(self.tap(sender:)))
			tapGestureReconizer.cancelsTouchesInView = false
			self.view.addGestureRecognizer(tapGestureReconizer)
			
			self.loadKeyboard()
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.setAppearance()
		}
	}

	override func textDidChange(_ textInput: UITextInput?) {
    let proxy = textDocumentProxy as UITextDocumentProxy
		guard isKeyboardReady, proxy.keyboardType != lastKeyboardType else { return }
		lastKeyboardType = proxy.keyboardType

		if hasFullAccess && scrollView != nil {
			if getKeyboardType() == .hex {
				scrollView.isHidden = false
				keyboardStackView.subviews.forEach({$0.removeFromSuperview()})
			} else {
				scrollView.isHidden = true
				showKeyboard(type: getKeyboardType(), forSelectedTextField: false, topPadding: 40)
			}
		} else {
			showKeyboard(type: getKeyboardType(), forSelectedTextField: false, topPadding: 40)
		}
	}

	func loadKeyboard() {
    let proxy = textDocumentProxy as UITextDocumentProxy
		lastKeyboardType = proxy.keyboardType
		let viewModel = KeyboardViewModel()

		if hasFullAccess {
			initializeHeaderView()
		}

		if hasFullAccess && viewModel.output.isTurnedOn {
			initializeScrollView()
			customize(viewModel: viewModel)
			nextKeyboardButton.isHidden = isModernIPhone

			if getKeyboardType() != .hex {
				scrollView.isHidden = true
				showKeyboard(type: getKeyboardType(), forSelectedTextField: false, topPadding: 40)
			}
		} else {
			showKeyboard(type: getKeyboardType(), forSelectedTextField: false, topPadding: 40)
		}

		isKeyboardReady = true
	}

	// MARK: -

	var balances: [String] = []

	lazy var pasteBtn = pasteButton()
	var additionalKeyboardView: UIView?
	var selectedTextField: FakeTextFieldView? {
		didSet {
			self.setKeyboardActionHandler()
			pasteBtn.removeFromSuperview()

			guard oldValue != selectedTextField else {
				if (nil != selectedTextField &&
					nil != UIPasteboard.general.string &&
					"" != UIPasteboard.general.string) {

					if pasteBtn.superview == nil {
						pasteBtn = pasteButton()
						self.view.addSubview(pasteBtn)
					} else {
						pasteBtn.removeFromSuperview()
						return
					}

					guard let selectedTF = self.selectedTextField else {
						return
					}

					let convertedFrame = self.view.convert(selectedTF.frame, from: selectedTF.superview!)
					pasteBtn.frame = CGRect(x: width/2, y: convertedFrame.maxY, width: 69, height: 45)
					pasteBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 9, right: 0)
					pasteBtn.titleLabel?.font = UIFont.defaultFont(of: 14.0)
					self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(top)-[paste]",
																																	options: [],
																																	metrics: ["top": (convertedFrame.minY - 45.0)],
																																	views: ["paste": pasteBtn]))
					self.view.addConstraint(NSLayoutConstraint(item: pasteBtn,
																										 attribute: .centerX,
																										 relatedBy: .equal,
																										 toItem: selectedTF,
																										 attribute: .centerX,
																										 multiplier: 1.0,
																										 constant: 0.0))
				}
				return
			}

			oldValue?.isTyping = false
			if selectedTextField as? AddressTextField != nil {
				if nil != oldValue {
					hideKeyboard()
				}
				showKeyboard(type: .hex)
			} else {
				showKeyboard(type: .numeric)
			}
			if let endPosition = selectedTextField?.endOfDocument {
				selectedTextField?.selectedTextRange = selectedTextField?.textRange(from: endPosition,
																																						to: endPosition)
			}
		}
	}

	var heightConstraint: NSLayoutConstraint!

	lazy var pickerView = self.coinPickerView()
	var scrollView: UIScrollView!
	var balanceView: UIView!
	var sendView: SendView!
	var convertView: UIView!
	var delegateView: UIView!
	var headerView: HeaderView!
	lazy var sentView: SentView! = {
		let sentViewNib = UINib(nibName: "SentView", bundle: nil)
		let sentViewObjects = sentViewNib.instantiate(withOwner: nil, options: nil)
		let sentV = sentViewObjects.first as? SentView
		sentV?.translatesAutoresizingMaskIntoConstraints = false
		sentV?.closeButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.hideSentView()
		}).disposed(by: self.disposeBag)
		sentV?.phraseButtons?.forEach({ (button) in
			button.addTapAction {
				(self.textDocumentProxy as UIKeyInput).insertText(button.titleLabel?.text ?? "")
			}
		})
		sentV?.transactionLinkButton.addTapAction { [weak self] in
			let hex = sentV?.transactionLinkButton.titleLabel?.text?.replacingOccurrences(of: "🔗", with: "") ?? ""
			(self?.textDocumentProxy as? UIKeyInput)?.insertText("https://explorer.minter.network/transactions/" + hex)
		}
		return sentV
	}()

	func setKeyboardActionHandler() {
		self.keyboardActionHandler = {
			if self.selectedTextField != nil {
				return SelectedTextfieldKeyboardActionHandler(textField: self.selectedTextField!, inputViewController: self)
			} else {
				return StandardKeyboardActionHandler(inputViewController: self)
			}
		}()
	}

	func setUpHeightConstraint() {
		if heightConstraint == nil {
			heightConstraint = NSLayoutConstraint(item: keyboardStackView,
																						attribute: .height,
																						relatedBy: .greaterThanOrEqual,
																						toItem: nil,
																						attribute: .notAnAttribute,
																						multiplier: 1,
																						constant: self.isTurnedOn ? 316.0 : 60.0)
			heightConstraint.priority = UILayoutPriority.defaultLow
			keyboardStackView.addConstraint(heightConstraint)
		}
		setNeedsChangeHeight(forKeyboard: .none)
	}

	// MARK: - Initialize views

	func initializeHeaderView() {
		let headerViewNib = UINib(nibName: "HeaderView", bundle: nil)
		let headerViewObjects = headerViewNib.instantiate(withOwner: nil, options: nil)
		headerView = headerViewObjects.first as? HeaderView
		guard let headerView = headerView else { return }
		headerView.addressButton.rx.tap.subscribe(onNext: { (_) in
			self.keyPressed(self.headerView.addressButton)
		}).disposed(by: disposeBag)
		headerView.translatesAutoresizingMaskIntoConstraints = false
		headerView.backgroundColor = backgroundColor
		view.addSubview(headerView)
	}

	func initializeScrollView() {

		// Scroll View
		scrollView = UIScrollView(frame: view.bounds)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.isScrollEnabled = false
		scrollView.backgroundColor = backgroundColor
		self.view?.addSubview(scrollView!)

		// Mix it all
		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerView(width)]-0-|",
																														 options: [],
																														 metrics: ["width": width],
																														 views: ["headerView": headerView]))
		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
																																	options: [],
																																	metrics: nil,
																																	views: ["view": scrollView]))
		self.view?.addConstraints(NSLayoutConstraint
			.constraints(withVisualFormat: "V:|-0-[headerView(48)]-0-[view(viewHeight)]",
									 options: [],
									 metrics: ["viewHeight": isModernIPhone ? 190 : 240],
									 views: ["view": scrollView,
													 "headerView": headerView]))

		bottomConstraint = NSLayoutConstraint(item: scrollView,
																					attribute: .bottom,
																					relatedBy: .equal,
																					toItem: view,
																					attribute: .bottom,
																					multiplier: 1.0,
																					constant: 0.0)
		bottomConstraint?.priority = .defaultLow
		self.view?.addConstraint(bottomConstraint!)

		let sendViewNib = UINib(nibName: "SendView", bundle: nil)
		let sendViewObjects = sendViewNib.instantiate(withOwner: nil, options: nil)
		sendView = sendViewObjects.first as? SendView

		guard let sendView = sendView else { return }
		sendView.translatesAutoresizingMaskIntoConstraints = false

		sendView.pasteButton.rx.tap
			.subscribe(onNext: { [weak self] (_) in
				self?.pasteAddress()
		}).disposed(by: disposeBag)

		sendView.coinButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.showPicker()
		}).disposed(by: disposeBag)

		self.sendView.addressTextField.keyboardDelegate = self
		self.sendView.amountTextField.keyboardDelegate = self
		scrollView.addSubview(sendView)

		// Delegate View
		let delegateViewNib = UINib(nibName: "DelegateView", bundle: nil)
		let delegateViewObjects = delegateViewNib.instantiate(withOwner: nil, options: nil)
		delegateView = delegateViewObjects.first as? DelegateView
		guard let delegateView = delegateView else { return }
		delegateView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(delegateView)

		// Convert View
		let convertViewNib = UINib(nibName: "ConvertView", bundle: nil)
		let convertViewObjects = convertViewNib.instantiate(withOwner: nil, options: nil)
		convertView = convertViewObjects.first as? ConvertView
		guard let convertView = convertView else { return }
		convertView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(convertView)

		// Next Keyboard Button
		if !isModernIPhone {
			nextKeyboardButton.setImage(UIImage(named: "Buttons/switchKeyboard"), for: .normal)
			nextKeyboardButton.contentVerticalAlignment = .fill
			nextKeyboardButton.contentHorizontalAlignment = .fill
			nextKeyboardButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
			nextKeyboardButton.tintColor = textColor

			nextKeyboardButton.sizeToFit()
			nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
			nextKeyboardButton.addTarget(self,
																	 action: #selector(UIInputViewController.advanceToNextInputMode),
																	 for: .touchUpInside)
			scrollView.addSubview(nextKeyboardButton)

			scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[nextKeyboardButton]",
																															 options: [],
																															 metrics: nil,
																															 views: ["nextKeyboardButton": nextKeyboardButton]))
			scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[nextKeyboardButton]-(-50)-|",
																															 options: [],
																															 metrics: nil,
																															 views: ["nextKeyboardButton": nextKeyboardButton]))
		}

		// Mix Scroll View
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[sendView(width)]-0-[delegateView(width)]-0-[convertView(width)]-0-|",
																														 options: [],
																														 metrics: ["width": width],
																														 views: ["balanceView": balanceView,
																																		 "sendView": sendView,
																																		 "delegateView": delegateView,
																																		 "convertView": convertView]))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[sendView(179)]-0-|",
																														 options: [],
																														 metrics: nil,
																														 views: ["sendView": sendView]))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[delegateView(179)]-0-|",
																														 options: [],
																														 metrics: nil,
																														 views: ["delegateView": delegateView]))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[convertView(179)]-0-|",
																														 options: [],
																														 metrics: nil,
																														 views: ["convertView": convertView]))
	}

	// MARK: - Key Actions

	@IBAction func keyPressed(_ button: UIButton) {
		guard let string = button.titleLabel?.text else { return }

		(textDocumentProxy as UIKeyInput).insertText("\(string)")

		UIView.animate(withDuration: 0.1, animations: {
			button.transform = CGAffineTransform.init(scaleX: 1.05, y: 1.05)
		}, completion: { (_) -> Void in
			button.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
		})
	}

	@objc func tap(sender: UITapGestureRecognizer) {
		pasteBtn.alpha = 0.0
		pasteBtn.removeFromSuperview()
	}

	@objc func pasteSendAddress() {
		if let str = UIPasteboard.general.string {
			self.sendView?.addressTextField?.text = str
		}
	}
}

extension KeyboardViewController: UITextFieldDelegate {
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			textField.isEnabled = false
		}
		return true
	}

	func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		view.endEditing(true)
	}

	func pasteAddress() {
		let pasteString = (UIPasteboard.general.string ?? "")
			.regex(pattern: String.addressRegexp).first

		sendView.addressTextField.text = pasteString
		let endPosition = sendView.addressTextField.endOfDocument
		sendView.addressTextField.selectedTextRange = sendView.addressTextField.textRange(from: endPosition,
																																											to: endPosition)
		sendView.addressTextField.sendActions(for: [.editingChanged])
		pasteBtn.alpha = 0.0
		pasteBtn.removeFromSuperview()
	}
	
	func pasteAmount() {
		let pasteString = (UIPasteboard.general.string ?? "")
			.regex(pattern: String.decimalRegexp).first
		sendView.amountTextField.text = pasteString
		let endPosition = sendView.amountTextField.endOfDocument
		sendView.amountTextField.selectedTextRange = sendView.amountTextField.textRange(from: endPosition,
																																										to: endPosition)
		sendView.amountTextField.sendActions(for: [.editingChanged])
		pasteBtn.alpha = 0.0
		pasteBtn.removeFromSuperview()
	}
}

extension KeyboardViewController {

	func setNeedsChangeHeight(forKeyboard ofType: KeyboardType) {
		if ofType == .none {
			heightConstraint?.constant = self.isTurnedOn ? 316.0 : 60.0
		}
		heightConstraint?.constant = (ofType == .numeric ? 470.0 : 316.0)
	}

	enum KeyboardType {
		case none
		case numeric
		case number
		case decimal
		case hex
		case letters
	}

	func showKeyboard(type: KeyboardType,
										forSelectedTextField: Bool = true,
										topPadding: CGFloat = 5.0) {
		if forSelectedTextField {
			guard selectedTextField != nil else { return }
		}

		var topPadding = topPadding
		var keyboard: UIView!
		switch type {
		case .none:
			setNeedsChangeHeight(forKeyboard: .none)
			keyboard = nil
			break

		case .hex:
			setNeedsChangeHeight(forKeyboard: .hex)
			keyboard = hexKeyboardView(hideOkButton: !forSelectedTextField)
			topPadding = max(5.0, topPadding)
			break

		case .numeric:
			setNeedsChangeHeight(forKeyboard: .numeric)
			keyboard = numericKeyboardView()
			topPadding = max(20.0, topPadding)
			break
		case .number:
			setNeedsChangeHeight(forKeyboard: .decimal)
			keyboard = decimalKeyboardView(isDecimal: false)
			topPadding = max(20.0, topPadding)
			break
		case .decimal:
			setNeedsChangeHeight(forKeyboard: .decimal)
			keyboard = decimalKeyboardView(isDecimal: true)
			topPadding = max(20.0, topPadding)
			break

		case .letters:
			setNeedsChangeHeight(forKeyboard: .letters)
			keyboard = lettersKeyboardView()
			topPadding = max(20.0, topPadding)
			break
		}
		additionalKeyboardView = keyboard

		keyboard.translatesAutoresizingMaskIntoConstraints = false
		if forSelectedTextField {
			view.addSubview(keyboard)
		} else {
			keyboardStackView.subviews.forEach({$0.removeFromSuperview()})
			keyboardStackView.addSubview(keyboard)
		}
		keyboard.frame = CGRect(x: 0,
														y: view.bounds.height,
														width: keyboard.bounds.width,
														height: keyboard.bounds.height)
		if forSelectedTextField {
			view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyboard]-0-|",
																															 options: [],
																															 metrics: nil,
																															 views: ["keyboard": keyboard]))
			view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selectedTextField]-(topPadding)-[keyboard(>=keyboardHeight)]-(0@750)-|",
																															options: [],
																															metrics: ["keyboardHeight": keyboard.bounds.height, 			"topPadding": topPadding],
																															views: ["keyboard": keyboard,
																																			"selectedTextField": selectedTextField]))
		} else {
			keyboardStackView.addConstraints(NSLayoutConstraint
				.constraints(withVisualFormat: "H:|-0-[keyboard(width)]-0-|",
										 options: [],
										 metrics: ["width": width],
										 views: ["keyboard": keyboard]))
			keyboardStackView.addConstraints(NSLayoutConstraint
				.constraints(withVisualFormat: "V:|-(topPadding)-[keyboard(>=keyboardHeight)]-(0)-|",
										 options: [],
										 metrics: ["keyboardHeight": keyboard.bounds.height,
															 "topPadding": topPadding],
										 views: ["keyboard": keyboard]))
		}
		view.layoutIfNeeded()
	}

	func hideKeyboard() {
		setNeedsChangeHeight(forKeyboard: .none)
		additionalKeyboardView?.removeFromSuperview()
		additionalKeyboardView = nil
		view.layoutIfNeeded()
	}

	func hexKeyboardView(hideOkButton: Bool = false) -> UIView {
		let height = Double(90.0)
		if hideOkButton {
			heightConstraint?.constant = 40.0
		}
		let keyboard = HexKeyboard(in: self)
		let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.backgroundColor = backgroundColor
		keyboardView.axis = .vertical
		keyboardView.alignment = .fill
		keyboardView.distribution = .equalSpacing
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		keyboardView.addArrangedSubviews(rows)

		let okButton = UIButton(frame: CGRect(x: 10, y: 0, width: (UIScreen.main.bounds.width - 10 - 10), height: 46))
		okButton.translatesAutoresizingMaskIntoConstraints = false
		okButton.setBackgroundImage(UIImage(named: "action-button"), for: .normal)
		okButton.setTitle("OK", for: .normal)
		okButton.setTitleColor(UIColor.white, for: .normal)
		okButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.hideKeyboard()
			self?.selectedTextField = nil
		}).disposed(by: disposeBag)
		if hideOkButton {
			okButton.isHidden = true
		}

		let keyboardViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
		keyboardViewWrapper.addSubview(keyboardView)
		keyboardViewWrapper.backgroundColor = self.backgroundColor
		keyboardViewWrapper.addSubview(okButton)
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[okButton]-10-|",
																																			options: [],
																																			metrics: nil,
																																			views: ["okButton": okButton]))
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[keyboard(height)]-7-[okButton(46)]-(>=0)-|",
																																			 options: [],
																																			 metrics: ["height": height],
																																			 views: ["keyboard": keyboardView,
																																							 "okButton": okButton]))
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyboard]-0-|",
																																			options: [],
																																			metrics: nil,
																																			views: ["keyboard": keyboardView]))
		return keyboardViewWrapper
	}

	func numericKeyboardView() -> UIView {
		let height = Double(230.0)

		let keyboard = NumericKeyboard(in: self)
		let rows = buttonRows(for: keyboard.actions, distribution: .fillEqually)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.backgroundColor = backgroundColor
		keyboardView.axis = .vertical
		keyboardView.alignment = .fill
		keyboardView.distribution = .equalSpacing
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		keyboardView.addArrangedSubviews(rows)

		let okButton = UIButton(frame: CGRect(x: 10, y: 0, width: (UIScreen.main.bounds.width - 10 - 10), height: 46))
		okButton.translatesAutoresizingMaskIntoConstraints = false
		okButton.setBackgroundImage(UIImage(named: "action-button"), for: .normal)
		okButton.setTitle("OK", for: .normal)
		okButton.setTitleColor(UIColor.white, for: .normal)
		okButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.hideKeyboard()
			self?.selectedTextField = nil
		}).disposed(by: disposeBag)

		let keyboardViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
		keyboardViewWrapper.addSubview(keyboardView)
		keyboardViewWrapper.backgroundColor = self.backgroundColor
		keyboardViewWrapper.addSubview(okButton)
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[okButton]-10-|",
																																			options: [],
																																			metrics: nil,
																																			views: ["okButton": okButton]))
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[keyboard(168)]-6-[okButton(46)]",
																																			options: [],
																																			metrics: nil,
																																			views: ["keyboard": keyboardView,
																																							"okButton": okButton]))
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyboard]-0-|",
																																			options: [],
																																			metrics: nil,
																																			views: ["keyboard": keyboardView]))
		return keyboardViewWrapper
	}
	
	func decimalKeyboardView(isDecimal: Bool) -> UIView {
		let height = Double(210.0)

		let keyboard = DecimalKeyboard(in: self, isDecimal: isDecimal)
		let rows = buttonRows(for: keyboard.actions, distribution: .fillEqually, buttonHeight: 52)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.axis = .vertical
		keyboardView.alignment = .fill
		keyboardView.distribution = .equalSpacing
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		keyboardView.addArrangedSubviews(rows)

		let keyboardViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
		keyboardViewWrapper.addSubview(keyboardView)
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[keyboard(210)]-6-|",
																																				options: [],
																																				metrics: nil,
																																				views: ["keyboard": keyboardView]))
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyboard]-0-|",
																																				options: [],
																																				metrics: nil,
																																				views: ["keyboard": keyboardView]))
		return keyboardViewWrapper
	}

	func lettersKeyboardView() -> UIView {
		let height = Double(178.0)
		let keyboard = AlphabeticKeyboard(uppercased: false, in: self)
		let rows = buttonRows(for: keyboard.actions, distribution: .fillEqually)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)
		keyboardView.axis = .vertical
		keyboardView.alignment = .fill
		keyboardView.distribution = .equalCentering
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		keyboardView.addArrangedSubviews(rows)
		let keyboardViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
		keyboardViewWrapper.addSubview(keyboardView)
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[keyboard(168)]",
																																			options: [],
																																			metrics: nil,
																																			views: ["keyboard": keyboardView]))
		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyboard]-0-|",
																																			options: [],
																																			metrics: nil,
																																			views: ["keyboard": keyboardView]))
		return keyboardViewWrapper
	}

	// MARK: -

	func button(for action: KeyboardAction, distribution: UIStackView.Distribution = .equalSpacing) -> UIView {
		if action == .none { return KeyboardSpacerView(width: 10) }
		let view = CharacterButton.fromNib(owner: self)
		view.setup(with: action, in: self, distribution: distribution)
		return view
	}

	func buttonRow(for actions: KeyboardActionRow, distribution: UIStackView.Distribution, buttonHeight: CGFloat) -> KeyboardButtonRow {
		return KeyboardButtonRow(height: buttonHeight, actions: actions, distribution: distribution) {
			return button(for: $0, distribution: distribution)
		}
	}

	func buttonRows(for actions: KeyboardActionRows, distribution: UIStackView.Distribution, buttonHeight: CGFloat = 42) -> [KeyboardButtonRow] {
		var rows = actions.map { buttonRow(for: $0, distribution: distribution, buttonHeight: buttonHeight) }
		guard rows.count > 2 else { return rows }
		rows[0].buttonStackView.distribution = .fillEqually
		rows[1].buttonStackView.distribution = .fillEqually
		return rows
	}
}

extension KeyboardViewController: FakeTextFieldViewDelegate {
	func didTap(textField: FakeTextFieldView) {
		self.selectedTextField = textField
	}
}

extension KeyboardViewController {

	func showSentView() {
		guard self.sentView != nil else { return }
		self.view.addSubview(self.sentView)
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
																														options: [],
																														metrics: nil,
																														views: ["view": sentView]))

		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[header]-0-[view(250)]-0-|",
																														options: [],
																														metrics: nil,
																														views: ["view": sentView,
																																		"header": self.headerView]))
	}

	func hideSentView() {
		self.sentView.removeFromSuperview()
		self.view.layoutIfNeeded()
	}

}

extension KeyboardViewController: UIGestureRecognizerDelegate, PickerViewDelegate, PickerViewDataSource {

	func showPicker() {
		view.addSubview(pickerView)
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["picker": pickerView]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker(250)]",
																																		options: [],
																																		metrics: nil,
																																		views: ["picker": pickerView]))
	}

	func hidePicker() {
		self.pickerView.removeFromSuperview()
	}

	func coinPickerView() -> UIView {
		let pickerViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 250))

		pickerViewWrapper.translatesAutoresizingMaskIntoConstraints = false

		let coinPicker = PickerView()
		coinPicker.translatesAutoresizingMaskIntoConstraints = false
		coinPicker.delegate = self
		coinPicker.dataSource = self
		coinPicker.backgroundColor = backgroundColor
		pickerViewWrapper.addSubview(coinPicker)
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|",
																											 options: [],
																											 metrics: nil,
																											 views: ["picker": coinPicker]))
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker(250)]-0-|",
																											 options: [],
																											 metrics: nil,
																											 views: ["picker": coinPicker]))
		pickerViewWrapper.backgroundColor = backgroundColor
		let okButton = UIButton(frame: CGRect(x: 10, y: 0, width: (width - 10 - 10), height: 46))
		okButton.translatesAutoresizingMaskIntoConstraints = false
		okButton.setBackgroundImage(UIImage(named: "action-button"), for: .normal)
		okButton.setTitle("OK", for: .normal)
		okButton.setTitleColor(UIColor.white, for: .normal)
		okButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.hidePicker()
		}).disposed(by: disposeBag)

		pickerViewWrapper.addSubview(okButton)
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[okButton]-10-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["okButton": okButton]))
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[okButton(46)]-(15)-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["okButton": okButton]))
		return pickerViewWrapper
	}

	func pasteButton() -> UIButton {
		let button = UIButton(frame: CGRect(x: 0, y: 0, width: 69, height: 45))
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setBackgroundImage(UIImage(named: "paste-icon"), for: .normal)
		button.setTitle("Paste", for: .normal)
		button.setTitleColor(.white, for: .normal)
		button.addTapAction {
			if nil != self.selectedTextField as? AddressTextField {
				self.pasteAddress()
			} else {
				self.pasteAmount()
			}
		}
		return button
	}

	func allowFullAccessView() -> UIView {
		let allowFullAccessView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 250))
		return allowFullAccessView
	}

	func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
		return balances.count
	}

	func pickerView(_ pickerView: PickerView, titleForRow row: Int) -> String {
		return balances[row]
	}

	func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
		return 25.0
	}

	func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
		label.textAlignment = .center

		if highlighted {
			label.font = UIFont.defaultFont(of: 25)
			if isDarkAppearance() {
				label.textColor = .white
			} else {
				label.textColor = .black
			}
		} else {
			label.font = UIFont.defaultFont(of: 24)
			label.textColor = .lightGray
		}
	}

	func pickerView(_ pickerView: PickerView, didSelectRow row: Int) {
		let title = pickerView.dataSource?.pickerView(pickerView, titleForRow: row)
		viewModel.input.selectedCoin.onNext(String(title?.split(separator: " ").first ?? ""))
	}
}

extension KeyboardViewController {
	func setAppearance() {
		view?.backgroundColor = .clear
		headerView?.setAppearance(isDark: isDarkAppearance())
		sendView?.setAppearance(isDark: isDarkAppearance())
		sentView?.setAppearance(isDark: isDarkAppearance())
	}

	func isDarkAppearance() -> Bool {
		return self.textDocumentProxy.keyboardAppearance == .dark
	}
	
	func getKeyboardType() -> KeyboardType {
		switch textDocumentProxy.keyboardType {
		case .decimalPad:
			return .decimal
		case .numberPad:
			return .number
		default:
			return .hex
		}
	}
}
