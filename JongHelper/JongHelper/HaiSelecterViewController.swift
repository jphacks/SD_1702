//
//  HaiSelecterViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/26.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

protocol HaiSelecterDelegate {
    func selectedHai(index: Int, tile: Tile)
}

class HaiSelecterViewController: UIViewController {
    
    @IBOutlet var haiImageViews: [UIImageView]!
    
    var delegate: HaiSelecterDelegate?
    var haiIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (k, iv) in self.haiImageViews.enumerated() {
            iv.image = Tile(rawValue: k)?.toUIImage()
            //imageViewをボタン化
            iv.isUserInteractionEnabled = true
            let gesture = AgariTapGestureRecognizer(target: self, action: #selector(HaiSelecterViewController.haiImageViewTapped(_:)))
            gesture.index = k
            iv.addGestureRecognizer(gesture)
        }
    }
    
    // 画像がタップされたら呼ばれる
    @objc func haiImageViewTapped(_ sender: AgariTapGestureRecognizer) {
        delegate?.selectedHai(index: haiIndex, tile: Tile(rawValue: sender.index!)!)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

