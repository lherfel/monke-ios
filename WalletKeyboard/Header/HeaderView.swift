//
//  HeaderView.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 16/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

class HeaderView: UIView {

	// MARK: -

	@IBOutlet weak var addressButton: UIButton!
	@IBOutlet weak var balanceLabel: UILabel!
	@IBOutlet weak var delegateLabel: UILabel!

	
	func setAppearance(isDark: Bool = false) {
		if isDark {
			addressButton.setBackgroundImage(UIImage(named: "address-button-dark"), for: .normal)
			addressButton?.setTitleColor(.white, for: .normal)
			balanceLabel?.textColor = .white
			delegateLabel?.textColor = .white
		} else {
			addressButton.setBackgroundImage(UIImage(named: "address-button"), for: .normal)
			addressButton?.setTitleColor(.black, for: .normal)
			balanceLabel?.textColor = .black
			delegateLabel?.textColor = .black
		}
	}
	
}
