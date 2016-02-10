//
//  Sensor.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/10.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import Foundation
import CoreMotion

public protocol SensorDelegate {
    func accelerometerUpdate(data: CMAccelerometerData)
    func proximityUpdate(detected: Bool)
}

public class Sensor: NSObject
{
    public static let shared = Sensor()
    
    public var delegate: SensorDelegate?
    
    private let motionMgr = CMMotionManager()
    
    private override init() {
        super.init()
        motionMgr.accelerometerUpdateInterval = 0.01;
    }
    
    public func startAccelerometer() {
        let handler:CMAccelerometerHandler = {(data:CMAccelerometerData?, error:NSError?) -> Void in
            if let delegate = self.delegate {
                delegate.accelerometerUpdate(data!)
            }
        }
        motionMgr.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler:handler)
    }
    
    public func stopAccelerometer() {
        motionMgr.stopAccelerometerUpdates()
    }
    
    public func startProximityMonitor() {
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "proximityUpdate:", name: UIDeviceProximityStateDidChangeNotification, object: nil)
    }
    
    public func stopProximityMonitor() {
        UIDevice.currentDevice().proximityMonitoringEnabled = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIDeviceProximityStateDidChangeNotification, object: nil)
    }
    
    private func proximityUpdate(notification: NSNotification) {
        if let delegate = self.delegate {
            delegate.proximityUpdate(UIDevice.currentDevice().proximityState)
        }
    }

}