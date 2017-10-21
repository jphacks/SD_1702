//
//  TenpaiView.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class TenpaiView : UIView {
    
    @IBOutlet var gomiHaiImage: [UIImageView]!
    @IBOutlet var matiHaiImage: [UIImageView]!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
