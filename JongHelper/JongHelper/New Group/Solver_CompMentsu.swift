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

class  CompMentu: Hashable {
    
    var hashValue = 0
    var toituList = [Toitu]()
    var syuntuList = [Syuntu]()
    var kotuList = [Kotu]()
    var tumo: Tile
    
    var isTitoitu = false
    
    var isTanki = false
    var isKanchan = false
    var isPenchan = false
    var isRyanmen = false
    var isSyanpon = false
    
    //var isOpenHand = false
    
    init(mentuList: [Mentu], tumo: Tile) {
        
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
    }
    
    init(tenpai: Tenpai, tumo: Tile, isOpenHand: Bool) {
        self.tumo = tumo
        
        toituList = tenpai.toituList
        syuntuList = tenpai.syuntuList
        kotuList = tenpai.kotuList
        
        if (tenpai.isTanki()) {
            // 頭まち
            toituList.append(Toitu(identifierTile: tenpai.uki[0]))
        } else if (tenpai.isKanchan()) {
            syuntuList.append(Syuntu(isOpen: false, identifierTile: Tile(rawValue:tenpai.uki[0].getCode() + 1)!))
        } else if (tenpai.isPenchan()) {
            if(tenpai.uki[0].getNumber() == 1) {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: Tile(rawValue: tenpai.uki[1].getCode() + 1)!))
            } else if(tenpai.uki[1].getNumber() == 9) {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: Tile(rawValue: tenpai.uki[0].getCode() - 1)!))
            }
        } else if (tenpai.isRyanmen()) {
            if(tenpai.uki[0].getNumber() > tumo.getNumber()) {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: tenpai.uki[0]))
            } else {
                syuntuList.append(Syuntu(isOpen: false, identifierTile: tenpai.uki[1]))
            }
        } else if (tenpai.isSyanpon()) {
            kotuList.append(Kotu(isOpen: false, identifierTile: tenpai.uki[0]))
        }
        
        self.isTanki = tenpai.isTanki()
        self.isKanchan = tenpai.isKanchan()
        self.isPenchan = tenpai.isPenchan()
        self.isRyanmen = tenpai.isRyanmen()
        self.isSyanpon = tenpai.isSyanpon()
        
        self.isOpenHand = isOpenHand
    }
    
    func getJanto() -> Toitu {
        return toituList[0]
    }
    
    func getToituCount() -> Int {
        return toituList.count
    }
    
    func getSyuntuCount() -> Int {
        return syuntuList.count
    }
    
    func getKotuCount() -> Int {
        return kotuList.count
    }
    
    func getAllMentu() -> [Mentu] {
        var allMentu = [Mentu]()
        allMentu.append(contentsOf: toituList as [Mentu])
        allMentu.append(contentsOf: syuntuList as [Mentu])
        allMentu.append(contentsOf: kotuList as [Mentu])
        return allMentu
    }
    
    func mentuListToIntList() -> [Int] {
        var result = [Int](repeating: 0, count: 34)
        for mentu in getAllMentu() {
            var code = mentu.identifierTile.getCode()
            
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
    
    func hashCode() -> Int {
        var result = 0
        var tmp = 0
        
        resutl += tumo
        
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

