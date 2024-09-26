//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 08.09.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let profileDescription = UILabel()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        showProfileImage()
        showName()
        showNicknameLabel()
        showProfileDescription()
        showExitButton()
        
    }
    
    private func showProfileImage() {
        let profileImage = UIImage(named: "profileImage")
        imageView.image = profileImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func showName() {
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .ypWhite
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func showNicknameLabel() {
        nicknameLabel.text = "@ekaterina_nov"
        nicknameLabel.textColor = .ypGray
        nicknameLabel.font = .systemFont(ofSize: 13, weight: .regular)
        nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nicknameLabel)
        
        NSLayoutConstraint.activate([
            nicknameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nicknameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
    
    private func showProfileDescription() {
        profileDescription.text = "Hello, World!"
        profileDescription.textColor = .ypWhite
        profileDescription.font = .systemFont(ofSize: 13, weight: .regular)
        profileDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileDescription)
        
        NSLayoutConstraint.activate([
            profileDescription.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            profileDescription.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            profileDescription.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
            ])
    }
    
    private func showExitButton() {
        let button = UIButton.systemButton(with: UIImage(named: "Exit")!, target: self, action: #selector(Self.didTapExitButton))
        button.tintColor = .ypRed
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(equalToConstant: 24),
            button.widthAnchor.constraint(equalToConstant: 24),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
    }
    
    @objc
    private func didTapExitButton() {
        print("Exit button tapped")
    }
    
}

