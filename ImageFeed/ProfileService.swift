import Foundation

final class ProfileService {
    
    // MARK: - Properties
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var profile: Profile?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService fetchProfile]: Ошибка - неправильный запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                
                switch result {
                    case .success(let profileResult):
                        let profile = Profile(profileResult: profileResult)
                        self.profile = profile
                        completion(.success(profile))
                    case .failure(let error):
                        print("[ProfileService fetchProfile]: Ошибка - \(error.localizedDescription)")
                        completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    func resetProfile() {
        self.profile = nil
    }
    
    // MARK: - Private Methods
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Некорректный URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

// MARK: - Models

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
    
    init(profileResult: ProfileResult) {
        self.username = profileResult.username
        let firstName = profileResult.firstName
        let lastName = profileResult.lastName ?? ""
        self.name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        self.loginName = "@\(profileResult.username)"
        self.bio = profileResult.bio
    }
}
