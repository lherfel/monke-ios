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

class HomeTableCellItem: BaseCellItem {
	var title: String
	var type: HomeTableCellItem.`Type`
	var desc: String?
	var image: String?

	enum `Type`: String {
		case balance = "BalanceTVCell"
		case menuItem = "MenuItemTVCell"
		case menuItemWithImage = "MenuItemWithImageTVCell"
		case spacer = "SpacerTVCell"
	}
	
	enum identifiers: String {
		case deposit
		case backupPhrase
		case reportProblem
		case rate
		case donate
		case buyBanana
		case telegram
		case about
	}

	init(identifier: String, title: String = "", type: HomeTableCellItem.`Type` = .spacer, desc: String? = nil, image: String? = nil) {
		self.title = title
		self.type = type
		self.desc = desc
		self.image = image
		super.init(reuseIdentifier: type.rawValue, identifier: identifier)
	}
}

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
		var cells: [HomeTableCellItem]
	}

	var input: HomeViewModel.Input!
	var output: HomeViewModel.Output!

	// MARK: -

	var didTapTurnOnSubject = PublishSubject<Void>()
	var isTurnedOnSubject = BehaviorSubject(value: AccountManager.shared.restoreTurnedOn())

	// MARK: - DataSource

	private var dataSource: [HomeTableCellItem] {
		return [
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.deposit.rawValue,
													title: "deposit",
													type: .balance),
				HomeTableCellItem(identifier: "spacer_1",
													title: "",
													type: .spacer),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.backupPhrase.rawValue,
													title: "🔑 Backup Phrase",
													type: .menuItem),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.reportProblem.rawValue,
													title: "Report 🙈 problem",
													type: .menuItem),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.rate.rawValue,
													title: "Rate Monke 💜 in Appstore",
													type: .menuItem),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.donate.rawValue,
													title: "Make a 🍩 donation",
													type: .menuItemWithImage,
													desc: "We spend  everything on development",
													image: "monke-icon"),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.buyBanana.rawValue,
													title: "Buy 🍌 Banana",
													type: .menuItemWithImage,
													desc: "Use coins to reduce transaction fees",
													image: "bip-uppercase"),
				HomeTableCellItem(identifier: "spacer_2",
													title: "",
													type: .spacer),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.telegram.rawValue,
													title: "Telegram channel",
													type: .menuItemWithImage,
													desc: "Updates and announcements from Monke team",
													image: "telegram-icon"),
				HomeTableCellItem(identifier: HomeTableCellItem.identifiers.about.rawValue,
													title: "About",
													type: .menuItemWithImage,
													desc: "Monke.io",
													image: "banana-icon"),
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

	var balanceCellItem: BaseCellItem {
		let item = BalanceTVCellItem(reuseIdentifier: "BalanceTVCell", identifier: "BalanceTVCell")
		item.image = UIImage(named: "bip-logo")
		item.titleObservable = balanceSubject.asObservable()
		return item
	}
}
