//
//  ViewController.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/09.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CameraDelegate {
    
    var timer: NSTimer?
    var timerCounter = 0
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Camera.shared.delegate = self
        Camera.shared.start()
        
        let label = UILabel(frame: CGRectMake(20, 20, 400, 30))
        label.text = "ダミーテキスト"
        view.addSubview(label)
        
        let voiceButton = UIButton(frame: CGRectMake(20, 60, 400, 30))
        voiceButton.setTitle("音声認識", forState: .Normal)
        voiceButton.backgroundColor = UIColor.blueColor()
        voiceButton.rx_tap.subscribeNext { _ in
            Listener.shared.listen({ (message, error) -> Void in
                if message == "" {
                    label.text = "認識失敗"
                }
                else {
                    label.text = message
                    Speaker.shared.speak(message)
                    Japanese.shared.parse(message, callback: { (xml) -> Void in
                        print(xml)
                    })
                }
            })
        }.addDisposableTo(disposeBag)
        
        view.addSubview(voiceButton)
        
        view.backgroundColor = UIColor.whiteColor()
    }
    
    func timerUpdate() {
        if timerCounter++ >= 2 {
            view.backgroundColor = UIColor.whiteColor()
            self.timer?.invalidate()
        }
    }
    
    // MARK: - CameraDelegate
    
    func detectMotion() {
        if view.backgroundColor == UIColor.whiteColor() {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "timerUpdate", userInfo: nil, repeats: true)
            view.backgroundColor = UIColor.redColor()
        }
        self.timerCounter = 0
    }
}

