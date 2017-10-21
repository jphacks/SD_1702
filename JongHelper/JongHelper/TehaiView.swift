//
//  TehaiView.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

protocol TehaiViewDelegate {
    func pushCapture()
}


class TehaiView: UIView {
    
    var delegate: TehaiViewDelegate?
    
    @IBOutlet var tableViews: [UITableView]!
    @IBOutlet var tableViewDora: [UITableView]!
    @IBOutlet weak var tableViewJikaze: UITableView!
    @IBOutlet weak var tableViewBakaze: UITableView!
    
    @IBAction func pushCapture(_ sender: UIButton) {
        delegate?.pushCapture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
}
