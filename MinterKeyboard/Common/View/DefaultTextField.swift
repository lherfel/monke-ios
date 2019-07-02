//
//  DefaultTextField.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 16/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

class DefaultTextField: UITextField {

	// MARK: -

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.layer.cornerRadius = 8.0
	}

	// MARK: -
	
//	override func textRect(forBounds bounds: CGRect) -> CGRect {
//		return CGRect(x: 10, y: 0, width: bounds.width - 20, height: 20)
//	}
//
//	override func editingRect(forBounds bounds: CGRect) -> CGRect {
//		return CGRect(x: 10, y: 0, width: bounds.width - 20, height: 20)
//	}
//
//	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//		return CGRect(x: 10, y: 0, width: bounds.width - 20, height: 20)
//	}

}
