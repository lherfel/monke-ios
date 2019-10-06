//
//  KeyboardViewModel.swift
//  WalletKeyboard
//
//  Created by Alexey Sidorov on 15/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import RxSwift
import MinterCore
import MinterMy
import LocalAuthentication
import BigInt

class KeyboardViewModel {

	static let address = "Mx" + Session.shared.account.address

	let currencyFormatter = CurrencyNumberFormatter.coinFormatter
	var context = LAContext() {
		didSet {
			context.touchIDAuthenticationAllowableReuseDuration = 1
		}
	}

	private let gateManager = GateManager.shared

	// MARK: -

	var disposeBag = DisposeBag()

	// MARK: -

	struct Input {
		var didTapMaxButton: AnyObserver<Void>
		var didTapSendButton: AnyObserver<Void>
		var address: AnyObserver<String?>
		var selectedCoin: AnyObserver<String>
		var amount: AnyObserver<String?>
	}

	struct Output {
		var address: Observable<String>
		var balance: Observable<String>
		var delegated: Observable<String>
		var amount: Observable<String?>
		var sendAddress: Observable<String?>
		var sendAddressImageURL: Observable<URL?>
		var coinImageURL: Observable<URL?>
		var showSentView: Observable<String>
		var error: Observable<String>
		var balances: Observable<[String]>
		var selectedCoin: Observable<String>
		var selectedCoinBalance: Observable<String>
		var isLoading: Observable<Bool>
		var addressFieldHasError: Observable<Bool>
		var isTurnedOn: (Bool)
		var fee: Observable<String>
	}

	var input: Input!
	var output: Output!

	// MARK: -

	private var balances: [String: Decimal] = [:] {
		didSet {
			var ret = [String]()
			balances.keys.forEach({ (key) in
				let bal = CurrencyNumberFormatter.formattedDecimal(with: (balances[key] ?? 0.0),
																													 formatter: self.currencyFormatter)
				ret.append(key + " " + bal)
			})
			self.balancesSubject.onNext(ret)
		}
	}
	private var originalBalances: [String: Decimal] = [:]

	var shouldConvert: Bool {
		return (balances["BANANA"] ?? 0.0) < Session.minimumBananasNumber
	}

	private var coinAvatarURLSubject = PublishSubject<URL?>()
	private var isLoadingSubject = PublishSubject<Bool>()
	private var addressSubject = BehaviorSubject<String>(value: address)
	private var sendAddressSubject = BehaviorSubject<String?>(value: nil)
	private var didTapMaxButtonSubject = PublishSubject<Void>()
	private var didTapSendButtonSubject = PublishSubject<Void>()
	private var amountSubject = BehaviorSubject<String?>(value: nil)
	private var sendAddressImageURLSubject = PublishSubject<URL?>()
	private var showSentViewSubject = PublishSubject<String>()
	private var balanceSubject = BehaviorSubject<String>(value: "")
	private var delegatedSubject = BehaviorSubject<String>(value: "")
	private var selectedCoinSubject = BehaviorSubject<String>(value: "")
	private var selectedCoinBalanceSubject = PublishSubject<String>()
	private var errorSubject = PublishSubject<String>()
	private var balancesSubject = PublishSubject<[String]>()
	private var didCompleteAuthenticationSubject = PublishSubject<Bool>()
	private func sendObservable() -> Observable<(String?, String?)> {
		return Observable.combineLatest(sendAddressSubject.asObservable(),
																		amountSubject.asObservable())
	}
	private func gateObservable() -> Observable<(Int, Int)> {
		return Observable.combineLatest(gateManager.minGas(),
																		gateManager.nonce(address: Session.shared.account.address))
	}
	private var addressFieldHasErrorSubject = PublishSubject<Bool>()
	private var feeSubject = PublishSubject<String>()

	private lazy var privateKey = Session.shared.account.privateKey

	// MARK: -

	init() {
		MinterSDKConfigurator.configure(isTestnet: false)

		selectedCoinSubject.onNext(Coin.baseCoin().symbol ?? "")

		self.input = Input(didTapMaxButton: didTapMaxButtonSubject.asObserver(),
											 didTapSendButton: didTapSendButtonSubject.asObserver(),
											 address: sendAddressSubject.asObserver(),
											 selectedCoin: selectedCoinSubject.asObserver(),
											 amount: amountSubject.asObserver()
		)
		self.output = Output(address: addressSubject.asObservable(),
												 balance: balanceSubject.asObservable(),
												 delegated: delegatedSubject.asObservable(),
												 amount: amountSubject.asObservable(),
												 sendAddress: sendAddressSubject.asObservable(),
												 sendAddressImageURL: sendAddressImageURLSubject.asObservable(),
												 coinImageURL: coinAvatarURLSubject.asObservable(),
												 showSentView: showSentViewSubject.asObservable(),
												 error: errorSubject.asObservable(),
												 balances: balancesSubject.asObservable(),
												 selectedCoin: selectedCoinSubject.asObservable(),
												 selectedCoinBalance: selectedCoinBalanceSubject.asObservable(),
												 isLoading: isLoadingSubject.asObservable(),
												 addressFieldHasError: addressFieldHasErrorSubject.asObservable(),
												 isTurnedOn: {
														return AccountManager.shared.restoreTurnedOn()
													}(),
												 fee: feeSubject.asObservable()
		)

		didTapMaxButtonSubject.withLatestFrom(selectedCoinSubject.asObservable())
			.subscribe(onNext: { [weak self] (coin) in
				guard let selectedBalance = self?.balances[coin] else {
					return
				}
				guard let formatter = self?.currencyFormatter else { return }
				let amount = CurrencyNumberFormatter.formattedDecimal(with: selectedBalance,
																															formatter: formatter)
				self?.amountSubject.onNext(amount.replacingOccurrences(of: " ", with: ""))
		}).disposed(by: disposeBag)

		selectedCoinSubject.subscribe(onNext: { [weak self] (coin) in
			guard let selectedBalance = self?.balances[coin] else {
				return
			}

			let text = self?.balanceText(with: coin, amount: selectedBalance) ?? ""
			self?.selectedCoinBalanceSubject.onNext(text)
		}).disposed(by: disposeBag)

		balanceSubject.subscribe(onNext: { [weak self] (val) in
			do {
				let coin = Coin.baseCoin().symbol ?? ""
				if coin == (try self?.selectedCoinSubject.value() ?? "") {
					guard let selectedBalance = self?.balances[coin] else {
						return
					}
					let text = self?.balanceText(with: coin, amount: selectedBalance) ?? ""
					self?.selectedCoinBalanceSubject.onNext(text)
				}
			} catch {

			}
			self?.feeSubject.onNext((self?.shouldConvert ?? false) ? "1% to BANANA + 0.1100 BIP" : "Fee 0.0100 BIP")
		}).disposed(by: disposeBag)

		sendAddressSubject.asObservable().subscribe(onNext: { [weak self] (address) in
			if address?.isValidAddress() ?? false {
				self?.addressFieldHasErrorSubject.onNext(false)
				let avatarURL = MinterMyAPIURL.avatarAddress(address: address!).url()
				self?.sendAddressImageURLSubject.onNext(avatarURL)
			} else {
				self?.sendAddressImageURLSubject.onNext(nil)
				if address != nil && address != "" {
					self?.addressFieldHasErrorSubject.onNext(true)
				} else {
					self?.addressFieldHasErrorSubject.onNext(false)
				}
			}
		}).disposed(by: disposeBag)

		didTapSendButtonSubject.withLatestFrom(sendAddressSubject.asObservable()).filter({ (address) -> Bool in
			return address?.isValidAddress() ?? false
		}).subscribe(onNext: { [weak self] (_) in
			self?.didCompleteAuthenticationSubject.onNext(false)
			self?.authenticateUser(completion: {})
		}).disposed(by: disposeBag)

		didCompleteAuthenticationSubject.filter({ (val) -> Bool in
			return val == true
		}).flatMap({ (val) -> Observable<(Int, Int)> in
			return self.gateObservable()
		}).subscribe(onNext: { [weak self] (val) in
			let address: String
			let amount: String
			let coin: String
			do {
				address = try self?.sendAddressSubject.value() ?? ""
				amount = (try self?.amountSubject.value() ?? "")
					.replacingOccurrences(of: " ", with: "")
					.replacingOccurrences(of: ",", with: ".")
				coin = try self?.selectedCoinSubject.value() ?? ""
			} catch {
				return
			}

			let nonce = Decimal(val.1)
			self?.sendTransactionObservable(nonce: nonce,
																						 address: address,
																						 amount: Decimal(string: amount) ?? 0.0,
																						 coin: coin).subscribe(onNext: { (val) in
																							self?.handleHash(hash: val)
																						}).disposed(by: self!.disposeBag)
		}).disposed(by: disposeBag)

		Session.shared.balanceSubject.map({ [weak self] (res) -> String in
			self?.balances = res
			self?.originalBalances = res
			if let balance = res[Coin.baseCoin().symbol ?? ""] {
				return CurrencyNumberFormatter.formattedDecimal(with: balance,
																												formatter: self!.currencyFormatter)
			}
			return ""
		}).subscribe(balanceSubject.asObserver()).disposed(by: disposeBag)

		Session.shared.delegationsSubject.map { [weak self] (total) -> String in
			return CurrencyNumberFormatter.formattedDecimal(with: total,
																											formatter: self!.currencyFormatter)
		}.subscribe(delegatedSubject.asObserver()).disposed(by: disposeBag)

		Observable.combineLatest(self.selectedCoinSubject, self.balancesSubject)
			.subscribe(onNext: { [weak self] (coin, balances) in
			self?.coinAvatarURLSubject.onNext(MinterMyAPIURL.avatarByCoin(coin: coin).url())
		}).disposed(by: disposeBag)

		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			Session.shared.updateBalance()
		}
	}

	func handleHash(hash: String?) {
		if nil != hash {
			self.showSentViewSubject.onNext(hash ?? "")
			self.clearForm()
			Session.shared.updateBalance()

			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
				Session.shared.updateBalance()
			}
		} else {
			self.errorSubject.onNext(hash ?? "")
		}
	}

	func sendTransactionObservable(nonce: Decimal,
																 address: String,
																 amount: Decimal,
																 coin: String) -> Observable<String?> {

		return TransactionConstructor.sendTransaction(nonce: nonce,
																									address: address,
																									amount: amount,
																									coin: coin,
																									coinBalance: self.balances[coin] ?? 0.0,
																									baseCoinBalance: self.balances[Coin.baseCoin().symbol ?? ""] ?? 0.0).filter({ (raw) -> Bool in
																												return raw != nil

																									}).flatMap({ (transaction) -> Observable<String?> in
																										let signedTx = RawTransactionSigner.sign(rawTx: transaction!,
																																														 privateKey: self.privateKey)
																										return self.gateManager.send(rawTx: signedTx)
																									})
		.do(onNext: { [weak self] (hash) in
			self?.isLoadingSubject.onNext(false)

			if self?.shouldConvert ?? false {
				self?.convertToBananas(coinFrom: coin, amount: amount)
			}
		}, onError: { [weak self] (error) in
			self?.isLoadingSubject.onNext(false)

			if let message = (error as? HTTPClientError)?.userData?["log"] as? String {
				self?.errorSubject.onNext(message)
			} else {
				self?.errorSubject.onNext(error.localizedDescription)
			}
		}, onCompleted: {
			
		}, onSubscribe: { [weak self] in
			self?.isLoadingSubject.onNext(true)
		})
	}

	private func canEvaluatePolicy(withBiometry: Bool) -> Bool {
		if withBiometry {
			return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
		}
		return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
	}

	private func authenticateUser(completion: @escaping () -> Void) {
		if canEvaluatePolicy(withBiometry: true) {
			context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
														 localizedReason: "To be able to send transaction") { [weak self] (res, error) in
															if res {
																self?.didCompleteAuthenticationSubject.onNext(true)
															} else {
																//Tx can't be sent
															}
															self?.context.invalidate()
															self?.context = LAContext()
			}
		} else if canEvaluatePolicy(withBiometry: false) {
			context.evaluatePolicy(.deviceOwnerAuthentication,
														 localizedReason: "To be able to send transaction") { [weak self] (res, error) in
															if res {
																self?.didCompleteAuthenticationSubject.onNext(true)
															} else {
																//Tx can't be sent
															}
															self?.context.invalidate()
															self?.context = LAContext()
			}
		}
	}

	func clearForm() {
		self.sendAddressSubject.onNext("")
		self.amountSubject.onNext("")
	}

	func balanceText(with coin: String, amount: Decimal) -> String? {
		let formatter = self.currencyFormatter
		let balance = CurrencyNumberFormatter.formattedDecimal(with: amount,
																													 formatter: formatter)
		return "Available " + balance
	}

	private func convertToBananas(coinFrom: String, amount: Decimal) {
		self.gateObservable().flatMap { (val) -> Observable<RawTransaction?> in

			let bananaBalance = self.balances["BANANA"] ?? Decimal(0.0)
			let baseCoinBalance = self.balances[Coin.baseCoin().symbol!] ?? Decimal(0.0)
			let convertAmount = min(max(0, 1.0 - bananaBalance), amount * 0.01)

			guard convertAmount > 0 && coinFrom != "BANANA"  else {
				return Observable.empty()
			}

			return TransactionConstructor.convertTransaction(nonce: Decimal(val.1),
																											 coinFrom: coinFrom,
																											 coinTo: "BANANA",
																											 amount: convertAmount,
																											 coinBalance: bananaBalance,
																											 baseCoinBalance: baseCoinBalance)
			}.flatMap({ (transaction) -> Observable<String?> in
				let signedTx = RawTransactionSigner.sign(rawTx: transaction!, privateKey: self.privateKey)
				return self.gateManager.send(rawTx: signedTx)
			}).do(onNext: { (tx) in
				
			}, onError: { error in
				
			}).subscribe().disposed(by: disposeBag)
	}
}
