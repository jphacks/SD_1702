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
    var canSetNull = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for (k, iv) in self.haiImageViews.enumerated() {
            if(k < 34) {
                iv.image = Tile(rawValue: k)?.toUIImage()
            } else {
                iv.image = Tile.null.toUIImage()
            }
            //imageViewをボタン化
            iv.isUserInteractionEnabled = true
            let gesture = AgariTapGestureRecognizer(target: self, action: #selector(HaiSelecterViewController.haiImageViewTapped(_:)))
            gesture.index = k
            iv.addGestureRecognizer(gesture)
        }
        if(canSetNull) {
            self.haiImageViews[34].isHidden = false
        }
    }
    
    // 画像がタップされたら呼ばれる
    @objc func haiImageViewTapped(_ sender: AgariTapGestureRecognizer) {
        if(sender.index! < 34) {
            delegate?.selectedHai(index: haiIndex, tile: Tile(rawValue: sender.index!)!)
        } else {
            delegate?.selectedHai(index: haiIndex, tile: Tile.null)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

