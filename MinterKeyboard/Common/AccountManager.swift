//
//  AccountManager.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 16/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import MinterCore
import KeychainSwift

protocol AccountManagerProtocol {
	func get(key: String) -> String?
	func set(key: String, value: String)
}

extension KeychainSwift: AccountManagerProtocol {
	func get(key: String) -> String? {
		return self.get(key)
	}

	func set(key: String, value: String) {
		self.set(value, forKey: key)
	}
}

enum AccountManagerError: Error {
	case cantConnectToStorage
	case cantCalculateAddress
}

class AccountManager {

	enum StorageKeys: String {
		case mnemonics
	}

	// MARK: -

	static let shared = AccountManager()

	private init() {
		let keychain = KeychainSwift(keyPrefix: "MinterKeyboardWallet")
		keychain.accessGroup = "group.monke.app"
		self.accountStorage = keychain
	}

	// MARK: -

	var accountStorage: AccountManagerProtocol

	var hasMnemonics = false

	func restoreAccount() throws -> Account {

		var mnemonics: String!
		let mnem = restoreMnemonics()
		mnemonics = mnem != nil ? mnem : generateMnemonics()
		if mnem == nil {
			//needs to be saved
			saveMnemonics(mnemonics)
		}

		guard let address = self.address(from: mnemonics, at: 0) else {
			throw AccountManagerError.cantCalculateAddress
		}

		return Account(address: address, mnemonics: mnemonics)
	}

	private func restoreMnemonics() -> String? {
		//checking if mnemonics exists
		return accountStorage.get(key: StorageKeys.mnemonics.rawValue)
	}

	private func saveMnemonics(_ mnemonics: String) {
		accountStorage.set(key: StorageKeys.mnemonics.rawValue, value: mnemonics)
	}

	private func generateMnemonics() -> String? {
		return String.generateMnemonicString()
	}

	func address(from mnemonic: String, at index: UInt32) -> String? {

		guard let seed = self.seed(mnemonic: mnemonic) else {
			return nil
		}

		let pk = PrivateKey(seed: seed)

		let newPk = pk.derive(at: 44, hardened: true)
			.derive(at: 60, hardened: true)
			.derive(at: 0, hardened: true)
			.derive(at: 0)
			.derive(at: index)

		guard
			let publicKey = RawTransactionSigner.publicKey(privateKey: newPk.raw,
																										 compressed: false)?.dropFirst(),
			let address = RawTransactionSigner.address(publicKey: publicKey) else {
				return nil
		}
		print(newPk.publicKey.toHexString())
		print(publicKey.toHexString())

		return address
	}

	//Generate Seed from mnemonic
	func seed(mnemonic: String, passphrase: String = "") -> Data? {
		return Data(hex: String.seedString(mnemonic, passphrase: passphrase)!)
	}

}
