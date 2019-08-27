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
//
    var ref:DatabaseReference?
    var storageRef:StorageReference?
//
    var replys = [Reply]()                //테이블 뷰에 표시될 포스트들을 담는 배열
    var loadedPosts = [Reply]()          //Firebase에서 로드된 포스트들
    
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
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.replys.count
//    }
//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as! ReplyTableViewCell
        let reply = replys[indexPath.row]
        cell.backgroundColor = UIColor(hex: backgroundColor)
        

        return cell
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
                if let text = dicDatum["text"],
                    let date = Int(dicDatum["date"]!){
                    let post = Post(text,date)

                    //Get Image
                    let imageRef = self.storageRef?.child("\(snapshotDatum.key).jpg")
                    post.imageView.sd_setImage(with: imageRef!, placeholderImage: UIImage(), completion:{(image,error,cacheType,imageURL) in

                    })

                    self.loadedPosts += [replys]
                }
            }

            self.replys += self.loadedPosts.prefix(g_NumPerOneLoad)
            self.tableView.reloadData()
        })
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
