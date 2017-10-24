//
//  Calculator.swift
//  MjTest
//
//  Created by oike toshiyuki on 2017/10/20.
//  Copyright © 2017年 oike toshiyuki. All rights reserved.
//
import Foundation

class Calculator {
    var normalYakuFuncList:[()->Bool] {
        return [isReach, isIppatu, isTumo, isPinhu, isTanyao, isIpeiko, isHaku, isHatu, isTyun, isJikaze, isBakaze, isRinsyan, isTyankan, isHaitei, isHoutei, isDoubleReach, isTyanta, isHonroutou, isSansyokuDoujun, isIttuu, isToiToi, isSansyokuDoukou, isSanankou, isSankantu, isSyousangen, isTitoitu, isRyanpeiko, isJuntyan, isHonitu, isTinitu]
    }
    
    var yakumanFuncList:[() -> Bool] {
        return[isSuankou, isSuankouTanki,  isDaisangen, isTuiso,  isSusiHou, isDaisusi, isRyuisou, isTyurenPoutou,  isJunseiTyurenpoutou, isTinroutou, isSukantu, isKokusimusou, isKokusimusou13, isTenhou, isTihou]
    }
    
    var scoreTableParent = [
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
    ]
    
    var score = 0
    var fu = 0
    var han = 0
    
    var normalYakuList = [NormalYaku]()
    var yakumanList = [Yakuman]()
    
    var compMentu: CompMentu
    
    var generalSituation: GeneralSituation
    var personalSituation: PersonalSituation
    
    init(compMentu: CompMentu, generalSituation: GeneralSituation, personalSituation: PersonalSituation, addHan: Int) {
        self.compMentu = compMentu
        self.generalSituation = generalSituation
        self.personalSituation = personalSituation
        calculateScore(addHan: addHan)
    }
    
    func calculateScore(addHan: Int) {
        
        // 本当は役満を先に探さなければならないが，役満を未実装のため通常役のみみる
        
        fu = calculateFu()
        han = calculateHan() + addHan
        
        print("役: ", terminator:"")
        for yaku in normalYakuList {
            print("\(yaku.getName())", terminator:", ")
        }
        print(han)
        print("符: \(fu)", terminator:"")
        
        var hanindex: Int
        if han == 0 {
            score = 0
            return
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
                score = scoreTableParent[fuindex][hanindex].0
            } else {
                let tmpscore : (Int, Int)
                switch han {
                case 0: tmpscore = (0, 0)
                case 5: tmpscore = (12000, 4000)
                case 6, 7: tmpscore = (18000, 6000)
                case 8, 9, 10: tmpscore = (24000, 8000)
                case 11, 12: tmpscore = (36000, 12000)
                default: tmpscore = (48000, 16000)
                }
                score  = tmpscore.0
            }
        } else {
            if (5 > han) {
                score = scoreTableChild[fuindex][hanindex].0
            } else {
                let tmpscore : (Int, (Int, Int))
                switch han {
                case 0: tmpscore = (0, (0, 0))
                case 5: tmpscore = (8000, (2000, 4000))
                case 6, 7: tmpscore = (12000, (3000, 6000))
                case 8, 9: tmpscore = (16000, (4000, 8000))
                case 11, 12: tmpscore = (24000, (6000, 12000))
                default: tmpscore = (32000, (8000, 16000))
                }
                score = tmpscore.0
            }
        }
    }
    
    
    func calculateFu() -> Int {
        
        if (normalYakuList.index(of: NormalYaku.Pinhu) != nil && normalYakuList.index(of: NormalYaku.Tumo) != nil) {
            return 20
        }
        
        if (normalYakuList.index(of: NormalYaku.Titoitu) != nil) {
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
        if (janto.getType() == "SANGEN") {
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
        if (compMentu.isTanki() || compMentu.isKanchan() || compMentu.isPenchan()) {
            return 2
        }
        return 0
    }
    
    func calculateHan()  -> Int {
        var tmpHan = 0
        for i in 0 ..< normalYakuFuncList.count {
            if(normalYakuFuncList[i]()) {
                normalYakuList.append(NormalYaku(rawValue: i)!)
                tmpHan += NormalYaku(rawValue: i)!.getHan()
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
            normalYakuList.append(NormalYaku.Dora)
        }
        return dora
    }
    
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
        if janto.getType() == "SANGEN" {
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
            if (kotu.identifierTile == personalSituation.jikaze) {
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
    
    // 先に役満の判定を行って仕舞えば，これだけですむ
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
        if (compMentu.getJanto().identifierTile.getType() != "SANGEN") {
            return false;
        }
        
        var count = 0
        for kotu in compMentu.kotuList {
            if (kotu.identifierTile.getType() == "SANGEN") {
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
        
        for mentu in allMentu {
            if(type != mentu.identifierTile.getType()) {
                return false
            }
        }
        
        return true
    }
    
    func isSuankou() -> Bool {
        return false
    }
    
    func isSuankouTanki() -> Bool {
        return false
    }
    
    func isDaisangen() -> Bool {
        return false
    }
    
    func isTuiso() -> Bool {
        return false
    }
    
    func isSusiHou() -> Bool {
        return false
    }
    
    func isDaisusi() -> Bool {
        return false
    }
    
    func isRyuisou() -> Bool {
        return false
    }
    
    func isTyurenPoutou() -> Bool {
        return false
    }
    
    func isJunseiTyurenpoutou() -> Bool {
        return false
    }
    
    func isTinroutou() -> Bool {
        return false
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

