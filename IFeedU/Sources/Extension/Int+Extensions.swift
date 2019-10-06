//
//  Int+Extensions.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/10/06.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation

extension Int {
    var toDayTime : String{
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from:date)
    }
}
