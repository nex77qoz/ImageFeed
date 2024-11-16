import Foundation

final class ProfilePresenter: ProfileViewPresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let tokenStorage: OAuth2TokenStorage
    private let logoutService: ProfileLogoutService
    
    private(set) var profile: Profile?
    
    init(
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
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
        // For testing purposes, allow empty token
        let token = tokenStorage.token ?? ""
        
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let profile = Profile(profileResult: profileResult)
                self.profile = profile
                self.view?.updateUI(with: profile)
                
                // Fetch avatar URL after profile is loaded
                self.fetchProfileImageURL(profile.username)
                
            case .failure(let error):
                print("[ProfilePresenter updateProfileDetails]: Ошибка получения профиля: \(error)")
            }
        }
    }
    
    func updateAvatar() {
        guard let username = profile?.username else { return }
        fetchProfileImageURL(username)
    }
    
    private func fetchProfileImageURL(_ username: String) {
        profileImageService.fetchProfileImageURL(username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let imageURLString):
                guard let imageURL = URL(string: imageURLString) else { return }
                self.view?.updateAvatar(with: imageURL)
                
            case .failure(let error):
                print("[ProfilePresenter]: Failed to fetch avatar URL with error: \(error)")
            }
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
        if let url = URL(string: profileImageService.avatarURL ?? "") {
            view?.updateAvatar(with: url)
        }
    }
}
