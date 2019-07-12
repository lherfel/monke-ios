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
	}

	var input: HomeViewModel.Input!

	var output: HomeViewModel.Output!

	// MARK: -

	var didTapTurnOnSubject = PublishSubject<Void>()
	var isTurnedOnSubject = BehaviorSubject(value: AccountManager.shared.restoreTurnedOn())

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
		let item = BalanceTableViewCellItem(reuseIdentifier: "BalanceTableViewCell",
																				identifier: "BalanceTableViewCell")
		item.image = UIImage(named: "bip-logo")
		item.titleObservable = balanceSubject.asObservable()
		return item
	}

}
