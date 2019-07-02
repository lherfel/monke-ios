//
//  HexKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 19/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import UIKit
import KeyboardKit

struct HexKeyboard {
	
	init(in viewController: KeyboardViewController) {
		actions = type(of: self).actions(in: viewController)
	}
	
	let actions: KeyboardActionRows
	
	static func bottomActions(
		leftmost: KeyboardAction,
		for viewController: KeyboardViewController) -> KeyboardActionRow {
		let includeEmojiAction = false
//		let switcher = viewController.keyboardSwitcherAction
		let actions = [leftmost]
		return includeEmojiAction ? actions : actions.filter { $0 != .switchToKeyboard(.emojis) }
	}
	
}

private extension HexKeyboard {
	
	static var characters: [[String]] = [
		["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
		["Mx", "a", "b", "c", "d", "e", "f"]
	]
	
	static func actions(in viewController: KeyboardViewController) -> KeyboardActionRows {
		return characters
			.mappedToActions()
			.addingSideActions()
//			.appending(bottomActions(leftmost: .switchToKeyboard(.alphabetic(uppercased: false)), for: viewController))
	}
}

private extension HexKeyboard {
	
	static func characters(uppercased: Bool) -> [[String]] {
		return characters
	}
}

private extension Sequence where Iterator.Element == KeyboardActionRow {
	
	func addingSideActions() -> [Iterator.Element] {
		var actions = map { $0 }
		actions[1].insert(.none, at: 0)
		actions[1].insert(.none, at: 1)
		actions[1].append(.backspace)
		actions[1].append(.none)
		actions[1].append(.none)
		return actions
	}
}

// MARK: - Character Extensions
extension Sequence where Iterator.Element == [String] {
	
	func uppercased() -> [Iterator.Element] {
		return map { $0.map { $0.uppercased() } }
	}
	
	func mappedToActions() -> KeyboardActionRows {
		return map { $0.map { .character($0) } }
	}
}


// MARK: - Action Extensions
extension Sequence where Iterator.Element == KeyboardActionRow {
	
	func appending(_ actions: KeyboardActionRow) -> KeyboardActionRows {
		var result = map { $0 }
		result.append(actions)
		return result
	}
}
