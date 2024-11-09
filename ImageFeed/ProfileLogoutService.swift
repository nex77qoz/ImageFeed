import Foundation
import WebKit

// Добавляем расширение для уведомлений
extension Notification.Name {
    static let didLogout = Notification.Name("ProfileLogoutServiceDidLogout")
}

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        // 1. Удаляем OAuth2 токен
        OAuth2TokenStorage.shared.token = nil
        
        // 2. Очищаем куки
        cleanCookies()
        
        // 3. Сбрасываем данные в сервисах
        ProfileService.shared.resetProfile()
        ProfileImageService.shared.resetAvatarURL()
        ImagesListService.shared.resetPhotos()
        
        // 4. Отправляем уведомление о выходе из профиля
        NotificationCenter.default.post(name: .didLogout, object: nil)
    }
    
    private func cleanCookies() {
        // Удаляем все куки из HTTPCookieStorage
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        
        // Удаляем все данные из WKWebsiteDataStore
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
}
