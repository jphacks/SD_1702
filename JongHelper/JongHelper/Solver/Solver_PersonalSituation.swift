//
//  PersonalSituation.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

class PersonalSituation {
    var isParent: Bool
    var isTsumo: Bool
    var isIppatu: Bool
    var isReach: Bool
    var isDoubleReach: Bool
    var isTyankan: Bool
    var isRinsyan: Bool
    var jikaze: Tile
    
    init() {
        self.isParent = false
        self.isTsumo = false
        self.isIppatu = false
        self.isReach = false
        self.isDoubleReach = false
        self.isTyankan = false
        self.isRinsyan = false
        self.jikaze = Tile.null
    }
    
    init(isTsumo: Bool, isIppatu: Bool, isReach: Bool, isDoubleReach: Bool, isTyankan: Bool, isRinsyan: Bool, jikaze: Tile) {
        self.isParent = (jikaze == Tile.Ton)
        self.isTsumo = isTsumo
        self.isIppatu = isIppatu
        self.isReach = isReach
        self.isDoubleReach = isDoubleReach
        self.isTyankan = isTyankan
        self.isRinsyan = isRinsyan
        self.jikaze = jikaze
    }
}
