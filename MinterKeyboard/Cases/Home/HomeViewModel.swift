//
//  HomeViewModel.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import MinterCore
import RxSwift

class HomeViewModel: BaseViewModel, ViewModelProtocol {

	// MARK: -

	private var balanceSubject: BehaviorSubject<String?> = BehaviorSubject(value: "0.0000 BIP")
	private let currencyFormatter = CurrencyNumberFormatter.coinFormatter

	// MARK: -

	struct Input {
		var didTapTurnOn: AnyObserver<Void>
	}

	struct Output {
		var isTurnedOn: Observable<Bool>
		var cells: [BaseCellItem]
	}

	var input: HomeViewModel.Input!
	var output: HomeViewModel.Output!

	// MARK: -

	var didTapTurnOnSubject = PublishSubject<Void>()
	var isTurnedOnSubject = BehaviorSubject(value: AccountManager.shared.restoreTurnedOn())

	// MARK: - DataSource

	public var dataSource: [BaseCellItem] {
		return [
				BalanceTVCellItem(identifier: "deposit",
													imageName: "bip-logo",
													titleObservable: balanceSubject.asObservable()),
				MenuItemTVCellItem(identifier: "transaction",
													title: "Transactions 💸"),
				MenuItemTVCellItem(identifier: "backupPhrase",
													title: "🔑 Backup Phrase"),
				SpacerTVCellItem(identifier: "spacer_1"),
				MenuItemTVCellItem(identifier: "changeWallet",
													 title: "Change 👛 wallet"),
//				MenuItemTVCellItem(identifier: "reportProblem",
//													title: "Report 🙈 problem"),
//				MenuItemTVCellItem(identifier: "rate",
//													title: "Rate Monke 💜 in Appstore"),
				MenuItemWithImageTVCellItem(identifier: "donate",
													title: "Make a 🍩 donation",
													subtitle: "We spend  everything on development",
													imageName: "monke-icon"),
//				MenuItemWithImageTVCellItem(identifier: "buyBanana",
//													title: "Buy 🍌 Banana",
//													subtitle: "Use coins to reduce transaction fees",
//													imageName: "bip-uppercase"),
				SpacerTVCellItem(identifier: "spacer_2"),
//				MenuItemWithImageTVCellItem(identifier: "telegram",
//													title: "Telegram channel",
//													subtitle: "Updates and announcements from Monke team",
//													imageName: "telegram-icon"),
				MenuItemWithImageTVCellItem(identifier: "about",
													title: "About",
													subtitle: "Monke.io",
													imageName: "banana-icon"),
		]
	}

	// MARK: -

	override init() {
		super.init()

		input = Input(didTapTurnOn: didTapTurnOnSubject.asObserver())
		output = Output(isTurnedOn: isTurnedOnSubject.asObservable(),
										cells: dataSource)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			Session.shared.updateBalance()
		}

		Session.shared.balanceSubject.map({ [weak self] (res) -> String in
			if let balance = res[Coin.baseCoin().symbol ?? ""] {
			let bal = CurrencyNumberFormatter.formattedDecimal(with: balance,
																												 formatter: self!.currencyFormatter)
				return bal + " " + (Coin.baseCoin().symbol ?? "")
			}
			return ""
		}).subscribe(onNext: { (val) in
			self.balanceSubject.onNext(val)
		}).disposed(by: disposeBag)

		didTapTurnOnSubject.asObservable().subscribe(onNext: { (val) in
			let isTurnedOn = AccountManager.shared.restoreTurnedOn()
			AccountManager.shared.setTurnedOn(isTurnedOn: !isTurnedOn)
			self.isTurnedOnSubject.onNext(!isTurnedOn)
		}).disposed(by: disposeBag)

	}
}
