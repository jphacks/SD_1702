//
//  TokutenViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/22.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class TokutenViewController: UIViewController {
    
    @IBOutlet var tileImage: [UIImageView]!
    @IBOutlet var doraImage: [UIImageView]!
    @IBOutlet weak var jikazemage: UIImageView!
    @IBOutlet weak var bakazemage: UIImageView!
    @IBOutlet weak var tumoSW: UISwitch!
    @IBOutlet weak var hanLabel: UILabel!
    @IBOutlet weak var hanStepper: UIStepper!
    @IBOutlet weak var yakuTV: UITextView!
    @IBOutlet weak var huLabel: UILabel!
    @IBOutlet weak var tenLabel: UILabel!
    
     var tehaiTileArray: [Tile] = []
     var doraTileArray: [Tile] = [Tile.m1, Tile.null, Tile.null, Tile.null]
     var bakazeTile = Tile.Ton
     var jikazeTile = Tile.Ton
    // var yakuStr = ""
    var suteTile: Tile!
    var matiTile: Tile!
    
    var isTsumo = false
    var plushan = 0
    
    @IBAction func pushClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        plushan = Int(sender.value)
        calculate()
    }
    
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        isTsumo = sender.isOn
        calculate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for (k, elem) in tehaiTileArray.enumerated() {
            if (elem == suteTile) {
                tehaiTileArray.remove(at: k)
                break
            }
        }
        tehaiTileArray.append(matiTile)
        
        for (k, elem) in tehaiTileArray.enumerated() {
            tileImage[k].image = elem.toUIImage()
        }
        for (k, elem) in doraTileArray.enumerated() {
            doraImage[k].image = elem.toUIImage()
        }
        jikazemage.image = jikazeTile.toUIImage()
        bakazemage.image = bakazeTile.toUIImage()
        calculate()
    }
    
    func calculate() {
        let normalYakuList = [NormalYaku]()
        
        let gs = GeneralSituation(isHoutei: false, bakaze: bakazeTile, dora: doraTileArray, honba: 1)
        let ps = PersonalSituation(isTsumo: isTsumo, isIppatu: false, isReach: false, isDoubleReach: false, isTyankan: false, isRinsyan: false, jikaze: jikazeTile)
    

        let hand = Hand(inputtedTiles: tehaiTileArray, tumo: matiTile, genSituation:gs, perSituation: ps)
        let score = hand.getScore()
        
        var str = ""
        for s in score.3 {
            str += s.getName()
        }
        yakuTV.text = str
        huLabel.text = "\(score.1)飜\(score.2)符"
        tenLabel.text = "\(score.0)点"
        
        
    }
}
