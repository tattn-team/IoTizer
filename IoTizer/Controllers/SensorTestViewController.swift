//
//  ViewController.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/09.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class SensorTestViewController: UIViewController, CameraDelegate, LocatorDelegate, SensorDelegate {
    
    var timer: NSTimer?
    var timerCounter = 0
    let disposeBag = DisposeBag()
    
    var locationLabel: UILabel!
    var rotationLabel: UILabel!
    var proximitySwitch: UISwitch!
    var accelerometerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Camera.shared.delegate = self
        Camera.shared.start()
        
        Locator.shared.delegate = self
        Locator.shared.start()
        
        Sensor.shared.delegate = self
        Sensor.shared.startAccelerometer()
        // 近接センサ (3cmくらいで反応, 反応後画面暗転, Landscapeだと動かない)
        // Sensor.shared.startProximityMonitor()
        
        let label = UILabel(frame: CGRectMake(20, 20, 500, 30))
        label.text = "ダミーテキスト"
        view.addSubview(label)
        
        let voiceButton = UIButton(frame: CGRectMake(20, 60, 500, 30))
        voiceButton.setTitle("音声認識", forState: .Normal)
        voiceButton.backgroundColor = UIColor.blueColor()
        voiceButton.rx_tap.subscribeNext { _ in
            Listener.shared.listen({ (message, error) -> Void in
                if message == "" {
                    label.text = "認識失敗"
                }
                else {
                    label.text = message
                    Speaker.shared.speak(message)
                    Japanese.shared.parse(message, callback: { (xml) -> Void in
                        print(xml)
                    })
                }
            })
        }.addDisposableTo(disposeBag)
        
        view.addSubview(voiceButton)
        
        locationLabel = UILabel(frame: CGRectMake(20, 100, 250, 30))
        locationLabel.font = UIFont.systemFontOfSize(7)
        rotationLabel = UILabel(frame: CGRectMake(270, 100, 250, 30))
        rotationLabel.font = UIFont.systemFontOfSize(7)
        view.addSubview(locationLabel)
        view.addSubview(rotationLabel)
        
        let proximityLabel = UILabel(frame: CGRectMake(20, 140, 80, 30))
        proximitySwitch = UISwitch(frame: CGRectMake(100, 140, 500, 30))
        proximityLabel.text = "近接センサ"
        view.addSubview(proximityLabel)
        view.addSubview(proximitySwitch)
        
        accelerometerLabel = UILabel(frame: CGRectMake(20, 180, 500, 30))
        accelerometerLabel.font = UIFont.systemFontOfSize(7)
        view.addSubview(accelerometerLabel)
        
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func timerUpdate() {
        if timerCounter++ >= 2 {
            view.backgroundColor = UIColor.whiteColor()
            self.timer?.invalidate()
        }
    }
    
// MARK: - CameraDelegate
    
    func detectMotion() {
        if view.backgroundColor == UIColor.whiteColor() {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
            view.backgroundColor = UIColor.redColor()
        }
        self.timerCounter = 0
    }
    
// MARK: - LocatorDelegate
    
    func updateLocation(location: CLLocation) {
        let coord = location.coordinate
        self.locationLabel.text = "lat: \(coord.latitude), long: \(coord.longitude)"
    }
    
    func updateRotation(heading: CLHeading) {
        self.rotationLabel.text = "\(heading.magneticHeading) deg"
    }
    
// MARK: - SensorDelegate
    
    func accelerometerUpdate(data: CMAccelerometerData) {
        let a = data.acceleration
        self.accelerometerLabel.text = "x:\(a.x) y:\(a.y) z:\(a.z)"
    }
    
    func proximityUpdate(detected: Bool) {
        proximitySwitch.on = detected
    }
}

