import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    private let ShowAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: self.ShowAuthenticationScreenSegueIdentifier, sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            fatalError("Не удалось получить UIWindow")
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        
        // Добавляем плавную анимацию перехода
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
            window.rootViewController = tabBarController
        })
    }
    
    private func fetchProfile(_ token: String) {
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case .success(let profile):
                    // Запускаем загрузку URL аватарки
                    self.profileImageService.fetchProfileImageURL(username: profile.username) { profileImageResult in
                        switch profileImageResult {
                            case .success(let imageURL):
                                print("Ссылка на аватарку: \(imageURL)")
                            case .failure(let error):
                                print("Не удалось получить ссылку на аватарку: \(error)")
                        }
                        // Скрываем индикатор загрузки после завершения всех запросов
                        UIBlockingProgressHUD.dismiss()
                        // Переходим на главный экран
                        DispatchQueue.main.async {
                            self.switchToTabBarController()
                        }
                    }
                case .failure(let error):
                    print("Загрузка профиля завершилась с ошибкой: \(error)")
                                if let networkError = error as? NetworkError {
                                    print("Данные сетевой ошибки: \(networkError)")
                                }
                    UIBlockingProgressHUD.dismiss()
                    print("Текущий токен: \(token)")
                    // Показываем ошибку пользователю
                    self.showError(error)
                    // Если ошибка связана с токеном, выполняем logout
                    self.handleProfileError(error)
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
    
    private func handleProfileError(_ error: Error) {
        // Если ошибка связана с токеном, обнуляем токен
        oauth2TokenStorage.token = nil
        // Показываем экран авторизации
        performSegue(withIdentifier: ShowAuthenticationScreenSegueIdentifier, sender: nil)
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else { fatalError("Не получилось перейти на экран авторизации \(ShowAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) {
            guard let token = self.oauth2TokenStorage.token else { return }
            self.fetchProfile(token)
        }
    }
}
