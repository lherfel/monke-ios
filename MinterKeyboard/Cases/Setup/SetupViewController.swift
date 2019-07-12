//
//  Setup.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 06/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxAppState

class SetupViewController: BaseViewController {

	var viewModel = SetupViewModel()

	// MARK: -

	@IBOutlet weak var getStartedButton: UIButton!

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()

		getStartedButton.rx.tap.subscribe(onNext: { (_) in
			self.openAppSettings()
		}).disposed(by: disposeBag)

//		if viewModel.isKeyboardEnabled() {
//			DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//				self.performSegue(withIdentifier: "showApp", sender: self)
//			}
//		}

		UIApplication.shared.rx.applicationWillEnterForeground.subscribe(onNext: { (appstore) in
			if RootViewController().isKeyboardEnabled() {
				self.navigationController?.setViewControllers([RootViewController().homeVC], animated: false)
			}
		}).disposed(by: disposeBag)

	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func openAppSettings() {
		var responder: UIResponder? = self
		var sharedApplication: UIResponder?
		while responder != nil {
			if let application = responder as? UIApplication {
				sharedApplication = application
				break
			}
			responder = responder?.next
		}

		guard let application = sharedApplication else { return }

		if #available(iOS 11.0, *) {
			application.perform(#selector(UIApplication.openURL(_:)), with: URL(string: UIApplication.openSettingsURLString))
		} else {
//			if #available(iOS 10.0, *) {
				application.perform(#selector(UIApplication.openURL(_:)),
														with: URL(string: "App-Prefs:root=General&path=Keyboard/KEYBOARDS"))
//			} else {
//				application.perform("openURL:",
//														with: URL(string: "prefs:root=General&path=Keyboard/KEYBOARDS"))
//			}
		}
	}

}
