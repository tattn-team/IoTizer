//
//  LimitManager.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/13.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import SwiftDate

class LimitManager {
    static let shared = LimitManager()
    
    let limits = [
        "玉ねぎ": 30,
        "にんじん": 30,
        "卵": 14,
        "牛乳": 10,
    ]
    
    init() {
    }
    
    func searchLimit(name: String) -> Int {
        return limits["name"]!
    }
}