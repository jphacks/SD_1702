//
//  Hand.swift
//  
//
//  Created by oike toshiyuki on 2017/10/17.
//

// 実装しなくちゃいけないこと
// ・国士無双
// ・エラー処理
import Foundation

// 手牌 13枚
class Hand {
    
    // テンパイ形のリスト
    var tenpaiSet = Set<Tenpai>()
    // 面前手かどうか
    var isOpenHand = false
    // テンパイしているかどうか
    var isTenpai = false
    // チートイかどうか
    var isTitoitu = false
    
    var invalidHand = false
    
    // 作業用変数
    var tmpTiles = [Int]()
    // 入力された各牌の数の配列
    var inputtedTiles = [Int](repeating: 0, count: 34)
    // 入力された面子リスト
    var inputtedMentsuList = [Mentsu]()
    
    // 面前手の場合はこちらでイニシャライズ
    init(inputtedTiles: [Tile]) {
        isOpenHand = false
        
        for tile in inputtedTiles {
            if (self.inputtedTiles[tile.getCode()] < 4) {
                self.inputtedTiles[tile.getCode()] += 1
            } else {
                invalidHand = true
                break
            }
        }
        if (!invalidHand) {
            getTenpaiCandidate()
        }
    }
    // 鳴いている場合はその面子をリストで入力
    init(inputtedTiles: [Tile], mentsuList: [Mentsu]) {
        isOpenHand = true
        for tile in inputtedTiles {
            self.inputtedTiles[tile.getCode()] += 1
        }
        inputtedMentsuList = mentsuList
        getTenpaiCandidate()
    }

    
    func initTmp() {
        tmpTiles = inputtedTiles
    }
    
    func getTenpaiCandidate() {
        
        //頭の候補を探してストック
        initTmp()
        
        let toitsuList: [Toitsu] = Toitsu.findJantoCandidate(tiles: tmpTiles)
        
        /*if (toitsuList.count == 6) {
         isTitoitu = true
         isTenpai = true
         }*/
        
        var tenpaiCandidate = [Mentsu]()
        /*if (isOpenHand) {
         tenpaiCandidate = inputtedMentsuList
         }*/
        // 頭確定のメンツ探索
        if (toitsuList.count != 0) {
            
            for toitsu in toitsuList {
                
                initTmp()
                tenpaiCandidate.removeAll()
                
                tmpTiles[toitsu.identifierTile.getCode()] -= 2
                tenpaiCandidate.append(toitsu)
                
                tenpaiCandidate.append(contentsOf: findKotsuCandidate())
                tenpaiCandidate.append(contentsOf: findShuntsuCandidate())
                
                if (countRemainderTiles() < 3) {
                    let uki = getRemainderTiles()
                    let tenpai = Tenpai(mentsuList: tenpaiCandidate, uki: uki)
                    if(tenpai.getTenpai()) {
                        tenpaiSet.insert(tenpai)
                        isTenpai = true
                    }
                }
                
                
                initTmp()
                tenpaiCandidate.removeAll()
                
                tmpTiles[toitsu.identifierTile.getCode()] -= 2
                tenpaiCandidate.append(toitsu)
                
                tenpaiCandidate.append(contentsOf: findShuntsuCandidate())
                tenpaiCandidate.append(contentsOf: findKotsuCandidate())
                
                if (countRemainderTiles() < 3) {
                    let uki = getRemainderTiles()
                    let tenpai = Tenpai(mentsuList: tenpaiCandidate, uki: uki)
                    if(tenpai.getTenpai()) {
                        tenpaiSet.insert(tenpai)
                        isTenpai = true
                    }
                }
            }
            
        }
        
        
        // 頭なしのメンツ探索
        initTmp()
        tenpaiCandidate.removeAll()
        
        tenpaiCandidate.append(contentsOf: findKotsuCandidate())
        tenpaiCandidate.append(contentsOf: findShuntsuCandidate())
        
        if (countRemainderTiles() < 2) {
            // 単騎待ち
            isTenpai = true
            let uki = getRemainderTiles()
            tenpaiSet.insert(Tenpai(mentsuList: tenpaiCandidate, uki: uki))
        }
        
        initTmp()
        tenpaiCandidate.removeAll()
        
        tenpaiCandidate.append(contentsOf: findShuntsuCandidate())
        tenpaiCandidate.append(contentsOf: findKotsuCandidate())
        
        if (countRemainderTiles() < 2) {
            // 単騎待ち
            isTenpai = true
            let uki = getRemainderTiles()
            tenpaiSet.insert(Tenpai(mentsuList: tenpaiCandidate, uki: uki))
        }
        
        //多面チャンを探していく (浮き牌の数によって余りを何個許容するか変わることに注意)
        if (tenpaiSet.count != 0) {
            
            for tenpai in tenpaiSet {
                let ukiNum = tenpai.uki.count
                let tmp = tenpai.getSyuntsuList() //浮き牌と同じ順子を取ってくる
                let oneTypeSyuntsuList = tmp.0 // 浮き牌と同じタイプの順子のリスト
                var decidedMentsuList = tmp.1 // 残った部分のリスト
                var tiles = [Tile]()
                for syuntsu in oneTypeSyuntsuList {
                    if (!syuntsu.isOpen) { //鳴いている面子は絡めないようにする
                        tiles.append(syuntsu.identifierTile)
                        tiles.append(Tile(rawValue: syuntsu.identifierTile.getCode() - 1)!)
                        tiles.append(Tile(rawValue: syuntsu.identifierTile.getCode() + 1)!)
                    }
                }
                for uki in tenpai.uki {
                    tiles.append(uki)
                }
                
                tmpTiles = encodeTiles(tiles: tiles)
                let _tmpTiles = tmpTiles
                
                // tiles[0].getCode ~ i　と i ~ tiles[tiles.count - 1].getCode() を見ていく
                // めんどいからとりあえず全部見る
                for i in 1 ..< 26 {
                    tmpTiles = _tmpTiles
                    decidedMentsuList = tmp.1
                    
                    for j in i ..< 26 {
                        if (tmpTiles[j - 1] > 0 && tmpTiles[j] > 0 && tmpTiles[j + 1] > 0) {
                            let shuntsu = Syuntsu(
                                isOpen: false,
                                tile1: Tile(rawValue: j - 1)!,
                                tile2: Tile(rawValue: j)!,
                                tile3: Tile(rawValue: j + 1)!
                            )
                            
                            if (shuntsu.isMentsu) {
                                decidedMentsuList.append(shuntsu)
                                tmpTiles[j - 1] -= 1
                                tmpTiles[j] -= 1
                                tmpTiles[j + 1] -= 1
                            }
                        }
                    }
                    
                    for j in 1 ..< i {
                        if (tmpTiles[j - 1] > 0 && tmpTiles[j] > 0 && tmpTiles[j + 1] > 0) {
                            let shuntsu = Syuntsu(
                                isOpen: false,
                                tile1: Tile(rawValue: j - 1)!,
                                tile2: Tile(rawValue: j)!,
                                tile3: Tile(rawValue: j + 1)!
                            )
                            
                            if (shuntsu.isMentsu) {
                                decidedMentsuList.append(shuntsu)
                                tmpTiles[j - 1] -= 1
                                tmpTiles[j] -= 1
                                tmpTiles[j + 1] -= 1
                            }
                        }
                    }
                    
                    
                    if (countRemainderTiles() <= ukiNum) {
                        let uki = getRemainderTiles()
                        let tenpai = Tenpai(mentsuList: decidedMentsuList, uki: uki)
                        if(tenpai.getTenpai()) {
                            tenpaiSet.insert(tenpai)
                        }
                    }
                }
            }
        }
  
    }
    
    func countRemainderTiles() -> Int {
        return tmpTiles.reduce(0) {(num1: Int, num2: Int) -> Int in num1 + num2 }
    }
    
    func getRemainderTiles() -> [Tile] {
        var uki = [Tile]()
        for i in 0 ..< tmpTiles.count {
            while(tmpTiles[i] > 0) {
                uki.append(Tile(rawValue: i)!)
                tmpTiles[i] -= 1
            }
        }
        return uki
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
    
    func encodeTiles(tiles :[Tile]) -> [Int] {
        var resultList = [Int](repeating: 0, count: 34)
        
        for tile in tiles {
            resultList[tile.getCode()] += 1
        }
        
        return resultList
    }
}


