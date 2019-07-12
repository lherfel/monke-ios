//
//  BalanceTableViewCell.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift

class BalanceTableViewCellItem: BaseCellItem {
	var image: UIImage?
	var titleObservable: Observable<String?>?
}

protocol BalanceTableViewCellDelegate: class {
	func didTapDeposit()
}

class BalanceTableViewCell: BaseCell {

	// MARK: -

	weak var delegate: BalanceTableViewCellDelegate?

	@IBOutlet weak var coinImage: UIImageView!
	@IBOutlet weak var title: UILabel!
	@IBOutlet weak var depositButton: UIButton!

	// MARK: -

	override func awakeFromNib() {
		super.awakeFromNib()

		depositButton.rx.tap.subscribe(onNext: { [weak self] (_) in
			self?.delegate?.didTapDeposit()
		}).disposed(by: disposeBag)
		
	}

	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}

	// MARK: -

	override func configure(item: BaseCellItem) {

		guard let item = item as? BalanceTableViewCellItem else {
			return
		}

		coinImage.image = item.image
		item.titleObservable?.asDriver(onErrorJustReturn: nil).drive(title.rx.text).disposed(by: disposeBag)
	}

}
