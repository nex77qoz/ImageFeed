import Foundation
import WebKit

// MARK: - Notification Names

extension Notification.Name {
    static let didLogout = Notification.Name("ProfileLogoutServiceDidLogout")
}

// MARK: - Profile Logout Service

final class ProfileLogoutService {
    
    // MARK: - Singleton
    
    static let shared = ProfileLogoutService()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func logout() {
        OAuth2TokenStorage.shared.token = nil
        
        cleanCookies()
        
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetAvatarURL()
        ImagesListService.shared.resetPhotos()
        
        NotificationCenter.default.post(name: .didLogout, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
