//
//  ViewController.swift
//  WEGExtensionApp
//
//  Created by Yogesh Singh on 04/12/18.
//  Copyright © 2018 Yogesh Singh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                
                if let dict = UserDefaults.standard.object(forKey: "WEGPushPayload") {
                 
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dict)
                        if let json = String(data: jsonData, encoding: .utf8) {
                            print(json)
                            NSLog("fetched Push paylods: \(json))")
                        }
                    } catch {
                        print("something went wrong with parsing json")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

