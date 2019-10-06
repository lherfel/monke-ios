//
//  BalanceTVCell.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift

class BalanceTVCellItem: BaseCellItem {
	var image: UIImage?
	var titleObservable: Observable<String?>?
	var addressObservable: Observable<String?>?

	init(identifier: String, imageName: String = "",
			 titleObservable: Observable<String?>?,
			 addressObservable: Observable<String?>?) {
		self.titleObservable = titleObservable
		self.addressObservable = addressObservable
		image = UIImage(named: imageName)
		super.init(reuseIdentifier: "BalanceTVCell", identifier: identifier)
	}
}

protocol BalanceTVCellDelegate: class {
	func didTapDeposit()
}

class BalanceTVCell: BaseCell {

	// MARK: -

	weak var delegate: BalanceTVCellDelegate?

	// MARK: -

	@IBOutlet weak var coinImage: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var subtitle: UILabel!
	@IBOutlet weak var depositButton: UIButton!

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()
	}

	// MARK: -

	override func configure(item: BaseCellItem) {
		guard let item = item as? BalanceTVCellItem else { return }

		coinImage.image = item.image

		item.addressObservable?.asDriver(onErrorJustReturn: nil)
			.drive(title.rx.text).disposed(by: disposeBag)

		item.titleObservable?.asDriver(onErrorJustReturn: nil)
			.drive(subtitle.rx.text).disposed(by: disposeBag)

		depositButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.delegate?.didTapDeposit()
		}).disposed(by: disposeBag)
	}

}
