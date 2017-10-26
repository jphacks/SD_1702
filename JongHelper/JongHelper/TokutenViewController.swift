//
//  TokutenViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/22.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class TokutenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tileImage: [UIImageView]!
    @IBOutlet var doraImage: [UIImageView]!
    @IBOutlet weak var jikazemage: UIImageView!
    @IBOutlet weak var bakazemage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var hanLabel: UILabel!
    @IBOutlet weak var plusHanLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
     var tehaiTileArray: [Tile] = []
     var doraTileArray: [Tile] = [Tile.m1, Tile.null, Tile.null, Tile.null]
     var bakazeTile = Tile.Ton
     var jikazeTile = Tile.Ton
    // var yakuStr = ""
    var suteTile: Tile!
    var matiTile: Tile!
    
    var isTsumo = false
    var isReach = false
    var plushan = 0
    
    var yakuList: [Yaku] = []
    
    @IBAction func pushClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchTumo(_ sender: UISegmentedControl) {
        isTsumo = sender.selectedSegmentIndex == 1
        calculate()
    }
    
    @IBAction func switchReach(_ sender: UISegmentedControl) {
        isReach = sender.selectedSegmentIndex == 1
        calculate()
    }
    
    @IBAction func pushMinus(_ sender: UIButton) {
        if(plushan > 0) {
            plushan -= 1
        }
        plusHanLabel.text = String(plushan) + "飜"
        calculate()
    }
    
    @IBAction func pushPlus(_ sender: UIButton) {
        plushan += 1
        plusHanLabel.text = String(plushan) + "飜"
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "YakuTableViewCell", bundle:nil), forCellReuseIdentifier:"YakuTableViewCell")
        
        calculate()
    }
    
    func calculate() {
        let normalYakuList = [Yaku]()
        
        let gs = GeneralSituation(isHoutei: false, bakaze: bakazeTile, dora: doraTileArray, honba: 1)
        let ps = PersonalSituation(isTsumo: isTsumo, isIppatu: false, isReach: isReach, isDoubleReach: false, isTyankan: false, isRinsyan: false, jikaze: jikazeTile)
    
        print(matiTile)
        let hand = Hand(inputtedTiles: tehaiTileArray, tumo: matiTile, genSituation:gs, perSituation: ps)
        let score = hand.getScore(addHan: plushan)
        
        var str = ""
        for s in score.3 {
            str += s.getName()
        }
        yakuList = score.yakuList
        //yakuTV.text = str
        hanLabel.text = "\(score.2)飜\(score.1)符"
        if(isTsumo){
            scoreLabel.text = "\(score.0.tumo)点"
        } else {
            scoreLabel.text = "\(score.0.ron)点"
        }
        
        //huLabel.text = "\(score.1)飜\(score.2)符"
        //tenLabel.text = "\(score.0)点"
        
        self.tableView.reloadData()
    }
    
    //tableview===============================================================
    // tag: 0->役リスト 1~14->手牌 20->場風 21->自風 31~34->ドラ
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return yakuList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "YakuTableViewCell", for:indexPath) as! YakuTableViewCell
        cell.yakuLabel.text = yakuList[indexPath.row].getName()
        cell.hanLabel.text = String(yakuList[indexPath.row].getHan())
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    //tableview===============================================================
    
}
