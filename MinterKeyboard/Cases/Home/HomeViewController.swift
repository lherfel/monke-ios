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
import PMAlertController
import EFQRCode
import SVProgressHUD

class HomeViewController: BaseViewController, ControllerProtocol, UITableViewDelegate, UITableViewDataSource {

	@IBOutlet weak var turnOnButton: UIButton!

	// MARK: - ControllerProtocol

	var viewModel = HomeViewModel()

	typealias ViewModelType = HomeViewModel

	func configure(with viewModel: HomeViewModel) {

		turnOnButton.rx.tap.asDriver()
			.drive(viewModel.input.didTapTurnOn).disposed(by: disposeBag)

		viewModel.output.isTurnedOn.subscribe(onNext: { (isTurnedOn) in
			self.turnOnButton.setTitle(isTurnedOn ? "TURN OFF MONKE" : "TURN ON MONKE", for: .normal)
		}).disposed(by: disposeBag)

	}

	// MARK: -

	@IBOutlet var headerView: UIView!
	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		configure(with: viewModel)
        registerCells()

		tableView.tableHeaderView = headerView
		tableView.tableFooterView = UIView()
	}
    
	// MARK: - TableView

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let object = viewModel.dataSource[indexPath.item]
        
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
        let object = viewModel.dataSource[indexPath.item]
        
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
		return viewModel.dataSource.count
	}

	func showDeposit() {

		let qr = EFQRCode.generate(content: "Mx" + Session.shared.account.address)

		var image = (qr != nil) ? UIImage(cgImage: qr!) : UIImage()
		let alertVC = PMAlertController(title: "Deposit",
																		description: "Mx" + Session.shared.account.address,
																		image: image,
																		style: .alert)
		
		alertVC.addAction(PMAlertAction(title: "Close", style: .cancel, action: { () -> Void in
//			print("Capture action Cancel")
		}))
		alertVC.addAction(PMAlertAction(title: "Copy", style: .`default`, action: { () -> Void in
			UIPasteboard.general.string = "Mx" + Session.shared.account.address
			SVProgressHUD.showSuccess(withStatus: "COPIED")
		}))
		self.present(alertVC, animated: true, completion: nil)
	}

}

extension HomeViewController: BalanceTVCellDelegate {
	
	func didTapDeposit() {
		//self.showDeposit()
        let card = CardViewController.init()
        card.configure(parent: self)
	}
	
}
