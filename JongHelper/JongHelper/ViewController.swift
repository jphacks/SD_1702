//
//  ViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/19.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AVCaptureDelegate, TehaiViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
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
    var bakazeTile = Tile.Ton
    var jikazeTile = Tile.Ton
    //let initTehaiArray: [Tile] = Array(repeating: Tile.p7, count: 14)
    //let initTehaiArray: [Tile] = [Tile.m2,Tile.m3,Tile.m4,Tile.m2,Tile.m3,Tile.m4,Tile.p2,Tile.p3,Tile.p4,Tile.s3,Tile.s4,Tile.m7,Tile.m7,Tile.Haku]
    var tehaiTileArray = [Tile.m2,Tile.m3,Tile.m4,Tile.m2,Tile.m3,Tile.m4,Tile.p2,Tile.p3,Tile.p4,Tile.s3,Tile.s4,Tile.m7,Tile.m7,Tile.Haku]
    
    var tenpaiDatas: [TenpaiData] = []
    
    let recognizer = Recognizer()
    
    var agariHaiIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        avCapture.delegate = self
        
        //ノーテン時のビュー
        notenView = UINib(nibName: "NotenView", bundle: nil).instantiate(withOwner: self, options: nil).first as? NotenView
        addSubviewWithAutoLayoutTop(childView: notenView!, parentView: self.view)

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
        
        //tehaiView.frame = CGRect(x:0,y:0,width:self.view.frame.size.width, height: 150.0)
        addSubviewWithAutoLayout(childView: tehaiView!, parentView: self.view)
        //self.view.addSubview(tehaiView)
        tehaiView.delegate = self
        
        setTehaiView(tehaiTileArray, animated: false)
        
        //テンパイ時のビュー
        tenpaiView = UINib(nibName: "TenpaiView", bundle: nil).instantiate(withOwner: self, options: nil).first as? TenpaiView
        tenpaiView.frame = CGRect(x:0,y:0,width:self.view.frame.size.width, height: 150.0)
        addSubviewWithAutoLayoutTop(childView: tenpaiView!, parentView: self.view)
        tenpaiView.tableView.delegate = self
        tenpaiView.tableView.dataSource = self
        tenpaiView.tableView.register(UINib(nibName: "TenpaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TenpaiViewCell")

        switchView(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //setTehaiView(initTehaiArray, animated: false)
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
        //let nsArr = openCVWrapper.getTehaiArray(image)
        let features = openCVWrapper.getFeatures(image)
        var arr: [Int] = []
        for (index, feature) in features!.enumerated() {
            //print("\(recognizer.recognize(feature: feature as! NSArray)) ", terminator:"")
            arr.append(recognizer.recognize(feature: feature as! NSArray))
        }
        
        //let tehaiIntArr = nsArr as! [Int]
        if(arr.count == 14){
            //self.tehaiArray = getTehaiListFromInt(tehaiIntArr)
            let arr2 = intArrToTile(arr)
            tehaiTileArray = arr2
            setTehaiView(arr2, animated: true)
            self.calculate(fromTalbe: false)
        }
        
    }
    // TehaiViewDelegate
    func pushCapture() {
        avCapture.takePicture()
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
            for i in 0..<min(tenpaiDatas[indexPath.row].matiTiles.count, 3) {
                cell.matiImageViews[i].image = tenpaiDatas[indexPath.row].matiTiles[i].toUIImage()
            }
            cell.score.text = String(tenpaiDatas[indexPath.row].score)
            return cell
        }
        
        var celll : UITableViewCell!
        return celll
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView.tag == 0){
            return 46
        } else if(tableView.tag > 0 && tableView.tag < 99) {
            return 45
        } else if (tableView.tag == 99) {
            return 80
        }
        return 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if ((scrollView as! UITableView).tag != 99) {
            stopTehaiCell(scrollView)
            self.calculate(fromTalbe: true)
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
        if(tableView.tag == 99) {
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
        vc.matiTile = tenpaiDatas[agariHaiIndex].matiTiles[0]
        vc.suteTile = tenpaiDatas[agariHaiIndex].suteTile
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
    
    func mergeTenpaiDatas() {
        print("mergeTenpaiDatas")
        var arr: [TenpaiData] = []
        for elem in tenpaiDatas {
            if(arr.count != 0){
                var flag = true
                for elem2 in arr {
                    if(compTenpaiData(data1: elem, data2: elem2)) {
                        flag = false
                        break
                    }
                }
                if (flag) {
                    arr.append(elem)
                }
            } else {
                arr.append(elem)
            }
        }
        tenpaiDatas = arr
    }
    
    func compTenpaiData(data1: TenpaiData, data2: TenpaiData) -> Bool {
        let sameSuteTile = data1.suteTile == data2.suteTile
        let sameScore = data1.score == data2.score
        let sameMatiTile = data1.matiTiles[0] == data2.matiTiles[0]
        let result = sameSuteTile && sameScore && sameMatiTile
        return ( result )
    }
    
    func calculate(fromTalbe: Bool) {
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
        let generalsituation = GeneralSituation(isHoutei: false, bakaze: bakazeTile, dora: dora, honba: 1)
        let personalsituation = PersonalSituation(isParent: false, isTsumo: false, isIppatu: false, isReach: false, isDoubleReach:
            false, isTyankan: false, isRinsyan: false, jikaze: jikazeTile)
        var matiArr: Set<Tile> = []
        var suteArr: Set<Tile> = []
        var isTenpai = false
        var invalidHand = false
        var minSyanten = 99
        tenpaiDatas = []
        
        var player = Player(hand14: tehaiTileArray)
        if(player.isAgari) {
            return
        }
        
        for i in 0..<14 {//13個にして聴牌かどうか確認
            var arr = tehaiTileArray
            let matiKouho = arr.remove(at: i)
            let x = Hand(inputtedTiles: arr)
            if(x.invalidHand) {
                invalidHand = true
            } else if (x.isTenpai) {
                isTenpai = true
                //print("tenpai-num: \(x.tenpaiSet.count)")
                
                for tenpai in x.tenpaiSet {
                    //tenpai.printTenpai()
//                    for hai in tenpai.wait { // 待ち牌ついか
//                        matiArr.insert(hai)
//                    }
//                    for hai in tenpai.uki { // 捨て牌追加
//                        suteArr.insert(hai)
//                    }
                    for last in tenpai.wait {
                        let compmentsu = CompMentsu(tenpai: tenpai, last: last, isOpenHand: x.isOpenHand)
                        let calculator = Calculator(compMentsu: compmentsu, generalSituation: generalsituation, personalSituation: personalsituation)
                        calculator.calculateScore()
                        let tenpaiData = TenpaiData(sute: matiKouho, mati: [last], score: calculator.score)
                        tenpaiDatas.append(tenpaiData)
                    }
                }
            } else {
                let syanten = Syanten(hand: arr)

                    minSyanten = min(minSyanten, syanten.getSyantenNum())
                    
                    for g in syanten.gomi {
                        suteArr.insert(g)
                    }
            }
        }
        
        print("まち：\(matiArr.count) すて：\(suteArr.count)")
        if(invalidHand){
            notenView.syantenLabel.text = "手牌が不正です"
            switchView(false)
        } else {
            if(isTenpai) {
                mergeTenpaiDatas()
                tenpaiView.tableView.reloadData()
            } else {
                for (k, elem) in suteArr.enumerated() {
                    if(k < 3) {
                        notenView.haiImage[k].image = elem.toUIImage()
                    }
                }
                notenView.syantenLabel.text = String(minSyanten) + "シャンテン"
            }
            switchView(isTenpai)
        }
        
    }

}

