//
//  FriendTableViewCell.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 03/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import Kingfisher

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imgViewSizeConstraint: NSLayoutConstraint!
    
    var friend: Friend! {
        didSet {
            
            nameLabel.text = friend.username
            
            guard let url = URL(string: friend.imageURL) else {
                return
            }
            
            let imageResource = ImageResource(downloadURL: url)
            let processor = RoundCornerImageProcessor(cornerRadius: imgViewSizeConstraint.constant / 2.0)
            
            imgView.kf.indicatorType = .activity
            imgView.kf.setImage(with: imageResource, options: [.processor(processor)])
            
            imgView.round(cornerRadius: imgViewSizeConstraint.constant / 2.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
