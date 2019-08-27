//
//  SignUpViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailSVC: UITextField!
    @IBOutlet weak var nameSVC: UITextField!
    @IBOutlet weak var passwordSVC: UITextField!
    @IBOutlet weak var signupButtonSVC: UIButton!
    @IBOutlet weak var cancelButtonSVC: UIButton!
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String?
    var color : String?
    var ref : DatabaseReference!
    
    let alert = UIAlertController(title: "title", message: "message", preferredStyle: UIAlertController.Style.alert)
    let signUpError = UIAlertAction(title: "Error", style: .default, handler: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints{ (n) in
            n.right.top.left.equalTo(self.view)
            n.height.equalTo(20)
            
        }
        
        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: backgroundColor!)
        self.view.backgroundColor = UIColor(hex: backgroundColor!)
        signupButtonSVC.backgroundColor = UIColor(hex: color!)
        cancelButtonSVC.backgroundColor = UIColor(hex: color!)
        
        signupButtonSVC.addTarget(self, action: #selector(signUpEvent), for: .touchUpInside)
        cancelButtonSVC.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    
    @IBAction func signUpEvent(_ sender: AnyObject){
        if emailSVC.text! == "" || passwordSVC.text! == "" || nameSVC.text! == "" {
            print("정상적으로 입력이 되지 않았습니다.")
            let alert = UIAlertController(title: "입력 불충분", message: "이메일, 이름, 비밀번호 중 하나 이상을 입력하지 않았습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        Auth.auth().createUser(withEmail: emailSVC.text!, password: passwordSVC.text!) { (user, err) in
            let uid = user?.user.uid
            self.ref = Database.database().reference()
            self.ref.child("users").child(uid!).setValue(["name": self.nameSVC.text!])
            let alert = UIAlertController(title: "회원가입", message: "완료", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
            print("email : "+self.emailSVC.text!+" password : "+self.passwordSVC.text!)
        }
        close()
    }
    
    func close(){
        login()
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(view , animated: true, completion: nil)
    }
    
    func login(){
        Auth.auth().signIn(withEmail: emailSVC.text!, password: passwordSVC.text!){(user, err) in
            if(err != nil){
                let alert = UIAlertController(title: "에러 발생", message: err.debugDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }

    }
    
    @IBAction func cancelEvent(){
        self.dismiss(animated: true, completion: nil)
    }
}
