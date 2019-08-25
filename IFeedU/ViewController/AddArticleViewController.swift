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

class AddArticleViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var TextView: UITextView!
    @IBOutlet weak var ImageAdd: UIButton!
    
    let picker = UIImagePickerController()

    var image = UIImage()
    
    var ref: DatabaseReference?
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

        picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate

        ref = Database.database().reference()   //Firebase Database 루트를 가리키는 레퍼런스
        storageRef = Storage.storage().reference()  ////Firebase Storage 루트를 가리키는 레퍼런스
        
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
        
        ImageAdd.addTarget(self, action: #selector(imagePicker), for: .touchUpInside)
        ImageView.isUserInteractionEnabled = true
        ImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - TextView PlaceHolder
    func dismissKeyboard(){
        TextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.TextView.isEditable = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.TextView.isEditable = false
    }
    
    //MARK: - ImageView
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
//        self.ImageView.image = image
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }


    
    @IBAction func imagePicker(_ sender: Any){
        
        let alert =  UIAlertController(title: "원하는 타이틀", message: "원하는 메세지", preferredStyle: .actionSheet)
        
        let library =  UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
        }
        let camera =  UIAlertAction(title: "카메라", style: .default) { (action) in
            self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(library)
        alert.addAction(camera)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
//        imagePicker.allowsEditing = true
//        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//
//        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func openLibrary()
    {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
        else{
            print("Camera not available")
        }
    }



    @IBAction func uploadPost(){
        let curRef = self.ref?.child("posts").childByAutoId()
  
//        self.ref.child("users").child(uid!).setValue(["name": self.nameSVC.text!])
//
//        
//        curRef?.chile("uid").setValue(uid)
        curRef?.child("text").setValue(self.TextView.text)
        
        textViewDidEndEditing(TextView)

        let date = Date()
        let IntValueOfDate = Int(date.timeIntervalSince1970)
        curRef?.child("date").setValue("\(IntValueOfDate)")
        
        let imageRef = storageRef?.child((curRef?.key)!+".jpg")
        
        guard let uploadData = image.jpegData(compressionQuality: 0.1) else{
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
        
        process()
    }
    
    @IBAction func process(){
        let view = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
        
        self.present(view , animated: true, completion: nil)
    }
    
    @IBAction func cancel(){
        let view = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
    
        self.present(view , animated: true, completion: nil)

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
extension AddArticleViewController : UIImagePickerControllerDelegate,
UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage
        {
            self.ImageView.image = image
            print(info)
            
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    //
    //    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    //        dismiss(animated: true, completion: nil)
    //    }
    
}
