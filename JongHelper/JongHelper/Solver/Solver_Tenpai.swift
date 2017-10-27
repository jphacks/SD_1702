//
//  Tenpai.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/19.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

// テンパイ形の情報を管理するクラス
class Tenpai: Hashable {
    var hashValue = 0
    
    static func ==(lhs: Tenpai, rhs: Tenpai) -> Bool {
        return (lhs.toituList == rhs.toituList) && (lhs.syuntuList == rhs.syuntuList) && (lhs.kotuList == rhs.kotuList) && (lhs.ukiList == rhs.ukiList) && (lhs.wait == rhs.wait)
    }
    
    // 面子のリスト
    var toituList = [Toitu]()
    var syuntuList = [Syuntu]()
    var kotuList = [Kotu]()
    // 捨て牌
    var suteTile = Tile.null
    // 浮いている牌の配列
    var ukiList = [Tile]() // uki[0] < uki[1]
    // 待ち牌の配列
    var wait = [Tile]()
    // テンパイ形かどうかのフラグ
    var isTenpai = false

    // イニシャライズ
    init(mentuList: [Mentu], ukiList: [Tile], suteTile: Tile) {
        
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
        
        self.ukiList = ukiList
        self.suteTile = suteTile
        
        
        if(isTanki()) {
            wait.append(ukiList[0])
            isTenpai = true
        } else if(isKanchan()) {
            wait.append(Tile(rawValue: ukiList[0].getCode() + 1)!)
            isTenpai = true
        } else if(isPenchan()) {
            if(ukiList[0].getNumber() == 1) {
                wait.append(Tile(rawValue: ukiList[1].getCode() + 1)!)
            } else if(ukiList[1].getNumber() == 9) {
                wait.append(Tile(rawValue: ukiList[0].getCode() - 1)!)
            }
            isTenpai = true
        } else if(isRyanmen()) {
            wait.append(Tile(rawValue: ukiList[0].getCode() - 1)!)
            wait.append(Tile(rawValue: ukiList[1].getCode() + 1)!)
            isTenpai = true
        } else if(isSyanpon()) {
            wait.append(ukiList[0])
            isTenpai = true
        }
        
        hashValue = hashCode()
    }

    func getWait() -> [Tile] {
        return wait
    }
    
    // 浮き牌と同じtypeの順子を取ってくる，とった順子の残りも返す
    func getSyuntuList() -> ([Syuntu], [Mentu]) {
        var _syuntuList = [Syuntu]()
        var nokori = [Mentu]()
        
        nokori.append(contentsOf: toituList as [Mentu])
        nokori.append(contentsOf: kotuList as [Mentu])
        
        
        for syuntu in syuntuList {
            if(syuntu.identifierTile.getType() == ukiList[0].getType()) {
                _syuntuList.append(syuntu)
            } else {
                nokori.append(syuntu)
            }
        }
        return (_syuntuList, nokori)
    }
    
    func isTanki() -> Bool {
        if (ukiList.count == 1) {
            return true
        }
        return false
    }
    
    func isKanchan() -> Bool {
        
        if (ukiList.count == 2) {
            if ukiList[0].getType() == ukiList[1].getType() && ukiList[0].getNumber() + 2 == ukiList[1].getNumber() {
                return true
            }
        }
        return false
    }
    
    func isPenchan() -> Bool {
        if (ukiList.count == 2) {
            if (ukiList[0].getType() == ukiList[1].getType()) {
                if (ukiList[0].getNumber() == 1 && ukiList[1].getNumber() == 2) {
                    return true
                } else if (ukiList[0].getNumber() == 8 && ukiList[1].getNumber() == 9) {
                    return true
                }
            }
        }
            
        return false
    }
    
    func isRyanmen() -> Bool {
        if (ukiList.count == 2) {
            if (ukiList[0].getType() == ukiList[1].getType()) {
                if (ukiList[0].getNumber() != 1 || ukiList[1].getNumber() != 9) {
                    if (ukiList[0].getNumber()  + 1 == ukiList[1].getNumber()) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isSyanpon() -> Bool {
        if (ukiList.count == 2) {
            if (ukiList[0].getCode() == ukiList[1].getCode()) {
                return true
            }
        }
        return false
    }
    
    // デバッグ用の表示関数
    func printTenpai() {
        
        for kotu in kotuList {
            let t = kotu.identifierTile
            print("\(t)\(t)\(t)\t", terminator:"")
        }
        for syuntu in syuntuList {
            let t2 = syuntu.identifierTile
            let t1 = Tile(rawValue: t2.getCode() - 1)!
            let t3 = Tile(rawValue: t2.getCode() + 1)!
            print("\(t1)\(t2)\(t3)\t", terminator:"")
        }
        for toitu in toituList {
            let t = toitu.identifierTile
            print("\(t)\(t)\t", terminator:"")
        }
        for uki in ukiList {
            print("\(uki)", terminator:"")
        }
        print("   ", terminator:"")
        for wait in wait {
            print("\(wait)", terminator:"")
        }
        print()
    }
    
    func hashCode() -> Int {
        var result = 0
        var tmp = 0
        
        for x in ukiList {
            result += x.getCode()
        }
        
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


extension Array where Element: Hashable {
    typealias E = Element
    func diff(_ other: [E]) -> [E] {
        let all = self + other
        var counter: [E: Int] = [:]
        all.forEach { counter[$0] = (counter[$0] ?? 0) + 1 }
        return all.filter { (counter[$0] ?? 0) == 1 }
    }
}
