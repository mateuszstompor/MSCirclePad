//
//  MSCirclePad.swift
//  MSCirclePad
//
//  Created by Mateusz Stompór on 09/04/2018.
//  Copyright © 2018 Mateusz Stompór. All rights reserved.
//

import UIKit

@objc public class MSCirclePad: UIView, UIGestureRecognizerDelegate {
    
    private let numberOfTouchesRequired: Int = 1
    private let activeViewAlpha: CGFloat = 0.4
    private let inActiveViewAlpha: CGFloat = 0.11
    private let becomeActiveAnimation: TimeInterval = 0.1
    private let becomeInactiveAnimation: TimeInterval = 0.8
    private let innerCircleSideLength: CGFloat = 50.0
    private let becomeInactiveDelay: TimeInterval = 2.0
    
    private var joyLayer: CALayer?
    private var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(recognizePan(_:)))
    private var lastDateOfTouchChange: Date?
    
    private var shouldBecomeInactive: Bool = true {
        didSet {
            if oldValue != shouldBecomeInactive {
                let duration = shouldBecomeInactive == true ? becomeInactiveAnimation : becomeActiveAnimation
                let alphaToSet = shouldBecomeInactive == true ? inActiveViewAlpha : activeViewAlpha
                UIView.animate(withDuration: duration, animations: { [unowned self] in
                    self.alpha = alphaToSet
                })
            }
        }
    }
    
    @objc public weak var delegate: MSCirclePadDelegate?
    
    @objc public var currentPosition: CGPoint {
        get {
            let distancetocenterX = Float(panGestureRecognizer.location(in: self).x - bounds.width/2)
            let distancetocenterY = Float(panGestureRecognizer.location(in: self).y - bounds.height/2)
            let xPos = CGFloat(distancetocenterX) / bounds.width / 2.0
            let yPos = -CGFloat(distancetocenterY) / bounds.height / 2.0
            return CGPoint(x: xPos, y: yPos)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
        self.setUpGestureRecognizer()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.prepareView()
        self.setUpGestureRecognizer()
    }
    
    private func prepareView() {
        self.alpha = self.inActiveViewAlpha
        let insideCircleSize = CGSize(width: innerCircleSideLength, height: innerCircleSideLength)
        self.isUserInteractionEnabled = true
        let layerCircle = CAShapeLayer()
        let centerPoint = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        
        let roundedRect = CGRect(x: centerPoint.x-insideCircleSize.width/2,
                                 y: centerPoint.y-insideCircleSize.height/2,
                                 width: insideCircleSize.width,
                                 height: insideCircleSize.height)
        
        layerCircle.path = UIBezierPath(roundedRect: roundedRect, cornerRadius: insideCircleSize.width/2).cgPath
        layerCircle.fillColor = UIColor.gray.cgColor
        self.layer.addSublayer(layerCircle)
        self.joyLayer = layerCircle
        self.layer.cornerRadius = self.frame.width/2
    }
    
    @objc private func setUpGestureRecognizer() {
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(recognizePan(_:)))
        self.panGestureRecognizer.delegate = self
        self.panGestureRecognizer.maximumNumberOfTouches = numberOfTouchesRequired
        self.panGestureRecognizer.minimumNumberOfTouches = numberOfTouchesRequired
        self.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    @objc private func recognizePan (_ pan: UIPanGestureRecognizer){
        
        if pan.state != .ended {
            self.lastDateOfTouchChange = Date()
            self.shouldBecomeInactive = false
        }
        
        switch pan.state {
            case .ended:
                self.delegate?.joyTouchRecognitionDidEnd?(sender: self)
                self.joyLayer?.position = CGPoint(x: 0.0, y: 0.0)
                self.lastDateOfTouchChange = Date()
                let deadlineTime = DispatchTime.now() + .seconds(Int(becomeInactiveDelay))
                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                    if Date().timeIntervalSince(self.lastDateOfTouchChange!) > self.becomeInactiveDelay {
                        self.shouldBecomeInactive = true
                    }
                }
                return
            case .began:
                self.delegate?.joyTouchRecognitionDidStart?(sender: self)
            default:
                break
        }
        
        var locationInSuperLayer = self.panGestureRecognizer.location(in: self)
        locationInSuperLayer.y = locationInSuperLayer.y - self.bounds.height/2
        locationInSuperLayer.x = locationInSuperLayer.x - self.bounds.width/2
        self.joyLayer?.position = locationInSuperLayer
        self.delegate?.joyPositionDidChanged?(sender: self)
    }
}

@objc public protocol MSCirclePadDelegate : class {
    @objc optional func joyTouchRecognitionDidStart(sender: MSCirclePad)
    @objc optional func joyTouchRecognitionDidEnd(sender: MSCirclePad)
    @objc optional func joyPositionDidChanged(sender: MSCirclePad)
}
