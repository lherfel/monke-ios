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

	let width = UIScreen.main.bounds.width
	let height = UIScreen.main.bounds.width

	// MARK: -

	var disposeBag = DisposeBag()

	// MARK: - ViewModel

	var viewModel = KeyboardViewModel()

	func customize(viewModel: KeyboardViewModel) {

		//Output
		viewModel.output.address.asDriver(onErrorJustReturn: "")
			.drive(onNext: { [weak self] (ttl) in
			self?.headerView?.addressButton.setTitle(ttl, for: .normal)
		}).disposed(by: disposeBag)

		viewModel.output.amount.asDriver(onErrorJustReturn: "")
			.drive(self.sendView.amountTextField.rx.text).disposed(by: disposeBag)

		viewModel.output.sendAddressImageURL
			.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] (url) in
				if let url = url {
					self?.sendView.addressImageView.af_setImage(withURL: url)
				} else {
					self?.sendView.addressImageView.image = nil
				}
		}).disposed(by: disposeBag)

		viewModel.output.sendAddress.asDriver(onErrorJustReturn: nil)
			.drive(self.sendView.addressTextField.rx.text).disposed(by: disposeBag)

		viewModel.output.showSentView.asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] (val) in
			self?.sentView.transactionLinkButton.setTitle(val, for: .normal)
			self?.sentView.transactionLinkButton.setTitle("🔗" + val, for: .normal)
			self?.showSentView()
		}).disposed(by: disposeBag)

		viewModel.output.balance.asDriver(onErrorJustReturn: "0.0000")
			.drive(self.headerView.balanceLabel.rx.text).disposed(by: disposeBag)

		viewModel.output.error.asDriver(onErrorJustReturn: "")
			.drive(onNext: { (val) in
//				self.headerView.delegateLabel.text = val
			let alert = CDAlertView(title: "Error 🙊", message: val, type: .noImage)
			let closeAction = CDAlertViewAction(title: "Close")
			alert.add(action: closeAction)
			alert.show(in: self.view)
		}).disposed(by: disposeBag)

		viewModel.output.delegated.asDriver(onErrorJustReturn: "")
			.drive(self.headerView.delegateLabel.rx.text).disposed(by: disposeBag)
		viewModel.output.balances.subscribe(onNext: { [weak self] (balances) in
			self?.balances = balances
		}).disposed(by: disposeBag)

		viewModel.output.selectedCoin.asDriver(onErrorJustReturn: "").drive(onNext: { [weak self] (coin) in
			self?.sendView.coinButton.setTitle(coin, for: .normal)
		}).disposed(by: disposeBag)

		viewModel.output.coinImageURL.asDriver(onErrorJustReturn: nil).drive(onNext: { [weak self] (url) in
			if let url = url {
				self?.sendView.coinLogo.af_setImage(withURL: url)
			}
		}).disposed(by: disposeBag)

		viewModel.output.isLoading.distinctUntilChanged().asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (val) in
			self?.sendView.activityIndicator.alpha = val ? 1.0 : 0.0
			self?.sendView.sendButton.isEnabled = !val
			if val {
				self?.sendView.activityIndicator.startAnimating()
				self?.sendView.sendButton.setTitle("", for: .normal)
			} else {
				self?.sendView.activityIndicator.stopAnimating()
				self?.sendView.sendButton.setTitle("SEND", for: .normal)
			}
		}).disposed(by: disposeBag)

		viewModel.output.selectedCoinBalance.asDriver(onErrorJustReturn: "")
			.drive(sendView.coinAvailableLabel.rx.text).disposed(by: disposeBag)
		
		viewModel.output.addressFieldHasError.distinctUntilChanged().asDriver(onErrorJustReturn: false)
			.drive(onNext: { [weak self] (hasError) in
				if hasError {
					self?.sendView?.addressTextField.superview?.layer.borderWidth = 1.0
					self?.sendView?.addressTextField.superview?.layer.borderColor = UIColor(red: 0.77,
																																			 green: 0.14,
																																			 blue: 0.63,
																																			 alpha: 1).cgColor
				} else {
					self?.sendView?.addressTextField.superview?.layer.borderWidth = 0.0
				}
		}).disposed(by: disposeBag)

		//Input
		self.sendView.maxButton.rx.tap.asDriver()
			.drive(viewModel.input.didTapMaxButton).disposed(by: disposeBag)
		self.sendView.sendButton.rx.tap.asObservable()
			.subscribe(viewModel.input.didTapSendButton).disposed(by: disposeBag)
		self.sendView.addressTextField.rx.text.asDriver()
			.drive(viewModel.input.address).disposed(by: disposeBag)
		self.sendView.amountTextField.rx.text.asDriver().map({ (str) -> String in
			return str ?? ""
		}).drive(viewModel.input.amount).disposed(by: disposeBag)
	}

	// MARK: -
	
	var balances: [String] = []

	var backgroundColor: UIColor {
		if isDarkAppearance() {
			return UIColor(red: 32/255, green: 35/255, blue: 40/255, alpha: 1)
		}
		return UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1.0)
	}

	var additionalKeyboardView: UIView?
	var selectedTextField: FakeTextFieldView? {
		didSet {
			self.setKeyboardActionHandler()

			guard oldValue != selectedTextField else {
				if nil != selectedTextField as? AddressTextField && nil != UIPasteboard.general.string {
					self.sendView.sendAddressPasteButton.alpha = 1.0
					self.sendView.bringSubviewToFront(self.sendView.sendAddressPasteButton)
//					view.sendSubviewToBack(additionalKeyboardView)
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

	override func updateViewConstraints() {
		super.updateViewConstraints()
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

	override func viewDidLoad() {
		super.viewDidLoad()

		setUpHeightConstraint()

		view.translatesAutoresizingMaskIntoConstraints = false

		let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(tap(sender:)))
		tapGestureReconizer.cancelsTouchesInView = false
		view.addGestureRecognizer(tapGestureReconizer)

		initializeScrollView()

		customize(viewModel: viewModel)
	}

	func hideForm() {
//		self.sendView?.add
	}

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
																						constant: 200)
			heightConstraint.priority = UILayoutPriority.defaultLow
			
			keyboardStackView.addConstraint(heightConstraint)
		} else {
//			heightConstraint.constant = customHeight
		}
	}

	// MARK: -

	func initializeScrollView() {

		let headerViewNib = UINib(nibName: "HeaderView", bundle: nil)
		let headerViewObjects = headerViewNib.instantiate(withOwner: nil, options: nil)
		headerView = headerViewObjects.first as? HeaderView
		guard let headerView = headerView else { return }
		headerView.addressButton.rx.tap.subscribe(onNext: { (_) in
			self.keyPressed(self.headerView.addressButton)
		}).disposed(by: disposeBag)
		headerView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(headerView)

		self.scrollView = UIScrollView(frame: view.bounds)
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.isScrollEnabled = false
		self.view?.addSubview(scrollView!)

		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[headerView(width)]-0-|",
																														 options: [],
																														 metrics: ["width": width],
																														 views: ["headerView": headerView]))
		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
																																	options: [],
																																	metrics: nil,
																																	views: ["view": scrollView]))
		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[headerView(48)]-0-[view(250)]-0@750-|",
																																	options: [],
																																	metrics: nil,
																																	views: ["view": scrollView,
																																					"headerView": headerView]))

		let sendViewNib = UINib(nibName: "SendView", bundle: nil)
		let sendViewObjects = sendViewNib.instantiate(withOwner: nil, options: nil)
		sendView = sendViewObjects.first as? SendView
		guard let sendView = sendView else { return }
		sendView.translatesAutoresizingMaskIntoConstraints = false

		sendView.pasteButton.rx.tap
			.subscribe(onNext: { [weak self] (_) in
				self?.pasteAddress()
		}).disposed(by: disposeBag)

		sendView.sendAddressPasteButton.rx.tap
			.subscribe(onNext: { [weak self] (_) in
				self?.pasteAddress()
		}).disposed(by: disposeBag)

		sendView.coinButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.showPicker()
		}).disposed(by: disposeBag)

		self.sendView.addressTextField.keyboardDelegate = self
		self.sendView.amountTextField.keyboardDelegate = self
		scrollView.addSubview(sendView)

		let delegateViewNib = UINib(nibName: "DelegateView", bundle: nil)
		let delegateViewObjects = delegateViewNib.instantiate(withOwner: nil, options: nil)
		delegateView = delegateViewObjects.first as? DelegateView
		guard let delegateView = delegateView else { return }
		delegateView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(delegateView)

		let convertViewNib = UINib(nibName: "ConvertView", bundle: nil)
		let convertViewObjects = convertViewNib.instantiate(withOwner: nil, options: nil)
		convertView = convertViewObjects.first as? ConvertView
		guard let convertView = convertView else { return }
		convertView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(convertView)

		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[sendView(width)]-0-[delegateView(width)]-0-[convertView(width)]-0-|",
																														 options: [],
																														 metrics: ["width": width],
																														 views: ["balanceView": balanceView,
																																		 "sendView": sendView,
																																		 "delegateView": delegateView,
																																		 "convertView": convertView]))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[sendView(150)]-0-|",
																														 options: [],
																														 metrics: nil,
																														 views: ["sendView": sendView]))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[delegateView(150)]-0-|",
																														 options: [],
																														 metrics: nil,
																														 views: ["delegateView": delegateView]))
		scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[convertView(150)]-0-|",
																														 options: [],
																														 metrics: nil,
																														 views: ["convertView": convertView]))
	}

	override func viewWillLayoutSubviews() {
		self.setAppearance()

		setGlobeButton()

		super.viewWillLayoutSubviews()
	}

	var nextKeyboardButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))

	func setGlobeButton() {
		if self.needsInputModeSwitchKey && nextKeyboardButton.superview == nil {
			nextKeyboardButton.setImage(UIImage(named: "globe-icon"), for: .normal)
			if isDarkAppearance() {
				nextKeyboardButton.tintColor = .white
			} else {
				nextKeyboardButton.tintColor = UIColor(red: 0.31, green: 0.33, blue: 0.36, alpha: 1)
			}
			self.nextKeyboardButton.sizeToFit()
			self.nextKeyboardButton.translatesAutoresizingMaskIntoConstraints = false
			
			self.nextKeyboardButton.addTarget(self, action: #selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)

			self.view.addSubview(self.nextKeyboardButton)

			let nextKeyboardButtonLeftSideConstraint = NSLayoutConstraint(item: self.nextKeyboardButton,
																																		attribute: .left,
																																		relatedBy: .equal,
																																		toItem: self.view,
																																		attribute: .left,
																																		multiplier: 1.0,
																																		constant: 16.0)
			let nextKeyboardButtonBottomConstraint = NSLayoutConstraint(item: self.nextKeyboardButton,
																																	attribute: .bottom,
																																	relatedBy: .equal,
																																	toItem: self.view,
																																	attribute: .bottom,
																																	multiplier: 1.0,
																																	constant: -16.0)
			self.view.addConstraints([nextKeyboardButtonLeftSideConstraint, nextKeyboardButtonBottomConstraint])
		} else {
			nextKeyboardButton.removeFromSuperview()
		}
		
	}

	override func textWillChange(_ textInput: UITextInput?) {
		// The app is about to change the document's contents. Perform any preparation here.
	}

	override func textDidChange(_ textInput: UITextInput?) {}

	override func selectionWillChange(_ textInput: UITextInput?) {
		super.selectionWillChange(textInput)
	}

	// MARK: -

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
//		print(sender.location(in: self.view))
		sendView.sendAddressPasteButton.alpha = 0.0
	}

	@objc func pasteSendAddress() {
		if let str = UIPasteboard.general.string {
			self.sendView?.addressTextField?.text = str
		}
	}

	deinit {
		
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
		self.view.endEditing(true)
	}

	func pasteAddress() {
		let pasteString = (UIPasteboard.general.string ?? "").regex(pattern: String.addressRegexp).first

		sendView.addressTextField.text = pasteString
		let endPosition = sendView.addressTextField.endOfDocument
		sendView.addressTextField.selectedTextRange = sendView.addressTextField.textRange(from: endPosition,
																																											to: endPosition)
		sendView.addressTextField.sendActions(for: [.editingChanged])
		sendView.sendAddressPasteButton.alpha = 0.0
	}

}

extension KeyboardViewController {

	func setNeedsChangeHeight(expand: Bool = true) {
		self.heightConstraint?.constant = expand ? 470.0 : 316.0
	}

	enum KeyboardType {
		case numeric
		case hex
	}

	func showKeyboard(type: KeyboardType) {

		guard selectedTextField != nil else { return }

		var topPadding = CGFloat(5)
		var keyboard: UIView!
		switch type {
		case .hex:
			setNeedsChangeHeight(expand: false)
			keyboard = hexKeyboardView()
			break
		case .numeric:
			setNeedsChangeHeight(expand: true)
			keyboard = numericKeyboardView()
			topPadding = 20
			break
		}
		additionalKeyboardView = keyboard

		keyboard.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(keyboard)
		keyboard.frame = CGRect(x: 0,
															 y: self.view.bounds.height,
															 width: keyboard.bounds.width,
															 height: keyboard.bounds.height)

		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[keyboard]-0-|",
																														options: [],
																														metrics: nil,
																														views: ["keyboard": keyboard]))
		self.view?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[selectedTextField]-(topPadding)-[keyboard(>=keyboardHeight)]-(0@750)-|",
																														options: [],
																														metrics: ["keyboardHeight": keyboard.bounds.height, 			"topPadding": topPadding],
																														views: ["keyboard": keyboard,
																																		"selectedTextField": selectedTextField]))

		self.view.layoutIfNeeded()
	}

	func hideKeyboard() {
		setNeedsChangeHeight(expand: false)
		self.additionalKeyboardView?.removeFromSuperview()
		self.additionalKeyboardView = nil
		self.view.layoutIfNeeded()
	}

	func hexKeyboardView() -> UIView {
		let height = Double(90.0)

		let keyboard = HexKeyboard(in: self)
		let rows = buttonRows(for: keyboard.actions, distribution: .fillProportionally)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)
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
		okButton.rx.tap.subscribe(onNext: { (_) in
			self.hideKeyboard()
			self.selectedTextField = nil
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

		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[keyboard(90)]-7-[okButton(46)]",
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

	func numericKeyboardView() -> UIView {
		let height = Double(230.0)

		let keyboard = NumericKeyboard(in: self)
		let rows = buttonRows(for: keyboard.actions, distribution: .fillEqually)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)
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
		okButton.rx.tap.subscribe(onNext: { (_) in
			self.hideKeyboard()
			self.selectedTextField = nil
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

	func shareKeyboardView() -> UIView {
		let height = Double(150)

		let keyboard = ShareKeyboard(in: self)
		let rows = buttonRows(for: keyboard.actions, distribution: .equalCentering)
		let keyboardView = UIStackView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardView.backgroundColor = UIColor(red: 0.91, green: 0.91, blue: 0.93, alpha: 1.0)
		keyboardView.axis = .vertical
		keyboardView.alignment = .center
		keyboardView.distribution = .equalSpacing
		keyboardView.translatesAutoresizingMaskIntoConstraints = false
		keyboardView.addArrangedSubviews(rows)

		let keyboardViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: Double(width), height: height))
		keyboardViewWrapper.translatesAutoresizingMaskIntoConstraints = false
		keyboardViewWrapper.addSubview(keyboardView)
		keyboardViewWrapper.backgroundColor = self.backgroundColor

		keyboardViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[keyboard(150)]",
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
		let view = DemoButton.fromNib(owner: self)
		view.setup(with: action, in: self, distribution: distribution)
		return view
	}

	func buttonRow(for actions: KeyboardActionRow, distribution: UIStackView.Distribution) -> KeyboardButtonRow {
		return KeyboardButtonRow(height: 42, actions: actions, distribution: distribution) {
			return button(for: $0, distribution: distribution)
		}
	}

	func buttonRows(for actions: KeyboardActionRows, distribution: UIStackView.Distribution) -> [KeyboardButtonRow] {
		var rows = actions.map { buttonRow(for: $0, distribution: distribution) }
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
		self.sentView.backgroundColor = self.backgroundColor
		self.view.addSubview(self.sentView)
		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|",
																														options: [],
																														metrics: nil,
																														views: ["view": sentView]))

		self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[header]-0-[view]-0-|",
																														options: [],
																														metrics: nil,
																														views: ["view": sentView,
																																		"header": self.headerView]))
	}

	func hideSentView() {
		self.sentView.removeFromSuperview()
	}

}

extension KeyboardViewController: UIGestureRecognizerDelegate, PickerViewDelegate, PickerViewDataSource {

	func showPicker() {
		view.addSubview(pickerView)
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["picker": pickerView]))
		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[picker]-0-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["picker": pickerView]))
	}

	func hidePicker() {
		self.pickerView.removeFromSuperview()
	}

	func coinPickerView() -> UIView {
		let pickerViewWrapper = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 250))
		pickerViewWrapper.backgroundColor = self.backgroundColor
		pickerViewWrapper.translatesAutoresizingMaskIntoConstraints = false

		let examplePicker = PickerView()
		examplePicker.backgroundColor = self.backgroundColor
		examplePicker.translatesAutoresizingMaskIntoConstraints = false
		examplePicker.delegate = self
		examplePicker.dataSource = self

		pickerViewWrapper.addSubview(examplePicker)
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[picker]-0-|",
																											 options: [],
																											 metrics: nil,
																											 views: ["picker": examplePicker]))
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[picker(250)]-0-|",
																											 options: [],
																											 metrics: nil,
																											 views: ["picker": examplePicker]))
		
		let okButton = UIButton(frame: CGRect(x: 10, y: 0, width: (width - 10 - 10), height: 46))
		okButton.translatesAutoresizingMaskIntoConstraints = false
		okButton.setBackgroundImage(UIImage(named: "action-button"), for: .normal)
		okButton.setTitle("OK", for: .normal)
		okButton.setTitleColor(UIColor.white, for: .normal)
		okButton.rx.tap.subscribe(onNext: { (_) in
			self.hidePicker()
		}).disposed(by: disposeBag)

		pickerViewWrapper.addSubview(okButton)
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[okButton]-10-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["okButton": okButton]))
		pickerViewWrapper.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[okButton(46)]-0-|",
																																		options: [],
																																		metrics: nil,
																																		views: ["okButton": okButton]))

		return pickerViewWrapper
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
		headerView.setAppearance(isDark: isDarkAppearance())
		sendView?.setAppearance(isDark: isDarkAppearance())
		sentView?.setAppearance(isDark: isDarkAppearance())
	}

	func isDarkAppearance() -> Bool {
		return self.textDocumentProxy.keyboardAppearance == .dark
	}

}
