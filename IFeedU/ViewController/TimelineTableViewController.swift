//
//  TimelineTableViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseUI

class TimelineTableViewController: UITableViewController {

    var ref:DatabaseReference?
    var storageRef:StorageReference?

    var posts = [Post]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Post]()          //Firebase에서 로드된 포스트들

    @IBOutlet weak var FooterLabel: UILabel!    //loading..메세지를 표시할 라벨
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!

    
    lazy var leftBarButton : UIBarButtonItem = {
        let button = UIBarButtonItem(title: "로그아웃", style: .plain, target: self, action: #selector(logoutButton))
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()    //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference()    //Firebase Storage 루트를 가리키는 레퍼런스
        
        loadPosts()     //Firebase에서 포스트들을 불러들임
        
        refreshControl = UIRefreshControl()         //최신글을 불러 들이기 위한 refreshControl
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(TimelineTableViewController.refresh), for: UIControl.Event.valueChanged)

        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue
        
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        
        self.tableView.separatorStyle = .none
        
        self.FooterLabel.textColor = UIColor(hex: color)
        self.view.backgroundColor = UIColor(hex: backgroundColor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    @IBAction func logoutButton(){
        try! Auth.auth().signOut()
        dismiss(animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineTableViewCell", for: indexPath) as! TimelineTableViewCell
        let post = posts[indexPath.row]
        tableView.rowHeight = 400
        cell.backgroundColor = UIColor(hex: backgroundColor)
        cell.tintColor = UIColor(hex: color)

        cell.nameLabel?.text = post.name
        cell.TextLabel?.text = post.text
        cell.ImageView?.image = post.imageView.image
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ArticleViewController") as? ArticleViewController
        
        let post = posts[indexPath.row]
        
        view?.mainText = post.text
        view?.img = post.imageView.image
        view?.timelineDate = post.date
        
        self.navigationController?.pushViewController(view!, animated: true)
    }
    
    func loadPosts(){
        var orderedQuery:DatabaseQuery?
        orderedQuery = ref?.child("posts").queryOrdered(byChild: "date")
        orderedQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                self.posts.removeAll()
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if  let text = dicDatum["text"],
                    let date = Double(dicDatum["date"]!){
                    let post = Post(text,date)
                    
                    //Get Image
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage(), completion:{(image,error,cacheType,imageURL) in self.tableView.reloadData() })
                    
                    self.loadedPosts += [post]
                }
            }
            
            self.posts += self.loadedPosts.prefix(g_NumPerOneLoad)
            self.tableView.reloadData()
        })
    }
    
    func loadFreshPosts(){
        var filteredQuery:DatabaseQuery?
        if let latestDate = self.posts.first?.date{
            filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(latestDate + 1)")
        }else{
            filteredQuery = ref?.child("posts").queryOrdered(byChild: "date").queryStarting(atValue: "\(0)")
        }
        
        filteredQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            var freshPostsChunk = [Post]()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if  let text = dicDatum["text"],
                    let date = Double(dicDatum["date"]!){
                    let post = Post(text, date)
                    
                    //Get Image from URL
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage())
                    
                    freshPostsChunk += [post]
                    
                }
            }
            self.loadedPosts.insert(contentsOf: freshPostsChunk, at: 0)
            self.posts.insert(contentsOf: freshPostsChunk, at: 0)
            self.tableView.reloadData()
        })
    }
    
    func loadPastPosts(){
        let pastPosts = self.loadedPosts.filter{$0.date < (self.posts.last?.date)!}
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        
        if pastChunkPosts.count > 0{
            self.posts += pastChunkPosts
            sleep(1)
            self.tableView.reloadData()
        }
    }
    
    @objc func refresh(){
        print("refresh")
        self.loadFreshPosts()
        self.refreshControl?.endRefreshing()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let  height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height + self.FooterLabel.frame.height - contentYoffset
        if distanceFromBottom < height {
            print(" you reached end of the table")
            loadPastPosts()
        }
    }

}

extension Int {
    var toDayTime : String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from:date)
    }
}
