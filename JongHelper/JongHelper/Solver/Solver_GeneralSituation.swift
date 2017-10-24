//
//  GeneralSituation.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

import Foundation

class GeneralSituation {
    var isHoutei: Bool
    var bakaze: Tile
    var dora: [Tile]
    var honba: Int
    
    init() {
        self.isHoutei = false
        self.bakaze = Tile.null
        self.dora = [Tile.null]
        self.honba = -1
    }
    
    init(isHoutei: Bool, bakaze: Tile, dora: [Tile], honba: Int) {
        self.isHoutei = isHoutei
        self.bakaze = bakaze
        self.dora = dora
        self.honba = honba
    }
    
    func addDora(newDora: Tile) {
        dora.append(newDora)
    }
}
