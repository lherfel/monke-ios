//
//  SentView.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 22/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

class SentView: UIView {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet var phraseButtons: [UIButton]!
	@IBOutlet weak var transactionLinkButton: UIButton!
	@IBOutlet weak var closeButton: UIButton!

	func setAppearance(isDark: Bool) {
		if isDark {
			self.backgroundColor = UIColor.defaultBackgroundDark
			titleLabel.textColor = .white
			phraseButtons.forEach { (button) in
				button.setBackgroundImage(UIImage(named: "keyboard-button-dark")!,
																	for: .normal)
				button.setTitleColor(UIColor.white, for: .normal)
			}
			transactionLinkButton.setBackgroundImage(UIImage(named: "keyboard-button-dark")!,
																							 for: .normal)
			transactionLinkButton.setTitleColor(.white, for: .normal)
			closeButton.setTitleColor(.white, for: .normal)
		} else {
			self.backgroundColor = UIColor.defaultBackground
			titleLabel.textColor = .black
			phraseButtons.forEach { (button) in
				button.setBackgroundImage(UIImage(named: "keyboard-button")!,
																	for: .normal)
				button.setTitleColor(UIColor.black, for: .normal)
			}
			transactionLinkButton.setBackgroundImage(UIImage(named: "keyboard-button")!,
																							 for: .normal)
			transactionLinkButton.setTitleColor(.black, for: .normal)
		}
	}

}
