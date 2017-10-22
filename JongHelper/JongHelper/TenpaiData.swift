//
//  TenpaiData.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/22.
//  Copyright © 2017年 tomato. All rights reserved.
//

class TenpaiData {
    var suteTile: Tile!
    var matiTiles: [Tile]!
    var score: Int!
    
    init(sute: Tile, mati: [Tile], score: Int) {
        self.suteTile = sute
        self.matiTiles = mati
        self.score = score
    }
}
