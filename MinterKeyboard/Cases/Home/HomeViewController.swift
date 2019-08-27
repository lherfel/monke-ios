//
//  HomeViewController.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import MinterCore
import MinterExplorer
import RxSwift
import SPStorkController

class HomeViewController: BaseViewController, ControllerProtocol, UITableViewDelegate, UITableViewDataSource {

	// MARK: - IBOutlet

	@IBOutlet weak var turnOnButton: UIButton!
	@IBOutlet var headerView: UIView!
	@IBOutlet weak var tableView: UITableView!

	// MARK: - ControllerProtocol

	var viewModel = HomeViewModel()

	typealias ViewModelType = HomeViewModel

	func configure(with viewModel: HomeViewModel) {

		turnOnButton.rx.tap.asDriver()
			.drive(viewModel.input.didTapTurnOn).disposed(by: disposeBag)

		viewModel.output.isTurnedOn.subscribe(onNext: { (isTurnedOn) in
			self.turnOnButton.setTitle(isTurnedOn ? "TURN OFF MONKE" : "TURN ON MONKE", for: .normal)
		}).disposed(by: disposeBag)

		tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
			guard let cell = self?.viewModel.output.cells[safe: indexPath.item] else {
				return
			}

			if cell.identifier == HomeTableCellItem.identifiers.backupPhrase.rawValue {
				self?.performSegue(withIdentifier: "showBackup", sender: nil)
			}
		}).disposed(by: disposeBag)

	}

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		configure(with: viewModel)
		registerCells()

		tableView.tableHeaderView = headerView
		tableView.tableFooterView = UIView()
	}

	// MARK: - TableView

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let object = viewModel.output.cells[safe: indexPath.item] else {
			assert(true)
			return UITableViewCell()
		}
		switch object.type {
		case .balance:
			let item = viewModel.balanceCellItem
			let cell = tableView.dequeueReusableCell(withIdentifier: BalanceTVCell.reuseID) as! BalanceTVCell
			cell.configure(item: item)
			cell.delegate = self
			return cell

		case .menuItem:
			let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemTVCell.reuseID) as! MenuItemTVCell
			cell.configure(title: object.title, subtitle: object.desc)
			return cell

		case .menuItemWithImage:
			let cell = tableView.dequeueReusableCell(withIdentifier: MenuItemWithImageTVCell.reuseID) as! MenuItemWithImageTVCell
			guard let image = object.image else { return cell }
			cell.configure(title: object.title, subtitle: object.desc, image: image)
			return cell

		case .spacer:
			let cell = tableView.dequeueReusableCell(withIdentifier: SpacerTVCell.reuseID) as! SpacerTVCell
			return cell
		}
	}

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let object = viewModel.output.cells[safe: indexPath.item] else {
			return 0.1
		}

		switch object.type {
		case .spacer:
				return 24
		default:
				return 60
		}
	}

	func registerCells() {
		tableView.register(cellReuseID: BalanceTVCell.reuseID)
		tableView.register(cellReuseID: MenuItemTVCell.reuseID)
		tableView.register(cellReuseID: MenuItemWithImageTVCell.reuseID)
		tableView.register(cellReuseID: SpacerTVCell.reuseID)
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.output.cells.count
	}
}

extension HomeViewController: BalanceTVCellDelegate {

	func didTapDeposit() {
		let depositViewController = DepositViewController()
		let transitionDelegate = SPStorkTransitioningDelegate()

		transitionDelegate.customHeight = 360
		depositViewController.transitioningDelegate = transitionDelegate
		depositViewController.modalPresentationStyle = .custom
		depositViewController.modalPresentationCapturesStatusBarAppearance = true

		self.present(depositViewController, animated: true, completion: nil)
	}
}
