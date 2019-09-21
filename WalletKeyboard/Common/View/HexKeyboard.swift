//
//  HexKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 19/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import KeyboardKit

struct HexKeyboard {
	
	init(in viewController: KeyboardViewController) {
		actions = type(of: self).actions(in: viewController)
	}
	
	let actions: KeyboardActionRows
}

private extension HexKeyboard {
	
	static var characters: [[String]] = [
		["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
		["a", "b", "c", "d", "e", "f"]
	]
	
	static func actions(in viewController: KeyboardViewController) -> KeyboardActionRows {
		return characters
			.mappedToActions()
			.addingSideActions(viewController: viewController)
//			.appending(bottomActions(leftmost: .switchToKeyboard(.alphabetic(uppercased: false)), for: viewController))
	}
}

private extension HexKeyboard {
	
	static func characters(uppercased: Bool) -> [[String]] {
		return characters
	}
}

private extension Sequence where Iterator.Element == KeyboardActionRow {
	
	func addingSideActions(viewController: KeyboardViewController) -> [Iterator.Element] {
		var actions = map { $0 }
		actions[1].insert(viewController.keyboardSwitcherAction, at: 0)
		actions[1].insert(.character("Mx"), at: 1)
		actions[1].append(.backspace)
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
