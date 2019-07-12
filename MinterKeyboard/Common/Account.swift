//
//  Account.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 23/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import MinterCore

class Account {

	enum type {
		case minter
	}

	var type: type = .minter

	//TODO: change to addresses: [Address]
	var address: String

	var mnemonics: String

	var isTurnedOn: Bool = false

	func privateKey(at: UInt32) -> PrivateKey {
		let seed = RawTransactionSigner.seed(from: self.mnemonics) ?? ""
		let privateKey = PrivateKey(seed: Data(hex: seed) ?? Data())

		let newPk = privateKey.derive(at: 44, hardened: true)
			.derive(at: 60, hardened: true)
			.derive(at: 0, hardened: true)
			.derive(at: 0)
			.derive(at: UInt32(at))
		return newPk
	}

	init(address: String, mnemonics: String, isTurnedOn: Bool) {
		self.address = address
		self.mnemonics = mnemonics
		self.isTurnedOn = isTurnedOn
	}
}
