//
//  MinterSDKConfigurator.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 23/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import MinterCore
import MinterMy
import MinterExplorer

class MinterSDKConfigurator {

	static func configure(isTestnet: Bool = false) {
		let conf = Configuration()
			if !isTestnet {
				MinterGateBaseURLString = "https://gate.apps.minter.network"
			}
			MinterCoreSDK.initialize(urlString: conf.environment.nodeBaseURL,
															 network: isTestnet ? .testnet : .mainnet)
			MinterExplorerSDK.initialize(APIURLString: conf.environment.explorerAPIBaseURL,
																	 WEBURLString: conf.environment.explorerWebURL,
																	 websocketURLString: conf.environment.explorerWebsocketURL)
		MinterMySDK.initialize(network: isTestnet ? .testnet : .mainnet)
	}

}
