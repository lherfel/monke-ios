//
//  NumericKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 20/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import KeyboardKit

struct DecimalKeyboard {

	init(in viewController: KeyboardViewController, isDecimal: Bool) {
		actions = type(of: self).actions(isDecimal: isDecimal, in: viewController)
	}
	
	let actions: KeyboardActionRows
}

private extension DecimalKeyboard {

	static var characters: [[String]] = [
		["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["0"]
	]

	static func actions(isDecimal: Bool, in viewController: KeyboardViewController) -> KeyboardActionRows {
		return characters
			.mappedToActions()
			.addingSideActions(isDecimal: isDecimal)
	}
}

private extension Sequence where Iterator.Element == KeyboardActionRow {
	
	func addingSideActions(isDecimal: Bool) -> [Iterator.Element] {
		let additionalButton: KeyboardAction = isDecimal ? .character(",") : .none
		var actions = map { $0 }
		actions[3].insert(additionalButton, at: 0)
		actions[3].append(.backspace)
		return actions
	}
}
