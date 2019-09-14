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
import Fusuma

class ArticleViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    var ref:DatabaseReference?
    var storageRef:StorageReference?

    var replys = [Reply]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedReplys = [Reply]()          //Firebase에서 로드된 포스트들
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!
    
    var mainText : String?
    var timelineDate : Double?
    var intTimelineDate : Int!
    var img : UIImage?
    
    lazy var rightBarButton : UIBarButtonItem = {
        let button = UIBarButtonItem(title: "삭제", style: .plain, target: self, action: #selector(deleteArticle))
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        intTimelineDate = Int(timelineDate!)
        
        ref = Database.database().reference()   //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference()  //Firebase Storage 루트를 가리키는 레퍼런스
        
        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue

        self.view.backgroundColor = UIColor(hex: backgroundColor)
        tableView.backgroundColor = UIColor(hex: backgroundColor)
        
        textView.text = mainText
        imageView.image = img
        
        replyButton.backgroundColor = UIColor(hex: color)
        replyButton.tintColor = UIColor(white: 1.0, alpha: 1.0)
                
        replyButton.addTarget(self, action: #selector(uploadReply), for: .touchUpInside)
        replyTextField.backgroundColor = UIColor(hex: backgroundColor)
        
        tableView.separatorStyle = .none
        
        replyTextField.delegate = self as? UITextFieldDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.textView.isEditable = false

    }
    override func viewDidDisappear(_ animated: Bool) {
        self.textView.isEditable = false
    }
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -300   // Move view 300 points upward
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0 // Move view to original position
    }

    func loadReply(){
        var orderedQuery:DatabaseQuery?
//        orderedQuery = ref?.child("replys").child("\(String(describing: intTimelineDate))").queryOrdered(byChild: "replydate")
        orderedQuery = ref?.child("replys").child("\(String(describing: intTimelineDate))").queryOrdered(byChild: "replydate")
        
        orderedQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
        
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                self.replys.removeAll()
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as? [String:String] ?? [:]
                if  let name = dicDatum["replyname"],
                    let text = dicDatum["replytext"],
                    let date = Double(dicDatum["replydate"]!){
                    let reply = Reply(name,text,date)
                    
                    
                    self.loadedReplys += [reply]
                }
            }
            
            self.replys += self.loadedReplys.prefix(reply_NumPerOneLoad)
            self.tableView.reloadData()
        })

    }
    
    func loadFreshReplys(){
        var filteredQuery:DatabaseQuery?
        if let latestDate = self.replys.first?.replydate{
            filteredQuery = ref?.child("replys").child("\(String(describing: intTimelineDate))").queryOrdered(byChild: "replydate").queryStarting(atValue: "\(latestDate + 1)")
        }else{
            filteredQuery = ref?.child("replys").child("\(String(describing: intTimelineDate))").queryOrdered(byChild: "replydate").queryStarting(atValue: "\(0)")
        }
        
        filteredQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            var freshPostsChunk = [Reply]()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as? [String:String] ?? [:]
                if  let name = dicDatum["replyname"],
                    let text = dicDatum["replytext"],
                    let date = Double(dicDatum["replydate"]!){
                    let reply = Reply(name,text,date)

                    freshPostsChunk += [reply]
                }
            }
            self.loadedReplys.insert(contentsOf: freshPostsChunk, at: 0)
            self.replys.insert(contentsOf: freshPostsChunk, at: 0)
            self.tableView.reloadData()
        })
        
        func loadPastReplys(){
            let pastReplys = self.loadedReplys.filter{$0.replydate < (self.replys.last?.replydate)!}
            let pastChunkReplys = pastReplys.prefix(reply_NumPerOneLoad)
            
            if pastChunkReplys.count > 0{
                self.replys += pastChunkReplys
                sleep(1)
                self.tableView.reloadData()
            }
        }
        
        func refresh(){
            print("refresh")
            self.loadFreshReplys()
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let  height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            if distanceFromBottom < height {
                print(" you reached end of the table")
                loadPastReplys()
                
            }
        }

    }

    
    @IBAction func uploadReply(){
//        let curRef = self.ref?.child("replys").child("\(timelineDate))")
        let curRef = self.ref?.child("replys").child("\(String(describing: intTimelineDate))").childByAutoId()
        
        let userID = Auth.auth().currentUser?.uid
        self.ref?.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["name"] as? String ?? ""
            curRef?.child("replyname").setValue(username)
        }) { (error) in
            print(error.localizedDescription)
        }

        if replyTextField.text! == "" {
            defaultAlert(title: "댓글을 입력하지 않았습니다.", message: "댓글을 입력해주세요.")
        }

        curRef?.child("replytext").setValue(self.replyTextField.text)
        
        let dateformmater = DateFormatter()
        let date = Date()
        dateformmater.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let DateValueOfDate = date.timeIntervalSince1970
        curRef?.child("replydate").setValue("\(DateValueOfDate)")
        
        loadReply()
    }
    
    @IBAction func deleteArticle(){
        
    }
    
}

extension ArticleViewController : UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.replys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let replycell = tableView.dequeueReusableCell(withIdentifier: "ReplyTableViewCell", for: indexPath) as! ReplyTableViewCell
        let reply = replys[indexPath.row]
//        var date = Date()
//        cell.ReplyDate?.text = reply.replydate
        replycell.ReplyName?.text = reply.replyname
        replycell.ReplyText?.text = reply.replytext

        return replycell
    }
}

