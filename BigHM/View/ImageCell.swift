//
//  ImageCell.swift
//  BigHM
//
//  Created by Майя Герасимова on 06.12.2020.
//

import UIKit

class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var likesLibel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with image: UIImage?, likes: Int) {
        imageView.image = image
        likesLibel.text = String(likes)
    }
    
}
