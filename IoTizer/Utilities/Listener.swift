//
//  Listener.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/10.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import Alamofire

public class Listener: NSObject, SRClientHelperDelegate
{
    public static let shared = Listener()
    
    private var srcHelper: SRClientHelper?
    private var settings: Dictionary<String, AnyObject>?
    private var recognizedCallback: ((String, String?) -> Void)?
    
    private override init() {
    }

    public func listen(callback: (String, String?) -> Void) {
        if self.srcHelper == nil {
            settings = Dictionary<String, AnyObject>()
            settings!["api_key"] = ApiKeys.DOCOMO
            settings!["sbm_mode"] = 0
            settings!["result_xml"] = true
            
            self.srcHelper = SRClientHelper(device: settings)
            srcHelper!.delegate = self
        }
    
        self.recognizedCallback = callback
        srcHelper!.start()
    }
    
    public func stop() {
        if let helper = self.srcHelper {
            helper.cancel()
        }
    }
    
// MARK: - SRClientHelperDelegate
    
    public func srcDidRecognize(data: NSData!) {
        let decodedObj = NSKeyedUnarchiver.unarchiveObjectWithData(data)!
        var serializedString = ""
        if decodedObj.isMemberOfClass(SRNbest.self) {
            let nbestObj = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! SRNbest
            
            // XML
//            if nbestObj.serialize() != nil {
//                serializedString = nbestObj.serialize()
//            }
//            else {
//                serializedString = "結果なし"
//            }
            
            if nbestObj.sentenceArray == nil || nbestObj.sentenceArray.count < 1 {
                serializedString = "結果なし"
            }
            else {
                for sentenceString in nbestObj.getNbestStringArray(true) as! [String] {
                    if serializedString.characters.count > 0 {
                        serializedString += "\r"
                    }
                    serializedString += sentenceString
                }
            }
        }
        
        self.recognizedCallback!(serializedString, nil)
    }
    
    public func srcDidReady() {
    }
    
    public func srcDidSentenceEnd() {
    }
    
    public func srcDidComplete(error: NSError!) {
        if (error) != nil {
            let description = error.localizedDescription
//            let reason = error.localizedFailureReason
            
            self.recognizedCallback!("", description)
        }
    }
    
    public func srcDidRecord(pcmData: NSData!) {
//        double level = [self decibelFromData:pcmData];
//        [self performSelectorOnMainThread:@selector(updatePressureLevel:) withObject:[NSNumber numberWithDouble:level] waitUntilDone:NO];
    }

    
}