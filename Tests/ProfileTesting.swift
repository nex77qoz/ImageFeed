@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    private struct ProfileServiceStub: ProfileServiceProtocol {
        var profile: ImageFeed.ProfileResult? = ProfileResult(
            username: "test",
            firstName: "test",
            lastName: "test",
            bio: "test"
        )
        
        func fetchProfile(_ token: String, completion: @escaping (Result<ImageFeed.ProfileResult, Error>) -> Void) {
            if let profile = profile {
                completion(.success(profile))
            }
        }
    }
    
    private struct ProfileImageServiceStub: ProfileImageServiceProtocol {
        var avatarURL: String? = "https://api.unsplash.com"
        
        func fetchProfileImageURL(_ username: String, completion: @escaping (Result<String, Error>) -> Void) {
            if let url = avatarURL {
                completion(.success(url))
            }
        }
    }
    
    func testProfileServiceStubReturnsExpectedData() {
        // given
        let profileServiceStub = ProfileServiceStub()
        let expectation = XCTestExpectation(description: "Fetch profile")
        
        // when
        var fetchedProfile: ProfileResult?
        profileServiceStub.fetchProfile("token") { result in
            if case .success(let profile) = result {
                fetchedProfile = profile
                expectation.fulfill()
            }
        }
        
        // Wait for the response
        wait(for: [expectation], timeout: 5)
        
        // then
        XCTAssertNotNil(fetchedProfile)
        XCTAssertEqual(fetchedProfile?.username, "test")
        XCTAssertEqual(fetchedProfile?.firstName, "test")
        XCTAssertEqual(fetchedProfile?.lastName, "test")
        XCTAssertEqual(fetchedProfile?.bio, "test")
    }
    
    func testProfileImageServiceStubReturnsExpectedData() {
        // given
        let profileImageServiceStub = ProfileImageServiceStub()
        
        // then
        XCTAssertNotNil(profileImageServiceStub.avatarURL)
        XCTAssertEqual(profileImageServiceStub.avatarURL, "https://api.unsplash.com")
        
        var fetchedAvatarURL: String?
        profileImageServiceStub.fetchProfileImageURL("username") { result in
            if case.success(let url) = result {
                fetchedAvatarURL = url
            }
        }
        XCTAssertNotNil(fetchedAvatarURL)
        XCTAssertEqual(fetchedAvatarURL, "https://api.unsplash.com")
    }
    
    func testUpdataProfileDetailsCalls() {
        // given
        let viewController = ProfileViewController()
        let spyPresenter = ProfileViewPresentSpy()
        viewController.presenter = spyPresenter
        spyPresenter.view = viewController
        
        // when
        viewController.viewDidLoad()
        
        // then
        XCTAssertTrue(spyPresenter.profileUpdated, "Profile should be updated when view loads")
    }
    
    func testViewControllerProfileDetailsCalls() {
        // given
        let updateUIExpectation = XCTestExpectation(description: "Update UI")
        let avatarUpdateExpectation = XCTestExpectation(description: "Update Avatar")
        let viewController = ProfileViewControllerSpy(updateUIExpectation: updateUIExpectation, avatarUpdateExpectation: avatarUpdateExpectation)
        let profileServiceStub = ProfileServiceStub()
        let profileImageServiceStub = ProfileImageServiceStub()
        let presenter = ProfilePresenter(profileService: profileServiceStub, profileImageService: profileImageServiceStub)
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.updateProfileDetails()
        
        // then
        wait(for: [updateUIExpectation, avatarUpdateExpectation], timeout: 10.0)
        XCTAssertTrue(viewController.updateUICalled, "updateUI should be called when profile details are updated")
        XCTAssertTrue(viewController.avatarUpdated, "Avatar should be updated when profile details are updated")
    }
}

// MARK: - Spies
final class ProfileViewPresentSpy: ProfileViewPresenterProtocol {
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    var avatarUpdated = false
    var profileUpdated = false
    var viewIsLoaded = false
    var logoutButtonTapped = false
    
    func updateProfileDetails() {
        profileUpdated = true
    }
    
    func updateAvatar() {
        avatarUpdated = true
    }
    
    func viewDidLoad() {
        viewIsLoaded = true
        updateProfileDetails()
    }
    
    func didTapLogoutButton() {
        logoutButtonTapped = true
    }
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?
    var updateUICalled = false
    var avatarUpdated = false
    private let updateUIExpectation: XCTestExpectation?
    private let avatarUpdateExpectation: XCTestExpectation?
    
    init(updateUIExpectation: XCTestExpectation? = nil, avatarUpdateExpectation: XCTestExpectation? = nil) {
        self.updateUIExpectation = updateUIExpectation
        self.avatarUpdateExpectation = avatarUpdateExpectation
    }
    
    func updateUI(with profile: Profile) {
        updateUICalled = true
        updateUIExpectation?.fulfill()
    }
    
    func updateAvatar(with url: URL) {
        avatarUpdated = true
        avatarUpdateExpectation?.fulfill()
    }
}
