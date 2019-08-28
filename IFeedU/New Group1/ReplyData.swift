//
//  ReplyData.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/26.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation
import UIKit

class Reply {
    var replyname : String
    var replytext : String
    var replydate : Date
    
    init(_ replyname : String,_ replytext:String, _ replydate:Date){
        self.replyname = replyname
        self.replytext = replytext
        self.replydate = replydate
    }
}
