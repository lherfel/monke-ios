//
//  AuthManager.swift
//  MinterKeyboard
//
//  Created by Freeeon on 15/10/2019.
//  Copyright © 2019 Sidorov. All rights reserved.
//


import LocalAuthentication

extension Int {
  internal func toEnum<Enum: RawRepresentable>() -> Enum? where Enum.RawValue == Int {
    return Enum(rawValue: self)
  }
}

public enum TouchIDError: Error, Equatable {
  case undeterminedState
  case unknownError(NSError)
  
  // LAError cases
  case appCancel
  case authenticationFailed
  case invalidContext
  case passcodeNotSet
  case systemCancel
  case touchIDLockout
  case touchIDNotAvailable
  case touchIDNotEnrolled
  case userCancel
  case userFallback
	case notInteractive
  
  internal static func createError(_ error: NSError?) -> TouchIDError {
    guard let tidError = error else {
      return TouchIDError.undeterminedState
    }
    
    guard let type: LAError.Code = tidError.code.toEnum() else {
      return TouchIDError.unknownError(tidError)
    }
    
    switch type {
    case .appCancel:
      return .appCancel
    case .authenticationFailed:
      return .authenticationFailed
    case .invalidContext:
      return .invalidContext
    case .passcodeNotSet:
      return .passcodeNotSet
    case .systemCancel:
      return .systemCancel
    case .touchIDLockout:
      return .touchIDLockout
    case .touchIDNotAvailable:
      return .touchIDNotAvailable
    case .touchIDNotEnrolled:
      return .touchIDNotEnrolled
    case .userCancel:
			return .userCancel
    case .userFallback:
			return .userFallback
		case .notInteractive:
			return .notInteractive
		@unknown default:
			return .undeterminedState
		}
  }
}

public enum TouchIDResponse: Equatable {
  case success
  case error(TouchIDError)
}

public typealias TouchIDPresenterCallback = (TouchIDResponse) -> Void

class AuthManager {
	
	static let shared = AuthManager()

  public var hardwareSupportsTouchID: TouchIDResponse {
    let response = evaluateTouchIDPolicy
    guard response != TouchIDResponse.error(.touchIDNotAvailable) else {
      return response
    }
    return .success
  }
  
  public var isTouchIDEnabled: TouchIDResponse {
    return evaluateTouchIDPolicy
  }
  
  fileprivate var evaluateTouchIDPolicy: TouchIDResponse {
    let context = LAContext()
    var error: NSError?
    guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
      return TouchIDResponse.error(TouchIDError.createError(error))
    }
    return TouchIDResponse.success
  }
  
  public func presentTouchID(_ reason: String, fallbackTitle: String, callback: @escaping TouchIDPresenterCallback) {
    let context = LAContext()
    context.localizedFallbackTitle = fallbackTitle
    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { _, error in
      guard error == nil else {
        DispatchQueue.main.async(execute: {
          callback(.error(TouchIDError.createError(error as NSError?)))
        })
        return
      }
      DispatchQueue.main.async(execute: {
        callback(.success)
      })
    }
  }

}
