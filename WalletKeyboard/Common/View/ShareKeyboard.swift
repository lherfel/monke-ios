//
//  ShareKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 22/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import UIKit
import KeyboardKit

struct ShareKeyboard {
	
	init(in viewController: KeyboardViewController) {
		actions = type(of: self).actions(in: viewController)
	}
	
	let actions: KeyboardActionRows
	
	static func bottomActions(
		leftmost: KeyboardAction,
		for viewController: KeyboardViewController) -> KeyboardActionRow {
		let actions = [leftmost]
		return actions.filter { $0 != .switchToKeyboard(.emojis) }
	}
	
}

private extension ShareKeyboard {
	
	static var characters: [[String]] = [
		["💸Sent ", "Shut up and take my money! "],
		["👍Thnx ", "No money, no honey🍯 "],
		["🔗Mt982da7320501…ad6d620110c55"]
	]
	
	static func actions(in viewController: KeyboardViewController) -> KeyboardActionRows {
		return characters
			.mappedToActions()
//			.addingSideActions()
		//			.appending(bottomActions(leftmost: .switchToKeyboard(.alphabetic(uppercased: false)), for: viewController))
	}
}

private extension ShareKeyboard {
	
	static func characters(uppercased: Bool) -> [[String]] {
		return characters
	}
}

//private extension Sequence where Iterator.Element == KeyboardActionRow {
//
//	func addingSideActions() -> [Iterator.Element] {
//		var actions = map { $0 }
//		actions[1].insert(.none, at: 0)
//		actions[1].insert(.none, at: 1)
//		actions[1].append(.backspace)
//		actions[1].append(.none)
//		actions[1].append(.none)
//		return actions
//	}
//}
