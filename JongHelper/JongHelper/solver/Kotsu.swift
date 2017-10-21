//
//  Kotsu.swift
//
//
//  Created by oike toshiyuki on 2017/10/17.
//

import Foundation

class Kotsu: Mentsu, Equatable, Comparable{
    
    
    static func <(lhs: Kotsu, rhs: Kotsu) -> Bool {
        if Int(lhs.identifierTile.rawValue) < Int(rhs.identifierTile.rawValue) {
            return true
        }
        return false
    }
    
    static func ==(lhs: Kotsu, rhs: Kotsu) -> Bool {
        return (lhs.isOpen == rhs.isOpen) && (lhs.isMentsu == rhs.isMentsu) && (lhs.identifierTile == rhs.identifierTile)
    }
    
    
    var isOpen = false
    var isMentsu = false
    //順子はどっかしら決めて持っとく
    var identifierTile: Tile
    
    init() {
        self.identifierTile = Tile.null
        self.isOpen = false
        self.isMentsu = false
    }
    
    init(isOpen: Bool, identifierTile: Tile) {
        self.identifierTile = identifierTile
        self.isOpen = isOpen
        self.isMentsu = true
    }
    
    
    init(isOpen: Bool, tile1: Tile, tile2: Tile, tile3: Tile) {
        self.isOpen = isOpen
        self.isMentsu = Kotsu.check(tile1: tile1, tile2: tile2, tile3: tile3)
        if (self.isMentsu) {
            identifierTile = tile1
        } else {
            identifierTile = Tile(rawValue: -1)!
        }
    }
    
    class func check(tile1: Tile, tile2: Tile, tile3: Tile) -> Bool {
        return tile1 == tile2 && tile2 == tile3
    }
    
    func hashCode() -> Int {
        var result: Int = identifierTile.getCode() != -1 ? identifierTile.hashValue : 0
        result = 31 * result + (isMentsu ? 1 : 0)
        result = 31 * result + (isOpen ? 1 : 0)
        return result
    }
    
    func getFu() -> Int {
        var mentsuFu = 2
        if (!isOpen) {
            mentsuFu *= 2
        }
        if (identifierTile.isYaochu()) {
            mentsuFu *= 2
        }
        return mentsuFu
    }
}
