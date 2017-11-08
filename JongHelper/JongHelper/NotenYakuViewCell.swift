//
//  NotenYakuViewCell.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/11/08.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class NotenYakuViewCell: UITableViewCell {
    
    @IBOutlet weak var yakuNameLabel: UILabel!
    @IBOutlet weak var yakuDescLabel: UILabel!
    @IBOutlet weak var hanLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setYakuInfo(_ yaku: Yaku) {
        yakuNameLabel.text = yaku.getName()
        yakuDescLabel.text = yaku.getDesc()
        if(yaku.getHan() == -1) {
            hanLabel.text = "役満"
        } else {
            hanLabel.text = String(yaku.getHan()) + "飜"
        }
    }
    
}
