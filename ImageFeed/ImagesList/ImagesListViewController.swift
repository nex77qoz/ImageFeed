import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let imagesListService = ImagesListService.shared
    private var photos: [Photo] = []
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    // Плейсхолдер изображение
    private let placeholderImage = UIImage(named: "placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        view.backgroundColor = .ypBlack
        imagesListService.fetchPhotosNextPage()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }
    
    @objc private func updateTableViewAnimated() {
        let oldCount = self.photos.count
        self.photos = self.imagesListService.photos
        let newCount = self.photos.count
        
        tableView.performBatchUpdates({
            if newCount > oldCount {
                let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } else if newCount < oldCount {
                let indexPaths = (newCount..<oldCount).map { IndexPath(row: $0, section: 0) }
                tableView.deleteRows(at: indexPaths, with: .automatic)
            } else {
                tableView.reloadData()
            }
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue")
                return
            }
            
            let photo = photos[indexPath.row]
            viewController.imageURL = photo.largeImageURL
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 2 {
            imagesListService.fetchPhotosNextPage()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let totalHorizontalInsets = imageInsets.left + imageInsets.right
        let imageViewWidth = tableView.bounds.width - totalHorizontalInsets
        let scale = imageViewWidth / photo.size.width
        let imageViewHeight = photo.size.height * scale
        let cellHeight = imageViewHeight + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        cell.setIsLiked(photo.isLiked)
        
        cell.cellImage.kf.indicatorType = .none  // Убираем индикатор загрузки
        
        // Запускаем анимацию градиента
        cell.addGradientAnimation()
        
        if let url = URL(string: photo.thumbImageURL) {
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]) { result in
                    DispatchQueue.main.async {
                        // Удаляем анимацию градиента
                        cell.removeGradientAnimation()
                        switch result {
                        case .success(_):
                            // Изображение успешно загружено
                            cell.cellImage.contentMode = .scaleAspectFill
                        case .failure(_):
                            // Ошибка загрузки, устанавливаем плейсхолдер
                            cell.cellImage.image = self.placeholderImage
                            cell.cellImage.contentMode = .center
                        }
                    }
                }
        } else {
            // Недействительный URL, удаляем анимацию и устанавливаем плейсхолдер
            cell.removeGradientAnimation()
            cell.cellImage.image = placeholderImage
            cell.cellImage.contentMode = .center
        }
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        let isLiked = !photo.isLiked
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: isLiked) { [weak self] (result: Result<Void, Error>) in
            guard let self = self else { return }
            switch result {
                case .success:
                    self.photos[indexPath.row].isLiked = isLiked
                    cell.setIsLiked(isLiked)
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    let alert = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    print("Ошибка установки лайка: \(error)")
            }
        }
    }
}
