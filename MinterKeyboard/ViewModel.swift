//
//  ViewModel.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 16/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation
import RxSwift

class ViewModel {
	
	// MARK: -
	
	var mnemonicsSubject = PublishSubject<String>()
	
	// MARK: -

	struct Input {
		
	}
	
	struct Output {
		var mnemonics: Observable<String>
	}

	var input: Input!
	var output: Output!

	// MARK: -
	
	init() {
		self.input = Input()
		self.output = Output(mnemonics: mnemonicsSubject.asObservable())
	}

}
