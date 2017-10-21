//
//  NotenUIView.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class NotenView : UIView {
    
    @IBOutlet var haiImage: [UIImageView]!
    @IBOutlet weak var syantenLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}

