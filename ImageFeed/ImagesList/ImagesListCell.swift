//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Max on 07.09.2024.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradientToBottom()
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var cellImage: UIImageView!
    
    func addGradientToBottom() {
        let gradientLayer = CAGradientLayer()
        
        let startColor = UIColor.ypBackground.withAlphaComponent(0.0).cgColor
        let endColor = UIColor.ypBackground.withAlphaComponent(0.2).cgColor

        gradientLayer.colors = [startColor, endColor]
        gradientLayer.locations = [0.0, 1.0]
        
        let gradientHeight: CGFloat = 30.0
        gradientLayer.frame = CGRect(x: 0, y: contentView.bounds.height - gradientHeight, width: contentView.bounds.width, height: gradientHeight)
        
        contentView.layer.addSublayer(gradientLayer)
    }
}
