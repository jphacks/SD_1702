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
        var normalYakuList = [NormalYaku]()
        
        var index = 0
        for (k, tile) in tehaiTileArray.enumerated() {
            if (tile == suteTile){
                index = k
                break
            }
        }
        tehaiTileArray.remove(at: index)
        
        var hand = Hand(inputtedTiles: tehaiTileArray)
        
        var score = 0
        var fu = 0
        var han = 0
        var gs = GeneralSituation(isHoutei: false, bakaze: Tile.Ton, dora: [Tile.s1], honba: 1)
        var ps = PersonalSituation(isParent: true, isTsumo: isTsumo, isIppatsu: false, isReach: false, isDoubleReach: false, isTyankan: false, isRinsyan: false, jikaze: Tile.Ton)
        
        if (hand.isTenpai) {
            for tenpai in hand.tenpaiSet {
                for last in tenpai.wait {
                    if last == matiTile {
                        let tehai = CompMentsu(tenpai: tenpai , last: matiTile, isOpenHand: false)
                        let calculator = Calculator(compMentsu: tehai, generalSituation: gs, personalSituation: ps)
                        if (calculator.score > score) {
                            score = calculator.score
                            fu = calculator.fu
                            han = calculator.han
                            normalYakuList = calculator.normalYakuList
                        }
                    }
                }
            }
        } else {
            print("not tenpai")
        }
        
        var str = ""
        for s in normalYakuList {
            str += s.getName()
        }
        yakuTV.text = str
        huLabel.text = "\(han)飜\(fu)符"
        tenLabel.text = "\(score)点"
        
        
    }
}
