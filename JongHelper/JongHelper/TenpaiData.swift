//
//  TenpaiData.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/22.
//  Copyright © 2017年 tomato. All rights reserved.
//

class TenpaiData {
    var suteTile: Tile!
    var matiTiles: [(tile: Tile, ron: Int, tumo: Int)]!
    
    init(sute: Tile!, mati: [(Tile, Int, Int)]!) {
        self.suteTile = sute
        self.matiTiles = mati
    }
}
