//
//  ViewController.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/09.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON
import SWXMLHash

class ViewController: UIViewController, AVAudioPlayerDelegate, SRClientHelperDelegate {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRectMake(20, 20, 400, 30))
        label.text = "ダミーテキスト"
        view.addSubview(label)
        
        let voiceButton = UIButton(frame: CGRectMake(20, 60, 400, 30))
        voiceButton.setTitle("音声認識", forState: .Normal)
        voiceButton.backgroundColor = UIColor.blueColor()
        voiceButton.rx_tap.subscribeNext { _ in
            self.recognizeVoice({ (msg, error) -> Void in
                if msg == "" {
                    label.text = "認識失敗"
                }
                else {
                    label.text = msg
                    self.speak(msg)
                    self.parse(msg)
                }
            })
        }.addDisposableTo(disposeBag)
        
        view.addSubview(voiceButton)
    }
    
    
    func parse(message: String) {
        let url = "http://jlp.yahooapis.jp/MAService/V1/parse"
        let params = ["appid": ApiKeys.YAHOO, "sentence": message, "results": "ma"]
        Alamofire.request(.GET, url, parameters: params)
        .response { (req, res, data, error) -> Void in
            let xml = SWXMLHash.parse(data!)
            print(xml["ResultSet"]["ma_result"])
//            print(xml["ResultSet"].element?.text)
        }
    }
    
    
    private var audioPlayer : AVAudioPlayer?
    
    func speak(message: String, var yomi: String? = nil) {
        
        if yomi == nil { yomi = message }
        
        let user = ApiKeys.VOICETEXT
        let password = ""
        
        let credentialData = "\(user):\(password)".dataUsingEncoding(NSUTF8StringEncoding)!
        let base64Credentials = credentialData.base64EncodedStringWithOptions([])
        
        let headers = [
            "Authorization": "Basic \(base64Credentials)",
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        let speaker = "hikari"
        let emotion = "happiness"
        let emotionLevel = "2" // max:4
        let pitch = "100"
        let speed = "100"
        let volume = "100"
        
        Alamofire.request(.POST, "https://api.voicetext.jp/v1/tts",
            headers: headers,
            parameters: [
                "text": yomi!,
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
    
// MARK - AVAudioPlayerDelegate
    
    //音楽再生が成功した時に呼ばれるメソッド.
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
//        print("Music Finish")
    }
    
    //デコード中にエラーが起きた時に呼ばれるメソッド.
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Audio Error")
        print(error)
    }
    

    
    var srcHelper: SRClientHelper?
    var settings: Dictionary<String, AnyObject>?
    var recognizedCallback: ((String, String?) -> Void)?

    func recognizeVoice(callback: (String, String?) -> Void) {
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
    
// MARK - SRClientHelperDelegate
    
    func srcDidRecognize(data: NSData!) {
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
    
    func srcDidReady() {
    }
    
    func srcDidSentenceEnd() {
    }
    
    func srcDidComplete(error: NSError!) {
        if (error) != nil {
            let description = error.localizedDescription
//            let reason = error.localizedFailureReason
            
            self.recognizedCallback!("", description)
        }
    }
    
    func srcDidRecord(pcmData: NSData!) {
//        double level = [self decibelFromData:pcmData];
//        [self performSelectorOnMainThread:@selector(updatePressureLevel:) withObject:[NSNumber numberWithDouble:level] waitUntilDone:NO];
    }

}

