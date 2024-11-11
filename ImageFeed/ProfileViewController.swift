import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    // MARK: - Properties
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let profileDescription = UILabel()
    private var profileImageServiceObserver: NSObjectProtocol?
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    private var animationLayers = [CAGradientLayer]()
    private var gradientLayersAdded = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileView()
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification, object: nil, queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .didLogout,
            object: nil
        )
        
        updateProfileDetails()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didLogout, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !gradientLayersAdded {
            addGradientLayer(to: imageView)
            addGradientLayer(to: nameLabel)
            addGradientLayer(to: nicknameLabel)
            addGradientLayer(to: profileDescription)
            gradientLayersAdded = true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - UI Setup
    
    private func setupProfileView() {
        showProfileImage()
        showName()
        showNicknameLabel()
        showProfileDescription()
        showExitButton()
        view.backgroundColor = .ypBlack
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
    
    // MARK: - Actions

    @objc
    private func didTapExitButton() {
        let alertController = UIAlertController(title: "Пока, пока!", message: "Уверены, что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            ProfileLogoutService.shared.logout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        
        present(alertController, animated: true)
    }
    
    @objc
    private func handleLogout() {
        print("Выход из системы")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else { fatalError("AuthViewController не найден в Storyboard") }
            authVC.modalPresentationStyle = .fullScreen
            self.present(authVC, animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func addGradientLayer(to view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        if view == imageView {
            gradient.cornerRadius = view.layer.cornerRadius
            gradient.masksToBounds = true
        }
        view.layer.addSublayer(gradient)
        animationLayers.append(gradient)
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    private func updateAvatar() {
        if let url = URL(string: ProfileImageService.shared.avatarURL ?? "") {
            imageView.kf.setImage(with: url, completionHandler: { [weak self] result in
                switch result {
                case .success(_):
                    if let index = self?.animationLayers.firstIndex(where: { $0.superlayer == self?.imageView.layer }) {
                        let gradientLayer = self?.animationLayers[index]
                        gradientLayer?.removeFromSuperlayer()
                        self?.animationLayers.remove(at: index)
                    }
                case .failure(let error):
                    print("Не удалось загрузить изображение: \(error)")
                }
            })
        }
    }
    
    private func updateProfileDetails() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileViewController updateProfileDetails]: Токен недоступен")
            return
        }
        
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.updateUI(with: profile)
            case .failure(let error):
                print("[ProfileViewController updateProfileDetails]: Ошибка получения профиля: \(error)")
            }
        }
    }
    
    private func updateUI(with profile: Profile) {
        nameLabel.text = profile.name
        nicknameLabel.text = profile.loginName
        profileDescription.text = profile.bio
        
        for label in [nameLabel, nicknameLabel, profileDescription] {
            if let index = animationLayers.firstIndex(where: { $0.superlayer == label.layer }) {
                let gradientLayer = animationLayers[index]
                gradientLayer.removeFromSuperlayer()
                animationLayers.remove(at: index)
            }
        }
        
        updateAvatar()
    }
}
