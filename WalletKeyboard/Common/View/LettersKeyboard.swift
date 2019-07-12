//
//  LettersKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 11/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import KeyboardKit

struct AlphabeticKeyboard {

	init(
		uppercased: Bool,
		in viewController: KeyboardViewController) {
		actions = type(of: self).actions(in: viewController, uppercased: uppercased)
	}

	let actions: KeyboardActionRows
}

private extension AlphabeticKeyboard {

	static var characters: [[String]] = [
		["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
		["a", "s", "d", "f", "g", "h", "j", "k", "l"],
		["z", "x", "c", "v", "b", "n", "m"]
	]

	static func actions(
		in viewController: KeyboardViewController,
		uppercased: Bool) -> KeyboardActionRows {
		return characters(uppercased: uppercased)
			.mappedToActions()
			.addingSideActions(uppercased: uppercased)
	}
}

private extension AlphabeticKeyboard {

	static func characters(uppercased: Bool) -> [[String]] {
		return uppercased ? characters.uppercased() : characters
	}
}

private extension Sequence where Iterator.Element == KeyboardActionRow {

	func addingSideActions(uppercased: Bool) -> [Iterator.Element] {
		var result = map { $0 }
		result[2].insert(uppercased ? .shiftDown : .shift, at: 0)
		result[2].insert(.none, at: 1)
		result[2].append(.none)
		result[2].append(.backspace)
		return result
	}
}
