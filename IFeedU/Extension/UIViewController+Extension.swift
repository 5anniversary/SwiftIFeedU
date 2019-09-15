//
//  UIViewController+Extension.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/09/12.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func defaultAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func exitAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: { (action) in
            exit(0)
        }))
        self.present(alert, animated: true, completion: nil)        
    }
    
    func sheetAlert(){
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "취소", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // 키보드가 나타날시에 view의 y축 올림
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -290  // Move view 333 points upward
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }
}
