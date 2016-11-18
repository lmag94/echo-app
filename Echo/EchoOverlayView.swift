//
//  EchoOverlayView.swift
//  Echo
//
//  Created by Luis Mariano Arobes on 23/10/16.
//  Copyright © 2016 Luis Mariano Arobes. All rights reserved.
//

import UIKit

class EchoOverlayView: UIView {

    //MARK: - Outlets
    @IBOutlet private var contentView: UIView!

    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var belugaImageView: UIImageView!
    
    //MARK: - Public fields
    public var presentationAnimationDuration: CGFloat = 0.5
    public var hideAnimationDuration: CGFloat = 0.3
    
    public var cornerRadius: CGFloat = 10.0
    public var shadowOpacity: Float = 0.7
    public var shadowOffset: CGSize = CGSize(width: 0.0, height: 0.0)
    
    public var height: CGFloat = 100.0
    public var width: CGFloat = 100.0
    
    public var isShowing = false
    
    public var pulseAnimationDuration: TimeInterval = 1.5
    
    //MARK: - Private fields
    private var initialScaleX: CGFloat = 0.1
    private var initialScaleY: CGFloat = 0.1
    
    private var finalScaleXWhenDisappearing: CGFloat = 8.0
    private var finalScaleYWhenDisappearing: CGFloat = 8.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func showView(onView: UIView) {
        
        if isShowing {
            return
        }
        
        isShowing = true
        transform = CGAffineTransform(scaleX: initialScaleX, y: initialScaleY)
        self.alpha = 0.0
        onView.addSubview(self)
        
        //Center view on superview
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: 0.0))
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        
        onView.needsUpdateConstraints()
        
        
        UIView.animate(withDuration: TimeInterval(presentationAnimationDuration), delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
            
            }, completion: { (success) in
                
                self.showPulse()
        })
        
        /*
        UIView.animate(withDuration: TimeInterval(presentationDuration)) {
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
        }*/
        
    }
    
    func hideView(scaleWhenDisappearing: Bool = true) {
        
        if !isShowing {
            return
        }
        
        isShowing = false
        
        if scaleWhenDisappearing {
            UIView.animate(withDuration: TimeInterval(hideAnimationDuration), animations: {
                
                self.transform = CGAffineTransform(scaleX: self.finalScaleXWhenDisappearing, y: self.finalScaleYWhenDisappearing)
                self.alpha = 0.0
            }) { (succes) in
                self.removeFromSuperview()
            }
        }
        else {
            self.removeFromSuperview()
        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EchoOverlayView", owner: self, options: nil)
        
        guard let content = contentView else {
            return
        }
        
        content.frame = self.bounds
        content.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(content)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        setupViews()
    }
    
    private func setupViews() {
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = shadowOpacity
        contentView.layer.shadowRadius = cornerRadius
        contentView.layer.shadowOffset = shadowOffset
        contentView.backgroundColor = UIColor.clear.withAlphaComponent(0.0)
        
        blurEffectView.layer.cornerRadius = self.height / 2.0
        blurEffectView.clipsToBounds = true
            
        let roundLayerView = UIView(frame: self.bounds)
        roundLayerView.clipsToBounds = true
        roundLayerView.layer.cornerRadius = self.height / 2.0
        roundLayerView.translatesAutoresizingMaskIntoConstraints = false
        roundLayerView.backgroundColor = UIColor.white
        roundLayerView.layer.masksToBounds = true
        
        contentView.addSubview(roundLayerView)
        contentView.sendSubview(toBack: roundLayerView)
        
        addConstraint(NSLayoutConstraint(item: roundLayerView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: roundLayerView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        addConstraint(NSLayoutConstraint(item: roundLayerView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: roundLayerView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }
    
    private func showPulse() {
        
        let pulsesRadius: [CGFloat] = [height / 2.0, height / 2.8, height / 4.5]
        
        for pulseRadius in pulsesRadius {
            let pulse = Pulsing(radius: pulseRadius, position: belugaImageView.center)
            pulse.animationDuration = pulseAnimationDuration
            layer.insertSublayer(pulse, below: belugaImageView.layer)
        }
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: width))
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }

}
