
//
//  Syuntu.swift
//
//
//  Created by oike toshiyuki on 2017/10/17.
//

import Foundation

class Toitu: Mentu, Equatable, Comparable {
    static func <(lhs: Toitu, rhs: Toitu) -> Bool {
        if Int(lhs.identifierTile.rawValue) < Int(rhs.identifierTile.rawValue) {
            return true
        }
        return false
    }
    
    
    static func ==(lhs: Toitu, rhs: Toitu) -> Bool {
        return (lhs.isOpen == rhs.isOpen) && (lhs.isMentu == rhs.isMentu) && (lhs.identifierTile == rhs.identifierTile)
    }
    
    var isOpen = false
    var isMentu = false
    //順子はどっかしら決めて持っとく
    var identifierTile: Tile
    
    init() {
        self.identifierTile = Tile.null
        self.isMentu = false
    }
    
    init(identifierTile: Tile) {
        self.identifierTile = identifierTile
        isMentu = true
    }
    
    
    init(tile1: Tile, tile2: Tile) {
        isMentu = Toitu.check(tile1: tile1, tile2: tile2)
        if (isMentu) {
            identifierTile = tile1
        } else {
            identifierTile = Tile(rawValue: -1)!
        }
    }
    
    class func check(tile1: Tile, tile2: Tile) -> Bool {
        return tile1 == tile2
    }
    
    //tilesは要素数34の配列
    class func findJantoCandidate(tiles: [Int]) -> [Toitu] {
        var result = [Toitu]();
        
        for i in 0 ..< tiles.count {
            if (tiles[i] >= 2) {
                result.append(Toitu(identifierTile: Tile(rawValue:i)!))
            }
        }
        
        return result
    }
    
    func getFu() -> Int {
        return 0
    }
    
    func hashCode() -> Int {
        var result: Int = identifierTile.getCode() != -1 ? identifierTile.hashValue : 0
        result = 31 * result + (isMentu ? 1 : 0)
        return result
    }
    
}
