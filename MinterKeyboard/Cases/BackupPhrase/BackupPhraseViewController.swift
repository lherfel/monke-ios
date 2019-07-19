//
//  BackupPhraseViewController.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SVProgressHUD

class BackupPhraseViewController: BaseViewController {

	// MARK: -

	@IBOutlet weak var mnemonicsLabel: UILabel!
	@IBOutlet weak var clipboardButton: UIButton!

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		mnemonicsLabel.text = Session.shared.account.mnemonics

		clipboardButton.rx.tap.subscribe(onNext: { (_) in
			UIPasteboard.general.string = Session.shared.account.mnemonics
			SVProgressHUD.showSuccess(withStatus: "COPIED")
		}).disposed(by: disposeBag)
	}

	// MARK: -

}
