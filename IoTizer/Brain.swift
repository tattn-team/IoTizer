//
//  Brain.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/13.
//  Copyright © 2016年 tattn. All rights reserved.
//

import Foundation

class Brain {
    static let shared = Brain()
    
    func input(message: String) {
        print("[INPUT] \(message)")
        var command = 0
        var name = ""
        Japanese.shared.parse(message) { (result) -> Void in
            for word in result["word_list"]["word"]{
                print(word)
                let pos = word["pos"].element?.text
                let reading = word["reading"].element?.text
                
                if pos == "動詞" && (reading == "いれ" || reading == "かって"){
                    command = 1
                }
                else if pos == "動詞" && (reading == "つかう" || reading == "なくなっ" || reading == "おわり"){
                    command = 2
                }
                else if pos == "名詞"{
                    if reading == "こうにゅう" || reading == "ついか"{
                        command = 1
                    }
                    else if reading == "さくじょ" || reading == "しょうきょ"{
                        command = 2
                    }
                    else{
                        name = reading!
                    }
                    
                }
            }
            if command == 1{
                InventoryManager.shared.addInventory(name)
            }
            else if command == 2{
                InventoryManager.shared.removeInventry(name)
            }
            print("[INPUTED] \(command): \(name)")
        }
    }
}