//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 04.11.2024.
//
import Foundation
import UIKit

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


struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage = 0
    private var isLoading = false
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()

    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        isLoading = true
        let nextPage = lastLoadedPage + 1

        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            print("Некорректный URL")
            isLoading = false
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        guard let url = urlComponents.url else {
            print("Не удалось получить URL из компонентов")
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
                print("Ошибка при загрузке фотографий: \(error)")
                self.isLoading = false
            }
        }
        task.resume()
    }
    
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
