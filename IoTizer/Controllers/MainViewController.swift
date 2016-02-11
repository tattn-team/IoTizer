//
//  MainViewController.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/11.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, CameraDelegate
{
    var timer: NSTimer?
    var timerCounter = 0
    
    var faceLabel: UILabel!
    
    override func viewDidLoad() {
        self.setupUI()
        
        Camera.shared.delegate = self
        Camera.shared.start()
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
    
// MARK: - CameraDelegate
    
    func detectMotion() {
        if self.faceLabel.hidden {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
            self.faceLabel.hidden = false
        }
        self.timerCounter = 0
    }
}
