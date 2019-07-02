//
//  SendView.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 15/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

protocol SendViewDelegate: class {
	func didTapPasteButton(_ field: UITextField?)
	func didTapMaxButton(_ field: UITextField?)
	func didTapSendButton()
}

class SendView: UIView {

	weak var delegate: SendViewDelegate?

	@IBOutlet weak var feeLabel: UILabel!
	@IBOutlet weak var sendAddressPasteButton: UIButton!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var coinAvailableLabel: UILabel!
	@IBOutlet weak var addressTextField: FakeTextFieldView! {
		didSet {
			self.addressTextField?.placeholder = "Address"
			self.addressTextField?.font = UIFont.defaultFont(of: 16.0)
		}
	}
	@IBOutlet weak var amountTextField: FakeTextFieldView! {
		didSet {
			self.amountTextField?.placeholder = "Amount"
			self.amountTextField?.font = UIFont.defaultFont(of: 16.0)
		}
	}
	@IBOutlet weak var addressImageView: UIImageView!
	@IBOutlet weak var maxButton: UIButton!
	@IBOutlet weak var coinButton: UIButton!
	@IBOutlet weak var pasteButton: UIButton!
	@IBOutlet weak var coinLogo: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	// MARK: -

	@IBAction func didTapPasteButton(_ sender: Any) {
		delegate?.didTapPasteButton(addressTextField)
	}

	@IBAction func didTapMaxButton(_ sender: Any) {
		delegate?.didTapMaxButton(amountTextField)
	}

	@IBAction func didTapSendButton(_ sender: Any) {
		delegate?.didTapSendButton()
	}

	func setAppearance(isDark: Bool = false) {
		if isDark {
			addressTextField?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			addressTextField?.superview?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			addressTextField?.textColor = .white
			addressTextField?.placeHolderColor = UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1)

			coinButton?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			coinButton?.setTitleColor(.white, for: .normal)

			pasteButton?.tintColor = .white

			amountTextField?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			amountTextField?.superview?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
			amountTextField?.superview?.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).cgColor
			amountTextField?.superview?.layer.borderWidth = 3.0
			amountTextField?.placeHolderColor = UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1)

			amountTextField?.textColor = .white

			maxButton?.setTitleColor(.white, for: .normal)
			coinAvailableLabel?.textColor = .white
			feeLabel?.textColor = .white
		} else {
			addressTextField?.backgroundColor = .white
			addressTextField?.superview?.backgroundColor = .white
			addressTextField?.textColor = .black
			addressTextField?.placeHolderColor = UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1)

			coinButton?.backgroundColor = .white
			coinButton?.setTitleColor(.black, for: .normal)

			pasteButton?.tintColor = UIColor(red: 0.32, green: 0.14, blue: 0.77, alpha: 1)

			amountTextField?.backgroundColor = .white
			amountTextField?.superview?.backgroundColor = .white
			amountTextField?.placeHolderColor = UIColor(red: 0.67, green: 0.71, blue: 0.75, alpha: 1)
			amountTextField?.layer.borderColor = UIColor.clear.cgColor
			amountTextField?.layer.borderWidth = 0.0
			amountTextField?.textColor = .black

			maxButton?.setTitleColor(UIColor(red: 0.32, green: 0.14, blue: 0.77, alpha: 1), for: .normal)
			coinAvailableLabel?.textColor = .black
			feeLabel?.textColor = .black
		}
	}

}
