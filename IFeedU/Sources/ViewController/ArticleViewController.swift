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

    // MARK: - UI components
    
    @IBOutlet weak var articleImageView: UIImageView!
    @IBOutlet weak var articleTextView: UITextView!
    @IBOutlet weak var replyTextView: UITextField!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var articleTableView: UITableView!
    
    // MARK: - Variables and Properties
    
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

    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intTimelineDate = Int(timelineDate!)
        
        ref = Database.database().reference()   //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference()  //Firebase Storage 루트를 가리키는 레퍼런스
        
        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue

        self.view.backgroundColor = UIColor(hex: backgroundColor)
        articleTableView.backgroundColor = UIColor(hex: backgroundColor)
        
        articleTextView.text = mainText
        articleImageView.image = img
        
        replyButton.backgroundColor = UIColor(hex: color)
        replyButton.tintColor = UIColor(white: 1.0, alpha: 1.0)
        replyButton.addTarget(self, action: #selector(uploadReply), for: .touchUpInside)

        articleTableView.separatorStyle = .none
        
        replyTextView.delegate = self
        replyTextView.returnKeyType = .done
        replyTextView.backgroundColor = UIColor(hex: backgroundColor)
        replyTextView.textColor = UIColor(hex: color)
        replyTextView.attributedPlaceholder = NSAttributedString(string: "댓글을 입력해주세요.", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: color)])

        // 키보드 활성화시 댓글뷰어의 pop
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        self.articleTextView.isEditable = false

    }
    override func viewDidDisappear(_ animated: Bool) {
        self.articleTextView.isEditable = false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    // MARK: -Helpers
    
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
            self.articleTableView.reloadData()
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
            self.articleTableView.reloadData()
        })
        
        func loadPastReplys(){
            let pastReplys = self.loadedReplys.filter{$0.replydate < (self.replys.last?.replydate)!}
            let pastChunkReplys = pastReplys.prefix(reply_NumPerOneLoad)
            
            if pastChunkReplys.count > 0{
                self.replys += pastChunkReplys
                sleep(1)
                self.articleTableView.reloadData()
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

        if replyTextView.text! == "" {
            defaultAlert(title: "댓글을 입력하지 않았습니다.", message: "댓글을 입력해주세요.")
        }

        curRef?.child("replytext").setValue(self.replyTextView.text)
        
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

// MARK: -UITextFieldDelegate

extension ArticleViewController : UITextFieldDelegate {
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        replyTextView.endEditing(true)
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        replyTextView.resignFirstResponder()
        return true
    }
}

// MARK: -UITableViewDataSource

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

