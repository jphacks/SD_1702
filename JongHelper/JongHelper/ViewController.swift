//
//  ViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/19.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AVCaptureDelegate, TehaiViewDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate, HaiSelecterDelegate, SettingViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!

    var tehaiView: TehaiView!
    var notenView: NotenView!
    var tenpaiView: TenpaiView!
    var agariView: AgariView!
    
    let avCapture = AVCapture()
    let openCVWrapper = OpenCVWrapper()
    let bakazeList = [Tile.Ton, Tile.Nan, Tile.Sya, Tile.Pe, Tile.Haku, Tile.Hatu, Tile.Tyun]
    let jikazeList = [Tile.Ton, Tile.Nan, Tile.Sya, Tile.Pe]
    var tehaiCellIndexPath: [IndexPath] = Array(repeating: IndexPath(row: 0, section: 0), count: 14)
    var bakazeCellIndexPath = IndexPath(row: 0, section: 0)
    var jikazeCellIndexPath = IndexPath(row: 0, section: 0)
    var doraCellIndexPath: [IndexPath] = Array(repeating: IndexPath(row: 0, section: 0), count: 4)
    var doraTileArray: [Tile] = [Tile.m1, Tile.null, Tile.null, Tile.null]
    var bakazeTile = Tile.Ton
    var jikazeTile = Tile.Ton
    //let initTehaiArray: [Tile] = Array(repeating: Tile.p7, count: 14)
    //let initTehaiArray: [Tile] = [Tile.m2,Tile.m3,Tile.m4,Tile.m2,Tile.m3,Tile.m4,Tile.p2,Tile.p3,Tile.p4,Tile.s3,Tile.s4,Tile.m7,Tile.m7,Tile.Haku]
    var tehaiTileArray = [Tile.Haku,Tile.Haku,Tile.Haku,Tile.Hatu,Tile.Hatu,Tile.Hatu,Tile.Tyun,Tile.Tyun,Tile.Tyun,Tile.Ton,Tile.Ton,Tile.Ton,Tile.Sya,Tile.Sya]
    //[Tile.p2,Tile.p3,Tile.p3,Tile.p3,Tile.p5,Tile.p6,Tile.p6,Tile.p7,Tile.p7,Tile.p8,Tile.p8,Tile.p9,Tile.p9,Tile.p9]
    
    var tenpaiDatas: [TenpaiData] = []
    
    let recognizer = Recognizer()
    
    var agariHaiIndex: Int!
    
    var isCaptureMode = true
    
    var isTenpai = false
    
    var isAgari = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avCapture.delegate = self
        
        //手牌ビューのレイヤー追加
        tehaiView = UINib(nibName: "TehaiView", bundle: nil).instantiate(withOwner: self, options: nil).first as? TehaiView
        for tv in (tehaiView?.tableViews)! {
            tv.delegate = self
            tv.dataSource = self
            tv.isScrollEnabled = false
            tv.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        }
        addSubviewWithAutoLayout(childView: tehaiView!, parentView: self.view)
        tehaiView.delegate = self
        
        setTehaiView(tehaiTileArray, animated: false)
        
        //テンパイ時のビュー
        tenpaiView = UINib(nibName: "TenpaiView", bundle: nil).instantiate(withOwner: self, options: nil).first as? TenpaiView
        tenpaiView.frame = CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: self.view.frame.height - 120.0)
        addSubviewWithAutoLayoutTop(childView: tenpaiView!, parentView: self.view)
        tenpaiView.tableView.delegate = self
        tenpaiView.tableView.dataSource = self
        tenpaiView.tableView.allowsSelection = false
        tenpaiView.tableView.register(UINib(nibName: "TenpaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TenpaiViewCell")
        
        //ノーテン時のビュー
        notenView = UINib(nibName: "NotenView", bundle: nil).instantiate(withOwner: self, options: nil).first as? NotenView
        notenView.frame = CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: self.view.frame.height - 120.0)
        addSubviewWithAutoLayoutTop(childView: notenView!, parentView: self.view)
        
        //アガリ時のビュー
        agariView = UINib(nibName: "AgariView", bundle: nil).instantiate(withOwner: self, options: nil).first as? AgariView
        agariView.frame = CGRect(x: 0, y: 0, width:self.view.frame.size.width, height: self.view.frame.height - 120.0)
        addSubviewWithAutoLayoutTop(childView: agariView!, parentView: self.view)
        
        calculate()
        tenpaiView.isHidden = true
        notenView.isHidden = true
    }
    
    func switchView(_ b: Bool) {
        if(isCaptureMode) {
            isCaptureMode = false
            //avCapture.stopRunning()
        }
        agariView.isHidden = !isAgari
        if(b){
            notenView.isHidden = true
            tenpaiView.isHidden = false
        } else {
            notenView.isHidden = false
            tenpaiView.isHidden = true
        }
    }
    
    // AVCaptureDelegate
    var count = 0
    func capture(image: UIImage) {
        if (count % 5 == 0) {
            imageView.image = openCVWrapper.filter(image)
            count = 0
        }
        count += 1
    }
    // AVCaptureDelegate
    func photo(image: UIImage){
        let features = openCVWrapper.getFeatures(image)
        var arr: [Int] = []
        for (index, feature) in features!.enumerated() {
            arr.append(recognizer.recognize(feature: feature as! NSArray))
        }
        
        if(arr.count == 14){
            let arr2 = intArrToTile(arr)
            tehaiTileArray = arr2
            setTehaiView(arr2, animated: true)
            self.calculate()
        }
        
    }
    
    // TehaiViewDelegate
    func pushCapture() {
        if (isCaptureMode) {
            avCapture.takePicture()
            isCaptureMode = false
            //avCapture.stopRunning()
        } else {
            isCaptureMode = true
            //avCapture.startRunning()
            //ビューをカメラモードへ
            tenpaiView.isHidden = true
            notenView.isHidden = true
            agariView.isHidden = true
        }
        
    }
    func pushSetting() {
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let settingViewController = storyboard.instantiateInitialViewController() as! SettingViewController
        settingViewController.delegate = self
        settingViewController.bakazeTile = self.bakazeTile
        settingViewController.jikazeTile = self.jikazeTile
        settingViewController.doraTileArray = self.doraTileArray
        self.present(settingViewController, animated: true, completion: nil)
    }
    
    func setSituation(jikaze: Tile, bakaze: Tile, dora: [Tile]) {
        self.jikazeTile = jikaze
        self.bakazeTile = bakaze
        self.doraTileArray = dora
        calculate()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func pushCaptureClose() {
        switchView(isTenpai)
        isCaptureMode = false
        //avCapture.stopRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 親viewに対してめいいっぱい表示するためのautolayoutの制約
    private func addSubviewWithAutoLayout(childView: UIView, parentView: UIView) {
        parentView.addSubview(childView)
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1.0, constant: 0))
    }
    
    // 親viewに対して下半分で表示するためのautolayoutの制約
    private func addSubviewWithAutoLayoutTop(childView: UIView, parentView: UIView) {
        parentView.addSubview(childView)
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0))
        //parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 400))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1.0, constant: 0))
    }
    
    //tableview===============================================================
    // tag: 0->役リスト 1~14->手牌 20->場風 21->自風 31~34->ドラ
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 0){
            return 3
        } else if(tableView.tag >= 1 && tableView.tag <= 14){
            return 34
        } else if(tableView.tag == 20) {
            return 7
        } else if(tableView.tag == 21) {
            return 4
        } else if(tableView.tag >= 31 && tableView.tag <= 34){
            if(tableView.tag == 31) {
                return 34
            }
            return 35
        } else if (tableView.tag == 99) {
            return tenpaiDatas.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView.tag == 0){

        } else if(tableView.tag >= 1 && tableView.tag <= 14) {
            tehaiCellIndexPath[tableView.tag - 1] = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            cell.haiImage.image = Tile(rawValue: indexPath.row)?.toUIImage()
            return cell
        }  else if(tableView.tag == 20) {
            bakazeCellIndexPath = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            cell.haiImage.image = Tile(rawValue: indexPath.row + 27)?.toUIImage()
            return cell
        } else if(tableView.tag == 21) {
            jikazeCellIndexPath = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            cell.haiImage.image = Tile(rawValue: indexPath.row + 27)?.toUIImage()
            return cell
        } else if(tableView.tag >= 31 && tableView.tag <= 34){
            doraCellIndexPath[tableView.tag - 31] = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            if(tableView.tag == 31) {
                cell.haiImage.image = Tile(rawValue: indexPath.row)?.toUIImage()
            } else {
                cell.haiImage.image = Tile(rawValue: indexPath.row - 1)?.toUIImage()
            }
            return cell
        } else if(tableView.tag == 99) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TenpaiViewCell", for:indexPath) as! TenpaiTableViewCell
            cell.suteImageView.image = tenpaiDatas[indexPath.row].suteTile.toUIImage()
            
            for i in 0..<cell.matiImageViews.count {
                cell.matiImageViews[i].isHidden = true
                cell.tumoScores[i].isHidden = true
                cell.ronScores[i].isHidden = true
            }
            
            for (k, elem) in tenpaiDatas[indexPath.row].matiTiles.enumerated() {
                cell.matiImageViews[k].image = elem.tile.toUIImage()
                cell.tumoScores[k].text = String(elem.tumo)
                cell.ronScores[k].text = String(elem.ron)
                cell.matiImageViews[k].isHidden = false
                cell.tumoScores[k].isHidden = false
                cell.ronScores[k].isHidden = false
                
                //imageViewをボタン化
                cell.matiImageViews[k].isUserInteractionEnabled = true
                let gesture = AgariTapGestureRecognizer(target: self, action: #selector(ViewController.matiImageViewTapped(_:)))
                gesture.row = indexPath.row
                gesture.index = k
                cell.matiImageViews[k].addGestureRecognizer(gesture)
                
                
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag > 0 && tableView.tag < 99) {
            return 45
        } else if (tableView.tag == 99) {
            return 120
        }
        return 1
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if ((scrollView as! UITableView).tag != 99) {
            stopTehaiCell(scrollView)
            self.calculate()
        }
    }
    
    // 減速開始時
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        stopTehaiCell(scrollView)
    }
    
    func stopTehaiCell(_ scrollView: UIScrollView) {
        let tv = scrollView as! UITableView
        if(tv.tag == 0){
            
        } else if(tv.tag >= 1 && tv.tag <= 14){
            tv.scrollToRow(at: tehaiCellIndexPath[tv.tag - 1], at: UITableViewScrollPosition.middle, animated: true)
            tehaiTileArray[tv.tag - 1] = Tile(rawValue: tehaiCellIndexPath[tv.tag - 1].row)!
        } else if(tv.tag == 20) {
            tv.scrollToRow(at: bakazeCellIndexPath, at: UITableViewScrollPosition.middle, animated: true)
            bakazeTile = Tile(rawValue: bakazeCellIndexPath.row)!
        } else if(tv.tag == 21) {
            tv.scrollToRow(at: jikazeCellIndexPath, at: UITableViewScrollPosition.middle, animated: true)
            jikazeTile = Tile(rawValue: jikazeCellIndexPath.row)!
        } else if(tv.tag >= 31 && tv.tag <= 34){
            if(tv.tag == 31){
                tv.scrollToRow(at: doraCellIndexPath[tv.tag - 31], at: UITableViewScrollPosition.middle, animated: true)
            } else {
                tv.scrollToRow(at: doraCellIndexPath[tv.tag - 31], at: UITableViewScrollPosition.middle, animated: true)
            }
            doraTileArray[tv.tag - 31] = Tile(rawValue: doraCellIndexPath[tv.tag - 31].row)!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.tag >= 1 && tableView.tag <= 14){
            let storyboard = UIStoryboard(name: "HaiSelecterView", bundle: nil)
            let selecterView = storyboard.instantiateInitialViewController() as! HaiSelecterViewController
            selecterView.delegate = self
            selecterView.haiIndex = tableView.tag - 1
            selecterView.modalPresentationStyle = UIModalPresentationStyle.popover
            selecterView.preferredContentSize = CGSize(width: 393, height: 236)
            let popoverController = selecterView.popoverPresentationController
            popoverController?.delegate = self
            popoverController?.permittedArrowDirections = UIPopoverArrowDirection.down
            popoverController?.sourceView = tableView
            popoverController?.sourceRect = tableView.bounds
            self.present(selecterView, animated: true, completion: nil)
        } else if(tableView.tag == 99) {
            agariHaiIndex = indexPath.row
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "toTokutenView",sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var vc = segue.destination as! TokutenViewController
        vc.tehaiTileArray = self.tehaiTileArray
        vc.doraTileArray = self.doraTileArray
        vc.bakazeTile = self.bakazeTile
        vc.jikazeTile = self.jikazeTile
        let agariSender = sender as! AgariTapGestureRecognizer
        vc.matiTile = tenpaiDatas[agariSender.row!].matiTiles[agariSender.index!].tile
        vc.suteTile = tenpaiDatas[agariSender.row!].suteTile
    }
    
    //tableview===============================================================
    
    // 画像がタップされたら呼ばれる
    @objc func matiImageViewTapped(_ sender: AgariTapGestureRecognizer) {
        performSegue(withIdentifier: "toTokutenView",sender: sender)
        
    }
    
    func selectedHai(index: Int, tile: Tile) {
        tehaiTileArray[index] = tile
        setTehaiView(tehaiTileArray, animated: true)
        calculate()
    }
    
    func indexPathToTileArray(_ indexPaths: [IndexPath]) -> [Tile] {
        var tiles: [Tile] = []
        for elem in indexPaths {
            tiles.append(Tile(rawValue: elem.row)!)
        }
        return tiles
    }
    
    func tileToIndexPathArray(_ tiles: [Tile]) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for elem in tiles {
            indexPaths.append(IndexPath(row: elem.rawValue, section: 0))
        }
        return indexPaths
    }

    func setTehaiView(_ list: [Tile], animated: Bool) {
        for tv in (self.tehaiView.tableViews)! {
            let index = IndexPath(row: list[tv.tag - 1].rawValue, section: 0)
            tv.scrollToRow(at: index, at: UITableViewScrollPosition.middle, animated: animated)
        }
    }
    
    func intArrToTile(_ arr: [Int]) -> [Tile] {
        var tiles: [Tile] = []
        for i in arr {
            tiles.append(Tile(rawValue: i)!)
        }
        return tiles
    }
    
    func getTehaiListFromInt(_ list: [Int]) -> [Tile] {
        var arr: [Tile] = []
        for element in list {
            arr.append(Tile(rawValue: element)!)
        }
        return arr
    }
    
    func getTehaiListFromTable() -> [Tile] {
        var tehaiList: [Tile] = []
        for i in 0..<14 {
            tehaiList.append(Tile(rawValue: tehaiCellIndexPath[i].row)!)
        }
        return tehaiList
    }

    func calculate() {
        //ドラのリスト作る
        var dora: [Tile] = []
        var isFirst = true
        for i in 0..<doraCellIndexPath.count {
            if(isFirst) {
                isFirst = false
                dora.append(doraTileArray[i])
            } else if(doraTileArray[i].rawValue != Tile.null.rawValue) {
                dora.append(Tile(rawValue: doraTileArray[i].rawValue - 1)!)
            }
        }
        
        let gs = GeneralSituation(isHoutei: false, bakaze: bakazeTile, dora: dora, honba: 1)
        let ps = PersonalSituation(isTsumo: false, isIppatu: false, isReach: false, isDoubleReach: false, isTyankan: false, isRinsyan: false, jikaze: jikazeTile)
        var matiArr: Set<Tile> = []
        var suteArr: Set<Tile> = []
        var minSyanten = 99
        tenpaiDatas = []
        
        let hand = Hand(inputtedTiles: tehaiTileArray, tumo: tehaiTileArray[0], genSituation: gs, perSituation: ps)
        if(hand.isAgari) {
            isAgari = true
            switchView(false)
            return
        } else {
            isAgari = false
        }
        
        tenpaiDatas = hand.getTenpaiData()
        
        if !hand.isTenpai {
            let syanten = Syanten(hand: tehaiTileArray)
            let tmpSyanten = syanten.getNormalSyantenNum()
            minSyanten = tmpSyanten.syanten_normal
            suteArr = Set(tmpSyanten.gomi)
        }
        
        if(hand.invalidHand){
            notenView.syantenLabel.text = "手牌が不正です"
            switchView(false)
            self.isTenpai = false
        } else {
            if(hand.isTenpai) {
                self.isTenpai = true
                tenpaiView.tableView.reloadData()
            } else {
                self.isTenpai = false
                for elem in notenView.haiImage {
                    elem.isHidden = true
                }
                for (k, elem) in suteArr.enumerated() {
                    if(k < 8) {
                        notenView.haiImage[k].image = elem.toUIImage()
                        notenView.haiImage[k].isHidden = false
                    }
                }
                notenView.syantenLabel.text = String(minSyanten) + "シャンテン"
            }
            switchView(hand.isTenpai)
        }
        
    }

}

