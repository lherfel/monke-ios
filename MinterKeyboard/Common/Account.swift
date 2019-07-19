//
//  Account.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 23/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import MinterCore

class Account: Codable {

	enum CodingKeys: String, CodingKey {
		case address
		case mnemonics
		case privateKey
		case isTurnedOn
	}

	var address: String
	var mnemonics: String
	var privateKey: String
	var isTurnedOn: Bool = false

	class func privateKey(from mnemonics: String, at: UInt32) -> PrivateKey {
		let seed = RawTransactionSigner.seed(from: mnemonics) ?? ""
		let privateKey = PrivateKey(seed: Data(hex: seed))

		let newPk = privateKey.derive(at: 44, hardened: true)
			.derive(at: 60, hardened: true)
			.derive(at: 0, hardened: true)
			.derive(at: 0)
			.derive(at: UInt32(at))
		return newPk
	}

	init(address: String, mnemonics: String, privateKey: String, isTurnedOn: Bool) {
		self.address = address
		self.mnemonics = mnemonics
		self.privateKey = privateKey
		self.isTurnedOn = isTurnedOn
	}

	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		address = try values.decode(String.self, forKey: .address)
		mnemonics = try values.decode(String.self, forKey: .mnemonics)
		privateKey = try values.decode(String.self, forKey: .privateKey)
		isTurnedOn = try values.decode(Bool.self, forKey: .isTurnedOn)
	}

}

extension Account {

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(address, forKey: .address)
		try container.encode(mnemonics, forKey: .mnemonics)
		try container.encode(privateKey, forKey: .privateKey)
		try container.encode(isTurnedOn, forKey: .isTurnedOn)
	}

}
