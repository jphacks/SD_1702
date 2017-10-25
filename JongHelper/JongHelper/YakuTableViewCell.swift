//
//  YakuTableViewCell.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/25.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class YakuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var yakuLabel: UILabel!
    @IBOutlet weak var hanLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
