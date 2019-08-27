//
//  CopyView.swift
//  MinterKeyboard
//
//  Created by Freeeon on 17/08/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import SVProgressHUD

class CopyView: UIView {
	
	// MARK: - Properites.
	
	var textToCopy: String?
	
	// MARK: - Computed properties.
	
	override var canBecomeFirstResponder: Bool {
		return true
	}
	
	// MARK: - Initialization.
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		sharedInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		sharedInit()
	}
	
	func sharedInit () {
		let tap = UITapGestureRecognizer(target: self, action: #selector(tapOnView))
		self.addGestureRecognizer(tap)
	}
	
	// MARK: - Configuration.
	
	func configure (text: String) {
		textToCopy = text
	}
	
	// MARK: - User Interaction.
	
	@objc
	func tapOnView (sender: UITapGestureRecognizer) {
		guard
			let senderView = sender.view,
			let superView = sender.view?.superview
			else { return }
		
		senderView.becomeFirstResponder()
		let saveMenuItem = UIMenuItem(title: "Copy", action: #selector(tapOnCopy))
		let menu = UIMenuController.shared
		
		menu.menuItems = [saveMenuItem]
		
		// Tell the menu controller the first responder's frame and its super view
		menu.setTargetRect(senderView.frame, in: superView)
		
		// Animate the menu onto view
		menu.setMenuVisible(true, animated: true)
	}
	
	@objc
	func tapOnCopy () {
		guard let textToCopy = textToCopy else { return }
		UIPasteboard.general.string = textToCopy
		SVProgressHUD.showSuccess(withStatus: "COPIED")
	}
}
