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

class AddArticleViewController: UIViewController, FusumaDelegate {

    @IBOutlet weak var AddImageCollectionView: UICollectionView!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TextView: UITextField!
    @IBOutlet weak var pageView: UIPageControl!
    
    let picker = UIImagePickerController()

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
                
        ImageView.isUserInteractionEnabled = true
        ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fusumaImagePicker)))

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard(){
        TextView.resignFirstResponder()
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
//        self.TextView.isEditable = true
    }
    override func viewDidDisappear(_ animated: Bool) {
//        self.TextView.isEditable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
//        self.ImageView.image = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    // Mark : Fusuma
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

        ImageView.image = image
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        print("Number of selection images: \(images.count)")

        var count: Double = 0

        for image in images {
            DispatchQueue.main.asyncAfter(deadline: .now() + (3.0 * count)) {
                self.ImageView.image = image
                print("w: \(image.size.width) - h: \(image.size.height)")
            }

            count += 1
        }
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 79
        let currentString: NSString = TextView.text! as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
    }
    
    @IBAction func uploadPost(){
        let curRef = self.ref?.child("posts").childByAutoId()
        
        let image = self.ImageView.image
        
        // 내용이 입력되지 않았을 경우 알람
        if TextView.text! == "내용입력" || TextView.text! == "" {
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
        
        curRef?.child("text").setValue(self.TextView.text)
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

extension AddArticleViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let vc = cell.viewWithTag(111) as? UIImageView{
            vc.image = imgArr[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
        
}

