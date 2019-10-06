//
//  ChangeWalletViewModel.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 05/10/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import GoldenKeystore

class ChangeWalletViewModel: BaseViewModel, ViewModelProtocol {

	// MARK: -

	struct Input {
		var mnemonics: AnyObserver<String?>
		var didTapDoneButton: AnyObserver<Void>
	}
	struct Output {
		var errorNotification: Observable<String?>
		var shouldDismiss: Observable<Void>
	}
	var input: ChangeWalletViewModel.Input!
	var output: ChangeWalletViewModel.Output!

	// MARK: -

	private var mnemonicsSubject = PublishSubject<String?>()
	private var didTapDoneButton = PublishSubject<Void>()
	private var errorSubject = PublishSubject<String?>()
	private var shouldDismissSubject = PublishSubject<Void>()

	// MARK: -
	
	override init() {
		super.init()

		input = Input(mnemonics: mnemonicsSubject.asObserver(),
									didTapDoneButton: didTapDoneButton.asObserver())
		output = Output(errorNotification: errorSubject.asObservable(),
										shouldDismiss: shouldDismissSubject.asObservable())

		didTapDoneButton.withLatestFrom(mnemonicsSubject).filter({ (mnemonics) -> Bool in
			return mnemonics != nil && mnemonics != ""
		}).subscribe(onNext: { [weak self] (mnemonics) in
			if let mnemonics = mnemonics, GoldenKeystore.mnemonicIsValid(mnemonics) {
				AccountManager.shared.changeAccount(mnemonics: mnemonics)
				Session.shared.refreshAccount()
				Session.shared.updateBalance()
				Session.shared.updateAddress()
				self?.shouldDismissSubject.onNext(())
			} else {
				self?.errorSubject.onNext("Invalid Phrase")
			}
		}).disposed(by: disposeBag)
	}
}
