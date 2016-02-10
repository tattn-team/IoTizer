//
//  Japanese.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/10.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import Alamofire
import SWXMLHash

public class Japanese: NSObject
{
    public static let shared = Japanese()
    
    private override init() {
    }
    
    func parse(message: String, callback: (XMLIndexer) -> Void) {
        let url = "http://jlp.yahooapis.jp/MAService/V1/parse"
        let params = ["appid": ApiKeys.YAHOO, "sentence": message, "results": "ma"]
        Alamofire.request(.GET, url, parameters: params)
        .response { (req, res, data, error) -> Void in
            let xml = SWXMLHash.parse(data!)
            callback(xml["ResultSet"]["ma_result"])
//            print(xml["ResultSet"].element?.text)
        }
    }
    

}