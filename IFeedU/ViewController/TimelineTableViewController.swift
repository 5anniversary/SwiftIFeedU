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

//    lazy var rigthBarButton : UIBarButtonItem = {
//        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton))
//
//        return button
//    }()
    
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
        
//        self.navigationItem.rightBarButtonItem = self.rigthBarButton
        self.navigationItem.leftBarButtonItem = self.leftBarButton

        self.FooterLabel.textColor = UIColor(hex: color)
        self.view.backgroundColor = UIColor(hex: backgroundColor)
//        self.navigationController?.navigationBar.tintColor = UIColor(hex: color)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineTableViewCell
        let post = posts[indexPath.row]
        cell.TextLabel?.text = post.text
        cell.ImageView?.image = post.imageView.image
        
        return cell
    }

    @IBAction func logoutButton(){
        let view = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        try! Auth.auth().signOut()
        self.present(view , animated: true, completion: nil)
    }

    @IBAction func loadPosts(){
        var orderedQuery:DatabaseQuery?
        orderedQuery = ref?.child("posts").queryOrdered(byChild: "date")
        
        orderedQuery?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            var snapshotData = snapshot.children.allObjects
            snapshotData = snapshotData.reversed()
            
            for anyDatum in snapshotData{
                let snapshotDatum = anyDatum as! DataSnapshot
                let dicDatum = snapshotDatum.value as! [String:String]
                if  let title = dicDatum["title"],
                    let text = dicDatum["text"],
                    let date = Int(dicDatum["date"]!){
                    let post = Post(title,text,date)
                    
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
    
    @IBAction func loadFreshPosts(){
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
                if  let title = dicDatum["title"],
                    let text = dicDatum["text"],
                    let date = Int(dicDatum["date"]!){
                    let post = Post(title,text,date)
                    
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
    @IBAction func loadPastPosts(){
        let pastPosts = self.loadedPosts.filter{$0.date < (self.posts.last?.date)!}
        let pastChunkPosts = pastPosts.prefix(g_NumPerOneLoad)
        
        if pastChunkPosts.count > 0{
            self.posts += pastChunkPosts
            sleep(1)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Reload Posts
    @IBAction func refresh(){
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

    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
