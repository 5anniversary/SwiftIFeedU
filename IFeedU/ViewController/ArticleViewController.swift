//
//  ArticleViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/24.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class ArticleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var replyButton: UIButton!

    var ref:DatabaseReference?
    var storageRef:StorageReference?

    var replys = [Reply]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Reply]()          //Firebase에서 로드된 포스트들
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!
    var mainText : String?
    var timelineDate : Int?
    var img : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue

        self.view.backgroundColor = UIColor(hex: backgroundColor)
        
        textView.text = mainText
        imageView.image = img
        
        replyButton.backgroundColor = UIColor(hex: color)
        replyButton.tintColor = UIColor(white: 1.0, alpha: 1.0)
        
        replyButton.addTarget(self, action: #selector(uploadReply), for: .touchUpInside)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
                self.textView.isEditable = false
    }
    override func viewDidDisappear(_ animated: Bool) {
                self.textView.isEditable = false
    }
    
    

//    func loadPost(){
//        var orderedQuery:DatabaseQuery?
//        orderedQuery = ref?.child("posts").child(refcode!)
//        orderedQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
////            Get user value
////            let value = snapshot.value as? NSDictionary
////            let username = value?["username"] as? String ?? ""
////            let user = User(username: username)
//            let value = snapshot.value as? NSDictionary
//            let text = value?["text"] as? String
//            let imageRef = self.storageRef?.child("\(self.refcode).jpg")
//            self.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage(), completion:{(image,error,cacheType,imageURL) in
//
//            })
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//    }
//
    func loadReply(){
        
        
    }
    
    @IBAction func uploadReply(){
        let curRef = self.ref?.child("replys").child("\(timelineDate)")
        
        if replyTextField.text! == "" {
            let alert = UIAlertController(title: "댓글을 입력하지 않으셨습니다", message: "댓글을 입력해주세요.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        curRef?.child("replytext").setValue(self.replyTextField.text)

        let dateformmater = DateFormatter()
        let date = Date()
        dateformmater.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let DateValueOfDate = date.timeIntervalSince1970
        curRef?.child("replydate").setValue("\(DateValueOfDate)")
        
//        loadPost()
    }
}

class ReplyTableView: UITableView {
    
    var ref:DatabaseReference?
    var storageRef:StorageReference?

    let config = RemoteConfig.remoteConfig()
    var groundColor : String!
    var color : String!
    
//    groundColor = config["splash_background"].stringValue
//    color = config["splash_color"].stringValue
    
    var replys = [Reply]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Reply]()          //Firebase에서 로드된 포스트들
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.replys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyTableViewCell
        let reply = replys[indexPath.row]
//        cell.backgroundColor = UIColor(hex: groundColor)
        
        let dateFormatter = DateFormatter()
        
        let replydate = dateFormatter.string(from: reply.replydate)
        cell.ReplyDate?.text = replydate
        cell.ReplyName?.text = reply.replyname
        cell.ReplyText?.text = reply.replytext
        
        return cell
    }

}
