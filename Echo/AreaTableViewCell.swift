//
//  AreaTableViewCell.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 17/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit

class AreaTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgViewSizeConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.round(cornerRadius: imgViewSizeConstraint.constant / 2.0)
        }
    }
    
    @IBOutlet weak var imgArea: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ownerLabel: UILabel!
    
    var area: Area! {
        didSet {
            
            if area.owner is Friend {
                ownerLabel.text = "\(NSLocalizedString("Owner", comment: "")): \(area.owner.username)"
            }
            else {
                ownerLabel.text = "\(NSLocalizedString("Owner", comment: "")): \(NSLocalizedString("Me", comment: ""))"
            }
            
            titleLabel.text = area.name
            
            guard let url = URL(string: area.imageURL) else {
                return
            }
            
            let imageResource = ImageResource(downloadURL: url)
            let processor = RoundCornerImageProcessor(cornerRadius: imgViewSizeConstraint.constant / 2.0)
            
            imgArea.kf.indicatorType = .activity
            imgArea.kf.setImage(with: imageResource, options: [.processor(processor)])
            
            imgArea.round(cornerRadius: imgViewSizeConstraint.constant / 2.0)
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
