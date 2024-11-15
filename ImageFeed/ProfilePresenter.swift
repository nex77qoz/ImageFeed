import Foundation

final class ProfilePresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let tokenStorage: OAuth2TokenStorage
    private let logoutService: ProfileLogoutService
    
    private(set) var profile: Profile?
    
    init(
        profileService: ProfileService = .shared,
        profileImageService: ProfileImageService = .shared,
        tokenStorage: OAuth2TokenStorage = .shared,
        logoutService: ProfileLogoutService = .shared
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.tokenStorage = tokenStorage
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        updateProfileDetails()
        setupProfileImageObserver()
    }
    
    func didTapLogoutButton() {
        logoutService.logout()
    }
    
    func updateProfileDetails() {
        guard let token = tokenStorage.token else {
            print("[ProfilePresenter updateProfileDetails]: Токен недоступен")
            return
        }
        
        profileService.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profile = profile
                self?.view?.updateUI(with: profile)
            case .failure(let error):
                print("[ProfilePresenter updateProfileDetails]: Ошибка получения профиля: \(error)")
            }
        }
    }
    
    func updateAvatar() {
        if let url = URL(string: profileImageService.avatarURL ?? "") {
            view?.updateAvatar(with: url)
        }
    }
    
    private func setupProfileImageObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleProfileImageUpdate),
            name: ProfileImageService.didChangeNotification,
            object: nil
        )
    }
    
    @objc
    private func handleProfileImageUpdate() {
        updateAvatar()
    }
}
