//
//  ViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/19.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AVCaptureDelegate, TehaiViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageView: UIImageView!

    var tehaiView: TehaiView!
    var notenView: NotenView!
    var tenpaiView: TenpaiView!
    
    let avCapture = AVCapture()
    let openCVWrapper = OpenCVWrapper()
    let bakazeList = [Tile.Ton, Tile.Nan, Tile.Sya, Tile.Pe, Tile.Haku, Tile.Hatu, Tile.Tyun]
    let jikazeList = [Tile.Ton, Tile.Nan, Tile.Sya, Tile.Pe]
    var tehaiCellIndexPath: [IndexPath] = Array(repeating: IndexPath(row: 0, section: 0), count: 14)
    var bakazeCellIndexPath = IndexPath(row: 0, section: 0)
    var jikazeCellIndexPath = IndexPath(row: 0, section: 0)
    var doraCellIndexPath: [IndexPath] = Array(repeating: IndexPath(row: 0, section: 0), count: 4)
    var doraTileArray: [Tile] = [Tile.m1, Tile.null, Tile.null, Tile.null]
    //let initTehaiArray: [Tile] = Array(repeating: Tile.p7, count: 14)
    //let initTehaiArray: [Tile] = [Tile.m2,Tile.m3,Tile.m4,Tile.m2,Tile.m3,Tile.m4,Tile.p2,Tile.p3,Tile.p4,Tile.s3,Tile.s4,Tile.m7,Tile.m7,Tile.Haku]
    var tehaiTileArray = [Tile.m2,Tile.m3,Tile.m4,Tile.m2,Tile.m3,Tile.m4,Tile.p2,Tile.p3,Tile.p4,Tile.s3,Tile.s4,Tile.m7,Tile.m7,Tile.Haku]
    
    var isFirstCalc = true
    
    let recognizer = Recognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avCapture.delegate = self
        
        //ノーテン時のビュー
        notenView = UINib(nibName: "NotenView", bundle: nil).instantiate(withOwner: self, options: nil).first as? NotenView
        addSubviewWithAutoLayoutTop(childView: notenView!, parentView: self.view)
        
        //テンパイ時のビュー
        tenpaiView = UINib(nibName: "TenpaiView", bundle: nil).instantiate(withOwner: self, options: nil).first as? TenpaiView
        addSubviewWithAutoLayoutTop(childView: tenpaiView!, parentView: self.view)
        
        //手牌ビューのレイヤー追加
        tehaiView = UINib(nibName: "TehaiView", bundle: nil).instantiate(withOwner: self, options: nil).first as? TehaiView
        for tv in (tehaiView?.tableViews)! {
            tv.delegate = self
            tv.dataSource = self
            tv.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        }
        for tv in (tehaiView?.tableViewDora)! {
            tv.delegate = self
            tv.dataSource = self
            tv.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        }
        tehaiView.tableViewJikaze.delegate = self
        tehaiView.tableViewJikaze.dataSource = self
        tehaiView.tableViewJikaze.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        tehaiView.tableViewBakaze.delegate = self
        tehaiView.tableViewBakaze.dataSource = self
        tehaiView.tableViewBakaze.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        addSubviewWithAutoLayoutBottom(childView: tehaiView!, parentView: self.view)
        tehaiView.delegate = self
        
        setTehaiView(tehaiTileArray, animated: false)

        switchView(false)
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ViewController.tapped(_:)))
        // デリゲートをセット
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //setTehaiView(initTehaiArray, animated: false)
    }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            //print(tehaiCellIndexPath)
            //print(indexPathToTileArray(tehaiCellIndexPath))
            //setTehaiView(initTehaiArray, animated: false)
        }
    }
    
    func switchView(_ b: Bool) {
        if(b){
            notenView.isHidden = true
            tenpaiView.isHidden = false
        } else {
            notenView.isHidden = false
            tenpaiView.isHidden = true
        }
    }
    
    // AVCaptureDelegate
    func capture(image: UIImage) {
        imageView.image = openCVWrapper.filter(image)
    }
    // AVCaptureDelegate
    func photo(image: UIImage){
        //let nsArr = openCVWrapper.getTehaiArray(image)
        let features = openCVWrapper.getFeatures(image)
        
        for (index, feature) in features!.enumerated() {
            print("\(recognizer.recognize(feature: feature as! NSArray)) ", terminator:"")
        }
        
        /*
        let tehaiIntArr = nsArr as! [Int]
        if(tehaiIntArr.count == 14){
            //self.tehaiArray = getTehaiListFromInt(tehaiIntArr)
            let arr = intArrToTile(tehaiIntArr)
            setTehaiView(arr, animated: true)
            self.calculate(fromTalbe: false)
        }*/
        
    }
    // TehaiViewDelegate
    func pushCapture() {
        avCapture.takePicture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 親viewに対して上半分で表示するためのautolayoutの制約
    private func addSubviewWithAutoLayoutTop(childView: UIView, parentView: UIView) {
        parentView.addSubview(childView)
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 200))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1.0, constant: 0))
    }
    
    // 親viewに対して上半分で表示するためのautolayoutの制約
    private func addSubviewWithAutoLayoutBottom(childView: UIView, parentView: UIView) {
        parentView.addSubview(childView)
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 200))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0))
        parentView.addConstraint(NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 0))
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
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView.tag == 0){

        } else if(tableView.tag >= 1 && tableView.tag <= 14) {
            tehaiCellIndexPath[tableView.tag - 1] = indexPath
            //tehaiTileArray[tableView.tag - 1] = Tile(rawValue: indexPath.row)!
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
        }
        
        var celll : UITableViewCell!
        return celll
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return 46
        } else if(tableView.tag > 0) {
            return 45
        }
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        stopTehaiCell(scrollView)
        self.calculate(fromTalbe: true)
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
            //tv.scrollToRow(at: IndexPath(row: tehaiTileArray[tv.tag - 1].rawValue, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        } else if(tv.tag == 20) {
            tv.scrollToRow(at: bakazeCellIndexPath, at: UITableViewScrollPosition.middle, animated: true)
        } else if(tv.tag == 21) {
            tv.scrollToRow(at: jikazeCellIndexPath, at: UITableViewScrollPosition.middle, animated: true)
        } else if(tv.tag >= 31 && tv.tag <= 34){
            if(tv.tag == 31){
                tv.scrollToRow(at: doraCellIndexPath[tv.tag - 31], at: UITableViewScrollPosition.middle, animated: true)
            } else {
                tv.scrollToRow(at: doraCellIndexPath[tv.tag - 31], at: UITableViewScrollPosition.middle, animated: true)
            }
            doraTileArray[tv.tag - 31] = Tile(rawValue: doraCellIndexPath[tv.tag - 31].row)!
        }
    }
    
    //tableview===============================================================
    
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
    
    func calculate(fromTalbe: Bool) {
        var arr = tehaiTileArray
        arr.removeLast()
        let x = Hand(inputtedTiles: arr)
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
        print(dora)
        let generalsituation = GeneralSituation(isHoutei: false, bakaze: Tile.Ton, dora: dora, honba: 1)
        let personalsituation = PersonalSituation(isParent: false, isTsumo: false, isIppatsu: false, isReach: false, isDoubleReach: false, isTyankan: false, isRinsyan: false, jikaze: Tile.Nan)
        
        if (x.isTenpai) {
            print("TENPAI")
            print("tenpai-num: \(x.tenpaiSet.count)")
            for tenpai in x.tenpaiSet {
                tenpai.printTenpai()
                for last in tenpai.uki {
                    let compmentsu = CompMentsu(tenpai: tenpai, last: last, isOpenHand: x.isOpenHand)
                    let calculator = Calculator(compMentsu: compmentsu, generalSituation: generalsituation, personalSituation: personalsituation)
                    calculator.calculateScore()
                }
            }
        } else {
            for elem in arr {
                print("\(elem) ", terminator: "")
            }
            print("NOTEN")
            let syanten = Syanten(hand: arr)
            if(x.invalidHand) {
                notenView.syantenLabel.text = "手牌が不正です"
            } else {
                notenView.syantenLabel.text = String(syanten.getSyantenNum()) + "シャンテン"
            }
        }
        switchView(x.isTenpai)
    }

}

