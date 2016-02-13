//
//  MenuManager.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/13.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import NCMB

class MenuManager {
    static let shared = MenuManager()
    
    init() {
    }
    
    func proposalMenu() -> String {
//        let query = NCMBQuery(className: "TestClass")
//        query.whereKey("message", equalTo: "test")
//        query.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
//            if error == nil {
//                if objs.count > 0 {
//                    print("[FIND] \(objs[0]["message"])")
//                }
//                else {
//                    var saveError: NSError?
//                    let obj = NCMBObject(className: "TestClass")
//                    obj.setObject("Hello, NCMB!", forKey: "message")
//                    obj.save(&saveError)
//                    if saveError == nil {
//                        print("[SAVE] Done")
//                    }
//                    else {
//                        print("[SAVE-ERROR] \(saveError)")
//                    }
//                }
//            }
//            else {
//                print("[ERROR] \(error)")
//            }
//        }
        return "グラタン"
    }
}