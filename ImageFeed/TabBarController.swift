import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        let profileViewController = ProfileViewController()
        
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil)
        
        let imagesNavController = UINavigationController(rootViewController: imagesListViewController)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .ypBlack
        
        imagesNavController.navigationBar.standardAppearance = navigationBarAppearance
        imagesNavController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        profileNavController.navigationBar.standardAppearance = navigationBarAppearance
        profileNavController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        imagesNavController.navigationBar.tintColor = .white
        profileNavController.navigationBar.tintColor = .white
        
        tabBar.backgroundColor = .ypBlack
        
        viewControllers = [imagesNavController, profileNavController]
    }
}
