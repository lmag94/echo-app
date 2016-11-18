//
//  Area.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 10/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class Area {
    var id: Int!
    var name: String!
    var owner: User!
    var polygon: [CLLocationCoordinate2D]!
    var friends: [Friend]!
    var imageURL: String!
    var color: UIColor!
    
    var entryMessage: String!
    var exitMessage: String!
    
    init(id: Int!, name: String!, owner: User!, polygon: [CLLocationCoordinate2D]!, imageURL: String!, entryMessage: String!, exitMessage: String!) {
        self.id = id
        self.name = name
        self.owner = owner
        self.polygon = polygon
        self.imageURL = imageURL
        
        self.entryMessage = entryMessage
        self.exitMessage = exitMessage
    }
}
