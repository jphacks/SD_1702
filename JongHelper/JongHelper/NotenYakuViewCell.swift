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
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // progressView.transform = transform.scaledBy(x: 1.0, y: 2.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setYakuInfo(_ yaku: (Yaku, Float)) {
        yakuNameLabel.text = yaku.0.getName()
        yakuDescLabel.text = yaku.0.getDesc()
        if(yaku.0.getHan() == -1) {
            hanLabel.text = "役満"
        } else {
            hanLabel.text = String(yaku.0.getHan()) + "飜"
        }
        progressView.progress = yaku.1
    }
    
}
