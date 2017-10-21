//
//  Tenpai.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/19.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

class Tenpai: Equatable, Hashable {
    var hashValue = 0
    
    static func ==(lhs: Tenpai, rhs: Tenpai) -> Bool {
        return (lhs.toitsuList == rhs.toitsuList) && (lhs.syuntsuList == rhs.syuntsuList) && (lhs.kotsuList == rhs.kotsuList) && (lhs.uki == rhs.uki) && (lhs.wait == rhs.wait)
    }
    
    
    var toitsuList = [Toitsu]()
    var syuntsuList = [Syuntsu]()
    var kotsuList = [Kotsu]()
    var uki = [Tile]() // uki[0] < uki[1]
    var wait = [Tile]()

    init(mentsuList: [Mentsu], uki: [Tile]) {
        
        for mentsu in mentsuList
        {
            if (mentsu is Toitsu) {
                toitsuList.append(mentsu as! Toitsu)
            } else if(mentsu is Syuntsu) {
                syuntsuList.append(mentsu as! Syuntsu)
            } else if(mentsu is Kotsu) {
                kotsuList.append(mentsu as! Kotsu)
            }
        }
        
        syuntsuList.sort {$0 < $1}
        
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
            wait.append(uki[0])
            wait.append(uki[1])
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
    func getSyuntsuList() -> ([Syuntsu], [Mentsu]) {
        var _syuntsuList = [Syuntsu]()
        var nokori = [Mentsu]()
        
        nokori.append(contentsOf: toitsuList as [Mentsu])
        nokori.append(contentsOf: kotsuList as [Mentsu])
        
        
        for syuntsu in syuntsuList {
            if(syuntsu.identifierTile.getType() == uki[0].getType()) {
                _syuntsuList.append(syuntsu)
            } else {
                nokori.append(syuntsu)
            }
        }
        return (_syuntsuList, nokori)
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
        
        for kotsu in kotsuList {
            let t = kotsu.identifierTile
            print("\(t)\(t)\(t)\t", terminator:"")
        }
        for syuntsu in syuntsuList {
            let t2 = syuntsu.identifierTile
            let t1 = Tile(rawValue: t2.getCode() - 1)!
            let t3 = Tile(rawValue: t2.getCode() + 1)!
            print("\(t1)\(t2)\(t3)\t", terminator:"")
        }
        for toitsu in toitsuList {
            let t = toitsu.identifierTile
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
        
        for toitsu in toitsuList {
            tmp += toitsu.hashCode()
        }
        
        result = 31 * result + tmp;
        
        for shuntsu in syuntsuList {
            tmp += shuntsu.hashCode()
        }
        
        result = 31 * result + tmp;
        
        tmp = 0
        for kotsu in kotsuList {
            tmp += kotsu.hashCode()
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
