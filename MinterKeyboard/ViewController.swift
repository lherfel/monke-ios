//
//  ViewController.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 15/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import KeychainSwift

class ViewController: UIViewController {

	@IBOutlet weak var mnemonicPhraseLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.view.subviews.forEach { (view) in
			if let textField = view as? UITextField {
				textField.becomeFirstResponder()
				textField.delegate = self
			}
			if let label = view as? UILabel {
				label.text = Session.shared.account.mnemonics
				label.numberOfLines = 0
			}
		}
	}
}

extension ViewController: UITextFieldDelegate {

	func textFieldDidEndEditing(_ textField: UITextField) {
		let keychain = KeychainSwift(keyPrefix: "MinterKeyboardWallet")
		keychain.accessGroup = "group.monke.app"
		if let mnemonics = textField.text?.lowercased() {
			if mnemonics.split(separator: " ").count == 12 && mnemonics != "" {
				keychain.set(mnemonics, forKey: "mnemonics")
			}
		}
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.endEditing(true)
		return true
	}

}
