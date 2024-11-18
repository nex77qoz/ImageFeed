import UIKit
import Kingfisher

// MARK: - ProfileViewController

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    // MARK: Properties

    var presenter: ProfileViewPresenterProtocol?

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let profileDescription = UILabel()

    private var animationLayers = [CAGradientLayer]()
    private var gradientLayersAdded = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileView()
        presenter?.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .didLogout,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didLogout, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !gradientLayersAdded {
            addGradientLayers()
            gradientLayersAdded = true
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: ProfileViewControllerProtocol

    func updateUI(with profile: Profile) {
        nameLabel.text = profile.name
        nicknameLabel.text = profile.loginName
        profileDescription.text = profile.bio

        removeGradientLayers(from: [nameLabel, nicknameLabel, profileDescription])
        presenter?.updateAvatar()
    }

    func updateAvatar(with url: URL) {
        imageView.kf.setImage(with: url, completionHandler: { [weak self] result in
            switch result {
            case .success(_):
                self?.removeGradientLayers(from: [self?.imageView].compactMap { $0 })
            case .failure(let error):
                print("Не удалось загрузить изображение: \(error)")
            }
        })
    }

    // MARK: Private Methods

    private func setupProfileView() {
        view.backgroundColor = .ypBlack
        setupImageView()
        setupNameLabel()
        setupNicknameLabel()
        setupProfileDescription()
        setupExitButton()
    }

    private func setupImageView() {
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

    private func setupNameLabel() {
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

    private func setupNicknameLabel() {
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

    private func setupProfileDescription() {
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

    private func setupExitButton() {
        guard let exitImage = UIImage(named: "Exit") else {
            fatalError("Не найдено изображение Exit")
        }
        let button = UIButton.systemButton(with: exitImage, target: self, action: #selector(didTapExitButton))

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

    private func addGradientLayers() {
        for view in [imageView, nameLabel, nicknameLabel, profileDescription] {
            addGradientLayer(to: view)
        }
    }

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

    private func removeGradientLayers(from views: [UIView]) {
        for view in views {
            if let index = animationLayers.firstIndex(where: { $0.superlayer == view.layer }) {
                let gradientLayer = animationLayers[index]
                gradientLayer.removeFromSuperlayer()
                animationLayers.remove(at: index)
            }
        }
    }

    // MARK: Actions

    @objc
    private func didTapExitButton() {
        let alertController = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        let yesAction = UIAlertAction(title: "Да", style: .destructive) { [weak self] _ in
            self?.presenter?.didTapLogoutButton()
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
            guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                fatalError("AuthViewController не найден в Storyboard")
            }
            authVC.modalPresentationStyle = .fullScreen
            self.present(authVC, animated: true)
        }
    }
}
