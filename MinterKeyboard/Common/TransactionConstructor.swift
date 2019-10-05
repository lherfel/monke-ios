//
//  TransactionConstructor.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 23/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import MinterCore
import BigInt
import RxSwift

class TransactionConstructor {

	static let formater = CurrencyNumberFormatter()
	static let gasCoin = "BANANA"

	enum TransactionConstructorError: Error {
		case invalidInputParam
	}

	static func sendTransaction(nonce: Decimal,
															address: String,
															amount: Decimal,
															coin: String,
															coinBalance: Decimal,
															baseCoinBalance: Decimal) -> Observable<RawTransaction?> {

		return Observable.create { (observer) -> Disposable in
			let nonce = BigUInt(decimal: nonce + 1)
			let value = BigUInt(decimal: amount * TransactionCoinFactorDecimal)
			if nonce == BigUInt(0) || value == BigUInt(0) {
				observer.onNext(nil)
			}

			let chainId = MinterCoreSDK.shared.network.rawValue
			let gasPrice = 1
			var gasCoin = TransactionConstructor.gasCoin//Coin.baseCoin().symbol ?? ""
			let to = address
			var newValue = value
			let payload = Data()

			let isBaseCoin = (coin == (Coin.baseCoin().symbol ?? ""))
			let baseCoinCommission = RawTransactionType.sendCoin.commission() +
				(Decimal(payload.count) * RawTransaction.payloadByteComissionPrice * TransactionCoinFactorDecimal)

			let coinBalanceComparable = CurrencyNumberFormatter
				.formattedDecimal(with: coinBalance,
													formatter: CurrencyNumberFormatter.coinFormatter)

			let baseCoinBalanceComparable = TransactionConstructor
				.formater.string(from: baseCoinBalance as NSNumber)?
				.replacingOccurrences(of: " ", with: "")
				.replacingOccurrences(of: ",", with: ".") ?? ""

			let isMax = CurrencyNumberFormatter.decimal(from: coinBalanceComparable) == amount

			if isBaseCoin {
				if isMax {
					newValue = value! - (BigUInt(decimal: baseCoinCommission) ?? BigUInt(0))
				}
			} else {
				if isMax {
					newValue = BigUInt(decimal: coinBalance * TransactionCoinFactorDecimal) ?? BigUInt(0)
				}
				if baseCoinBalance * TransactionCoinFactorDecimal >= baseCoinCommission {
//					gasCoin = Coin.baseCoin().symbol ?? ""
				} else {
//					gasCoin = coin
					let sendTransaction = SendCoinRawTransaction(nonce: nonce!,
																											 chainId: chainId,
																											 gasPrice: gasPrice,
																											 gasCoin: gasCoin,
																											 to: to,
																											 value: newValue!,
																											 coin: coin)
					if let tx = sendTransaction.encode()?.toHexString() {
						GateManager.shared.estimateTXCommission(for: tx, completion: { (commission, error) in
							newValue = newValue! - (BigUInt(decimal: (commission ?? 0.0)) ?? BigUInt(0))
							guard commission != nil, newValue! > BigUInt(0) else {
								observer.onNext(nil)
								return
							}

							let sendTransaction = SendCoinRawTransaction(nonce: nonce!,
																													 chainId: chainId,
																													 gasPrice: gasPrice,
																													 gasCoin: gasCoin,
																													 to: to,
																													 value: newValue!,
																													 coin: coin)

							observer.onNext(sendTransaction)
						})
						return Disposables.create()
					} else {
						observer.onNext(nil)
					}
				}
			}
			let sendTransaction = SendCoinRawTransaction(nonce: nonce!,
																									 chainId: chainId,
																									 gasPrice: gasPrice,
																									 gasCoin: gasCoin,
																									 to: to,
																									 value: newValue!,
																									 coin: coin)
			observer.onNext(sendTransaction)

			return Disposables.create()
		}
	}

	static func convertTransaction(nonce: Decimal,
																 coinFrom: String,
																 coinTo: String,
																 amount: Decimal,
																 coinBalance: Decimal,
																 baseCoinBalance: Decimal) -> Observable<RawTransaction?> {

		return Observable.create { (observer) -> Disposable in
			let nonce = BigUInt(decimal: nonce + 1)
			let value = BigUInt(decimal: amount * TransactionCoinFactorDecimal)
			if nonce == BigUInt(0) || value == BigUInt(0) {
				observer.onNext(nil)
			}

			let chainId = MinterCoreSDK.shared.network.rawValue
			let gasPrice = 1
			let gasCoin = TransactionConstructor.gasCoin//Coin.baseCoin().symbol ?? ""
			let minimumValueToBuy = BigUInt(decimal: 0.9 * amount * TransactionCoinFactorDecimal)

			let tx = SellCoinRawTransaction(nonce: nonce!,
																		 chainId: chainId,
																		 gasPrice: gasPrice,
																		 gasCoin: gasCoin,
																		 coinFrom: coinFrom,
																		 coinTo: coinTo,
																		 value: value ?? BigUInt(0),
																		 minimumValueToBuy: BigUInt(0))
			observer.onNext(tx)
			return Disposables.create()
		}
	}
}
