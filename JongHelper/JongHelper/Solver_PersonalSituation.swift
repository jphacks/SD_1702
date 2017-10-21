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
    var isIppatsu: Bool
    var isReach: Bool
    var isDoubleReach: Bool
    var isTyankan: Bool
    var isRinsyan: Bool
    var jikaze: Tile
    
    init(isParent: Bool, isTsumo: Bool, isIppatsu: Bool, isReach: Bool, isDoubleReach: Bool, isTyankan: Bool, isRinsyan: Bool, jikaze: Tile) {
        self.isParent = isParent
        self.isTsumo = isTsumo
        self.isIppatsu = isIppatsu
        self.isReach = isReach
        self.isDoubleReach = isDoubleReach
        self.isTyankan = isTyankan
        self.isRinsyan = isRinsyan
        self.jikaze = jikaze
    }
}
