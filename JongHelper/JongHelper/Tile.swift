//
//  Tile.swift
//  JongHelper
//
//  Created by Satoshi Kobayashi on 2017/10/21.
//  Copyright © 2017年 tomato. All rights reserved.
//

import UIKit

enum Tile: Int {
    case null = -1
    case m1
    case m2
    case m3
    case m4
    case m5
    case m6
    case m7
    case m8
    case m9
    case p1
    case p2
    case p3
    case p4
    case p5
    case p6
    case p7
    case p8
    case p9
    case s1
    case s2
    case s3
    case s4
    case s5
    case s6
    case s7
    case s8
    case s9
    case Ton
    case Nan
    case Sya
    case Pe
    case Haku
    case Hatu
    case Tyun
    
    func getCode() -> Int {
        return self.rawValue
    }
    
    func getType() -> String {
        switch self {
        case .null: return "NULL"
        case .m1, .m2, .m3, .m4, .m5, .m6, .m7, .m8, .m9: return "MANZU"
        case .p1, .p2, .p3, .p4, .p5, .p6, .p7, .p8, .p9: return "PINZU"
        case .s1, .s2, .s3, .s4, .s5, .s6, .s7, .s8, .s9: return "SOHZU"
        case .Ton, .Nan, .Sya, .Pe: return "FONPAI"
        case .Haku, .Hatu, .Tyun: return "SANGENPAI"
        }
    }
    
    
    func getNumber() -> Int {
        switch self {
        case .null: return -1
        case .Ton, .Nan, .Sya, .Pe, .Haku, .Hatu, .Tyun: return 0
        case .m1, .p1, .s1: return 1
        case .m2, .p2, .s2: return 2
        case .m3, .p3, .s3: return 3
        case .m4, .p4, .s4: return 4
        case .m5, .p5, .s5: return 5
        case .m6, .p6, .s6: return 6
        case .m7, .p7, .s7: return 7
        case .m8, .p8, .s8: return 8
        case .m9, .p9, .s9: return 9
        }
    }
    
    func isYaochu() -> Bool {
        return self.getNumber() == 0 || self.getNumber() == 1 || self.getNumber() == 9
    }
    
    func toUIImage() -> UIImage {
        let imgDir = "Resource/Hai/"
        var imgName: String
        switch self {
        case .null:
            imgName = "none.png"
        case .Ton:
            imgName = "ji1-66-90-l.png"
        case .Nan:
            imgName = "ji2-66-90-l.png"
        case .Sya:
            imgName = "ji3-66-90-l.png"
        case .Pe:
            imgName = "ji4-66-90-l.png"
        case .Haku:
            imgName = "ji6-66-90-l.png"
        case .Hatu:
            imgName = "ji5-66-90-l.png"
        case .Tyun:
            imgName = "ji7-66-90-l.png"
        case .m1:
            imgName = "man1-66-90-l.png"
        case .m2:
            imgName = "man2-66-90-l.png"
        case .m3:
            imgName = "man3-66-90-l.png"
        case .m4:
            imgName = "man4-66-90-l.png"
        case .m5:
            imgName = "man5-66-90-l.png"
        case .m6:
            imgName = "man6-66-90-l.png"
        case .m7:
            imgName = "man7-66-90-l.png"
        case .m8:
            imgName = "man8-66-90-l.png"
        case .m9:
            imgName = "man9-66-90-l.png"
        case .p1:
            imgName = "pin1-66-90-l.png"
        case .p2:
            imgName = "pin2-66-90-l.png"
        case .p3:
            imgName = "pin3-66-90-l.png"
        case .p4:
            imgName = "pin4-66-90-l.png"
        case .p5:
            imgName = "pin5-66-90-l.png"
        case .p6:
            imgName = "pin6-66-90-l.png"
        case .p7:
            imgName = "pin7-66-90-l.png"
        case .p8:
            imgName = "pin8-66-90-l.png"
        case .p9:
            imgName = "pin9-66-90-l.png"
        case .s1:
            imgName = "sou1-66-90-l.png"
        case .s2:
            imgName = "sou2-66-90-l.png"
        case .s3:
            imgName = "sou3-66-90-l.png"
        case .s4:
            imgName = "sou4-66-90-l.png"
        case .s5:
            imgName = "sou5-66-90-l.png"
        case .s6:
            imgName = "sou6-66-90-l.png"
        case .s7:
            imgName = "sou7-66-90-l.png"
        case .s8:
            imgName = "sou8-66-90-l.png"
        case .s9:
            imgName = "sou9-66-90-l.png"
        default:
            imgName = "ji1-66-90-l.png"
        }
        return UIImage(named: imgDir + imgName)!
    }
    
}
