//
//  ViewController.swift
//  ImageFeed
//
//  Created by Максим Бабкин on 04.09.2024.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Private Properties
    private let imagesListService = ImagesListService()
        private var photos: [Photo] = []
        private var imageLoadQueue = DispatchQueue(label: "com.imageLoad.queue", attributes: .concurrent)
        
        private let showSingleImageSegueIdentifier = "ShowSingleImage"
        private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
            imagesListService.fetchPhotosNextPage()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateTableView),
                name: ImagesListService.didChangeNotification,
                object: nil
            )
        }
        
        @objc private func updateTableView() {
            let oldCount = photos.count
            photos = imagesListService.photos
            let newCount = photos.count
            if oldCount != newCount {
                tableView.performBatchUpdates {
                    let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
                    tableView.insertRows(at: indexPaths, with: .automatic)
                }
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == showSingleImageSegueIdentifier {
                guard
                    let viewController = segue.destination as? SingleImageViewController,
                    let indexPath = sender as? IndexPath
                else {
                    assertionFailure("Некорректный переход")
                    return
                }
                
                let photo = photos[indexPath.row]
                viewController.imageURL = photo.largeImageURL
            } else {
                super.prepare(for: segue, sender: sender)
            }
        }
    }

// MARK: - Extensions
extension ImagesListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return photos.count
     }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

         guard let imageListCell = tableView.dequeueReusableCell(
             withIdentifier: ImagesListCell.reuseIdentifier,
             for: indexPath
         ) as? ImagesListCell else {
             return UITableViewCell()
         }

         configCell(for: imageListCell, with: indexPath)
         return imageListCell
     }

     func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         if indexPath.row == photos.count - 1 {
             imagesListService.fetchPhotosNextPage()
         }
     }

     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
     }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         let photo = photos[indexPath.row]
         let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
         let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
         let scale = imageViewWidth / photo.size.width
         let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
         return cellHeight
     }
}
extension ImagesListViewController {
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        let isLiked = photo.isLiked
        let likeImageName = isLiked ? "Active" : "No Active"
        cell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        if let likeImage = UIImage(named: likeImageName)?.withRenderingMode(.alwaysOriginal) {
            cell.likeButton.setImage(likeImage, for: .normal)
        }
        
        if let url = URL(string: photo.thumbImageURL) {
            let placeholder = UIImage(named: "placeholder")
            cell.cellImage.kf.indicatorType = .activity
            cell.cellImage.kf.setImage(
                with: url,
                placeholder: placeholder,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            cell.cellImage.image = UIImage(named: "placeholder")
        }
    }
}

