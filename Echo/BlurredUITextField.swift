//
//  BlurredUITextField.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 23/09/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit

class BlurredUITextField: UITextField {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let blurEffectDark = UIBlurEffect(style: .light)
    var blurView: UIVisualEffectView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        round()
        textColor = UIColor.white
        backgroundColor = UIColor.clear
        
        blurView = UIVisualEffectView(effect: blurEffectDark)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        blurView.alpha = 0.0
        
        blurView.frame = frame
        blurView.round()
        superview?.insertSubview(blurView, belowSubview: self)
    }
    
    var hasAddedBlurView = false
    
    func addBlurredBackground(animationDuration: TimeInterval = 1.0) {
        
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.blurView.alpha = 0.8
        })
        
    }
    
    func removeBlurredBackground(animationDuration: TimeInterval = 1.0) {
        UIView.animate(withDuration: animationDuration, animations: { [weak self] in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.blurView.alpha = 0.0
        })
    }
    
}
