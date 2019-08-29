//
//  ReplyData.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/26.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation
import UIKit

let reply_NumPerOneLoad = 4 //한 Load에 불러올 게시글의 수

class Reply {
    var replyname : String
    var replytext : String
    var replydate : Double
    
    init(_ replyname:String, _ replytext:String, _ replydate:Double){
        self.replyname = replyname
        self.replytext = replytext
        self.replydate = replydate
    }
}
