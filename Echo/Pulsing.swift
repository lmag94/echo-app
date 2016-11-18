//
//  Pulsing.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 23/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit

class Pulsing: CALayer {

    var animationGroup = CAAnimationGroup()
    
    public var initialPulseScale: Float = 0.0
    public var nextPulseAfer: TimeInterval = 0
    public var animationDuration: TimeInterval = 1.5
    public var radius: CGFloat = 200
    public var numberOfPulses: Float = Float.infinity
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init(numberOfPulses: Float = Float.infinity, radius: CGFloat, position: CGPoint, backgroundColor: UIColor = Color.radarColor) {
        super.init()
        
        self.numberOfPulses = numberOfPulses
        self.radius = radius
        self.backgroundColor = backgroundColor.cgColor
        
        self.contentsScale = UIScreen.main.scale
        self.position = position
        self.opacity = 0
        
        self.bounds = CGRect(x: 0.0, y: 0.0, width: radius * 2, height: radius * 2)
        self.cornerRadius = radius
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            self.setupAnimationGroup()
            
            DispatchQueue.main.async {
                self.add(self.animationGroup, forKey: "pulse")
            }
        }
        
        
    }
    
    
    func createScaleAnimation() -> CABasicAnimation {
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale.xy")
        
        scaleAnimation.fromValue = NSNumber(value: initialPulseScale)
        scaleAnimation.toValue = NSNumber(value: 1.0)
        scaleAnimation.duration = animationDuration
        
        return scaleAnimation
    }
    
    func createOpacityAnimation() -> CAKeyframeAnimation {
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.duration = animationDuration
        
        //Values of opacity of the pulse
        opacityAnimation.values = [0.1, 0.8, 0.0]
        
        //Specify at which point in time the keyframes occurr, fractions of total duration
        opacityAnimation.keyTimes = [0, 0.2, 1]
        
        return opacityAnimation
    }
    
    func setupAnimationGroup() {
        
        animationGroup = CAAnimationGroup()
        
        animationGroup.duration = animationDuration + nextPulseAfer
        animationGroup.repeatCount = numberOfPulses
        
        let defaultCurve = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        animationGroup.timingFunction = defaultCurve
        
        animationGroup.animations = [createScaleAnimation(), createOpacityAnimation()]
    }
}
