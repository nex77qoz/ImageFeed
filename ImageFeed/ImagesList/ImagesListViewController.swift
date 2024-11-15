import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let presenter = ImagesListPresenter()
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
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
    }
    
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

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter.imageListCellDidTapLike(at: indexPath)
    }
}
