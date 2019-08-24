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

    var ref:DatabaseReference?
    var storageRef:StorageReference?
    
    var posts = [Post]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Post]()          //Firebase에서 로드된 포스트들
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue

        self.view.backgroundColor = UIColor(hex: backgroundColor)
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineTableViewCell
        let post = posts[indexPath.row]
        cell.TextLabel?.text = post.text
        cell.ImageView?.image = post.imageView.image
        
        return cell
    }


    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
