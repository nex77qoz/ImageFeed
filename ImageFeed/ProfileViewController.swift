//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 08.09.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let profileDescription = UILabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showProfileImage()
        showName()
        showNicknameLabel()
        showProfileDescription()
        showExitButton()
        updateProfileDetails()
        view.backgroundColor = .ypBlack
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
    }
    private func updateAvatar() {
        guard
            let avatarURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: avatarURL)
                else { return }
        imageView.kf.setImage(with: url)
    }
    
    private func showProfileImage() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
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
        nameLabel.text = ""
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
        nicknameLabel.text = ""
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
        profileDescription.text = ""
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
        guard let exitImage = UIImage(named: "Exit") else {
            fatalError("Не найдено изображение Exit")
        }
        let button = UIButton.systemButton(with: exitImage, target: self, action: #selector(Self.didTapExitButton))

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
        print("Нажата кнопка выхода")
    }
    
    // MARK: - Получение данных профиля
    
    private func updateProfileDetails() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Токен недоступен")
            return
        }
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.updateUI(with: profile)
            case .failure(let error):
                print("Ошибка получения профиля: \(error)")
            }
        }
    }
    
    private func updateUI(with profile: Profile) {
        nameLabel.text = profile.name
        nicknameLabel.text = profile.loginName
        profileDescription.text = profile.bio
        updateAvatar()
    }
}
