//
//  Kotu.swift
//
//
//  Created by oike toshiyuki on 2017/10/17.
//

import Foundation

class Kotu: Mentu, Equatable, Comparable{
    
    
    static func <(lhs: Kotu, rhs: Kotu) -> Bool {
        if Int(lhs.identifierTile.rawValue) < Int(rhs.identifierTile.rawValue) {
            return true
        }
        return false
    }
    
    static func ==(lhs: Kotu, rhs: Kotu) -> Bool {
        return (lhs.isOpen == rhs.isOpen) && (lhs.isMentu == rhs.isMentu) && (lhs.identifierTile == rhs.identifierTile)
    }
    
    
    var isOpen = false
    var isMentu = false
    //順子はどっかしら決めて持っとく
    var identifierTile: Tile
    
    init() {
        self.identifierTile = Tile.null
        self.isOpen = false
        self.isMentu = false
    }
    
    init(isOpen: Bool, identifierTile: Tile) {
        self.identifierTile = identifierTile
        self.isOpen = isOpen
        self.isMentu = true
    }
    
    
    init(isOpen: Bool, tile1: Tile, tile2: Tile, tile3: Tile) {
        self.isOpen = isOpen
        self.isMentu = Kotu.check(tile1: tile1, tile2: tile2, tile3: tile3)
        if (self.isMentu) {
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
        result = 31 * result + (isMentu ? 1 : 0)
        result = 31 * result + (isOpen ? 1 : 0)
        return result
    }
    
    func getFu() -> Int {
        var mentuFu = 2
        if (!isOpen) {
            mentuFu *= 2
        }
        if (identifierTile.isYaochu()) {
            mentuFu *= 2
        }
        return mentuFu
    }
}
