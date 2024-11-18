import UIKit

// MARK: - ImagesListPresenterDelegate

protocol ImagesListPresenterDelegate: AnyObject {
    func updateTableViewAnimated()
    func showSingleImageViewController(with photo: Photo)
    func showErrorAlert(with message: String)
}

// MARK: - ImagesListPresenter

class ImagesListPresenter {
    // MARK: Properties
    
    weak var delegate: ImagesListPresenterDelegate?
    private let imagesListService: ImagesListServiceProtocol
    
    // MARK: Lifecycle
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    // MARK: Private Properties
    
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    // MARK: Placeholder Image
    
    private let placeholderImage = UIImage(named: "placeholder")
    
    // MARK: Public Methods
    
    func getPhotos() -> [Photo] {
        return imagesListService.photos
    }
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    // MARK: Notification Handling
    
    @objc private func updateTableViewAnimated() {
        let oldCount = self.photos.count
        self.photos = self.imagesListService.photos
        let newCount = self.photos.count
        
        DispatchQueue.main.async {
            if oldCount != newCount {
                self.delegate?.updateTableViewAnimated()
            }
        }
    }
    
    // MARK: Segue Handling
    
    func prepareForSegue(withIdentifier identifier: String, sender: Any?) {
        if identifier == showSingleImageSegueIdentifier {
            guard let photo = sender as? Photo else {
                assertionFailure("Invalid sender type for ShowSingleImage segue")
                return
            }
            
            delegate?.showSingleImageViewController(with: photo)
        }
    }
    
    // MARK: Table View Data Source
    
    func tableViewNumberOfRowsInSection() -> Int {
        return imagesListService.photos.count
    }
    
    func tableViewCellForRow(at indexPath: IndexPath) -> (Photo, UIImage?) {
        let photo = photos[indexPath.row]
        return (photo, placeholderImage)
    }
    
    func tableViewWillDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 2 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableViewDidSelectRowAt(indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        delegate?.showSingleImageViewController(with: photo)
    }
    
    func tableViewHeightForRowAt(indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let totalHorizontalInsets = imageInsets.left + imageInsets.right
        let imageViewWidth = UIScreen.main.bounds.width - totalHorizontalInsets
        let scale = imageViewWidth / photo.size.width
        let imageViewHeight = photo.size.height * scale
        let cellHeight = imageViewHeight + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    // MARK: Cell Actions
    
    func imageListCellDidTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let isLiked = !photo.isLiked
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: isLiked) { [weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.photos[indexPath.row].isLiked = isLiked
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["index": indexPath.row]
                    )
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    self.delegate?.showErrorAlert(with: error.localizedDescription)
                    print("Ошибка установки лайка: \(error)")
                }
            }
        }
    }
}
