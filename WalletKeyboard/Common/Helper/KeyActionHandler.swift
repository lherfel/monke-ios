//
//  KeyHandler.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 20/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import Foundation
import KeyboardKit

open class SelectedTextfieldKeyboardActionHandler: NSObject, KeyboardActionHandler {
	public func handleRepeat(on action: KeyboardAction, view: UIView) {
		
	}

	init(textField: UITextField, inputViewController: UIInputViewController) {
		self.textField = textField
		self.inputViewController = inputViewController
	}

	weak var textField: UITextField?

	var inputViewController: UIInputViewController?

	public var textDocumentProxy: UITextDocumentProxy? {
		return inputViewController?.textDocumentProxy
	}

	public func handleTap(on action: KeyboardAction, view: UIView) {
		guard let action = inputViewControllerAction(for: action) ?? textDocumentProxyAction(for: action) else {
			return
		}
		action()
		textField?.sendActions(for: .editingChanged)
	}

	public func handleLongPress(on action: KeyboardAction, view: UIView) {}

	func inputViewControllerAction(for action: KeyboardAction) -> (() -> ())? {
		guard let inputAction = action.standardInputViewControllerAction else { return nil }
		return { inputAction(self.inputViewController) }
	}

	func textDocumentProxyAction(for action: KeyboardAction) -> (() -> ())? {
		guard let proxyAction = standardTextFieldAction(action: action) else { return nil }

		if let keyboardVC = inputViewController as? KeyboardViewController {
			self.textField = keyboardVC.selectedTextField
		}
		return { proxyAction(self.textField) }
	}

	func standardTextFieldAction(action: KeyboardAction) -> ((UITextField?) -> ())? {
		switch action {
		case .none: return nil
		case .backspace: return {
			proxy in proxy?.deleteBackward()
			
			}
		case .capsLock: return nil
		case .character(let char): return {
			proxy in proxy?.insertText(char); print(proxy ?? "")
			
			}
		case .command: return nil
		case .custom: return nil
		case .dismissKeyboard: return nil
		case .escape: return nil
		case .function: return nil
		case .image: return nil
		case .moveCursorBackward: return { proxy in proxy?.adjustTextPosition(byCharacterOffset: -1) }
		case .moveCursorForward: return { proxy in proxy?.adjustTextPosition(byCharacterOffset: -1) }
		case .newLine: return { proxy in proxy?.insertText("\n") }
		case .option: return nil
		case .shift: return nil
		case .shiftDown: return nil
		case .space: return { proxy in proxy?.insertText(" ") }
		case .switchKeyboard: return nil
		case .switchToKeyboard: return nil
		case .tab: return { proxy in proxy?.insertText("\t") }
		}
	}

}
