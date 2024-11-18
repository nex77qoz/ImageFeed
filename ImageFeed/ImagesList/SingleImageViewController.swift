import UIKit
import Kingfisher
import ProgressHUD

// MARK: - SingleImageViewController

final class SingleImageViewController: UIViewController {

    // MARK: Properties

    var imageURL: String? {
        didSet {
            guard isViewLoaded else { return }
            loadImage()
        }
    }

    var photo: Photo? {
        didSet {
            guard isViewLoaded, let photo = photo else { return }
            imageURL = photo.largeImageURL
        }
    }

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!

    private var hasAdjustedImageView = false

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustImageViewIfNecessary()
    }

    // MARK: Setup

    private func setupView() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        setupScrollView()
    }

    private func setupScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: Image Loading

    private func loadImage() {
        imageView.image = nil

        guard let photo = photo, let imageURLString = photo.largeImageURL, let url = URL(string: imageURLString) else {
            ProgressHUD.failed("Неверный URL изображения")
            showError()
            return
        }

        ProgressHUD.animate()
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
            ProgressHUD.dismiss()

            switch result {
            case .success(let value):
                self?.imageView.image = value.image
                DispatchQueue.main.async {
                    self?.hasAdjustedImageView = false
                    self?.adjustImageView()
                }
            case .failure(let error):
                self?.showError()
            }
        }
    }

    // MARK: Image Adjustment

    private func adjustImageViewIfNecessary() {
        if hasAdjustedImageView {
            return
        }
        if imageView.image != nil {
            adjustImageView()
            hasAdjustedImageView = true
        }
    }

    private func adjustImageView() {
        guard let image = imageView.image else { return }

        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size

        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        scrollView.maximumZoomScale = max(minScale * 3, 1.0)
        scrollView.layoutIfNeeded()

        centerImage()
    }

    private func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size

        let horizontalInset = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        let verticalInset = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0

        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }

    // MARK: Button Actions

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Error Handling

    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Не надо", style: .cancel))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        })

        present(alert, animated: true)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
