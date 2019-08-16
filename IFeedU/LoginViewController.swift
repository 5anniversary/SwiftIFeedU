//
//  LoginViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/15.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailLVC: UITextField!
    @IBOutlet weak var passwordLVC: UITextField!
    @IBOutlet weak var loginButtonLV: UIButton!
    @IBOutlet weak var signUpButtonLV: UIButton!
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        try! Auth.auth().signOut()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints{ (n) in
            n.right.top.left.equalTo(self.view)
            n.height.equalTo(20)
        }
        
        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue
        
        //statusBar.backgroundColor = UIColor(hex: color)
        loginButtonLV.backgroundColor = UIColor(hex: color)
        signUpButtonLV.backgroundColor = UIColor(hex: color)
        
        self.view.backgroundColor = UIColor(hex: backgroundColor)
        // Do any additional setup after loading the view.
        
        loginButtonLV.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        signUpButtonLV.addTarget(self, action: #selector(presentSignUp), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener{ (auth, user) in
            if(user != nil){
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
                self.present(view, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginEvent(){
        Auth.auth().signIn(withEmail: emailLVC.text!, password: passwordLVC.text!){(user, err) in
            if(err != nil){
                let alert = UIAlertController(title: "에러 발생", message: err.debugDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    
    @IBAction func presentSignUp() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.present(view, animated: true, completion: nil)
    }
}
