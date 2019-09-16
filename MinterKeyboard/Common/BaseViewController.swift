//
//  BaseViewController.swift
//  MinterWallet
//
//  Created by Alexey Sidorov on 02/04/2018.
//  Copyright © 2018 Minter. All rights reserved.
//

import UIKit
import SafariServices
import RxSwift
import Reachability
import RxAppState
import RxDataSources

struct SingleSection {
	var items: [Item]
}

extension SingleSection: SectionModelType {
	typealias Item = BaseCellItem
	init(original: SingleSection, items: [Item]) {
		self = original
		self.items = items
	}
}

protocol ControllerProtocol: class {
	associatedtype ViewModelType: ViewModelProtocol
	/// Configurates controller with specified ViewModelProtocol subclass
	///
	/// - Parameter viewModel: CPViewModel subclass instance to configure with
	func configure(with viewModel: ViewModelType)
	/// Factory function for view controller instatiation
	///
	/// - Parameter viewModel: View model object
	/// - Returns: View controller of concrete type
//	static func create(with viewModel: ViewModelType) -> UIViewController
}

class BaseViewController: UIViewController {

	var disposeBag = DisposeBag()

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		self.setNeedsStatusBarAppearanceUpdate()
	}
}
