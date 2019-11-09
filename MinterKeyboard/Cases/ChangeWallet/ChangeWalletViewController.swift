//
//  ChangeWalletViewController.swift
//  MinterKeyboard
//
//  Created by Freeeon on 04/09/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChangeWalletViewController: BaseViewController, ControllerProtocol {

	// MARK: -

	typealias ViewModelType = ChangeWalletViewModel

	var viewModel: ChangeWalletViewModel! = ChangeWalletViewModel()

	func configure(with viewModel: ChangeWalletViewController.ViewModelType) {
		mnemonicsTextView.rx.text
			.asDriver(onErrorJustReturn: nil)
			.drive(viewModel.input.mnemonics)
			.disposed(by: disposeBag)
		doneButton.rx.tap.asDriver(onErrorJustReturn: ())
			.drive(viewModel.input.didTapDoneButton)
			.disposed(by: disposeBag)

		viewModel.output.errorNotification
			.asDriver(onErrorJustReturn: nil)
			.drive(onNext: { (message) in
				SVProgressHUD.showError(withStatus: message)
		}).disposed(by: disposeBag)

		viewModel.output.shouldDismiss
			.asDriver(onErrorJustReturn: ())
			.drive(onNext: { [weak self] (_) in
				self?.dismiss(animated: true, completion: nil)
		}).disposed(by: disposeBag)
	}

	// MARK: - Properties.

	private var height: CGFloat = 0

	// MARK: - Outlets.

	@IBOutlet weak var mnemonicsTextView: UITextView!
	@IBOutlet weak var doneButton: UIButton!

	// MARK: - Lifecycle.

	override func viewDidLoad() {
		super.viewDidLoad()

		configure(with: viewModel)

		NotificationCenter.default.addObserver(self, selector: #selector(willChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)

		if UIScreen.main.bounds.height <= 568 {
			mnemonicsTextView.font = mnemonicsTextView.font?.withSize(16)
		}

		DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
			self.mnemonicsTextView.isEditable = true
			self.mnemonicsTextView.becomeFirstResponder()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		height = view.frame.origin.y
	}

	// MARK: - Resizing when the keyboard is visible.

	@objc
	private func willChangeFrame(_ notification: Notification) {
		let rectValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
		guard let frame = rectValue?.cgRectValue else { return }
		let frameY = height - frame.height
		print("Height: ", view.frame.origin.y)
		view.frame.origin.y = frameY > 0 ? frameY : 1
	}

	@objc
	private func willHide(_ notification: Notification) {
		view.frame.origin.y = height
	}
}
