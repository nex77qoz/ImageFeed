import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupNavigationBarAppearance()
        setupTabBarAppearance()
    }
    
    // MARK: - Private Methods
    
    private func setupViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        
        // Используем билдер вместо прямого создания
        let profileViewController = ProfileBuilder.build()
        
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
        
        viewControllers = [imagesNavController, profileNavController]
    }
    
    private func setupNavigationBarAppearance() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .ypBlack
        
        guard let viewControllers = viewControllers else { return }
        
        for navController in viewControllers {
            if let nav = navController as? UINavigationController {
                nav.navigationBar.standardAppearance = navigationBarAppearance
                nav.navigationBar.scrollEdgeAppearance = navigationBarAppearance
                nav.navigationBar.tintColor = .white
            }
        }
    }
    
    private func setupTabBarAppearance() {
        tabBar.backgroundColor = .ypBlack
    }
}
