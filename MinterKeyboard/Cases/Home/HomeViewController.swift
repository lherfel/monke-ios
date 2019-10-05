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
import SafariServices

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

			if cell.identifier == "donate" {
				self?.didTapDeposit(type: .donate)
			}

			if cell.identifier == "changeWallet" {
				self?.didTapChangeWallet()
			}

			if cell.identifier == "deposit" {
				self?.didTapDeposit(type: .deposit)
			}
			
			if cell.identifier == "transaction" {
				self?.didTapTransactions()
			}
			
			if cell.identifier == "about" {
				self?.didTapAbout()
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

extension HomeViewController {
	func didTapDeposit(type: AddressType) {
		let addressViewController = AddressViewController()
		let transitionDelegate = SPStorkTransitioningDelegate()

		addressViewController.configure(type: type)
		
		transitionDelegate.customHeight = 360
		addressViewController.transitioningDelegate = transitionDelegate
		addressViewController.modalPresentationStyle = .custom
		addressViewController.modalPresentationCapturesStatusBarAppearance = true

		self.present(addressViewController, animated: true, completion: nil)
	}
}

extension HomeViewController {
	func didTapChangeWallet() {
		let changeWalletViewController = ChangeWalletViewController()
		let transitionDelegate = SPStorkTransitioningDelegate()
		let windowHeight: CGFloat = UIScreen.main.bounds.height <= 568 ? 290 : 330
		
		transitionDelegate.customHeight = windowHeight
		changeWalletViewController.transitioningDelegate = transitionDelegate
		changeWalletViewController.modalPresentationStyle = .custom
		changeWalletViewController.modalPresentationCapturesStatusBarAppearance = true
		
		self.present(changeWalletViewController, animated: true, completion: nil)
	}
	
	func didTapTransactions() {
		if let url = URL(string: "https://explorer.minter.network/address/Mx" + Session.shared.account.address) {
			let safariVC = SFSafariViewController(url: url)
			self.present(safariVC, animated: true, completion: nil)
		}
	}
	
	func didTapAbout() {
		if let url = URL(string: "https://monke.io") {
			let safariVC = SFSafariViewController(url: url)
			self.present(safariVC, animated: true, completion: nil)
		}
	}
}
