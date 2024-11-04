//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 30.10.2024.
//

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
        
        // Встраивание в навигационные контроллеры
        let imagesNavController = UINavigationController(rootViewController: imagesListViewController)
        let profileNavController = UINavigationController(rootViewController: profileViewController)
        
        // Назначение контроллеров в TabBar
        viewControllers = [imagesNavController, profileNavController]
    }
}
