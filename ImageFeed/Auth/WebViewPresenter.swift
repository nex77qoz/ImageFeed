import Foundation

// MARK: - Constants

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: - Protocols

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ newValue: Double)
    func code(from url: URL) -> String?
}

// MARK: - Presenter

final class WebViewPresenter: WebViewPresenterProtocol {
    // MARK: Properties
    
    weak var view: WebViewViewControllerProtocol?
    var authHelper: AuthHelperProtocol
    
    // MARK: Initialization
    
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    
    // MARK: Lifecycle
    
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        
        view?.load(request: request)
        didUpdateProgressValue(0)
    }
    
    // MARK: Progress Handling
    
    func didUpdateProgressValue(_ newValue: Double) {
        let newProgressValue = Float(newValue)
        view?.setProgressValue(newProgressValue)
        
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    // MARK: Helper Functions
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    // MARK: Code Extraction
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
