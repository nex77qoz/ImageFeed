import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    private let imageView = UIImageView()
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        showSplashScreen()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthorizationStatus()
    }

    private func checkAuthorizationStatus() {
        if let token = oauth2TokenStorage.token {
            UIBlockingProgressHUD.show()
            fetchProfile(token)
        } else {
            showAuthViewController()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Рисуем интерфейс
    private func showSplashScreen() {
        view.backgroundColor = .ypBlack
        imageView.image = UIImage(named: "Image")
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 75),
            imageView.heightAnchor.constraint(equalToConstant: 77)
        ])
    }

    // MARK: - Функции
    private func showAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            fatalError("Не удалось инициализировать AuthViewController из Storyboard")
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? TabBarController else {
            fatalError("Не удалось инициализировать TabBarController из Storyboard")
        }
        
        // Плавный переход с анимацией
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("Не удалось получить UIWindow")
        }
        window.rootViewController = tabBarController
    }

    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else {
                UIBlockingProgressHUD.dismiss()
                return
            }

            switch result {
                case .success(let profile):
                    // Запускаем загрузку URL аватарки
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { [weak self] profileImageResult in
                        guard let self = self else {
                            UIBlockingProgressHUD.dismiss()
                            return
                        }
                        switch profileImageResult {
                            case .success(let imageURL):
                                print("Ссылка на аватарку: \(imageURL)")
                            case .failure(let error):
                                print("[SplashViewController fetchProfile]: Не удалось получить ссылку на аватарку: \(error)")
                        }
                        // Скрываем индикатор загрузки после завершения всех запросов
                        UIBlockingProgressHUD.dismiss()
                        // Переходим на главный экран
                        DispatchQueue.main.async {
                            self.switchToTabBarController()
                        }
                    }
                case .failure(let error):
                    print("[SplashViewController fetchProfile]: Загрузка профиля завершилась с ошибкой: \(error)")
                    UIBlockingProgressHUD.dismiss()
                    self.showError(error)
            }
        }
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить профиль: \(error.localizedDescription)",
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) {
            guard let token = self.oauth2TokenStorage.token else { return }
            UIBlockingProgressHUD.show()
            self.fetchProfile(token)
        }
    }
}
