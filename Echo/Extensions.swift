//
//  Extensions.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 20/09/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension UIViewController {
    
    func hideNavigationBar(animated: Bool! = true) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func showNavigationBar(animated: Bool! = true) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
}

extension UIAlertController {
    
    static func presentErrorAlert(message: String = NSLocalizedString("Something went wrong, please try again later", comment: ""), inViewController viewController: UIViewController, action: ( (UIAlertAction) -> Void )? = nil, completion: ( () -> Void)? = nil ) {
        
        presentAlert(withTitle: NSLocalizedString("Error", comment: ""), message: message, inViewController: viewController, action: action, completion: completion)
    }
    
    static func presentAlert(withTitle title: String, message: String, inViewController viewController: UIViewController, action: ( (UIAlertAction) -> Void )? = nil, completion: ( () -> Void)?) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: action)
        alert.addAction(alertAction)
        
        viewController.present(alert, animated: true, completion: completion)
    }
    
}



extension UIView {
    func round(cornerRadius: CGFloat! = 5.0) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
    }
    
    func addShadow(color: UIColor = UIColor.black, opacity: Float = 1.0, offset: CGSize = CGSize.zero, radius: CGFloat = 5) {
        //layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius
    }
    
}

extension MKMapView {
    
    func zoomTo(center: CLLocationCoordinate2D, span: MKCoordinateSpan = MapView.preferredSpan, animated: Bool = true) {
        let region = MKCoordinateRegion(center: center, span: span)
        setRegion(region, animated: animated)
    }
    
}

extension UIColor {
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat
        
        if hexString.hasPrefix("#") {
            let start = hexString.index(hexString.startIndex, offsetBy: 1)
            let hexColor = hexString.substring(from: start)
            
            if hexColor.characters.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
    
    static var randomColor: UIColor {
        var colors: [UIColor?] = [UIColor(hexString: "#039BE5FF"), UIColor(hexString: "#4CAF50FF"), UIColor(hexString: "#0D47A1FF"), UIColor(hexString: "#673AB7FF"), UIColor(hexString: "#303F9FFF"), UIColor(hexString: "#C2185BFF"), UIColor(hexString: "EF5350FF"), UIColor(hexString: "#FFC107FF"), UIColor(hexString: "#388E3CFF"), UIColor(hexString: "#607D8BFF")]
        
        let randomNumber = Int(arc4random_uniform(UInt32(colors.count)))
        
        if let randomColor = colors[randomNumber] {
            return randomColor
        }
        else {
            return UIColor.brown
        }
        
    }        
}

