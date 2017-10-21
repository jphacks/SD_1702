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

class  CompMentsu {
    
    var toitsuList = [Toitsu]()
    var syuntsuList = [Syuntsu]()
    var kotsuList = [Kotsu]()
    var last: Tile
    
    var isTitoitsu = false
    
    var isTanki = false
    var isKanchan = false
    var isPenchan = false
    var isRyanmen = false
    var isSyanpon = false
    
    var isOpenHand = false
    
    init(tenpai: Tenpai, last: Tile, isOpenHand: Bool) {
        self.last = last
        
        toitsuList = tenpai.toitsuList
        syuntsuList = tenpai.syuntsuList
        kotsuList = tenpai.kotsuList
        
        if (tenpai.isTanki()) {
            // 頭まち
            toitsuList.append(Toitsu(identifierTile: tenpai.uki[0]))
        } else if (tenpai.isKanchan()) {
            syuntsuList.append(Syuntsu(isOpen: false, identifierTile: Tile(rawValue:tenpai.uki[0].getCode() + 1)!))
        } else if (tenpai.isPenchan()) {
            if(tenpai.uki[0].getNumber() == 1) {
                syuntsuList.append(Syuntsu(isOpen: false, identifierTile: Tile(rawValue: tenpai.uki[1].getCode() + 1)!))
            } else if(tenpai.uki[1].getNumber() == 9) {
                syuntsuList.append(Syuntsu(isOpen: false, identifierTile: Tile(rawValue: tenpai.uki[0].getCode() - 1)!))
            }
        } else if (tenpai.isRyanmen()) {
            if(tenpai.uki[0].getNumber() > last.getNumber()) {
                syuntsuList.append(Syuntsu(isOpen: false, identifierTile: tenpai.uki[0]))
            } else {
                syuntsuList.append(Syuntsu(isOpen: false, identifierTile: tenpai.uki[1]))
            }
        } else if (tenpai.isSyanpon()) {
            kotsuList.append(Kotsu(isOpen: false, identifierTile: tenpai.uki[0]))
        }
        
        self.isTanki = tenpai.isTanki()
        self.isKanchan = tenpai.isKanchan()
        self.isPenchan = tenpai.isPenchan()
        self.isRyanmen = tenpai.isRyanmen()
        self.isSyanpon = tenpai.isSyanpon()
        
        self.isOpenHand = isOpenHand
    }
    
    func getJanto() -> Toitsu {
        return toitsuList[0]
    }
    
    func getToitsuCount() -> Int {
        return toitsuList.count
    }
    
    func getSyuntsuCount() -> Int {
        return syuntsuList.count
    }
    
    func getKotsuCount() -> Int {
        return kotsuList.count
    }
    
    func getAllMentsu() -> [Mentsu] {
        var allMentsu = [Mentsu]()
        allMentsu.append(contentsOf: toitsuList as [Mentsu])
        allMentsu.append(contentsOf: syuntsuList as [Mentsu])
        allMentsu.append(contentsOf: kotsuList as [Mentsu])
        return allMentsu
    }
    
    func mentsuListToIntList() -> [Int] {
        var result = [Int](repeating: 0, count: 34)
        for mentsu in getAllMentsu() {
            var code = mentsu.identifierTile.getCode()
            
            if (mentsu is Syuntsu) {
                result[code - 1] += 1
                result[code] += 1
                result[code + 1] += 1
            } else if (mentsu is Kotsu) {
                result[code] += 3
            } else if (mentsu is Toitsu) {
                result[code] += 2
            }
        }
        return result
    }
}


