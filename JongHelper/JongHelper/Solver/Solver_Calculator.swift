//
//  Calculator.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//
import Foundation

class Calculator {
    
    // 役満は通常役を喰うため，通常役と役満の判定は別にする必要がある
    // 通常役を判定するための関数テーブル
    var normalYakuFuncList:[()->Bool] {
        return [isReach, isIppatu, isTumo, isPinhu, isTanyao, isIpeiko, isHaku, isHatu, isTyun, isJikaze, isBakaze, isRinsyan, isTyankan, isHaitei, isHoutei, isDoubleReach, isTyanta, isHonroutou, isSansyokuDoujun, isIttuu, isToiToi, isSansyokuDoukou, isSanankou, isSankantu, isSyousangen, isTitoitu, isRyanpeiko, isJuntyan, isHonitu, isTinitu]
    }
    
    // 役満を判定するための関数テーブル
    var yakumanFuncList:[() -> Bool] {
        return[isSuankou, isSuankouTanki,  isDaisangen, isTuiso,  isSyoususi, isDaisusi, isRyuisou, isTyurenPoutou,  isJunseiTyurenpoutou, isTinroutou, isSukantu, isKokusimusou, isKokusimusou13, isTenhou, isTihou]
    }
    
    /*var scoreTableParent = [
        [(0, 0), (0, 700), (0, 1300), (0, 2600)], //20符
        [(0, 0), (2400, 0), (4800, 1600), (9600, 3200)], //25符
        [(1500, 500), (2900, 1000), (5800, 2000), (11600, 3900)],
        [(2000, 700), (3900, 1300), (7700, 2600), (12000, 4000)],
        [(2400, 800), (4800, 1600), (9600, 3200), (12000, 4000)],
        [(2900, 1000), (5800, 2000), (11600, 3900), (12000, 4000)],
        [(3400, 1200), (6800, 2300), (12000, 4000), (12000, 4000)],
        [(3900, 1300), (7700, 2600), (12000, 4000), (12000, 4000)],
        [(4400, 1500), (8700, 2900), (12000, 4000), (12000, 4000)],
        [(4800, 1600), (9600, 3200), (12000, 4000), (12000, 4000)],
        [(5300, 1800), (10600, 3600), (12000, 4000), (12000, 4000)]
    ]
    
    var scoreTableChild = [
        [(0, (0, 0)), (0, (400, 700)), (0, (700, 1300)), (0, (1300, 2600))], //20符
        [(0, (0, 0)), (1600, (0, 0)), (3200, (800, 1600)), (6400, (1600, 3200))], //25符
        [(1000, (300, 500)), (2000, (500, 1000)), (3900, (1000, 2000)), (7700, (2000, 3900))],
        [(1300, (400, 700)), (2600, (700, 1300)), (5200, (1300, 2600)), (8000, (2000, 4000))],
        [(1600, (400, 800)), (3200, (800, 1600)), (6400, (1600, 3200)), (8000, (2000, 4000))],
        [(2000, (600, 1200)), (3900, (1000, 2000)), (7700, (2000, 3900)), (8000, (2000, 4000))],
        [(2300, (600, 1200)), (4500, (1300, 2300)), (8000, (2000, 4000)), (8000, (2000, 4000))],
        [(2600, (700, 1300)), (5200, (1300, 2600)), (8000, (2000, 4000)), (8000, (2000, 4000))],
        [(2900, (800, 1500)), (5800, (1500, 2900)), (8000, (2000, 4000)), (8000, (2000, 4000))],
        [(3200, (800, 1600)), (6400, (1600, 3200)), (8000, (2000, 4000)), (8000, (2000, 4000))],
        [(3600, (900, 1800)), (7100, (1800, 3600)), (8000, (2000, 4000)), (8000, (2000, 4000))]
    ]*/
    
    // 満貫以下の親の上がりに対する点数表（インデックスは符と飜数）
    var scoreTableParent = [
        [(0, 0), (0, 2100), (0, 3900), (0, 7800)], //20符
        [(0, 0), (2400, 0), (4800, 4800), (9600, 9600)], //25符
        [(1500, 1500), (2900, 3000), (5800, 6000), (11600, 11700)],
        [(2000, 2100), (3900, 3900), (7700, 7800), (12000, 12000)],
        [(2400, 2400), (4800, 4800), (9600, 9600), (12000, 12000)],
        [(2900, 3000), (5800, 6000), (11600, 11700), (12000, 12000)],
        [(3400, 3600), (6800, 6900), (12000, 12000), (12000, 12000)],
        [(3900, 3900), (7700, 7800), (12000, 12000), (12000, 12000)],
        [(4400, 4500), (8700, 8700), (12000, 12000), (12000, 12000)],
        [(4800, 4800), (9600, 9600), (12000, 12000), (12000, 12000)],
        [(5300, 5400), (10600, 10800), (12000, 12000), (12000, 12000)]
    ]
    // 満貫以下の子の上がりに対する点数表（インデックスは符と飜数）
    var scoreTableChild = [
        [(0, 0), (0, 1500), (0, 2400), (0, 5200)], //20符
        [(0, 0), (1600, 0), (3200, 3200), (6400, 6400)], //25符
        [(1000, 1100), (2000, 2000), (3900, 4000), (7700, 7900)],
        [(1300, 1500), (2600, 2700), (5200, 5200), (8000, 8000)],
        [(1600, 1600), (3200, 3200), (6400, 6400), (8000, 8000)],
        [(2000, 2400), (3900, 4000), (7700, 7900), (8000, 8000)],
        [(2300, 2400), (4500, 4900), (8000, 8000), (8000, 8000)],
        [(2600, 2700), (5200, 5200), (8000, 8000), (8000, 8000)],
        [(2900, 3100), (5800, 5900), (8000, 8000), (8000, 8000)],
        [(3200, 3200), (6400, 6400), (8000, 8000), (8000, 8000)],
        [(3600, 3600), (7100, 7200), (8000, 8000), (8000, 8000)]
    ]
    
    // 成立する役のリスト
    var yakuList = [Yaku]()
    
    // ----- 成立する役を調べるためのプロパティ -----
    var compMentu: CompMentu //上がりの形
    var generalSituation: GeneralSituation
    var personalSituation: PersonalSituation
    
    // 与えられた上がりの形，状況によってイニシャライズ
    init(compMentu: CompMentu, generalSituation: GeneralSituation, personalSituation: PersonalSituation) {
        self.compMentu = compMentu
        self.generalSituation = generalSituation
        self.personalSituation = personalSituation
    }
    
    // 返り値 ((ロン，ツモ），符，飜)
    func calculateScore(addHan: Int) -> (score: (ron: Int, tumo: Int), fu: Int, han: Int){
        
        // 役満が成立するかどうかを調べる
        let yakumanCount = calculateYakuman()

        if yakumanCount > 0 {
            if personalSituation.isParent {
                return (score: (ron: 48000 * yakumanCount, tumo: 48000 * yakumanCount), 0, 0)
            } else {
                return (score: (ron: 32000 * yakumanCount, tumo: 32000 * yakumanCount), 0, 0)
            }
        }
        
        
        // 役満が成立しない場合に，通常役の判定を行う
        let han = calculateHan() + addHan
        let fu = calculateFu()
        
        print("役: ", terminator:"")
        for yaku in yakuList {
            print("\(yaku.getName())", terminator:", ")
        }
        print(han)
        print("符: \(fu)")
        
        // 点数表にアクセスするために，飜数と符からインデックスを求める
        var hanindex: Int
        if han == 0 {
            return ((0, 0), 0, 0)
        } else {
            hanindex =  han - 1
        }
        var fuindex: Int
        if (fu == 20) {
            fuindex = 0
        } else if (fu == 25){
            fuindex = 1
        } else {
            fuindex = fu / 10 - 1
        }
        
        if (personalSituation.isParent) {
            if (5 > han) {
                return (scoreTableParent[fuindex][hanindex], fu, han)
            } else {
                let tmpscore : (Int, Int)
                switch han {
                case 0: tmpscore = (0, 0)
                case 5: tmpscore = (12000, 12000)
                case 6, 7: tmpscore = (18000, 18000)
                case 8, 9, 10: tmpscore = (24000, 24000)
                case 11, 12: tmpscore = (36000, 36000)
                default: tmpscore = (48000, 48000)
                }
                print(tmpscore)
                return (tmpscore, fu, han)
            }
        } else {
            if (5 > han) {
                return (scoreTableChild[fuindex][hanindex], fu, han)
            } else {
                let tmpscore : (Int, Int)
                switch han {
                case 0: tmpscore = (0, 0)
                case 5: tmpscore = (8000, 8000)
                case 6, 7: tmpscore = (12000, 12000)
                case 8, 9, 10: tmpscore = (16000, 16000)
                case 11, 12: tmpscore = (24000, 24000)
                default: tmpscore = (32000, 32000)
                }
                print(tmpscore)
                return (tmpscore, fu, han)
            }
        }
    }
    
    // 成立する役満を調べる関数
    func calculateYakuman() -> Int {
        var yakumanCount = 0
        for i in 0 ..< yakumanFuncList.count {
            if(yakumanFuncList[i]()) {
                yakuList.append(Yaku(rawValue: 31 + i)!)
                yakumanCount += Yaku(rawValue: 31 + i)!.isDoubleYakuman() ? 2 : 1
            }
        }
        
        return yakumanCount
    }
    
    
    // 符の計算を行う関数
    func calculateFu() -> Int {
        
        if (yakuList.index(of: Yaku.Pinhu) != nil && yakuList.index(of: Yaku.Tumo) != nil) {
            return 20
        }
        
        if (yakuList.index(of: Yaku.Titoitu) != nil) {
            return 25
        }
        
        var tmpFu = 20
        tmpFu += calculateFuByJanto()
        tmpFu += calculateFuByAgari()
        tmpFu += calculateFuByWait()
        
        for mentu in compMentu.getAllMentu() {
            tmpFu += mentu.getFu();
        }
        
        let fu = ceil(Float(tmpFu) / 10.0)
        return Int(fu) * 10
    }
    
    func calculateFuByJanto() -> Int {
        let janto = compMentu.getJanto().identifierTile
        var tmp = 0
        if (janto == generalSituation.bakaze) {
            tmp += 2
        }
        if (janto == personalSituation.jikaze) {
            tmp += 2
        }
        if (janto.getType() == "SANGENPAI") {
            tmp += 2
        }
        return tmp
    }
    
    func calculateFuByAgari() -> Int {
        if (personalSituation.isTsumo) {
            return 2
        }
        if (!compMentu.isOpenHand) {
            return 10
        }
        return 0
    }
    
    func calculateFuByWait() -> Int {
        if ((compMentu.isTanki() || compMentu.isKanchan() || compMentu.isPenchan()) && !isPinhu()) {
            return 2
        }
        return 0
    }
    
    // 飜の計算を行う関数
    func calculateHan()  -> Int {
        var tmpHan = 0
        for i in 0 ..< normalYakuFuncList.count {
            if(normalYakuFuncList[i]()) {
                yakuList.append(Yaku(rawValue: i)!)
                tmpHan += Yaku(rawValue: i)!.getHan()
            }
        }
        
        if (tmpHan > 0) {
            tmpHan += calculateHanByDora()
        }
        return tmpHan
    }
    
    func calculateHanByDora() -> Int {
        var dora = 0
        var tmphand = compMentu.mentuListToIntList()
        
        for tileDora in generalSituation.dora {
            if tileDora != Tile.null {
                dora += tmphand[tileDora.getCode()]
            }
        }
        for _ in 0 ..< dora {
            yakuList.append(Yaku.Dora)
        }
        return dora
    }
    
    // ----- 以下は各役に対して成立するか調べる関数が書いてある -----
    
    func isReach() -> Bool {
        if (personalSituation.isReach) {
            return true
        }
        return false
    }
    func isIppatu() -> Bool {
        if (personalSituation.isIppatu) {
            return true
        }
        return false
    }
    func isTumo() -> Bool {
        if (personalSituation.isTsumo) {
            return true
        }
        return false
    }
    
    
    func isPinhu() -> Bool {
        if compMentu.getSyuntuCount() < 4 {
            return false
        }
        
        let janto = compMentu.getJanto().identifierTile
        if janto.getType() == "SANGENPAI" || janto == personalSituation.jikaze || janto == generalSituation.bakaze {
            return false
        }
        
        if (!compMentu.isRyanmen()) {
            return false
        }
        return true
    }
    
    func isTanyao() -> Bool {
        for mentu in compMentu.getAllMentu() {
            let number = mentu.identifierTile.getNumber()
            if (number == 0 || number == 1 || number == 9) {
                return false
            }
            
            if (mentu is Syuntu) {
                let syuntuNum = mentu.identifierTile.getNumber()
                if (syuntuNum == 2 || syuntuNum == 8) {
                    return false
                }
            }
        }
        
        return true
    }
    
   
    func isIpeiko() -> Bool {
        
        var arr = [Int](repeating:0, count:26)
        
        for syuntu in compMentu.syuntuList {
            arr[syuntu.identifierTile.getCode()] += 1
        }
        var count = 0
        for i in 1 ..< 26 {
            if arr[i] > 1 {
                count += 1
            }
        }
        if count == 1 {
            return true
        }
        return false
    }
    
    func isHaku() -> Bool {
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile == Tile.Haku) {
                return true
            }
        }
        return false
    }
    
    func isHatu() -> Bool {
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile == Tile.Hatu) {
                return true
            }
        }
        return false
    }
    
    func isTyun() -> Bool {
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile == Tile.Tyun) {
                return true
            }
        }
        return false
    }
    
    func isJikaze() -> Bool {
        for kotu in compMentu.kotuList {
            if kotu.identifierTile == personalSituation.jikaze {
                return true
            }
        }
        return false
    }
    
    func isBakaze() -> Bool {
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile == generalSituation.bakaze) {
                return true
            }
        }
        return false
    }
    
    func isRinsyan() -> Bool {
        if (personalSituation.isRinsyan) {
            return true
        }
        return false
    }
    func isTyankan() -> Bool {
        if (personalSituation.isTyankan) {
            return true
        }
        return false
    }
    func isHaitei() -> Bool {
        if (generalSituation.isHoutei && personalSituation.isTsumo) {
            return true
        }
        return false
    }
    func isHoutei() -> Bool {
        if (generalSituation.isHoutei && !personalSituation.isTsumo) {
            return true
        }
        return false
    }
    func isDoubleReach() -> Bool {
        if (personalSituation.isDoubleReach) {
            return true
        }
        return false
    }
    
    
    func isTyanta() -> Bool{
        
        let jantoNum = compMentu.getJanto().identifierTile.getNumber()
        
        if (isJuntyan()) {
            return false
        }
        
        if (jantoNum != 1 && jantoNum != 9 && jantoNum != 0) {
            return false
        }
        
        if (compMentu.getSyuntuCount() == 0) {
            return false
        }
        
        for syuntu in compMentu.syuntuList {
            let syuntuNum = syuntu.identifierTile.getNumber()
            if (syuntuNum != 2 && syuntuNum != 8) {
                return false
            }
        }
        
        for kotu in compMentu.kotuList {
            let kotuNum = kotu.identifierTile.getNumber()
            if (kotuNum != 1 && kotuNum != 9 && kotuNum != 0) {
                return false
            }
        }
        
        return true
    }
    
    func isHonroutou() -> Bool {
        if (compMentu.syuntuList.count > 0) {
            return false
        }
        for toitu in compMentu.toituList {
            let num = toitu.identifierTile.getNumber()
            if (1 < num && num < 9) {
                return false
            }
        }
        
        for kotu in compMentu.kotuList {
            let num = kotu.identifierTile.getNumber()
            if (1 < num && num < 9) {
                return false
            }
        }
        
        return true
    }
    
    func isSansyokuDoujun() -> Bool {
        var manzu = false
        var pinzu = false
        var sohzu = false
        var f1 = false
        var f2 = false
        
        if (compMentu.getSyuntuCount() < 3) {
            return false
        }
        
        let candidate1 = compMentu.syuntuList[0]
        let candidate2 = compMentu.syuntuList[1]
        
        for syuntu in compMentu.syuntuList {
            let syuntuType = syuntu.identifierTile.getType()
            let syuntuNum = syuntu.identifierTile.getNumber()
            
            if (candidate1.identifierTile.getNumber() == syuntuNum) {
                if (syuntuType == "MANZU") {
                    manzu = true
                } else if (syuntuType == "PINZU") {
                    pinzu = true
                } else if (syuntuType == "SOHZU") {
                    sohzu = true
                }
            }
        }
        f1 = manzu && pinzu && sohzu
        
        manzu = false; pinzu = false; sohzu = false
        for syuntu in compMentu.syuntuList {
            let syuntuType = syuntu.identifierTile.getType()
            let syuntuNum = syuntu.identifierTile.getNumber()
            
            if (candidate2.identifierTile.getNumber() == syuntuNum) {
                if (syuntuType == "MANZU") {
                    manzu = true
                } else if (syuntuType == "PINZU") {
                    pinzu = true
                } else if (syuntuType == "SOHZU") {
                    sohzu = true
                }
            }
        }
        f2 = manzu && pinzu && sohzu
        
        return f1 || f2
    }
    
    func IttuuSolver(oneTypeSyuntuList: [Syuntu]) -> Bool {
        var number2 = false
        var number5 = false
        var number8 = false
        
        for syuntu in oneTypeSyuntuList {
            let num = syuntu.identifierTile.getNumber()
            if (num == 2) {
                number2 = true
            } else if (num == 5) {
                number5 = true
            } else if (num == 8) {
                number8 = true
            }
        }
        
        return number2 && number5 && number8
    }
    
    func isIttuu() -> Bool {
        if (compMentu.getSyuntuCount() < 3) {
            return false
        }
        
        var manzu = [Syuntu]()
        var pinzu = [Syuntu]()
        var sohzu = [Syuntu]()
        
        for syuntu in compMentu.syuntuList {
            let type = syuntu.identifierTile.getType()
            if (type == "MANZU") {
                manzu.append(syuntu)
            } else if (type == "PINZU") {
                pinzu.append(syuntu)
            } else if (type == "SOHZU") {
                sohzu.append(syuntu)
            }
        }
        
        if (manzu.count >= 3) {
            return IttuuSolver(oneTypeSyuntuList: manzu)
        } else if (pinzu.count >= 3) {
            return IttuuSolver(oneTypeSyuntuList: pinzu)
        } else if (sohzu.count >= 3) {
            return IttuuSolver(oneTypeSyuntuList: sohzu)
        }
        return false
    }
    
    // 面前手のみなのでトイトイはない
    func isToiToi() -> Bool {
        return compMentu.getKotuCount() == 4
    }
    
    // 現状の実装だとそーとしておかないとダメそう
    func isSansyokuDoukou() -> Bool {
        var manzu = false
        var pinzu = false
        var sohzu = false
        var f1 = false
        var f2 = false
        
        if (compMentu.getKotuCount() < 3) {
            return false
        }
        
        let candidate1 = compMentu.kotuList[0]
        let candidate2 = compMentu.kotuList[1]
        
        
        for kotu in compMentu.kotuList {
            let kotuType = kotu.identifierTile.getType()
            let kotuNum = kotu.identifierTile.getNumber()
            
            
            if (candidate1.identifierTile.getNumber() == kotuNum) {
                if (kotuType == "MANZU") {
                    manzu = true
                } else if (kotuType == "PINZU") {
                    pinzu = true
                } else if (kotuType == "SOHZU") {
                    sohzu = true
                }
            }
        }
        
        f1 = manzu && pinzu && sohzu
        
        for kotu in compMentu.kotuList {
            let kotuType = kotu.identifierTile.getType()
            let kotuNum = kotu.identifierTile.getNumber()
            
            if (candidate2.identifierTile.getNumber() == kotuNum) {
                if (kotuType == "MANZU") {
                    manzu = true
                } else if (kotuType == "PINZU") {
                    pinzu = true
                } else if (kotuType == "SOHZU") {
                    sohzu = true
                }
            }
        }
        
        f2 = manzu && pinzu && sohzu
        
        return f1 || f2
    }
    
    func isSanankou() -> Bool {
        if (compMentu.getKotuCount() < 3) {
            return false
        }
        
        var ankouCount = 0
        for kotu in compMentu.kotuList {
            if (!kotu.isOpen) {
                ankouCount += 1
            }
        }
        return ankouCount == 3
    }
    
    // まだ槓子を未実装のため後回し
    func isSankantu() -> Bool {
        return false
    }
    
    func isSyousangen() -> Bool {
        if (compMentu.getJanto().identifierTile.getType() != "SANGENPAI") {
            return false;
        }
        
        var count = 0
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile.getType() == "SANGENPAI") {
                count += 1
            }
            if (count == 2) {
                return true;
            }
        }
        
        return false;
    }
    
    // 特別な処理が必要なためあとで実装する
    func isTitoitu() -> Bool{
        if compMentu.getToituCount() == 7 {
            return true
        }
        
        return false
    }
    
    func isRyanpeiko() -> Bool {
        var arr = [Int](repeating:0, count:26)
        
        for syuntu in compMentu.syuntuList {
            arr[syuntu.identifierTile.getCode()] += 1
        }
        var count = 0
        for i in 1 ..< 26 {
            if arr[i] > 1 {
                count += 1
            }
        }
        if count == 2 {
            return true
        }
        return false
    }
    
    func isJuntyan() -> Bool {
        
        if (isTitoitu()) { return false }
        
        for syuntu in compMentu.syuntuList {
            let num = syuntu.identifierTile.getNumber()
            if (num != 2 && num != 8) {
                return false
            }
        }
        
        for kotu in compMentu.kotuList {
            let num = kotu.identifierTile.getNumber()
            if (num != 1 && num != 9) {
                return false
            }
        }
        
        return true
    }
    
    func isHonitu() -> Bool {
        var hasJihai = false
        var type = ""
        
        for mentu in compMentu.getAllMentu() {
            if (mentu.identifierTile.getNumber() == 0) {
                hasJihai = true
            } else if (type.isEmpty) {
                type = mentu.identifierTile.getType()
            } else if (type != mentu.identifierTile.getType()) {
                return false
            }
        }
        return hasJihai
    }
    
    func isTinitu() -> Bool {
        
        let allMentu = compMentu.getAllMentu()
        let type = allMentu[0].identifierTile.getType()
        
        for mentu in compMentu.getAllMentu() {
            if(type != mentu.identifierTile.getType()) {
                return false
            }
        }
        
        return true
    }
    
    func isSuankou() -> Bool {
        return !compMentu.isTanki() && compMentu.getKotuCount() == 4
    }
    
    func isSuankouTanki() -> Bool {
        return compMentu.isTanki() && compMentu.getKotuCount() == 4
    }
    
    func isDaisangen() -> Bool {
        var count = 0
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile.getType() == "SANGENPAI") {
                count += 1
            }
            if (count == 3) {
                return true
            }
        }
        return false
    }
    
    func isTuiso() -> Bool {
        for mentu in compMentu.getAllMentu() {
            if mentu.identifierTile.getNumber() != 0 {
                return false
            }
        }
        
        return true
    }
    
    func isSyoususi() -> Bool {
        if compMentu.getJanto().identifierTile.getType() != "FONPAI" {
            return false
        }
        
        var count = 0
        for kotu in compMentu.kotuList {
            if kotu.identifierTile.getType() == "FONPAI" {
                count += 1
            }
        }
        
        if count == 3 {
            return true
        }
        return false
    }
    
    func isDaisusi() -> Bool {
        if compMentu.getSyuntuCount() > 0 {
            return false
        }
        
        for kotu in compMentu.kotuList {
            if kotu.identifierTile.getType() != "FONPAI" {
                return false
            }
        }
        
        return true
    }
    
    func isRyuisou() -> Bool {
        
        for syuntu in compMentu.syuntuList {
            if syuntu.identifierTile.getCode() != 20 {
                return false
            }
        }
        
        for kotu in compMentu.kotuList {
            var tmp = kotu.identifierTile.getCode()
            if tmp != 19 && tmp != 20 && tmp != 21 && tmp != 23 && tmp != 25 && tmp != 32{
                return false
            }
        }
        
        for toitu in compMentu.toituList {
            var tmp = toitu.identifierTile.getCode()
            if tmp != 19 && tmp != 20 && tmp != 21 && tmp != 23 && tmp != 25 && tmp != 32{
                return false
            }
        }
        
        return true
    }
    
    func isTyurenPoutou() -> Bool {
        if !isTinitu() {
            return false
        }
        
        if isJunseiTyurenpoutou() {
            return false
        }
        
        let allMentu = compMentu.getAllMentu()
        let type = allMentu[0].identifierTile.getType()
        var hand = compMentu.mentuListToIntList()
        var start = 0
        var end = 8
        
        switch type {
        case "MANZU": start = 0; end = 8
        case "PINZU": start = 9; end = 17
        case "SOHZU": start = 18; end = 26
        default: return false
        }
        
        if hand[start] >= 3  && hand[end] >= 3 {
            hand[start] -= 3
            hand[end] -= 3
        } else {
            return false
        }
        
        for i in start + 1 ..< end {
            if hand[i] >= 1 {
                hand[i] -= 1
            } else {
                return false
            }
        }
        
        for i in start ... end {
            if hand[i] > 0 {
                return true
            }
        }
        
        return false
    }
    
    func isJunseiTyurenpoutou() -> Bool {
        if !isTinitu() {
            return false
        }
        
        let allMentu = compMentu.getAllMentu()
        let type = allMentu[0].identifierTile.getType()
        var hand = compMentu.mentuListToIntList()
        var start = 0
        var end = 8
        
        switch type {
        case "MANZU": start = 0; end = 8
        case "PINZU": start = 9; end = 17
        case "SOHZU": start = 18; end = 26
        default: return false
        }
        
        if hand[start] >= 3  && hand[end] >= 3 {
            hand[start] -= 3
            hand[end] -= 3
        } else {
            return false
        }
        
        for i in start + 1 ..< end {
            if hand[i] >= 1 {
                hand[i] -= 1
            } else {
                return false
            }
        }
        
        for i in start ... end {
            if hand[i] > 0 {
                continue
            }
            
            if (i == compMentu.tumo.getCode()) {
                return true
            } else {
                return false
            }
        }
        
        return false
    }
    
    func isTinroutou() -> Bool {
        
        if compMentu.syuntuList.count > 0 {
            return false
        }
        
        var janto = compMentu.getJanto().identifierTile
        if janto.getNumber() != 1 && janto.getNumber() != 9 {
            return false
        }
        
        for kotu in compMentu.kotuList {
            if kotu.identifierTile.getNumber() != 1 && kotu.identifierTile.getNumber() != 9 {
                return false
            }
        }
        
        return true
    }
    
    func isSukantu() -> Bool {
        return false
    }
    
    func isKokusimusou() -> Bool {
        return false
    }
    
    func isKokusimusou13() -> Bool {
        return false
    }
    
    func isTenhou() -> Bool {
        return false
    }
    
    func isTihou() -> Bool {
        return false
    }
}

