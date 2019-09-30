//
//  ChangeWalletViewController.swift
//  MinterKeyboard
//
//  Created by Freeeon on 04/09/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import GoldenKeystore
import SVProgressHUD

class ChangeWalletViewController: UIViewController {
	
	// MARK: - Properties.
	
	private var height: CGFloat = 0
	
	// MARK: - Outlets.
	
	@IBOutlet weak var mnemonicsTextView: UITextView!
	@IBOutlet weak var doneButton: UIButton!
	
	// MARK: - Lifecycle.
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(willChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
		
		if UIScreen.main.bounds.height <= 568 {
			mnemonicsTextView.font = mnemonicsTextView.font?.withSize(16)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		height = view.frame.origin.y
	}
	
	//MARK: - IBActions
	
	@IBAction func buttonDidTap(_ sender: Any) {
		guard let mnemonics = mnemonicsTextView.text,
			GoldenKeystore.mnemonicIsValid(mnemonics) else {
			SVProgressHUD.showError(withStatus: "Invalid phrase")
			return
		}
		
		AccountManager.shared.changeAccount(mnemonics: mnemonics)

		SVProgressHUD.showSuccess(withStatus: "Wallet changed!")
		self.dismiss(animated: true)
	}
	
	// MARK: - Resizing when the keyboard is visible.
	
	@objc
	private func willChangeFrame(_ notification: Notification) {
		let rectValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
		guard let frame = rectValue?.cgRectValue else { return }
	
		view.frame.origin.y = height - frame.height
	}
	
	@objc
	private func willHide(_ notification: Notification) {
		view.frame.origin.y = height
	}
}

