//
//  SchoolCrwaling.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/19.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

let isBaseUrl = "http://skhu.ac.kr/uni_zelkova/uni_zelkova_4_3_view.aspx?"
let week = "idx="+String(373)+"&curpage=1"
let url = URL(string: isBaseUrl + week)!

let encodingEUCKR = CFStringConvertEncodingToNSStringEncoding(0x0422)

let task = URLSession.shared.dataTask(with: url) { (data, resp, error) in
    
    guard let data = data else {
        print("data was nil")
        return
    }
    
    guard let htmlString = String(data: data, encoding: String.Encoding(rawValue: encodingEUCKR)) else{
        print("cannot case data init String")
        return
    }
    
    let leftSideOfTheValue = """
    <tr>
    <th scope="row" rowspan="6" class="first">중식</th>
    """
    
    //    guard let  else {
    //
    //    }
    
    print(htmlString)
}

task.resume()
