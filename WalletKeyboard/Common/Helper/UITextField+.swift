//
//  UITextField+.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 20/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

extension UITextField {

	func deleteBackwords() {
		self.text?.dropLast()
	}

	func insertText(_ char: Character) {
		self.text?.append(char)
	}

	func adjustTextPosition(byCharacterOffset: Int) {

	}
}
