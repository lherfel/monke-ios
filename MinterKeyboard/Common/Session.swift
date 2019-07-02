//
//  Session.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 15/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import MinterCore
import MinterExplorer
import KeychainSwift

class Session {

	enum SessionError: Error {
		case cantCreateSession
	}

	private let disposeBag = DisposeBag()

	// MARK: -

	static let shared = Session()

	var account: Account {
		didSet {
			accountSubject.onNext(account)
		}
	}

	private init() {
		self.account = try! AccountManager.shared.restoreAccount()
		
		accountSubject.subscribe(onNext: { (account) in
			
		}).disposed(by: disposeBag)
	}

	// MARK: -

	var accountSubject = ReplaySubject<Account>.create(bufferSize: 1)
	var balanceSubject = ReplaySubject<[String: Decimal]>.create(bufferSize: 1)
	var delegationsSubject = ReplaySubject<Decimal>.create(bufferSize: 1)

	// MARK: -

	private let defaultHttp = APIClient()
	lazy private var addressManager = ExplorerAddressManager(httpClient: defaultHttp)

	func updateBalance() {
		addressManager.address(address: "Mx" + self.account.address) { [weak self] (res, error) in
			if let balances = res?["balances"] as? [[String: String]] {
				var ret: [String: Decimal] = [:]
				balances.forEach({ (balance) in
					if let key = balance["coin"] as? String {
						ret[key] = Decimal(string: balance["amount"] ?? "") ?? 0.0
					}
				})
				self?.balanceSubject.onNext(ret)
			}
		}

		addressManager.delegations(address: "Mx" + self.account.address) { [weak self] (delegations, total, error) in
			if let total = total {
				self?.delegationsSubject.onNext(total)
			}
		}
	}

}
