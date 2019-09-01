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
	var title: String?
	var subtitle: String?
	
	init(identifier: String, title: String = "", subtitle: String? = nil) {
		self.title = title
		self.subtitle = subtitle
		super.init(reuseIdentifier: "MenuItemTVCell", identifier: identifier)
	}
}

class MenuItemTVCell: BaseCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	
	// MARK: -
	
	override func configure(item: BaseCellItem) {
		guard let item = item as? MenuItemTVCellItem else { return }
		titleLabel.text = item.title
		if let subtitle = item.subtitle {
			subtitleLabel.text = subtitle
			subtitleLabel.isHidden = false
		}
	}
}
