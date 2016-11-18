//
//  SelectedFriendCollectionViewCell.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 03/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import Kingfisher

class SelectedFriendCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    var didSelect: Bool = false
    
    var friend: Friend! {
        didSet {
            if let url = URL(string: friend.imageURL) {
                let imageResource = ImageResource(downloadURL: url)
                let processor = RoundCornerImageProcessor(cornerRadius: imageView.frame.size.width / 2.0)
                imageView.kf.indicatorType = .activity
                imageView.kf.setImage(with: imageResource, options: [.processor(processor), .transition(.fade(0.2))])
            }
        }
    }
}
