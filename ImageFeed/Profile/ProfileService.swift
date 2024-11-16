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
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService fetchProfile]: Ошибка - неправильный запрос")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    print("[ProfileService fetchProfile]: Успешно загружен профиль")
                    completion(.success(profileResult))
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
