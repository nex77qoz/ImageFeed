import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    
    func updateUI(with profile: Profile)
    func updateAvatar(with url: URL)
}
