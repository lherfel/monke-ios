//
//  MenuItemWithImageTVCell.swift
//  MinterKeyboard
//
//  Created by Freeeon on 24.07.2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift

class MenuItemWithImageTVCellItem: BaseCellItem {
	var title: String
	var subtitle: String?
	var image: UIImage?
	
	init(identifier: String, title: String = "", subtitle: String? = nil, imageName: String = "") {
		self.title = title
		self.subtitle = subtitle
		self.image = UIImage(named: imageName)
		super.init(reuseIdentifier: "MenuItemWithImageTVCell", identifier: identifier)
	}
}

class MenuItemWithImageTVCell: BaseCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var subtitleLabel: UILabel!
	@IBOutlet weak var iconImage: UIImageView!
	
	// MARK: -
	
	override func configure(item: BaseCellItem) {
		guard let item = item as? MenuItemWithImageTVCellItem else { return }
		titleLabel.text = item.title
		
		if let subtitle = item.subtitle {
			subtitleLabel.text = subtitle
			subtitleLabel.isHidden = false
		}

		iconImage.image = item.image
	}
}
