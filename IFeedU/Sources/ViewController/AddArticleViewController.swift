//
//  AddArticleViewController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/23.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit

import Firebase
import FirebaseDatabase
import FirebaseStorage
import Fusuma

class AddArticleViewController: UIViewController {

    // MARK: - UI components
    
    @IBOutlet weak var addImageCollectionView: UICollectionView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var addTextView: UITextField!
    @IBOutlet weak var addPageView: UIPageControl!
    
    // MARK: - Variables and Properties
    
    var image = UIImage()
    var ref:DatabaseReference?
    var storageRef:StorageReference?
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String!
    var color : String!
    var barColor : String!
    
    lazy var leftBarButton : UIBarButtonItem = {
        let button = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(cancel))
        return button
    }()
    
    lazy var rigthBarButton : UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(uploadPost))
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()   //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference()  //Firebase Storage 루트를 가리키는 레퍼런스
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints{ (n) in
            n.right.top.left.equalTo(self.view)
            n.height.equalTo(45)
        }
        
        self.navigationItem.rightBarButtonItem = self.rigthBarButton
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        
        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue
        barColor = remoteconfig["splash_barcolor"].stringValue
        
        self.view.backgroundColor = UIColor(hex: backgroundColor)
        statusBar.backgroundColor = UIColor(hex: barColor)
                
        addImageView.isUserInteractionEnabled = true
        addImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fusumaImagePicker)))

    }
        
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
//        self.ImageView.image = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Helpers
    
    func dismissKeyboard(){
        addTextView.resignFirstResponder()
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    @IBAction func uploadPost(){
        let curRef = self.ref?.child("posts").childByAutoId()
        
        let image = self.addImageView.image
        
        // 내용이 입력되지 않았을 경우 알람
        if addTextView.text! == "내용입력" || addTextView.text! == "" {
            defaultAlert(title: "내용을 입력하지 않았습니다.", message: "내용을 입력해주세요.")
        }
        
        // 이미지가 추가되지 않았을 경우 알람
        if image == nil {
            defaultAlert(title: "이미지를 추가하지 않았습니다.", message: "이미지를 추가해주세요.")
        }
        
        let userID = Auth.auth().currentUser?.uid
        self.ref?.child("users").child(userID!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let username = value?["name"] as? String ?? ""
            curRef?.child("replyname").setValue(username)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        curRef?.child("text").setValue(self.addTextView.text)
        curRef?.child("refcode").setValue(curRef?.key)
        
        let date = Date()
        let DoubleValueOfDate = Double(date.timeIntervalSince1970)
        curRef?.child("date").setValue("\(DoubleValueOfDate)")
            
        let imageRef = storageRef?.child((curRef?.key)!+".jpg")

        guard let uploadData =
            image?.jpegData(compressionQuality: 0.7) else{
            return
        }

        imageRef?.putData(uploadData, metadata: nil, completion:{ metadata, error in
            if error != nil {
                // 에러 발생
                print("firebase 사진 업로드 에러")
            } else {
                // Metadata는 size, content-type, download URL과 같은 컨텐트의 메타데이터를 가진다
            }
        })
        
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancel(){
        dismiss(animated: true)
    }
    
}

// MARK: -FusumaDelegate
extension AddArticleViewController : FusumaDelegate {
    
    @IBAction func fusumaImagePicker(){
        let fusuma = FusumaViewController()

        fusuma.delegate = self
        fusuma.cropHeightRatio = 1.0
        fusuma.allowMultipleSelection = true
        fusuma.availableModes = [.library, .video, .camera]
        fusuma.photoSelectionLimit = 4
        fusumaSavesImage = true

        present(fusuma, animated: true, completion: nil)
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        switch source {
        case .camera:
            print("Image captured from Camera")
        case .library:
            print("Image selected from Camera Roll")
        default:
            print("Image selected")
        }

        addImageView.image = image
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        print("Number of selection images: \(images.count)")

        var count: Double = 0

        for image in images {
            DispatchQueue.main.asyncAfter(deadline: .now() + (3.0 * count)) {
                self.addImageView.image = image
                print("w: \(image.size.width) - h: \(image.size.height)")
            }

            count += 1
        }
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }

}
