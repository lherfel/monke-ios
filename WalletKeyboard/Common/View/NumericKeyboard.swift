//
//  NumericKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 20/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import KeyboardKit

struct NumericKeyboard {

	init(in viewController: KeyboardViewController) {
		actions = type(of: self).actions(in: viewController)
	}
	
	let actions: KeyboardActionRows
}

private extension NumericKeyboard {

	static var characters: [[String]] = [
		["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], [",", "0"]
	]

	static func actions(in viewController: KeyboardViewController) -> KeyboardActionRows {
		return characters
			.mappedToActions()
			.addingSideActions()
	}
}

private extension Sequence where Iterator.Element == KeyboardActionRow {
	
	func addingSideActions() -> [Iterator.Element] {
		var actions = map { $0 }
		actions[3].append(.backspace)
		return actions
	}
}
