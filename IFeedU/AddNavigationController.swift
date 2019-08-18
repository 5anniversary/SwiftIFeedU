//
//  AddNavigationController.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit
import Firebase
import Fusuma

class AddNavigationController: UINavigationController, FusumaDelegate {

    let fusuma = FusumaViewController()
    var uploadController = UploadViewController()
    let storyBoard = UIStoryboard(name: "Main", bundle: nil)
    
    let remoteconfig = RemoteConfig.remoteConfig()
    var backgroundColor : String?
    var color : String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        fusumaTintColor = UIColor.black
        fusumaBaseTintColor = UIColor.black
        fusumaBackgroundColor = UIColor.white
        
        fusuma.delegate = self
//        fusuma.hasVideo = false
        fusuma.cropHeightRatio = 0.6
        fusuma.allowMultipleSelection = false

        let statusBar = UIView()

        backgroundColor = remoteconfig["splash_background"].stringValue
        color = remoteconfig["splash_color"].stringValue

        
        statusBar.backgroundColor = UIColor(hex: backgroundColor!)
        self.view.backgroundColor = UIColor(hex: backgroundColor!)

    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
}
