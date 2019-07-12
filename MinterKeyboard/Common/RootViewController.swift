//
//  RootViewController.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 07/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAppState

class RootViewController: UIViewController {

	var disposeBag = DisposeBag()

	// MARK: -

	let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController")
	let setupVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SetupViewController")

	override func viewDidLoad() {
		super.viewDidLoad()

		UIApplication.shared.rx.didOpenApp.asDriver(onErrorJustReturn: ()).drive(onNext: { [weak self] (_) in
			if self?.isKeyboardEnabled() ?? false {
				self?.navigationController?.setViewControllers([self!.homeVC], animated: false)
			} else {
				self?.navigationController?.setViewControllers([self!.setupVC], animated: false)
			}
		}).disposed(by: disposeBag)

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	// MARK: -

	func isKeyboardEnabled() -> Bool {
		guard let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] else {
			return false
		}
		return keyboards.contains("SID.monke.mobilekeyboard")
	}

}
