//
//  Yaku.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//

enum Yaku: Int {
    // 1 han
    case Reach = 0
    case Ippatu
    case Tumo
    case Pinhu
    case Tanyao
    case Ipeiko
    case Haku
    case Hatu
    case Tyun
    case Jikaze
    case Bakaze
    case Rinsyan
    case Tyankan
    case Haitei
    case Houtei //14
    // 2han
    case DoubleReach
    case Tyanta
    case Honroutou
    case SansyokuDoujun
    case Ittuu
    case ToiToi
    case SansyokuDoukou
    case Sanankou
    case Sankantu
    case Syousangen
    case Titoitu //25
    // 3han
    case Ryanpeikou
    case Juntyan
    case Honitu
    // 6han
    case Tinitu
    // Dora
    case Dora //30
    //　役満
    case Suankou //31
    case SuankouTanki
    case Daisangen
    case Tuisou
    case Syoususi
    case Daisusi
    case Ryuisou
    case Tyurenpoutou
    case JunseiTyurenpoutou
    case Tinroutou
    case Sukantu
    case Tenhou
    case Tihou
    case Kokusimusou
    case Kokusimusou13
    
    func getHan() -> Int {
        switch self {
        case .Reach, .Ippatu, .Tumo, .Pinhu, .Tanyao, .Ipeiko, .Haku, .Hatu, .Tyun, .Jikaze, .Bakaze, .Rinsyan, .Tyankan, .Haitei, .Houtei, .Dora: return 1
        case .DoubleReach, .Tyanta, .Honroutou, .SansyokuDoujun, .Ittuu, .ToiToi, .SansyokuDoukou, .Sanankou, .Sankantu, .Syousangen, .Titoitu: return 2
        case .Ryanpeikou, .Juntyan, .Honitu: return 3
        case .Tinitu: return 6
        default: return -1
        }
    }
    
    func isKuisagari() -> Bool {
        switch self {
        case .Tyanta, .SansyokuDoujun, .SansyokuDoukou, .Ittuu, .Juntyan, .Honitu, .Tinitu: return true
        default: return false
        }
    }
    
    func isDoubleYakuman() -> Bool {
        switch self {
        case .SuankouTanki, .Daisusi, .JunseiTyurenpoutou, .Sukantu, .Kokusimusou13: return true
        default: return false
        }
    }
    
    func getName() -> String {
        switch self {
        case .Reach: return "リーチ"
        case .Ippatu: return "一発"
        case .Tumo: return "門前清模和"
        case .Pinhu: return "平和"
        case .Tanyao: return "断ヤオ"
        case .Ipeiko: return "一盃口"
        case .Haku: return "白"
        case .Hatu: return "發"
        case .Tyun: return "中"
        case .Jikaze: return"門風牌"
        case .Bakaze: return "荘風牌"
        case .Rinsyan: return "嶺上開花"
        case .Tyankan: return "槍槓"
        case .Haitei: return "海底撈月"
        case .Houtei: return "河底撈魚"
        case .DoubleReach: return "ダブルリーチ"
        case .Tyanta: return "全帯"
        case .Honroutou: return "混老頭"
        case .SansyokuDoujun: return "三色同順"
        case .Ittuu: return "一気通貫"
        case .ToiToi: return "対々和"
        case .SansyokuDoukou: return "三色同刻"
        case .Sanankou: return "三暗刻"
        case .Sankantu: return "三槓子"
        case .Syousangen: return "小三元"
        case .Titoitu: return "七対子"
        case .Ryanpeikou: return "二盃口"
        case .Juntyan: return "純全帯"
        case .Honitu: return "混一色"
        case .Tinitu: return "清一色"
        case .Dora: return "ドラ"
        case .Suankou: return "四暗刻"
        case .SuankouTanki: return "四暗刻単騎待ち"
        case .Daisangen: return "大三元"
        case .Tuisou: return "字一色"
        case .Syoususi: return "小四喜"
        case .Daisusi: return "大四喜"
        case .Ryuisou: return "緑一色"
        case .Tyurenpoutou: return "九蓮宝燈"
        case .JunseiTyurenpoutou: return "純正九連宝燈"
        case .Tinroutou: return "清老頭"
        case .Sukantu: return "四槓子"
        case .Tenhou: return "天和"
        case .Tihou: return "地和"
        case .Kokusimusou: return "国士無双"
        case .Kokusimusou13: return "国士無双十三面待ち"
        }
    }
    
    func getDesc() -> String {
        switch self {
        case .Reach: return "リーチ"
        case .Ippatu: return "一発"
        case .Tumo: return "門前清模和"
        case .Pinhu: return "メンツが４つとも順子で、雀頭が役牌でなく、両面待ちの時に成立"
        case .Tanyao: return "２～８の数牌のみの場合に成立"
        case .Ipeiko: return "同じ順子が２組ある場合に成立"
        case .Haku: return "字牌の「白」の刻子（槓子）がある場合に成立"
        case .Hatu: return "字牌の「發」の刻子（槓子）がある場合に成立"
        case .Tyun: return "字牌の「中」の刻子（槓子）がある場合に成立"
        case .Jikaze: return"自風（親なら東家なので「東」）と同じ字牌の刻子（槓子）がある場合に成立"
        case .Bakaze: return "場風（南場の「南」）と同じ字牌の刻子（槓子）がある場合に成立"
        case .Rinsyan: return "嶺上開花"
        case .Tyankan: return "槍槓"
        case .Haitei: return "海底撈月"
        case .Houtei: return "河底撈魚"
        case .DoubleReach: return "ダブルリーチ"
        case .Tyanta: return "４つのメンツと雀頭すべてにヤオ九牌（1・9と字牌）が含まれている場合に成立"
        case .Honroutou: return "すべての牌がヤオ九牌（1・9と字牌）だけの場合に成立"
        case .SansyokuDoujun: return "３種類の色（万子・索子・筒子）それぞれに、同じ数字の並びの順子がある場合に成立"
        case .Ittuu: return "同種（同色）の数牌で、１２３、４５６、７８９、の順子がある場合に成立"
        case .ToiToi: return "４つのメンツすべてが刻子（槓子）の場合に成立"
        case .SansyokuDoukou: return "３種類の色（万子・索子・筒子）それぞれに、同じ数字の刻子（槓子）がある場合に成立"
        case .Sanankou: return "暗刻（暗槓）が３つある場合に成立．ロンの場合、アガリ牌を含む刻子は暗刻とみなされないことに注意が必要．"
        case .Sankantu: return "槓子（暗刻・明刻いずれでも可）が３つある場合に成立"
        case .Syousangen: return "三元牌（白・發・中）のいずれか１つを雀頭とし、残り２種類を刻子（槓子）とした場合に成立"
        case .Titoitu: return "対子が７組ある場合に成立．同牌が４枚ある場合には成立しない．"
        case .Ryanpeikou: return "同じ順子が２組という組み合わせが２つある場合に成立"
        case .Juntyan: return "４つのメンツと雀頭すべてに老頭牌（１・９）が含まれる場合に成立"
        case .Honitu: return "万子、索子、筒子のどれか一種類の牌と、字牌だけの場合に成立"
        case .Tinitu: return "万子、索子、筒子のどれか一種類の牌だけの場合に成立"
        case .Dora: return "上がった時に、手牌や鳴いた牌の中にドラが含まれると1枚につき1飜加算する．ドラ表示牌の次の牌がドラになる．（アガリ役ではないため、ドラだけでは上がることはできない．）"
        case .Suankou: return "暗刻（暗槓）が３つある場合に成立します．ロンの場合、アガリ牌を含む刻子は暗刻とみなされないことに注意が必要．"
        case .SuankouTanki: return "四暗刻のうち単騎待ちの場合に成立．ダブル役満"
        case .Daisangen: return "三元牌（白・發・中）の３種類すべてが刻子（槓子）である場合に成立"
        case .Tuisou: return "すべての牌が字牌である場合に成立"
        case .Syoususi: return "風牌（東・南・西・北）のうち３種が刻子（槓子）で、残りの１種が雀頭である場合に成立"
        case .Daisusi: return "風牌（東・南・西・北）の４種類すべてが刻子（槓子）である場合に成立．ダブル役満"
        case .Ryuisou: return "索子の２３４６８と字牌の發のみである場合に成立"
        case .Tyurenpoutou: return "万子、索子、筒子のどれか一種類の牌だけで、１１１２３４５６７８９９９の牌とさらに１枚１～９の牌を追加した牌形である場合に成立"
        case .JunseiTyurenpoutou: return "九連宝燈のうち、聴牌時の牌形が１１１２３４５６７８９９９の牌であり、１～９の牌いずれでも上がれる場合（９面待ち）に成立．ダブル役満"
        case .Tinroutou: return "すべての牌が老頭牌（１・９）だけである場合に成立"
        case .Sukantu: return "槓子（暗槓・明槓いずれでも可）が４つある場合に成立．ダブル役満"
        case .Tenhou: return "親の配牌の時点で既にアガリ形になっている場合に成立"
        case .Tihou: return "子の最初のツモでツモアガリした場合に成立．そのツモの前にポン・チー・カン（暗カンを含む）が行われると無効"
        case .Kokusimusou: return "13種類すべてのヤオ九牌（１・９と字牌）が最低１枚ずつあり、そのうちのどれか１種類が２枚ある場合に成立"
        case .Kokusimusou13: return "国士無双のうち、聴牌時に13種類すべてのヤオ九牌が１枚ずつあり、ヤオ九牌ならどれでも上がれる場合（13面待ち）に成立．ダブル役満"
        }
    }
}

