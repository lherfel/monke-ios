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
import SVProgressHUD

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

			switch cell.identifier {
				case "deposit":
					self?.didTapDeposit(type: .deposit)
				case "backupPhrase":
					self?.didTapBackupPhrase()
				case "donate":
					self?.didTapDeposit(type: .donate)
				case "changeWallet":
					self?.didTapChangeWallet()
				case "reportProblem":
					self?.didTapReportProblem()
				case "transaction":
					self?.didTapTransactions()
				case "telegram":
					self?.didTapTelegram()
				case "about":
					self?.didTapAbout()
				default:
					break
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
	
	func didTapBackupPhrase() {
		AuthManager.shared.presentTouchID("Open backup phrase", fallbackTitle: "Enter Passcode") { (response) in
			if response == .success {
				self.performSegue(withIdentifier: "showBackup", sender: nil)
			} else if response == .error(.passcodeNotSet) {
				SVProgressHUD.showError(withStatus: "Add a passcode or biometric identification to see the backup phrase.")
			}
		}
	}
	
	func didTapReportProblem() {
		let email = "monkeapp@gmail.com"
		if let url = URL(string: "mailto:\(email)") {
			if UIApplication.shared.canOpenURL(url){
				UIApplication.shared.open(url)
			} else {
				SVProgressHUD.showError(withStatus: "There is no any mail application")
			}
		}
	}
	
	func didTapTelegram() {
		if let appUrl = URL(string: "tg://resolve?domain=MonkeApp"), UIApplication.shared.canOpenURL(appUrl) {
			UIApplication.shared.open(appUrl)
		} else {
			guard let webUrl = URL(string: "https://t.me/MonkeApp") else { return }
			UIApplication.shared.open(webUrl)
		}
	}
	
	func didTapAbout() {
		if let url = URL(string: "https://en.monke.io") {
			let safariVC = SFSafariViewController(url: url)
			self.present(safariVC, animated: true, completion: nil)
		}
	}
}
