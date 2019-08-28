//
//  ReplyTableViewCell.swift
//  IFeedU
//
//  Created by Junhyeon on 2019/08/26.
//  Copyright © 2019 Junhyeon. All rights reserved.
//

import UIKit

class ReplyTableViewCell: UITableViewCell {

    //    닉네임
    @IBOutlet weak var ReplyName: UILabel?
    //    댓글
    @IBOutlet weak var ReplyText: UILabel?
    //    날짜
    @IBOutlet weak var ReplyDate: UILabel?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
