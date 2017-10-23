//
//  Player.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/22.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

// 手牌14枚のクラス
class Player {
    
    var tmpTiles = [Int]()
    var inputtedTiles = [Int](repeating: 0, count: 34)
    var invalidHand = false
    var isAgari = false
    
    init(hand14: [Tile]) {
        
        for tile in hand14 {
            if (self.inputtedTiles[tile.getCode()] < 4) {
                self.inputtedTiles[tile.getCode()] += 1
            }
        }
        isAgari = getAgari()
    }
    
    func initTmp() {
        tmpTiles = inputtedTiles
    }
    
    func getAgari() -> Bool {
        
        //頭の候補を探してストック
        initTmp()
        
        let toitsuList: [Toitsu] = Toitsu.findJantoCandidate(tiles: tmpTiles)
        // 頭確定のメンツ探索
        if (toitsuList.count != 0) {
                
            for toitsu in toitsuList {
                initTmp()
                    
                tmpTiles[toitsu.identifierTile.getCode()] -= 2
                findKotsuCandidate()
                findShuntsuCandidate()
                    
                if (countRemainderTiles() == 0) {
                    return true
                }
                    
                    
                initTmp()
                    
                tmpTiles[toitsu.identifierTile.getCode()] -= 2
                findShuntsuCandidate()
                findKotsuCandidate()
                    
                if (countRemainderTiles() == 0) {
                    return true
                }
            }
            return false
        } else {
            return false
        }
    }
    
    
    func findShuntsuCandidate() -> [Mentsu] {
        var resultList = [Mentsu]()
        
        for i in 1 ..< 26 {
            while tmpTiles[i - 1] > 0 && tmpTiles[i] > 0 && tmpTiles[i + 1] > 0 {
                let shuntsu = Syuntsu(
                    isOpen: false,
                    tile1: Tile(rawValue: i - 1)!,
                    tile2: Tile(rawValue: i)!,
                    tile3: Tile(rawValue: i + 1)!
                )
                
                if (shuntsu.isMentsu) {
                    resultList.append(shuntsu)
                    tmpTiles[i - 1] -= 1
                    tmpTiles[i] -= 1
                    tmpTiles[i + 1] -= 1
                } else {
                    break
                }
            }
        }
        
        return resultList
    }
    
    func findKotsuCandidate() -> [Mentsu] {
        var resultList = [Mentsu]()
        
        for i in 0 ..< tmpTiles.count {
            if (tmpTiles[i] >=  3) {
                resultList.append(Kotsu(isOpen: false, identifierTile: Tile(rawValue: i)!))
                tmpTiles[i] -= 3
            }
        }
        
        return resultList
    }
    
    func countRemainderTiles() -> Int {
        return tmpTiles.reduce(0) {(num1: Int, num2: Int) -> Int in num1 + num2 }
    }
}
