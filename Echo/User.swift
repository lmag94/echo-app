//
//  User.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 10/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import Foundation

class User {
    var username: String!
    var email: String?
    var imageURL: String!
    var id: Int!
    var token: String?
    
    static let sharedInstance = User()
    
    
    init(username: String!, email: String?, imageURL: String!, id: Int!, token: String?) {
        self.username = username
        self.email = email
        self.imageURL = imageURL
        self.id = id
        self.token = token
    }
    
    private init() {}
    
}
