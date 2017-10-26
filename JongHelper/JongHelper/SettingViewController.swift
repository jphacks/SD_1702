//
//  SettingViewController.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/24.
//  Copyright © 2017年 tomato. All rights reserved.
//


import UIKit

protocol SettingViewDelegate {
    func setSituation(jikaze: Tile, bakaze: Tile, dora: [Tile])
}

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, HaiSelecterDelegate, UIPopoverPresentationControllerDelegate {
    
    
    @IBOutlet weak var tableViewJikaze: UITableView!
    @IBOutlet weak var tableViewBakaze: UITableView!
    @IBOutlet var doraTableViews: [UITableView]!
    
    @IBAction func pushClose(_ sender: UIButton) {
        delegate?.setSituation(jikaze: jikazeTile, bakaze: bakazeTile, dora: doraTileArray)
        self.dismiss(animated: true, completion: nil)
    }
    
    let bakazeList = [Tile.Ton, Tile.Nan, Tile.Sya, Tile.Pe, Tile.Haku, Tile.Hatu, Tile.Tyun]
    let jikazeList = [Tile.Ton, Tile.Nan, Tile.Sya, Tile.Pe]
    
    var delegate: SettingViewDelegate?
    
    var bakazeTile = Tile.Ton
    var jikazeTile = Tile.Ton
    var doraTileArray: [Tile] = [Tile.m1, Tile.null, Tile.null, Tile.null]
    var bakazeCellIndexPath = IndexPath(row: 0, section: 0)
    var jikazeCellIndexPath = IndexPath(row: 0, section: 0)
    var doraCellIndexPath: [IndexPath] = Array(repeating: IndexPath(row: 0, section: 0), count: 4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.bring
        tableViewBakaze.delegate = self
        tableViewJikaze.delegate = self
        tableViewBakaze.dataSource = self
        tableViewJikaze.dataSource = self
        tableViewBakaze.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        tableViewJikaze.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        for tv in doraTableViews {
            tv.delegate = self
            tv.dataSource = self
            tv.isScrollEnabled = false
            tv.register(UINib(nibName: "TehaiTableViewCell", bundle:nil), forCellReuseIdentifier:"TehaiCell")
        }
        setTehaiView(animated: false)
    }
    
    func setTehaiView(animated: Bool) {
        for (k, tv) in doraTableViews!.enumerated() {
            if(k == 0) {
                let index = IndexPath(row: doraTileArray[tv.tag].rawValue, section: 0)
                tv.scrollToRow(at: index, at: UITableViewScrollPosition.middle, animated: animated)
            } else {
                let index = IndexPath(row: doraTileArray[tv.tag].rawValue + 1, section: 0)
                tv.scrollToRow(at: index, at: UITableViewScrollPosition.middle, animated: animated)
            }
            //print("indexpathrow:\(list[tv.tag].rawValue)")
        }
        tableViewJikaze.scrollToRow(at: IndexPath(row: jikazeTile.rawValue - 27, section: 0), at: UITableViewScrollPosition.middle, animated: animated)
        tableViewBakaze.scrollToRow(at: IndexPath(row: bakazeTile.rawValue - 27, section: 0), at: UITableViewScrollPosition.middle, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 10) {
            return 4
        } else if(tableView.tag == 11) {
            return 7
        } else {
            if(tableView.tag == 0) {
                return 34
            }
            return 35
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(tableView.tag == 10) {
            jikazeCellIndexPath = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            cell.haiImage.image = Tile(rawValue: indexPath.row + 27)?.toUIImage()
        } else if(tableView.tag == 11) {
            bakazeCellIndexPath = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            cell.haiImage.image = Tile(rawValue: indexPath.row + 27)?.toUIImage()
            return cell
        } else {
            doraCellIndexPath[tableView.tag] = indexPath
            let cell = tableView.dequeueReusableCell(withIdentifier: "TehaiCell", for:indexPath) as! TehaiTableViewCell
            if(tableView.tag == 0) {
                cell.haiImage.image = Tile(rawValue: indexPath.row)?.toUIImage()
            } else {
                cell.haiImage.image = Tile(rawValue: indexPath.row - 1)?.toUIImage()
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            stopTehaiCell(scrollView)
            //self.calculate()
    }
    
    // 減速開始時
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        stopTehaiCell(scrollView)
    }
    
    func stopTehaiCell(_ scrollView: UIScrollView) {
        let tableView = scrollView as! UITableView
        
        if(tableView.tag == 10) {
            tableView.scrollToRow(at: jikazeCellIndexPath, at: UITableViewScrollPosition.middle, animated: true)
            jikazeTile = Tile(rawValue: jikazeCellIndexPath.row + 27)!
        } else if(tableView.tag == 11) {
            tableView.scrollToRow(at: bakazeCellIndexPath, at: UITableViewScrollPosition.middle, animated: true)
            bakazeTile = Tile(rawValue: bakazeCellIndexPath.row + 27)!
        } else {
            tableView.scrollToRow(at: doraCellIndexPath[tableView.tag], at: UITableViewScrollPosition.middle, animated: true)
            if(tableView.tag == 0) {
                doraTileArray[tableView.tag] = Tile(rawValue: doraCellIndexPath[tableView.tag].row)!
            } else {
                doraTileArray[tableView.tag] = Tile(rawValue: doraCellIndexPath[tableView.tag - 1].row)!
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(tableView.tag >= 0 && tableView.tag <= 3){
            let storyboard = UIStoryboard(name: "HaiSelecterView", bundle: nil)
            let selecterView = storyboard.instantiateInitialViewController() as! HaiSelecterViewController
            selecterView.delegate = self
            selecterView.haiIndex = tableView.tag
            selecterView.modalPresentationStyle = UIModalPresentationStyle.popover
            selecterView.preferredContentSize = CGSize(width: 393, height: 236)
            let popoverController = selecterView.popoverPresentationController
            popoverController?.delegate = self
            // 出す向き(DownはsourceViewの上)
            popoverController?.permittedArrowDirections = UIPopoverArrowDirection.down
            // どこから出た感じにするか
            popoverController?.sourceView = tableView
            popoverController?.sourceRect = tableView.bounds
            self.present(selecterView, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func selectedHai(index: Int, tile: Tile) {
        doraTileArray[index] = tile
        setTehaiView(animated: true)
    }
    
    

}
