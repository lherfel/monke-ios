//
//  AddWalletViewController.swift
//  MinterKeyboard
//
//  Created by Freeeon on 04/09/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

class AddWalletViewController: UIViewController {
	
	// MARK: - Properties.
	
	private var height: CGFloat = 0
	
	// MARK: - Outlets.
	
	@IBOutlet weak var phaseTextView: UITextView!
	@IBOutlet weak var doneButton: UIButton!
	
	// MARK: - Lifecycle.
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		NotificationCenter.default.addObserver(self, selector: #selector(willChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
	
		view.frame.origin.y = height - frame.height
	}
	
	@objc
	private func willHide(_ notification: Notification) {
		view.frame.origin.y = height
	}
}

