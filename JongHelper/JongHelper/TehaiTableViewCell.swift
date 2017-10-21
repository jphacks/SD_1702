//
//  TehaiTableViewCell.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class TehaiTableViewCell: UITableViewCell {
    
    @IBOutlet weak var haiImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
