import XCTest
@testable import ImageFeed

final class ImagesListPresenterTests: XCTestCase {
    
    var presenter: ImagesListPresenter!
    var mockDelegate: MockImagesListPresenterDelegate!
    var mockImagesListService: MockImagesListService!
    
    override func setUp() {
        super.setUp()
        mockDelegate = MockImagesListPresenterDelegate()
        mockImagesListService = MockImagesListService()
        
        mockImagesListService.photos = createMockPhotos(count: 5)
        
        presenter = ImagesListPresenter(imagesListService: mockImagesListService)
        presenter.delegate = mockDelegate
    }
    
    override func tearDown() {
        presenter = nil
        mockDelegate = nil
        mockImagesListService = nil
        super.tearDown()
    }
    
    func testViewDidLoad() {
        // Given
        let expectFetchPhotos = expectation(description: "Fetch photos called")
        mockImagesListService.fetchPhotosNextPageCalled = {
            expectFetchPhotos.fulfill()
        }
        
        // When
        presenter.viewDidLoad()
        
        // Then
        waitForExpectations(timeout: 1.0)
    }
    
    func testTableViewNumberOfRowsInSection() {
        // Given
        let mockPhotos = createMockPhotos(count: 5)
        mockImagesListService.photos = mockPhotos
        
        // When
        let numberOfRows = presenter.tableViewNumberOfRowsInSection()
        
        // Then
        XCTAssertEqual(numberOfRows, mockPhotos.count, "Number of rows should match mock photos")
    }
    
    func testTableViewCellForRow() {
        // Given
        let mockPhotos = createMockPhotos(count: 3)
        mockImagesListService.photos = mockPhotos
        
        // When & Then
        XCTAssertTrue(mockPhotos.count > 0, "Mock photos should not be empty")
        
        XCTAssertNoThrow({ [self] in
            let (photo, placeholderImage) = presenter.tableViewCellForRow(at: IndexPath(row: 0, section: 0))
            XCTAssertEqual(photo.id, "photo0")
            XCTAssertNotNil(placeholderImage)
        }, "Should safely access first row")
    }
    
    func testTableViewCellWithMockImages() {
        // Given
        let mockPhotos = createMockPhotos(count: 5)
        mockImagesListService.photos = mockPhotos
        
        print("Presenter method implementation:")
        print("tableViewNumberOfRowsInSection: \(presenter.tableViewNumberOfRowsInSection())")
        print("getPhotos() count: \(presenter.getPhotos().count)")
        
        // When
        let numberOfRows = presenter.tableViewNumberOfRowsInSection()
        
        // Then
        XCTAssertEqual(numberOfRows, 5, "Number of rows should match mock photos")
    }
    
    private func createMockPhotos(count: Int) -> [Photo] {
        return (0..<count).map { index in
            let actualIndex = index % 20
            
            return Photo(
                id: "photo\(actualIndex)",
                size: CGSize(width: 1080, height: 1920),
                createdAt: Date(),
                welcomeDescription: "Mock Description \(actualIndex)",
                thumbImageURL: "Mock Images/\(actualIndex)",
                largeImageURL: "Mock Images/\(actualIndex)",
                isLiked: false
            )
        }
    }
}

// Mock
class MockImagesListPresenterDelegate: ImagesListPresenterDelegate {
    var updateTableViewAnimatedCalled: (() -> Void)?
    var showSingleImageViewControllerCalled: ((Photo) -> Void)?
    var showErrorAlertCalled: ((String) -> Void)?
    
    func updateTableViewAnimated() {
        updateTableViewAnimatedCalled?()
    }
    
    func showSingleImageViewController(with photo: Photo) {
        showSingleImageViewControllerCalled?(photo)
    }
    
    func showErrorAlert(with message: String) {
        showErrorAlertCalled?(message)
    }
}

class MockImagesListService: ImagesListServiceProtocol {
    private var _photos: [Photo] = []
    var fetchPhotosNextPageCalled: (() -> Void)?
    var changeLikeCalled: ((String, Bool, @escaping (Result<Void, Error>) -> Void) -> Void)?
    
    var photos: [Photo] {
        get { return _photos }
        set { _photos = newValue }
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled?()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled?(photoId, isLike, completion)
        completion(.success(()))
    }
}
