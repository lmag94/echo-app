//
//  Friend.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 02/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import Foundation

class Friend: User {
    var selected: Bool!
    
    init(username: String!, email: String? = nil, imageURL: String, id: Int!) {
        super.init(username: username, email: email, imageURL: imageURL, id: id, token: nil)
        self.selected = false
    }
}
