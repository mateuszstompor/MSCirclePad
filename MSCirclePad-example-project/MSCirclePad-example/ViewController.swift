//
//  ViewController.swift
//  joystick-example
//
//  Created by Mateusz Stompór on 09/04/2018.
//  Copyright © 2018 Mateusz Stompór. All rights reserved.
//

import UIKit
import MSCirclePad

class ViewController: UIViewController {
    
    @IBOutlet weak var circlepad: MSCirclePad!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        circlepad?.delegate = self
    }

}

extension ViewController : MSCirclePadDelegate {
    
    func joyPositionDidChanged(sender: MSCirclePad) {
        let x = String(format: "%.2f", sender.currentPosition.x)
        let y = String(format: "%.2f", sender.currentPosition.y)
        print("x: " + x + " y: " + y)
    }
    
}

