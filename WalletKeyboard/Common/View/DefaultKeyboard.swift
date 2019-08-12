//
//  DefaultKeyboard.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 23/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation

var counter = 0

enum ShiftState {
	case disabled
	case enabled
	case locked
	
	func uppercase() -> Bool {
		switch self {
		case .disabled:
			return false
		case .enabled:
			return true
		case .locked:
			return true
		}
	}
}

class Keyboard {
	var pages: [Page] = []
	
	func add(key: Key, row: Int, page: Int) {
		if self.pages.count <= page {
			for _ in self.pages.count...page {
				self.pages.append(Page())
			}
		}
		
		self.pages[page].add(key: key, row: row)
	}
}

class Page {
	var rows: [[Key]] = []
	
	func add(key: Key, row: Int) {
		if self.rows.count <= row {
			for _ in self.rows.count...row {
				self.rows.append([])
			}
		}
		
		self.rows[row].append(key)
	}
}

class Key: Hashable {
	enum KeyType {
		case character
		case specialCharacter
		case shift
		case backspace
		case modeChange
		case keyboardChange
		case period
		case space
		case `return`
		case settings
		case other
	}
	
	var type: KeyType
	var uppercaseKeyCap: String?
	var lowercaseKeyCap: String?
	var uppercaseOutput: String?
	var lowercaseOutput: String?
	var toMode: Int? //if the key is a mode button, this indicates which page it links to
	
	var isCharacter: Bool {
		get {
			switch self.type {
			case
			.character,
			.specialCharacter,
			.period:
				return true
			default:
				return false
			}
		}
	}
	
	var isSpecial: Bool {
		get {
			switch self.type {
			case .shift:
				return true
			case .backspace:
				return true
			case .modeChange:
				return true
			case .keyboardChange:
				return true
			case .return:
				return true
			case .settings:
				return true
			default:
				return false
			}
		}
	}
	
	var hasOutput: Bool {
		get {
			return (self.uppercaseOutput != nil) || (self.lowercaseOutput != nil)
		}
	}
	
	// TODO: this is kind of a hack
	var hashValue: Int
	
	init(_ type: KeyType) {
		self.type = type
		self.hashValue = counter
		counter += 1
	}
	
	convenience init(_ key: Key) {
		self.init(key.type)
		
		self.uppercaseKeyCap = key.uppercaseKeyCap
		self.lowercaseKeyCap = key.lowercaseKeyCap
		self.uppercaseOutput = key.uppercaseOutput
		self.lowercaseOutput = key.lowercaseOutput
		self.toMode = key.toMode
	}
	
	func setLetter(_ letter: String) {
		self.lowercaseOutput = letter.lowercased()
		self.uppercaseOutput = letter.uppercased()
		self.lowercaseKeyCap = self.lowercaseOutput
		self.uppercaseKeyCap = self.uppercaseOutput
	}
	
	func outputForCase(_ uppercase: Bool) -> String {
		if uppercase {
			return uppercaseOutput ?? lowercaseOutput ?? ""
		}
		else {
			return lowercaseOutput ?? uppercaseOutput ?? ""
		}
	}
	
	func keyCapForCase(_ uppercase: Bool) -> String {
		if uppercase {
			return uppercaseKeyCap ?? lowercaseKeyCap ?? ""
		}
		else {
			return lowercaseKeyCap ?? uppercaseKeyCap ?? ""
		}
	}
}

func ==(lhs: Key, rhs: Key) -> Bool {
	return lhs.hashValue == rhs.hashValue
}

func defaultKeyboard() -> Keyboard {
	let defaultKeyboard = Keyboard()
	
	for key in ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"] {
		let keyModel = Key(.character)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 0, page: 0)
	}
	
	for key in ["A", "S", "D", "F", "G", "H", "J", "K", "L"] {
		let keyModel = Key(.character)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 1, page: 0)
	}
	
	let keyModel = Key(.shift)
	defaultKeyboard.add(key: keyModel, row: 2, page: 0)
	
	for key in ["Z", "X", "C", "V", "B", "N", "M"] {
		let keyModel = Key(.character)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 2, page: 0)
	}
	
	let backspace = Key(.backspace)
	defaultKeyboard.add(key: backspace, row: 2, page: 0)
	
	let keyModeChangeNumbers = Key(.modeChange)
	keyModeChangeNumbers.uppercaseKeyCap = "123"
	keyModeChangeNumbers.toMode = 1
	defaultKeyboard.add(key: keyModeChangeNumbers, row: 3, page: 0)
	
	let keyboardChange = Key(.keyboardChange)
	defaultKeyboard.add(key: keyboardChange, row: 3, page: 0)
	
	let settings = Key(.settings)
	defaultKeyboard.add(key: settings, row: 3, page: 0)
	
	let space = Key(.space)
	space.uppercaseKeyCap = "space"
	space.uppercaseOutput = " "
	space.lowercaseOutput = " "
	defaultKeyboard.add(key: space, row: 3, page: 0)
	
	let returnKey = Key(.return)
	returnKey.uppercaseKeyCap = "return"
	returnKey.uppercaseOutput = "\n"
	returnKey.lowercaseOutput = "\n"
	defaultKeyboard.add(key: returnKey, row: 3, page: 0)
	
	for key in ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"] {
		let keyModel = Key(.specialCharacter)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 0, page: 1)
	}
	
	for key in ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""] {
		let keyModel = Key(.specialCharacter)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 1, page: 1)
	}
	
	let keyModeChangeSpecialCharacters = Key(.modeChange)
	keyModeChangeSpecialCharacters.uppercaseKeyCap = "#+="
	keyModeChangeSpecialCharacters.toMode = 2
	defaultKeyboard.add(key: keyModeChangeSpecialCharacters, row: 2, page: 1)
	
	for key in [".", ",", "?", "!", "'"] {
		let keyModel = Key(.specialCharacter)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 2, page: 1)
	}
	
	defaultKeyboard.add(key: Key(backspace), row: 2, page: 1)
	
	let keyModeChangeLetters = Key(.modeChange)
	keyModeChangeLetters.uppercaseKeyCap = "ABC"
	keyModeChangeLetters.toMode = 0
	defaultKeyboard.add(key: keyModeChangeLetters, row: 3, page: 1)
	
	defaultKeyboard.add(key: Key(keyboardChange), row: 3, page: 1)
	
	defaultKeyboard.add(key: Key(settings), row: 3, page: 1)
	
	defaultKeyboard.add(key: Key(space), row: 3, page: 1)
	
	defaultKeyboard.add(key: Key(returnKey), row: 3, page: 1)
	
	for key in ["[", "]", "{", "}", "#", "%", "^", "*", "+", "="] {
		let keyModel = Key(.specialCharacter)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 0, page: 2)
	}
	
	for key in ["_", "\\", "|", "~", "<", ">", "€", "£", "¥", "•"] {
		let keyModel = Key(.specialCharacter)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 1, page: 2)
	}
	
	defaultKeyboard.add(key: Key(keyModeChangeNumbers), row: 2, page: 2)
	
	for key in [".", ",", "?", "!", "'"] {
		let keyModel = Key(.specialCharacter)
		keyModel.setLetter(key)
		defaultKeyboard.add(key: keyModel, row: 2, page: 2)
	}
	
	defaultKeyboard.add(key: Key(backspace), row: 2, page: 2)
	
	defaultKeyboard.add(key: Key(keyModeChangeLetters), row: 3, page: 2)
	
	defaultKeyboard.add(key: Key(keyboardChange), row: 3, page: 2)
	
	defaultKeyboard.add(key: Key(settings), row: 3, page: 2)
	
	defaultKeyboard.add(key: Key(space), row: 3, page: 2)
	
	defaultKeyboard.add(key: Key(returnKey), row: 3, page: 2)
	
	return defaultKeyboard
}
