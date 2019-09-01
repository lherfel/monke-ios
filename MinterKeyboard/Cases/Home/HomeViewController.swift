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
import RxDataSources
import SPStorkController

class HomeViewController: BaseViewController, ControllerProtocol {

	// MARK: - IBOutlet

	@IBOutlet weak var turnOnButton: UIButton!
	@IBOutlet var headerView: UIView!
	@IBOutlet weak var tableView: UITableView!

	// MARK: - ControllerProtocol

	var viewModel = HomeViewModel()

	typealias ViewModelType = HomeViewModel

	func configure(with viewModel: HomeViewModel) {
		let datasource = RxTableViewSectionedReloadDataSource<SingleSection> (
			configureCell: { datasource, tableView, indexPath, item in
				let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) as! BaseCell
				cell.configure(item: item)
				return cell
		})
		let section = [SingleSection(items: viewModel.dataSource)]
		
		Observable.just(section)
			.bind(to: tableView.rx.items(dataSource: datasource))
			.disposed(by: disposeBag)
		
		tableView.rx.setDelegate(self)
			.disposed(by: disposeBag)
		
		tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
			guard let cell = self?.viewModel.output.cells[safe: indexPath.item] else {
				return
			}
			
			if cell.identifier == "backupPhrase" {
				self?.performSegue(withIdentifier: "showBackup", sender: nil)
			}
			
			if cell.identifier == "deposit" {
				self?.didTapDeposit()
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

	func registerCells() {
		tableView.register(cellReuseID: BalanceTVCell.reuseID)
		tableView.register(cellReuseID: MenuItemTVCell.reuseID)
		tableView.register(cellReuseID: MenuItemWithImageTVCell.reuseID)
		tableView.register(cellReuseID: SpacerTVCell.reuseID)
	}
}

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let item = viewModel.output.cells[safe: indexPath.item] else {
			return 0.1
		}
		
		if item is SpacerTVCellItem {
			return 24
		}

		return 60
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
