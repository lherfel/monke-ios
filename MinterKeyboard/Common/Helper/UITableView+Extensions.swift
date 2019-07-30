//
//  UITableView+Extensions.swift
//  MinterKeyboard
//
//  Created by Freeeon on 29.07.2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit

extension UITableView {
    func register(cellReuseID reuseID: String) {
        let nib = UINib(nibName: reuseID, bundle: nil)
        register(nib, forCellReuseIdentifier: reuseID)
    }
}
