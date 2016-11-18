//
//  Constants.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 10/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct Color {
    static let primaryColor = UIColor(red: 3.0/255.0, green: 43.0/255.0, blue: 67.0/255.0, alpha: 1.0)
    static let radarColor = UIColor(red: 3.0/255.0, green: 43.0/255.0, blue: 67.0/255.0, alpha: 0.6)
}

struct MapView {
    static let preferredSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
}

struct Webservice {
    static let url = "https://echo-mx.herokuapp.com/api"
}

struct PushbotsConstants {
    static let applicationId = "582ecd0a4a9efa7ef88b4567"
}
