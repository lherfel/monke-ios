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
    var image: UIImage?
    var titleObservable: Observable<String?>?
}

class MenuItemWithImageTVCell: BaseCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
        
    // MARK: -
    
    func configure(title: String, subtitle: String?, image: String) {
        titleLabel.text = title
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        }
        iconImage.image = UIImage(named: image)
    }
}
