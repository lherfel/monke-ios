//
//  SetupViewModel.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 06/07/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import RxSwift

class SetupViewModel {

	func isKeyboardEnabled() -> Bool {
		guard let keyboards = UserDefaults.standard.object(forKey: "AppleKeyboards") as? [String] else {
			return false
		}
		return keyboards.contains("SID.monke.mobilekeyboard")
	}

}
