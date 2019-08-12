//
//  UITableViewCell+Extensions.swift
//  MinterKeyboard
//
//  Created by Freeeon on 29.07.2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var reuseID: String {
        return String(describing: self)
    }
}
