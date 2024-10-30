//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 01.10.2024.
//

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private enum Keys: String {
        case bearerToken
    }
    
    private init() {}
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.bearerToken.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.bearerToken.rawValue)
        }
    }
}
