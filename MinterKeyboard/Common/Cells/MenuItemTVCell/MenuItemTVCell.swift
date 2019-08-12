//
//  MenuItemTVCell.swift
//  MinterKeyboard
//
//  Created by Freeeon on 24.07.2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift

class MenuItemTVCellItem: BaseCellItem {
	var titleObservable: Observable<String?>?
}

class MenuItemTVCell: BaseCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	
	// MARK: -
	
	func configure(title: String, subtitle: String?) {
		titleLabel.text = title
		if let subtitle = subtitle {
				subtitleLabel.text = subtitle
				subtitleLabel.isHidden = false
		}
	}
}
