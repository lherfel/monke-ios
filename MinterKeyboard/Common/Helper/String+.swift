//
//  String+.swift
//  MinterKeyboard
//
//  Created by Alexey Sidorov on 22/06/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//

import Foundation

extension String {
	
	static let addressRegexp = "Mx[a-zA-Z0-9]{40}"

	func isValidAddress() -> Bool {
		let addressTest = NSPredicate(format:"SELF MATCHES %@", "^Mx[a-zA-Z0-9]{40}$")
		return addressTest.evaluate(with: self)
	}

	func isValidPublicKey() -> Bool {
		let publicKeyTest = NSPredicate(format:"SELF MATCHES %@", "^Mp[a-fA-F0-9]{64}$")
		return publicKeyTest.evaluate(with: self)
	}

}

extension String {
	func regex (pattern: String) -> [String] {
		do {
			let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0))
			let nsstr = self as NSString
			let all = NSRange(location: 0, length: nsstr.length)
			var matches : [String] = [String]()
			regex.enumerateMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: all) {
				(result : NSTextCheckingResult?, _, _) in
				if let r = result {
					let result = nsstr.substring(with: r.range) as String
					matches.append(result)
				}
			}
			return matches
		} catch {
			return [String]()
		}
	}
}
