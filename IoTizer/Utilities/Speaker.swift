//
//  Speaker.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/10.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation
import AVFoundation
import Alamofire

public class Speaker: NSObject, AVAudioPlayerDelegate
{
    public static let shared = Speaker()
    
    private let speaker = "hikari"
    private let emotion = "happiness"
    private let emotionLevel = "2" // max:4
    private let pitch = "100"
    private let speed = "100"
    private let volume = "100"
    
    private let loginHeaders: Dictionary<String, String>
    
    private var audioPlayer : AVAudioPlayer?
    
    private override init() {
        let user = ApiKeys.VOICETEXT
        let password = ""
        
        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        
        loginHeaders = [
            "Authorization": "Basic \(base64Credentials)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
    }
    
    public func speak(message: String) {
        Alamofire.request(.POST, "https://api.voicetext.jp/v1/tts",
            headers: loginHeaders,
            parameters: [
                "text": message,
                "speaker": speaker,
                "emotion": emotion,
                "emotion_level": emotionLevel,
                "pitch": pitch,
                "speed": speed,
                "volume": volume
            ])
        .responseData { response in
            if response.response?.statusCode == 200 {
                do {
                    try self.audioPlayer = AVAudioPlayer(data: response.result.value!)
                    self.audioPlayer!.delegate = self
                    self.audioPlayer?.play()
                }
                catch{}
            }
            else {
                print(response.response?.statusCode)
            }
        }
    }
    
// MARK: - AVAudioPlayerDelegate
    
    //音楽再生が成功した時に呼ばれるメソッド.
    public func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//        print("Music Finish")
    }
    
    //デコード中にエラーが起きた時に呼ばれるメソッド.
    public func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Audio Error")
        print(error)
    }
}
