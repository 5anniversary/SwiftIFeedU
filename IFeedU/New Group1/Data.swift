//
//  Data.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/17.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation
import UIKit

let g_NumPerOneLoad = 3 //한 Load에 불러올 게시글의 수

class Post {
    var text : String
    var date : Int
    var imageView = UIImageView()
    
    init(_ text:String, _ date:Int){
        self.text = text
        self.date = date
    }
}
