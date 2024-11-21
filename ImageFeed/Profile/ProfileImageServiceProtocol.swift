import Foundation

protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    
    func fetchProfileImageURL(_ username: String, completion: @escaping (Result<String, Error>) -> Void)
}
