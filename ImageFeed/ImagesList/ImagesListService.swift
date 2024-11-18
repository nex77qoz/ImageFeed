import Foundation
import UIKit

// MARK: - Models

struct PhotoResult: Decodable {
    let id: String
    let createdAt: String?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

// MARK: - Photo Model

class Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String?
    var isLiked: Bool
    
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.largeImageURL = largeImageURL
        self.isLiked = isLiked
    }
}

// MARK: - Services

protocol ImagesListServiceProtocol {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

// MARK: - ImagesListService

final class ImagesListService: ImagesListServiceProtocol {
    // MARK: - Singleton
    
    internal static var shared = ImagesListService()
    
    // MARK: - Notifications
    
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    // MARK: - Properties
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private var isLoading = false
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    // MARK: - Initializer
    
    private init() {}
    
    // MARK: - Public Methods
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        let nextPage = lastLoadedPage + 1
        
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            print("Неправильный URL")
            isLoading = false
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else {
            print("Не получилось собрать URL из urlComponents")
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Токен недоступен")
            isLoading = false
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map { self.convert($0) }
                    DispatchQueue.main.async {
                        self.photos.append(contentsOf: newPhotos)
                        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                        self.lastLoadedPage = nextPage
                        self.isLoading = false
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        print("Ошибка загрузки фотографий: \(error)")
                        self.isLoading = false
                    }
            }
        }
        self.task = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            completion(.failure(NetworkError.noData))
            return
        }
        
        let method = isLike ? "POST" : "DELETE"
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(for: request) { result in
            switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func resetPhotos() {
        self.photos = []
        self.lastLoadedPage = 0
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
    }
    
    // MARK: - Private Methods
    
    private func convert(_ photoResult: PhotoResult) -> Photo {
        let id = photoResult.id
        let width = CGFloat(photoResult.width)
        let height = CGFloat(photoResult.height)
        let size = CGSize(width: width, height: height)
        let createdAt = photoResult.createdAt.flatMap { dateFormatter.date(from: $0) }
        let description = photoResult.description
        let thumbImageURL = photoResult.urls.regular
        let largeImageURL = photoResult.urls.full
        let isLiked = photoResult.likedByUser
        return Photo(
            id: id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: description,
            thumbImageURL: thumbImageURL,
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}
