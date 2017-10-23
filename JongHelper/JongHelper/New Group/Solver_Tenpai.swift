//
//  Tenpai.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/19.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

class Tenpai: Hashable {
    var hashValue = 0
    
    static func ==(lhs: Tenpai, rhs: Tenpai) -> Bool {
        return (lhs.toituList == rhs.toituList) && (lhs.syuntuList == rhs.syuntuList) && (lhs.kotuList == rhs.kotuList) && (lhs.uki == rhs.uki) && (lhs.wait == rhs.wait)
    }
    
    var toituList = [Toitu]()
    var syuntuList = [Syuntu]()
    var kotuList = [Kotu]()
    var uki = [Tile]() // uki[0] < uki[1]
    var wait = [Tile]()

    init(mentuList: [Mentu], uki: [Tile]) {
        
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
        
        self.uki = uki
        
        if(isTanki()) {
            wait.append(uki[0])
        } else if(isKanchan()) {
            wait.append(Tile(rawValue: uki[0].getCode() + 1)!)
        } else if(isPenchan()) {
            if(uki[0].getNumber() == 1) {
                wait.append(Tile(rawValue: uki[1].getCode() + 1)!)
            } else if(uki[1].getNumber() == 9) {
                wait.append(Tile(rawValue: uki[0].getCode() - 1)!)
            }
        } else if(isRyanmen()) {
            wait.append(Tile(rawValue: uki[0].getCode() - 1)!)
            wait.append(Tile(rawValue: uki[1].getCode() + 1)!)
        } else if(isSyanpon()) {
            wait.append(uki[0])
        }
        
        hashValue = hashCode()
        
    }
    
    func getTenpai() -> Bool {
        if(isTanki() || isKanchan() || isPenchan() || isRyanmen() || isSyanpon()) {
            return true
        }
        return false
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
            if(syuntu.identifierTile.getType() == uki[0].getType()) {
                _syuntuList.append(syuntu)
            } else {
                nokori.append(syuntu)
            }
        }
        return (_syuntuList, nokori)
    }
    
    func isTanki() -> Bool {
        if (uki.count == 1) {
            //print("isTanki")
            return true
        }
        return false
    }
    
    func isKanchan() -> Bool {
        if (uki.count == 2) {
            if ((uki[0].getType() == uki[1].getType()) && (uki[0].getNumber() + 2 == uki[1].getNumber())) {
            //print("isKanchan")
                return true
            }
        }
        return false
    }
    
    func isPenchan() -> Bool {
        if (uki.count == 2) {
            if (uki[0].getType() == uki[1].getType()) {
                if (uki[0].getNumber() == 1 && uki[1].getNumber() == 2) {
                    //print("\(uki[0])\(uki[1])")
                    //print("isPenchan")
                    return true
                } else if (uki[0].getNumber() == 8 && uki[1].getNumber() == 9) {
                    //print("\(uki[0])\(uki[1])")
                    //print("isPenchan")
                    return true
                }
            }
        }
        return false
    }
    
    func isRyanmen() -> Bool {
        if (uki.count == 2) {
            if (uki[0].getType() == uki[0].getType()) {
                if (uki[0].getNumber() != 1 || uki[1].getNumber() != 9) {
                    if (uki[0].getNumber() + 1 == uki[1].getNumber()) {
                        return true
                        //print("isRyanmen")
                    }
                }
            }
        }
        return false
    }
    
    func isSyanpon() -> Bool {
        if (uki.count == 2) {
            if (uki[0].getCode() == uki[1].getCode()) {
                //print("isSyanpon")
                return true
            }
            
        }
        return false
    }
    
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
        for uki in uki {
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
        
        for x in uki {
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
