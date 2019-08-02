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

class HomeTableCellItem : BaseCellItem {
    var title: String
    var type: HomeTableCellType
    var desc: String?
    var image: String?
    
    enum HomeTableCellType: String {
        case balance = "BalanceTVCell"
        case menuItem = "MenuItemTVCell"
        case menuItemWithImage = "MenuItemWithImageTVCell"
        case spacer = "SpacerTVCell"
    }
    
    init(title: String = "", type: HomeTableCellType = .spacer, desc: String? = nil, image: String? = nil) {
        self.title = title
        self.type = type
        self.desc = desc
        self.image = image
        super.init(reuseIdentifier: type.rawValue, identifier: type.rawValue)
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
	}

	var input: HomeViewModel.Input!

	var output: HomeViewModel.Output!

	// MARK: -

	var didTapTurnOnSubject = PublishSubject<Void>()
	var isTurnedOnSubject = BehaviorSubject(value: AccountManager.shared.restoreTurnedOn())

    // MARK: - DataSource
    
    public var dataSource: [HomeTableCellItem] {
        return [
            HomeTableCellItem(title: "deposit", type: .balance),
            HomeTableCellItem(title: "", type: .spacer),
            HomeTableCellItem(title: "🔑 Backup Phrase", type: .menuItem),
            HomeTableCellItem(title: "Report 🙈 problem", type: .menuItem),
            HomeTableCellItem(title: "Rate Monke 💜 in Appstore", type: .menuItem),
            HomeTableCellItem(title: "Make a 🍩 donation", type: .menuItemWithImage, desc: "We spend  everything on development", image: "monke-icon"),
            HomeTableCellItem(title: "Buy 🍌 Banana", type: .menuItemWithImage, desc: "Use coins to reduce transaction fees", image: "bip-uppercase"),
            HomeTableCellItem(title: "", type: .spacer),
            HomeTableCellItem(title: "Telegram channel", type: .menuItemWithImage, desc: "Updates and announcements from Monke team", image: "telegram-icon"),
            HomeTableCellItem(title: "About", type: .menuItemWithImage, desc: "Monke.io", image: "banana-icon"),
        ]
    }
    
	// MARK: -

	override init() {
		super.init()

		input = Input(didTapTurnOn: didTapTurnOnSubject.asObserver())
		output = Output(isTurnedOn: isTurnedOnSubject.asObservable())

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
