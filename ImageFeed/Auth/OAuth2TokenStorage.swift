import Foundation
import SwiftKeychainWrapper

// MARK: - OAuth2TokenStorage

final class OAuth2TokenStorage {
    // MARK: Shared Instance
    
    static let shared = OAuth2TokenStorage()
    
    // MARK: Private Keys
    
    private enum Keys {
        static let bearerToken = "bearerToken"
    }
    
    // MARK: Initialization
    
    private init() {}
    
    // MARK: Token Storage
    
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
