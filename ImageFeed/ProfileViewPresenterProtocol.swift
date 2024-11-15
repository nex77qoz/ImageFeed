import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profile: Profile? { get }
    
    func viewDidLoad()
    func didTapLogoutButton()
    func updateProfileDetails()
    func updateAvatar()
}
