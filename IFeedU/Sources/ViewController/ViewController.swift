//
//  ViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit

import Firebase
import SnapKit

class ViewController: UIViewController {
    
    // MARK: - Variables and Properties

    var box = UIImageView()
    var remoteConfig : RemoteConfig!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        let backgroundColor : String! = remoteConfig["splash_background"].stringValue
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(0)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate(completionHandler: { (error) in
                    // ...
                })
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
            self.displayWelcome()
        }
        
        self.view.backgroundColor = UIColor(hex: backgroundColor!)
        
        self.view.addSubview(box)
        box.snp.makeConstraints{ (make) in
            make.center.equalTo(self.view)
        }
        box.image = UIImage(named: "sticks")
    
    }
    
    // MARK: - Helpers

    func displayWelcome(){
        
        let backgroundColor : String! = remoteConfig["splash_background"].stringValue
        let caps = remoteConfig["splash_message_caps"].boolValue
        let message = remoteConfig["splash_message"].stringValue
        
        if(caps){
            exitAlert(title: "공지사항", message: message!)
        } else {
            let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .overFullScreen
            
            self.present(loginVC, animated: false, completion: nil)
        }
        self.view.backgroundColor = UIColor(hex: backgroundColor!)
    }
    
}
