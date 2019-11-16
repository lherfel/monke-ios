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

	// MARK: - IBOutlet.

	@IBOutlet weak var mnemonicsLabel: UILabel!
	@IBOutlet weak var clipboardButton: UIButton!
	@IBOutlet weak var warningLabel: UILabel!

	// MARK: - Lifecycle.

	override func viewDidLoad() {
		super.viewDidLoad()

		let warningText = NSMutableAttributedString(string: "Please ", attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-regular", size: 16)!])

		warningText.append(NSMutableAttributedString(string: "write these 12 words down in order, ", attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-bold", size: 16)!]))

		warningText.append(NSMutableAttributedString(string: "and keep them somewhere safe offline.\n\nBackup Phrase allows you get access to funds of your Monke.", attributes: [NSAttributedString.Key.font: UIFont(name: "SFProDisplay-regular", size: 16)!]))

		warningLabel.attributedText = warningText
		mnemonicsLabel.text = Session.shared.account.mnemonics

		clipboardButton.rx.tap.subscribe(onNext: { (_) in
			UIPasteboard.general.string = Session.shared.account.mnemonics
			SVProgressHUD.showSuccess(withStatus: "COPIED")
		}).disposed(by: disposeBag)
	}
}
