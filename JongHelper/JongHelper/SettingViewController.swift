//
//  SettingViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/24.
//  Copyright © 2017年 tomato. All rights reserved.
//


import UIKit

class SettingViewController: UIViewController {
    @IBOutlet weak var tableViewJikaze: UITableView!
    @IBOutlet weak var tableViewBakaze: UITableView!
    @IBOutlet var doraTableViews: [UITableView]!
    @IBAction func pushClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.bring
    }
    

}
