//
//  WinTehai.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

//
//  Calculator.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

// 上がりの形を管理するクラス
class  CompMentu: Hashable {
    // ------- 上がりの形における各面子のリスト -------
    var toituList = [Toitu]()
    var syuntuList = [Syuntu]()
    var kotuList = [Kotu]()
    var tumo = Tile.null //上がり牌
    
     // ------ 特別な状況に関するフラグ -------
    var isTitoitu = false
    var isOpenHand = false
    
    // 与えられた面子の配列によりイニシャライズ
    init(mentuList: [Mentu], tumo: Tile, isOpenHand: Bool) {
        
        for mentu in mentuList
        {
            if (mentu is Toitu) {
                toituList.append(mentu as! Toitu)
            } else if(mentu is Syuntu) {
                syuntuList.append(mentu as! Syuntu)
            } else if(mentu is Kotu) {
                kotuList.append(mentu as! Kotu)
            }
        }
        hashValue = hashCode()
        self.tumo = tumo
        self.isOpenHand = isOpenHand
    }
    
    // Tenpai型によるイニシャライズ
    init(tenpai: Tenpai, tumo: Tile, isOpenHand: Bool) {
        self.tumo = tumo
        
        toituList = tenpai.toituList
        syuntuList = tenpai.syuntuList
        kotuList = tenpai.kotuList
        
        // テンパイ形における浮き牌と上がり牌で面子を構成し面子のリストに追加
        if (tenpai.isTanki()) {
            // 頭まち & チートイ待ち
            toituList.append(Toitu(identifierTile: tenpai.ukiList[0]))
        } else if (tenpai.isKanchan()) {
            syuntuList.append(Syuntu(isOpen: false, identifierTile: Tile(rawValue:tenpai.ukiList[0].getCode() + 1)!))
        } else if (tenpai.isPenchan()) {
            if(tenpai.ukiList[0].getNumber() == 1) {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: Tile(rawValue: tenpai.ukiList[1].getCode())!))
            } else if(tenpai.ukiList[1].getNumber() == 9) {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: Tile(rawValue: tenpai.ukiList[0].getCode())!))
            }
        } else if (tenpai.isRyanmen()) {
            if(tenpai.ukiList[0].getNumber() > tumo.getNumber()) {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: tenpai.ukiList[0]))
            } else {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: tenpai.ukiList[1]))
            }
        } else if (tenpai.isSyanpon()) {
            kotuList.append(Kotu(isOpen: false, identifierTile: tenpai.ukiList[0]))
        }
        
        self.isOpenHand = isOpenHand
    }
    
    // 雀頭を得る関数
    func getJanto() -> Toitu {
        return toituList[0]
    }
    
    // 対子の数をカウントする関数
    func getToituCount() -> Int {
        return toituList.count
    }
    
    // 順子の数をカウントする関数
    func getSyuntuCount() -> Int {
        return syuntuList.count
    }
    
    // 刻子の数をカウントする関数
    func getKotuCount() -> Int {
        return kotuList.count
    }
    
    // 全ての面子の配列を得る関数
    func getAllMentu() -> [Mentu] {
        var allMentu = [Mentu]()
        allMentu.append(contentsOf: toituList as [Mentu])
        allMentu.append(contentsOf: syuntuList as [Mentu])
        allMentu.append(contentsOf: kotuList as [Mentu])
        return allMentu
    }
    
    // 面子の配列からIntの配列へ変換を行う関数
    func mentuListToIntList() -> [Int] {
        var result = [Int](repeating: 0, count: 34)
        for mentu in getAllMentu() {
            let code = mentu.identifierTile.getCode()
            
            if (mentu is Syuntu) {
                result[code - 1] += 1
                result[code] += 1
                result[code + 1] += 1
            } else if (mentu is Kotu) {
                result[code] += 3
            } else if (mentu is Toitu) {
                result[code] += 2
            }
        }
        return result
    }
    
    static func ==(lhs: CompMentu, rhs: CompMentu) -> Bool {
        return lhs.toituList == rhs.toituList && lhs.syuntuList == rhs.syuntuList && lhs.kotuList == rhs.kotuList && lhs.tumo == rhs.tumo
    }
    
    // 単騎待ちかどうか
    func isTanki() -> Bool {
        return getJanto().identifierTile == tumo
    }
    
    // リャンメン待ちかどうか
    func isRyanmen() -> Bool {
        if isPenchan() {
            return false
        }
        
        for syuntu in syuntuList {
            if (syuntu.identifierTile.getType() != tumo.getType()) {
                continue
            }
            
            let number = syuntu.identifierTile.getNumber()
    
            if number - 1 == tumo.getNumber() || number + 1 == tumo.getNumber() {
                return true
            }
        }
        return false
    }
    
    // 辺張待ちかどうか
    func isPenchan() -> Bool {
        
        for syuntu in syuntuList {
            if (syuntu.identifierTile.getType() != tumo.getType()) {
                continue
            }
            
            var number = syuntu.identifierTile.getNumber()
            if number == 8 && tumo.getNumber() == 7 {
                return true
            }
            if number == 2 && tumo.getNumber() == 3 {
                return true
            }
        }
        return false
    }
    
    // かんちゃん待ちかどうか
    func isKanchan() -> Bool {
        if isRyanmen() {
            return false
        }
        for syuntu in syuntuList {
            if (syuntu.identifierTile.getType() != tumo.getType()) {
                continue
            }
            
            if syuntu.identifierTile.getNumber() == tumo.getNumber() {
                return true
            }
        }
        return false
    }
    
    var hashValue = 0
    
    func hashCode() -> Int {
        var result = 0
        var tmp = 0
        
        result += tumo.getNumber()
        
        for toitu in toituList {
            tmp += toitu.hashCode()
        }
        
        result = 31 * result + tmp;
        
        for shuntu in syuntuList {
            tmp += shuntu.hashCode()
        }
        
        result = 31 * result + tmp;
        
        tmp = 0
        for kotu in kotuList {
            tmp += kotu.hashCode()
        }
        
        return 31 * result + tmp;
        
    }
}



