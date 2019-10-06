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
		case account
		case mnemonics
		case privateKey
		case address
		case turnedOn
	}

	enum AccountManagerError: Error {
		case incorrectMnemonics
		case incorretPrivateKey
		case canNotEncodeAccount
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

	func restore() throws -> Account {
		var mnemonics: String!
		let mnem = restoreMnemonics()
		mnemonics = mnem != nil ? mnem : generateMnemonics()
		if mnem == nil {
			//needs to be saved
			saveMnemonics(mnemonics)
		}

		var account: Account!
		account = restoreAccount()

		if account == nil {
			account = getAccount(mnemonics)
		}

		return Account(address: account.address,
									 mnemonics: account.mnemonics,
									 privateKey: account.privateKey,
									 isTurnedOn: restoreTurnedOn())
	}

	// MARK: - Public methods
	
	func changeAccount(mnemonics: String) {
		let acc = getAccount(mnemonics)
		do {
			try saveAccount(acc!)
		} catch {
			fatalError("Can't save Account")
		}
		saveMnemonics(mnemonics)
	}

	// MARK: -

	private func restoreAccount() -> Account? {
		let restored = accountStorage.get(key: StorageKeys.account.rawValue)?
			.data(using: .utf8) ?? Data()
		return try? JSONDecoder().decode(Account.self, from: restored)
	}

	private func saveAccount(_ account: Account) throws {
		let stored = try JSONEncoder().encode(account)
		guard let encoded = String(data: stored, encoding: .utf8) else {
			throw AccountManagerError.canNotEncodeAccount
		}
		accountStorage.set(key: StorageKeys.account.rawValue, value: encoded)
	}

	// MARK: -

	private func restoreMnemonics() -> String? {
		//checking if mnemonics exists
		return accountStorage.get(key: StorageKeys.mnemonics.rawValue)
	}

	private func restorePrivateKey() -> String? {
		return accountStorage.get(key: StorageKeys.privateKey.rawValue)
	}

	private func restoreAddress() -> String? {
		return accountStorage.get(key: StorageKeys.address.rawValue)
	}

	func restoreTurnedOn() -> Bool {
		return "true" == accountStorage.get(key: StorageKeys.turnedOn.rawValue) ? true : false
	}

	func setTurnedOn(isTurnedOn: Bool) {
		accountStorage.set(key: StorageKeys.turnedOn.rawValue,
											 value: isTurnedOn ? "true" : "false")
	}

	private func saveMnemonics(_ mnemonics: String) {
		accountStorage.set(key: StorageKeys.mnemonics.rawValue, value: mnemonics)
	}

	private func savePrivateKey(_ key: String) {
		accountStorage.set(key: StorageKeys.privateKey.rawValue, value: key)
	}

	private func saveAddress(_ address: String) {
		accountStorage.set(key: StorageKeys.address.rawValue, value: address)
	}

	private func getAccount(_ mnemonics: String) -> Account? {
		do {
			let acc = try AccountManager.shared.account(from: mnemonics, at: 0)
			if nil == acc {
				fatalError("Can't get Private key or address")
			}
			return acc
		} catch {
			fatalError("Can't get Account")
		}
	}

	private func generateMnemonics() -> String? {
		return String.generateMnemonicString()
	}

	func account(from mnemonic: String, at index: UInt32) throws -> Account? {

		guard let seed = self.seed(mnemonic: mnemonic) else {
			throw AccountManagerError.incorrectMnemonics
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
				throw AccountManagerError.incorretPrivateKey
		}

		return Account(address: address,
									 mnemonics: mnemonic,
									 privateKey: newPk.raw.toHexString(),
									 isTurnedOn: false)
	}

	//Generate Seed from mnemonic
	func seed(mnemonic: String, passphrase: String = "") -> Data? {
		return Data(hex: String.seedString(mnemonic, passphrase: passphrase)!)
	}

}
