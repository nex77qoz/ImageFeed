import Foundation

// MARK: - Profile Image Service

final class ProfileImageService: ProfileImageServiceProtocol {
    
    // MARK: - Singleton
    
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Properties
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?
    
    // MARK: - Fetch Profile Image URL
    
    func fetchProfileImageURL(_ username: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastUsername == username, let existingURL = avatarURL {
            completion(.success(existingURL))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard let request = makeRequest(username: username) else {
            print("[ProfileImageService fetchProfileImageURL]: Ошибка - неправильный запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                self.lastUsername = nil
                
                switch result {
                    case .success(let userResult):
                        let avatarURL = userResult.profileImage.small
                        self.avatarURL = avatarURL
                        completion(.success(avatarURL))
                        NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": avatarURL]
                        )
                    case .failure(let error):
                        print("[ProfileImageService fetchProfileImageURL]: Ошибка - \(error.localizedDescription)")
                        completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Reset Avatar URL
    
    func resetAvatarURL() {
        self.avatarURL = nil
        NotificationCenter.default.post(name: ProfileImageService.didChangeNotification, object: nil)
    }
    
    // MARK: - Make Request
    
    private func makeRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            return nil
        }
        return request
    }
}

// MARK: - User Result

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
    
    // MARK: - Profile Image
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
}
