//
//  Mentsu.swift
//  
//
//  Created by oike toshiyuki on 2017/10/17.
//

import Foundation

protocol Mentsu: class {
    
    var isOpen: Bool {get set}
    var isMentsu: Bool {get set}
    //順子はどっかしら決めて持っとく
    var identifierTile: Tile {get set}
    
    func getFu() -> Int
    
}
