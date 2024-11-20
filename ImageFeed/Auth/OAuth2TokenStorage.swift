//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 01.10.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private enum Keys {
        static let bearerToken = "bearerToken"
    }
    
    private init() {}
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.bearerToken)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.bearerToken)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Keys.bearerToken)
            }
        }
    }
}
