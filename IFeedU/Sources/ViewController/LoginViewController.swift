//
//  LoginViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - UI components

    @IBOutlet weak var emailLVC: UITextField!
    @IBOutlet weak var passwordLVC: UITextField!
    @IBOutlet weak var loginButtonLV: UIButton!
    @IBOutlet weak var signUpButtonLV: UIButton!
    
    // MARK: - Variables and Properties

    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

//        try! Auth.auth().signOut()
        
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
        
        loginButtonLV.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)
        signUpButtonLV.addTarget(self, action: #selector(presentSignUp), for: .touchUpInside)
        
        Auth.auth().addStateDidChangeListener{ (auth, user) in
            if(user != nil){
                let view = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController?
                view?.modalPresentationStyle = .fullScreen
                self.present(view!, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Helpers

    @IBAction func loginEvent(){
        Auth.auth().signIn(withEmail: emailLVC.text!, password: passwordLVC.text!){(user, err) in
            if(err != nil){
                self.defaultAlert(title: "에러발생", message: err.debugDescription)
            }
            
        }
    }
    
    @IBAction func presentSignUp() {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        view.modalPresentationStyle = .fullScreen
        self.present(view, animated: true, completion: nil)
    }
}
