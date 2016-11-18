//
//  Keychain.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 18/11/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import Foundation

class Keychain {
    
    public static let TOKEN_KEY = "token"
    public static let ID_KEY = "id"
    
    static func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: TOKEN_KEY)
    }
    
    static func retriveToken() -> String? {
        return UserDefaults.standard.object(forKey: TOKEN_KEY) as? String
    }
    
    static func saveId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: ID_KEY)
    }
    
    static func retrieveId() -> Int? {
        return UserDefaults.standard.object(forKey: ID_KEY) as? Int
    }
}
