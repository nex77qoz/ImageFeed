import UIKit

// MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

// MARK: - ImagesListCell

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    // MARK: - Subviews
    
    let cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "No Active"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Gradient Layer
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Actions
    
    @objc private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Setup
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImageName = isLiked ? "Active" : "No Active"
        let likeImage = UIImage(named: likeImageName)?.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        setupSubviews()
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        selectionStyle = .none
        contentView.backgroundColor = .ypBlack
        backgroundColor = .ypBlack
    }
    
    private func setupSubviews() {
        contentView.addSubview(cellImage)
        contentView.addSubview(likeButton)
        contentView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            cellImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cellImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cellImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            likeButton.topAnchor.constraint(equalTo: cellImage.topAnchor, constant: 12),
            likeButton.trailingAnchor.constraint(equalTo: cellImage.trailingAnchor, constant: -12),
            likeButton.widthAnchor.constraint(equalToConstant: 21),
            likeButton.heightAnchor.constraint(equalToConstant: 18),
            
            dateLabel.leadingAnchor.constraint(equalTo: cellImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: cellImage.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Gradient Animation
    
    func addGradientAnimation() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = cellImage.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cellImage.layer.cornerRadius
        gradient.masksToBounds = true
        
        cellImage.layer.addSublayer(gradient)
        self.gradientLayer = gradient
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func removeGradientAnimation() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        cellImage.contentMode = .scaleAspectFill
        removeGradientAnimation()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = cellImage.bounds
    }
    
    // MARK: - Configuration
    private let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    func configCell(for photo: Photo, with placeholderImage: UIImage?) {
        if let createdAt = photo.createdAt {
            dateLabel.text = displayDateFormatter.string(from: createdAt)
        } else {
            dateLabel.text = ""
        }
        setIsLiked(photo.isLiked)
        
        cellImage.kf.indicatorType = .none
        
        addGradientAnimation()
        
        if let url = URL(string: photo.thumbImageURL) {
            cellImage.kf.setImage(
                with: url,
                placeholder: placeholderImage,
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]) { result in
                    DispatchQueue.main.async {
                        self.removeGradientAnimation()
                        switch result {
                            case .success(_):
                                self.cellImage.contentMode = .scaleAspectFill
                            case .failure(_):
                                self.cellImage.image = placeholderImage
                                self.cellImage.contentMode = .center
                        }
                    }
                }
        } else {
            removeGradientAnimation()
            cellImage.image = placeholderImage
            cellImage.contentMode = .center
        }
    }
}
