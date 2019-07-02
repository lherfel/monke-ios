//
//  FakeTextField.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 17/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

private let textInset = CGPoint(x: 31, y: 0)

class CursorView: UIView {
	override init(frame: CGRect) {
		super.init(frame: frame)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func animate() {
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.fromValue = 1
		animation.toValue = 0
		animation.duration = 0.5
//		animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
		animation.autoreverses = true
		animation.repeatCount = Float.infinity
		self.layer.add(animation, forKey: "opacity")
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()

		if self.window != nil {
			self.backgroundColor = self.tintColor
			self.animate()
		}
	}
}

protocol FakeTextFieldViewDelegate: class {
	func didTap(textField: FakeTextFieldView)
}

class FakeTextFieldView: UITextField {

	@IBInspectable var placeHolderColor: UIColor? {
		get {
			return self.placeHolderColor
		}
		set {
			self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
		}
	}

	private var _placeholder: String?
	var isTyping = false {
		didSet {
			if isTyping {
				_placeholder = self.placeholder
				placeholder = ""
			} else {
				placeholder = _placeholder
			}
			cursorView.isHidden = !isTyping
		}
	}

	weak var keyboardDelegate: FakeTextFieldViewDelegate?

	private var cursorView: CursorView!

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.delegate = self
		self.cursorView = CursorView()
		self.cursorView.isHidden = true
		self.addSubview(self.cursorView)
	}

	private var keyboardCapturing: Bool = false {
		didSet {
			guard oldValue != self.keyboardCapturing else { return }

			if self.keyboardCapturing {
//				KeyboardTextDocumentCoordinator.sharedInstance.addObserver(self)
			} else {
//				KeyboardTextDocumentCoordinator.sharedInstance.removeObserver(self)
			}
		}
	}

	private func updateKeyboardCapturing() {
		self.keyboardCapturing = self.window != nil && !self.isHidden
	}

	override var isHidden: Bool {
		didSet {
			self.updateKeyboardCapturing()
		}
	}

	override func didMoveToWindow() {
		super.didMoveToWindow()
		self.updateKeyboardCapturing()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.delegate = self
		self.cursorView = CursorView()
		self.cursorView.isHidden = true
		self.addSubview(self.cursorView)
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		let font = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
		let textFittingSize = (text ?? "").size(withAttributes:[.font: font])//font.stringSize( (self.text != nil) ? (self.text! as NSString) : "")
		let textFrame = self.textRect(forBounds: self.bounds)
		let textFittingFrame = CGRect(origin: textFrame.origin, size: textFittingSize)
		var cursorFrame = CGRect(x: textFittingFrame.maxX, y: textFittingFrame.minY, width: 2.0, height: textFittingFrame.height)

		switch self.contentVerticalAlignment {
		case .center:
			let centeredCursorFrame = cursorFrame.offsetBy(dx: 0, dy: (textFrame.height - cursorFrame.height) / 2.0)
			cursorFrame = centeredCursorFrame
		case .bottom:
			let bottomCursorFrame = cursorFrame.offsetBy(dx: 0, dy: (textFrame.height - cursorFrame.height))
			cursorFrame = bottomCursorFrame
		default: break
		}
		
		self.cursorView.frame = cursorFrame
	}

	override func textRect(forBounds bounds: CGRect) -> CGRect {
		var rect = super.textRect(forBounds: bounds).insetBy(dx: 10, dy: 0)

		let font = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
		let textFittingSize = (text ?? "").size(withAttributes:[.font: font])//font.stringSize((self.text != nil) ? (self.text! as NSString) : "")
		
		if rect.size.width < textFittingSize.width {
			rect.origin.x -= textFittingSize.width - rect.size.width
			rect.size.width = textFittingSize.width
		}
		
		return rect
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: 10, y: 0, width: bounds.width - 10, height: bounds.height)
	}

}

extension FakeTextFieldView: UITextFieldDelegate {
	func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		isTyping = true
		keyboardDelegate?.didTap(textField: self)
		return false
	}
}

class AddressTextField: FakeTextFieldView {

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.adjustsFontSizeToFitWidth = true
		self.minimumFontSize = 9.0
	}

	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		return super.canPerformAction(action, withSender: sender)
	}

	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: textInset.x, y: bounds.minY,
									width: bounds.width - textInset.x - 10.0,
									height: bounds.height)
		
		var rect = super.textRect(forBounds: bounds).insetBy(dx: textInset.x, dy: textInset.y)

		let font = self.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
		let textFittingSize = (text ?? "").size(withAttributes:[.font: font])//font.stringSize((self.text != nil) ? (self.text! as NSString) : "")

//		if rect.size.width < textFittingSize.width {
//			rect.origin.x -= textFittingSize.width - rect.size.width
//			rect.size.width = textFittingSize.width
//		}

		return rect
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: textInset.x, y: bounds.minY,
									width: bounds.width - textInset.x,
									height: bounds.height)
	}

	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(x: 10, y: 0, width: bounds.width - 10, height: bounds.height)
	}

}
