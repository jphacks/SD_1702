
//
//  Syuntsu.swift
//
//
//  Created by oike toshiyuki on 2017/10/17.
//

import Foundation

class Toitsu: Mentsu, Equatable, Comparable {
    static func <(lhs: Toitsu, rhs: Toitsu) -> Bool {
        if Int(lhs.identifierTile.rawValue) < Int(rhs.identifierTile.rawValue) {
            return true
        }
        return false
    }
    
    
    static func ==(lhs: Toitsu, rhs: Toitsu) -> Bool {
        return (lhs.isOpen == rhs.isOpen) && (lhs.isMentsu == rhs.isMentsu) && (lhs.identifierTile == rhs.identifierTile)
    }
    
    var isOpen = false
    var isMentsu = false
    //順子はどっかしら決めて持っとく
    var identifierTile: Tile
    
    init() {
        self.identifierTile = Tile.null
        self.isMentsu = false
    }
    
    init(identifierTile: Tile) {
        self.identifierTile = identifierTile
        isMentsu = true
    }
    
    
    init(tile1: Tile, tile2: Tile) {
        isMentsu = Toitsu.check(tile1: tile1, tile2: tile2)
        if (isMentsu) {
            identifierTile = tile1
        } else {
            identifierTile = Tile(rawValue: -1)!
        }
    }
    
    class func check(tile1: Tile, tile2: Tile) -> Bool {
        return tile1 == tile2
    }
    
    //tilesは要素数34の配列
    class func findJantoCandidate(tiles: [Int]) -> [Toitsu] {
        var result = [Toitsu]();
        
        for i in 0 ..< tiles.count {
            if (tiles[i] >= 2) {
                result.append(Toitsu(identifierTile: Tile(rawValue:i)!))
            }
        }
        
        return result
    }
    
    func getFu() -> Int {
        return 0
    }
    
    func hashCode() -> Int {
        var result: Int = identifierTile.getCode() != -1 ? identifierTile.hashValue : 0
        result = 31 * result + (isMentsu ? 1 : 0)
        return result
    }
    
}
