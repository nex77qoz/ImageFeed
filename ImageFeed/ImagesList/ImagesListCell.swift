import UIKit

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    let cellImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
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
    
    @objc private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        let likeImageName = isLiked ? "Active" : "No Active"
        let likeImage = UIImage(named: likeImageName)?.withRenderingMode(.alwaysOriginal)
        likeButton.setImage(likeImage, for: .normal)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        selectionStyle = .none
        contentView.backgroundColor = .ypBlack
        backgroundColor = .ypBlack
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
}
