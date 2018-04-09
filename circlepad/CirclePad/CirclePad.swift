//
//  CirclePad.swift
//  circlepad
//
//  Created by Mateusz Stompór on 09/04/2018.
//  Copyright © 2018 Mateusz Stompór. All rights reserved.
//

import UIKit

@objc public class MSCirclePad: UIView, UIGestureRecognizerDelegate {
    
    private var joyLayer: CALayer?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var lastDateOfTouchChange: Date?
    private let activeViewAlpha: CGFloat = 0.4
    private let inActiveViewAlpha: CGFloat = 0.11
    private let becomeActiveDuration: TimeInterval = 0.1
    private let becomeInActiveDuration: TimeInterval = 0.8
    private let intervalAfterWhichViewBecomeInactive: TimeInterval = 2.0
    
    private var becomeInactive: Bool = true {
        didSet {
            if oldValue != self.becomeInactive {
                UIView.animate(withDuration: self.becomeInactive == true ? becomeInActiveDuration : becomeActiveDuration, animations: {
                    self.alpha = self.becomeInactive == true ? self.inActiveViewAlpha : self.activeViewAlpha
                })
            }
        }
    }
    
    public weak var delegate: MSCirclePadDelegate?
    
    public var currentPosition: CGPoint {
        get {
            let distancetocenterX = Float(panGestureRecognizer!.location(in: self).x - self.bounds.width/2)
            let distancetocenterY = Float(panGestureRecognizer!.location(in: self).y - self.bounds.height/2)
            let xPos = CGFloat(distancetocenterX)/(self.bounds.width/2.0)
            let yPos = -CGFloat(distancetocenterY)/(self.bounds.height/2.0)
            return CGPoint(x: xPos, y: yPos)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareView()
    }
    
    private func prepareView() {
        self.alpha = self.inActiveViewAlpha
        let sizeinside = 50
        let insideCircleSize = CGSize(width: sizeinside, height: sizeinside)
        self.isUserInteractionEnabled = true
        let layerCircle = CAShapeLayer()
        let centerPoint = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        layerCircle.path = UIBezierPath(roundedRect: CGRect(x: centerPoint.x-insideCircleSize.width/2, y: centerPoint.y-insideCircleSize.height/2, width: insideCircleSize.width, height: insideCircleSize.height), cornerRadius: insideCircleSize.width/2).cgPath
        layerCircle.fillColor = UIColor.gray.cgColor
        self.layer.addSublayer(layerCircle)
        self.joyLayer = layerCircle
        
        self.layer.cornerRadius = self.frame.width/2
        self.setUpGestureRecognizer()
    }
    
    @objc private func setUpGestureRecognizer() {
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(recognizePan(_:)))
        self.panGestureRecognizer?.delegate = self
        self.panGestureRecognizer?.maximumNumberOfTouches = 1
        self.panGestureRecognizer?.minimumNumberOfTouches = 1
        self.addGestureRecognizer(self.panGestureRecognizer!)
    }
    
    @objc private func recognizePan (_ pan: UIPanGestureRecognizer){
        
        if pan.state != .ended {
            self.lastDateOfTouchChange = Date()
            self.becomeInactive = false
        }
        
        switch pan.state {
        case .ended:
            self.delegate?.joyTouchRecognitionDidEnd?(sender: self)
            self.joyLayer?.position = CGPoint(x: 0.0, y: 0.0)
            self.lastDateOfTouchChange = Date()
            let deadlineTime = DispatchTime.now() + .seconds(Int(intervalAfterWhichViewBecomeInactive))
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                if let lastChange = self.lastDateOfTouchChange {
                    if Date().timeIntervalSince(lastChange) > self.intervalAfterWhichViewBecomeInactive {
                        self.becomeInactive = true
                    }
                    
                }
            }
            return
        case .began:
            self.delegate?.joyTouchRecognitionDidStart?(sender: self)
        default:
            break
        }
        
        if var locationInSuperLayer = self.panGestureRecognizer?.location(in: self) {
            locationInSuperLayer.y = locationInSuperLayer.y-self.bounds.height/2
            locationInSuperLayer.x = locationInSuperLayer.x-self.bounds.width/2
            self.joyLayer?.position = locationInSuperLayer
            self.delegate?.joyPositionDidChanged?(sender: self)
        }
    }
}

@objc public protocol MSCirclePadDelegate : class {
    @objc optional func joyTouchRecognitionDidStart(sender: MSCirclePad)
    @objc optional func joyTouchRecognitionDidEnd(sender: MSCirclePad)
    @objc optional func joyPositionDidChanged(sender: MSCirclePad)
}
