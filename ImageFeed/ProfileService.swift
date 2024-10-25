import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    private (set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("Некорректный запрос профиля")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.task = nil
                
                if let error = error {
                    print("Ошибка при запросе профиля: \(error)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    print("Нет данных в ответе")
                    completion(.failure(NSError(domain: "ProfileService", code: -1, userInfo: nil)))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let profileResult = try decoder.decode(ProfileResult.self, from: data)
                    let profile = Profile(profileResult: profileResult)
                    self?.profile = profile
                    completion(.success(profile))
                } catch {
                    print("Ошибка декодирования профиля: \(error)")
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
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

// MARK: - Модели

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String?
    let bio: String?
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
