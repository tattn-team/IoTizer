//
//  InventoryManager.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/13.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import NCMB

class InventoryManager {
    static let shared = InventoryManager()
    
    init() {
        
    }
    
    func addInventory(name: String){
        let query = NCMBQuery(className: "TestClass")
        query.whereKey("message", equalTo: "test")
        query.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
            if error == nil {
                if objs.count > 0 {
                    print("[FIND] \(objs[0]["message"])")
                }
                else {
                    var saveError: NSError?
                    let obj = NCMBObject(className: "TestClass")
                    obj.setObject(name, forKey: "content")
                    obj.save(&saveError)
                    if saveError == nil {
                        print("[SAVE] Done")
                    }
                    else {
                        print("[SAVE-ERROR] \(saveError)")
                    }
                }
            }
            else {
                print("[ERROR] \(error)")
            }
        }
    }
    
    func removeInventry(name :String){
        let query = NCMBQuery(className: "TestClass")
        query.whereKey("content", equalTo: name)
        query.findObjectsInBackgroundWithBlock { (objs, error) -> Void in
            if error == nil {
                if objs.count > 0 {
                    print("[FIND] \(objs[0]["message"])")
                    objs?.first!.deleteInBackgroundWithBlock { error in
                        print("saved")
                    }

                }
            }
        }
    }
}