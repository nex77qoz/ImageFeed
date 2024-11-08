import UIKit
import Kingfisher
import ProgressHUD

final class SingleImageViewController: UIViewController {
    // MARK: - Свойства
    
    var imageURL: String? {
        didSet {
            guard isViewLoaded else { return }
            loadImage()
        }
    }

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // Флаг для предотвращения повторного вызова adjustImageView
    private var hasAdjustedImageView = false

    // MARK: - Жизненный цикл

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        setupScrollView()
        loadImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Вызываем adjustImageView только один раз после загрузки изображения и обновления макета
        if hasAdjustedImageView {
            return
        }
        if imageView.image != nil {
            adjustImageView()
            hasAdjustedImageView = true
        }
    }

    // MARK: - Настройка ScrollView

    private func setupScrollView() {
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.delegate = self
        
        // Устанавливаем ограничения для imageView относительно scrollView
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)
            // Удаляем ограничения на ширину и высоту
        ])
    }

    // MARK: - Загрузка изображения

    private func loadImage() {
        imageView.image = nil

        guard let imageURLString = imageURL, let url = URL(string: imageURLString) else {
            ProgressHUD.failed("Неверный URL изображения")
            return
        }
        ProgressHUD.animate()
        imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))]) { [weak self] result in
            ProgressHUD.dismiss()
            
            switch result {
            case .success(let value):
                self?.imageView.image = value.image
                DispatchQueue.main.async {
                    // Сбрасываем флаг, чтобы adjustImageView мог быть вызван снова при обновлении макета
                    self?.hasAdjustedImageView = false
                    self?.adjustImageView()
                }
            case .failure(_):
                self?.showError()
            }
        }
    }
    
    // MARK: - Настройка ImageView после загрузки изображения
    
    private func adjustImageView() {
        guard let image = imageView.image else { return }
        
        let scrollViewSize = scrollView.bounds.size
        let imageSize = image.size
        
        // Вычисляем масштаб для минимального масштабирования, чтобы изображение заполняло экран
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        
        // Устанавливаем максимальный масштаб, чтобы пользователи могли увеличивать изображение до 3x от минимального масштаба
        scrollView.maximumZoomScale = max(minScale * 3, 1.0)
        
        centerImage()
    }

    // MARK: - Функции кнопок

    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityViewController, animated: true)
    }

    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Центрирование изображения

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
    
    // MARK: - Функция отображения ошибки

    private func showError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel, handler: nil)
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadImage()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        
        present(alert, animated: true, completion: nil)
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
