import Foundation
import UIKit

final class ProfileBuilder {
    static func build() -> ProfileViewController {
        let profileService: ProfileServiceProtocol = ProfileService.shared
        let profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared
        let tokenStorage = OAuth2TokenStorage.shared
        let logoutService = ProfileLogoutService.shared
        
        let presenter = ProfilePresenter(
            profileService: profileService,
            profileImageService: profileImageService,
            tokenStorage: tokenStorage,
            logoutService: logoutService
        )
        
        let viewController = ProfileViewController()
        presenter.view = viewController
        viewController.presenter = presenter
        
        return viewController
    }
}
