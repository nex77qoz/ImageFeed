import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    
    func updateProfileDetails()
    func updateAvatar()
    func didTapLogoutButton()
    func viewDidLoad() 
}
