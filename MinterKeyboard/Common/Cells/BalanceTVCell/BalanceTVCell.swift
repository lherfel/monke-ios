//
//  BalanceTVCell.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import MinterMy

class BalanceTVCellItem: BaseCellItem {
	var image: UIImage?
	var titleObservable: Observable<String?>?
	var addressObservable: Observable<String?>?

	init(identifier: String,
			 imageName: String = "",
			 titleObservable: Observable<String?>?,
			 addressObservable: Observable<String?>?) {

		self.titleObservable = titleObservable
		self.addressObservable = addressObservable
		self.image = UIImage(named: imageName)
		super.init(reuseIdentifier: "BalanceTVCell", identifier: identifier)
	}
}

class BalanceTVCell: BaseCell {

	// MARK: - IBOutlets.

	@IBOutlet weak var coinImage: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subtitle: UILabel!

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	// MARK: - Configure.

	override func configure(item: BaseCellItem) {
		guard let item = item as? BalanceTVCellItem else { return }

		coinImage.image = item.image

		item.addressObservable?.asDriver(onErrorJustReturn: nil)
			.drive(title.rx.text).disposed(by: disposeBag)

		item.addressObservable?.bind(onNext: { address in
			guard let address = address else { return }
			let avatarURL = MinterMyAPIURL.avatarAddress(address: address).url()
			self.coinImage.af_setImage(withURL: avatarURL)
		}).disposed(by: disposeBag)

		item.titleObservable?.asDriver(onErrorJustReturn: nil)
			.drive(subtitle.rx.text).disposed(by: disposeBag)

	}

}
