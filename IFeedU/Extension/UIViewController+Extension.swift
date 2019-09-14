//
//  UIViewController+Extension.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/09/12.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController : UITextViewDelegate, UITableViewDelegate {
    
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
    
    
}
