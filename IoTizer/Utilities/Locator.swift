//
//  Locator.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/10.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import CoreLocation

public protocol LocatorDelegate {
    func updateLocation(location: CLLocation)
    func updateRotation(heading: CLHeading)
}

public class Locator: NSObject, CLLocationManagerDelegate
{
    public static let shared = Locator()
    
    public var delegate: LocatorDelegate?
    
    private let mgr = CLLocationManager()
    
    private override init() {
        super.init()
        mgr.delegate = self
//        mgr.distanceFilter = 1.0 // 1m毎にGPS情報取得
        mgr.distanceFilter = kCLDistanceFilterNone
        mgr.desiredAccuracy = kCLLocationAccuracyBest // 最高精度でGPS取得
    }
    
    public func start() {
        mgr.requestAlwaysAuthorization()
        mgr.startUpdatingLocation() // 位置情報更新
        mgr.startUpdatingHeading() // コンパス更新
    }
    
    public func stop() {
        mgr.stopUpdatingLocation()
        mgr.stopUpdatingHeading()
    }
    
    public func getRotation() -> CLLocationDirection {
        return mgr.heading!.magneticHeading
    }
    
// MARK: - CLLocationManagerDelegate
    
    public func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation){
        if let delegate = self.delegate {
            delegate.updateLocation(newLocation)
        }
    }
    
    public func locationManager(manager:CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        if let delegate = self.delegate {
            delegate.updateRotation(newHeading)
        }
    }
    

}
