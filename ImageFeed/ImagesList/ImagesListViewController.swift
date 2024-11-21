import UIKit
import Kingfisher

// MARK: - ImagesListViewController

final class ImagesListViewController: UIViewController {
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    private let presenter = ImagesListPresenter()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypBlack
        view.backgroundColor = .ypBlack
        
        presenter.delegate = self
        presenter.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCell(_:)),
            name: ImagesListService.didChangeNotification,
            object: presenter
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func updateCell(_ notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell {
                let photo = presenter.getPhotos()[index]
                cell.setIsLiked(photo.isLiked)
            }
        }
    }
    
    // MARK: Segue Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSingleImage" {
            guard
                let singleImageVC = segue.destination as? SingleImageViewController,
                let photo = sender as? Photo
            else {
                assertionFailure("Не получилось перейти на SingleImageViewController")
                return
            }
            singleImageVC.photo = photo
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.tableViewNumberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let imageListCell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        let (photo, placeholderImage) = presenter.tableViewCellForRow(at: indexPath)
        imageListCell.configCell(for: photo, with: placeholderImage)
        return imageListCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter.tableViewWillDisplayCell(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.tableViewDidSelectRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter.tableViewHeightForRowAt(indexPath: indexPath)
    }
}

// MARK: - ImagesListPresenterDelegate

extension ImagesListViewController: ImagesListPresenterDelegate {
    func updateTableViewAnimated() {
        let oldCount = presenter.getPhotos().count
        let newCount = presenter.getPhotos().count
        
        tableView.reloadData()
        
        if newCount > oldCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func showSingleImageViewController(with photo: Photo) {
        performSegue(withIdentifier: "ShowSingleImage", sender: photo)
    }
    
    func showErrorAlert(with message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.imageListCellDidTapLike(at: indexPath)
    }
}
