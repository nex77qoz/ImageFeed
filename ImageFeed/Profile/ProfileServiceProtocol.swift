import Foundation

protocol ProfileServiceProtocol {
    var profile: ProfileResult? { get }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void)
}
