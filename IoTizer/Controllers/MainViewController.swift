//
//  MainViewController.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/11.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, LocatorDelegate, CameraDelegate
{
    var timer: NSTimer?
    var timerCounter = 0
    
    var faceLabel: UILabel!
    
    var baseRotation: CLLocationDirection?
    var isOpening = false
    
    override func viewDidLoad() {
        self.setupUI()
        
        Camera.shared.delegate = self
        Camera.shared.start()
        
        Locator.shared.delegate = self
        Locator.shared.start()
    }
    
    private func setupUI() {
        let frame = UIScreen.mainScreen().bounds
        faceLabel = UILabel(frame: frame)
        faceLabel.text = "≧∇≦"
        faceLabel.font = UIFont.systemFontOfSize(200)
        faceLabel.textAlignment = .Center
        faceLabel.backgroundColor = UIColor.whiteColor()
        faceLabel.hidden = true
        view.addSubview(faceLabel)
    }
    
    func timerUpdate() {
        if timerCounter++ >= 2 {
            faceLabel.hidden = true
            self.timer?.invalidate()
        }
    }
    
    func detectOpening(flag: Bool) {
        if flag {
            print("[LISTENING]")
            Listener.shared.listen({ (message, error) -> Void in
                if message == "" {
                    // stackoverflowが怖い
                    self.detectOpening(flag)
                }
                else {
                    print(message)
                }
            })
        }
        else {
            print("[FINISHED to LISTEN]")
            Listener.shared.stop()
        }
    }
    
    
// MARK: - CameraDelegate
    
    func detectMotion() {
        if self.faceLabel.hidden {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
            self.faceLabel.hidden = false
        }
        self.timerCounter = 0
    }
    
    
// MARK: - LocatorDelegate
    
    func updateLocation(location: CLLocation) {
    }
    
    func updateRotation(heading: CLHeading) {
        if baseRotation == nil {
            baseRotation = heading.magneticHeading
        }
        else {
            let value = fabs(baseRotation!.distanceTo(heading.magneticHeading))
            if isOpening {
                if value < 30 {
                    self.detectOpening(false)
                    isOpening = false
                }
            }
            else {
                if value > 30 {
                    self.detectOpening(true)
                    isOpening = true
                }
            }
        }
    }
}
