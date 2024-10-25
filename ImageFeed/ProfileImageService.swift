//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 24.10.2024.
//


import Foundation
import UIKit
import WebKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastUsername: String?
    private(set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastUsername == username {
            return
        }
        task?.cancel()
        lastUsername = username
        
        guard let request = makeRequest(username: username) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                self.lastUsername = nil
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let avatarURL = userResult.profileImage.small
                    self.avatarURL = avatarURL
                    completion(.success(avatarURL))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
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

struct UserResult: Codable {
    let profileImage: ProfileImage
    
    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }
}
