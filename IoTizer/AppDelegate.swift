//
//  AppDelegate.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/09.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import NCMB

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let vc = MainViewController()
//        let vc = SensorTestViewController()
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        self.window!.rootViewController = vc
        self.window!.backgroundColor = UIColor.blackColor()
        self.window!.makeKeyAndVisible()
        
        NCMB.setApplicationKey(ApiKeys.NCMB_APP, clientKey: ApiKeys.NCMB_CLI)
        
        // Nifty Cloud mBaaS sample
//        let query = NCMBQuery(className: "Menu")
//        query.whereKey("message", equalTo: "test")
//        query.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
//            if error == nil {
//                if objs.count > 0 {
//                    print("[FIND] \(objs[0]["message"])")
//                }
//                else {
                    var saveError: NSError?
                    let obj = NCMBObject(className: "Menu")
//        obj.setObject(["玉ねぎ", "にんじん"], forKey: "")
//                    obj.setObject("Hello, NCMB!", forKey: "message")
                    obj.save(&saveError)
                    if saveError == nil {
                        print("[SAVE] Done")
                    }
                    else {
                        print("[SAVE-ERROR] \(saveError)")
                    }
//                }
//            }
//            else {
//                print("[ERROR] \(error)")
//            }
//        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

