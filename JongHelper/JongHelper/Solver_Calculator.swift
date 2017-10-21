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
    
    var yakumanFuncList:[() -> Void] {
        return[]
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
    
    var normalYakuList = [NormalYaku]()
    var yakumanList = [Yakuman]()
    
    var compMentsu: CompMentsu
    
    var generalSituation: GeneralSituation
    var personalSituation: PersonalSituation
    
    init(compMentsu: CompMentsu, generalSituation: GeneralSituation, personalSituation: PersonalSituation) {
        self.compMentsu = compMentsu
        self.generalSituation = generalSituation
        self.personalSituation = personalSituation
    }
    
    func calculateScore() {
        
        // 本当は役満を先に探さなければならないが，役満を未実装のため通常役のみみる
        
        let fu = calculateFu()
        let han = calculateHan()
        
        print("役: ", terminator:"")
        for yaku in normalYakuList {
            print("\(yaku.getName())", terminator:", ")
        }
        print(han)
        print("符: \(fu)", terminator:"")
        
        var hanindex = han - 1
        var fuindex: Int
        if (fu == 25) {
            fuindex = 1
        } else if (fu % 10 == 0){
            fuindex = fu / 10 - 2
        } else {
            fuindex = 0
            print("fu:error")
        }
        
        
        if (personalSituation.isParent) {
            if (5 > han) {
                print(scoreTableParent[fuindex][hanindex])
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
                print(tmpscore)
            }
        } else {
            if (5 > han) {
                print(scoreTableParent[fuindex][hanindex])
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
                print(tmpscore)
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
        
        for mentsu in compMentsu.getAllMentsu() {
            tmpFu += mentsu.getFu();
        }
        
        let fu = ceil(Float(tmpFu) / 10.0)
        return Int(fu) * 10
    }
    
    func calculateFuByJanto() -> Int {
        let janto = compMentsu.getJanto().identifierTile
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
        if (!compMentsu.isOpenHand) {
            return 10
        }
        return 0
    }
    
    func calculateFuByWait() -> Int {
        if (compMentsu.isTanki || compMentsu.isKanchan || compMentsu.isPenchan) {
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
        var tmphand = compMentsu.mentsuListToIntList()
        
        for tileDora in generalSituation.dora {
            dora += tmphand[tileDora.getCode()]
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
        if (personalSituation.isIppatsu) {
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
        if compMentsu.getSyuntsuCount() < 4 {
            return false
        }
        let janto = compMentsu.getJanto().identifierTile
        if janto.getType() == "SANGEN" {
            return false
        }
        
        if (!compMentsu.isRyanmen) {
            return false
        }
        return true
    }
    
    func isTanyao() -> Bool {
        for mentsu in compMentsu.getAllMentsu() {
            let number = mentsu.identifierTile.getNumber()
            if (number == 0 || number == 1 || number == 9) {
                return false
            }
        
            if (mentsu is Syuntsu) {
                let syuntsuNum = mentsu.identifierTile.getNumber()
                if (syuntsuNum == 2 || syuntsuNum == 8) {
                    return false
                }
            }
        }
        
        return true
    }
    
    func peikoCount() -> Int {
        var peiko = 0
        var stock1 = Syuntsu()
        var stock2 = Syuntsu()
        
        for syuntsu in compMentsu.syuntsuList {
            
            if (syuntsu.isOpen) {
                return 0
            }
            
            if (!stock1.isMentsu) {
                stock1 = syuntsu
                continue
            }
            
            if (stock1 == syuntsu && peiko == 0) {
                peiko = 1
                continue
            }
            
            if (!stock2.isMentsu) {
                stock2 = syuntsu
                continue
            }
            
            if (stock2 == syuntsu) {
                peiko = 2
            }
        }
        return peiko
    }
    
    func isIpeiko() -> Bool {
        return peikoCount() == 1
    }
    
    func isHaku() -> Bool {
        for kotsu in compMentsu.kotsuList {
            if (kotsu.identifierTile == Tile.Haku) {
                return true
            }
        }
        return false
    }
    
    func isHatu() -> Bool {
        for kotsu in compMentsu.kotsuList {
            if (kotsu.identifierTile == Tile.Hatu) {
                return true
            }
        }
        return false
    }
    
    func isTyun() -> Bool {
        for kotsu in compMentsu.kotsuList {
            if (kotsu.identifierTile == Tile.Tyun) {
                return true
            }
        }
        return false
    }
    
    func isJikaze() -> Bool {
        for kotsu in compMentsu.kotsuList {
            if (kotsu.identifierTile == personalSituation.jikaze) {
                return true
            }
        }
        return false
    }
    func isBakaze() -> Bool {
        for kotsu in compMentsu.kotsuList {
            if (kotsu.identifierTile == generalSituation.bakaze) {
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
        let jantoNum = compMentsu.getJanto().identifierTile.getNumber()
        
        if (jantoNum != 1 && jantoNum != 9 && jantoNum != 0) {
            return false
        }
        
        if (compMentsu.getSyuntsuCount() == 0) {
            return false
        }
        
        for syuntsu in compMentsu.syuntsuList {
            let syuntsuNum = syuntsu.identifierTile.getNumber()
            if (syuntsuNum != 2 && syuntsuNum != 8) {
                return false
            }
        }
        
        for kotsu in compMentsu.kotsuList {
            let kotsuNum = kotsu.identifierTile.getNumber()
            if (kotsuNum != 1 && kotsuNum != 9 && kotsuNum != 0) {
                return false
            }
        }
        
        return true
    }
    
    func isHonroutou() -> Bool {
        if (compMentsu.syuntsuList.count > 0) {
            return false
        }
        for toitsu in compMentsu.toitsuList {
            let num = toitsu.identifierTile.getNumber()
            if (1 < num && num < 9) {
                return false
            }
        }
        
        for kotsu in compMentsu.kotsuList {
            let num = kotsu.identifierTile.getNumber()
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
        
        if (compMentsu.getSyuntsuCount() < 3) {
            return false
        }
        
        var candidate = Syuntsu()
        
        for syuntsu in compMentsu.syuntsuList {
            let syuntsuType = syuntsu.identifierTile.getType()
            let syuntsuNum = syuntsu.identifierTile.getNumber()
            
            if (candidate.isMentsu == false) {
                candidate = syuntsu
                continue
            }
            
            if (candidate.identifierTile.getNumber() == syuntsuNum) {
                if (syuntsuType == "MANZU") {
                    manzu = true
                } else if (syuntsuType == "PINZU") {
                    pinzu = true
                } else if (syuntsuType == "SOHZU") {
                    sohzu = true
                }
                
                
                if (candidate.identifierTile.getType() == "MANZU") {
                    manzu = true
                } else if (candidate.identifierTile.getType() == "PINZU") {
                    pinzu = true
                } else if (candidate.identifierTile.getType() == "SOHZU") {
                    sohzu = true
                }
            } else {
                candidate = syuntsu
            }
        }
        return manzu && pinzu && sohzu
    }
    
    func IttuuSolver(oneTypeSyuntuList: [Syuntsu]) -> Bool {
        var number2 = false
        var number5 = false
        var number8 = false
        
        for syuntsu in oneTypeSyuntuList {
            let num = syuntsu.identifierTile.getNumber()
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
        if (compMentsu.getSyuntsuCount() < 3) {
            return false
        }
        
        var manzu = [Syuntsu]()
        var pinzu = [Syuntsu]()
        var sohzu = [Syuntsu]()
        
        for syuntsu in compMentsu.syuntsuList {
            let type = syuntsu.identifierTile.getType()
            if (type == "MANZU") {
                manzu.append(syuntsu)
            } else if (type == "PINZU") {
                pinzu.append(syuntsu)
            } else if (type == "SOHZU") {
                sohzu.append(syuntsu)
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
        return compMentsu.getKotsuCount() == 4
    }
    
    // 現状の実装だとそーとしておかないとダメそう
    func isSansyokuDoukou() -> Bool {
        var manzu = false
        var pinzu = false
        var sohzu = false
        
        if (compMentsu.getKotsuCount() < 3) {
            return false
        }
        
        var candidate = Kotsu()
        
        for kotsu in compMentsu.kotsuList {
            let kotsuType = kotsu.identifierTile.getType()
            let kotsuNum = kotsu.identifierTile.getNumber()
            
            if (candidate.isMentsu == false) {
                candidate = kotsu
                continue
            }
            
            if (candidate.identifierTile.getNumber() == kotsuNum) {
                if (kotsuType == "MANZU") {
                    manzu = true
                } else if (kotsuType == "PINZU") {
                    pinzu = true
                } else if (kotsuType == "SOHZU") {
                    sohzu = true
                }
                
                
                if (candidate.identifierTile.getType() == "MANZU") {
                    manzu = true
                } else if (candidate.identifierTile.getType() == "PINZU") {
                    pinzu = true
                } else if (candidate.identifierTile.getType() == "SOHZU") {
                    sohzu = true
                }
            } else {
                candidate = kotsu
            }
        }
        return manzu && pinzu && sohzu
    }
    
    func isSanankou() -> Bool {
        if (compMentsu.getKotsuCount() < 3) {
            return false
        }
        
        var ankouCount = 0
        for kotsu in compMentsu.kotsuList {
            if (!kotsu.isOpen) {
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
        if (compMentsu.getJanto().identifierTile.getType() != "SANGEN") {
            return false;
        }
        
        var count = 0
        for kotsu in compMentsu.kotsuList {
            if (kotsu.identifierTile.getType() == "SANGEN") {
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
        return peikoCount() == 2
    }
    
    func isJuntyan() -> Bool {
        for syuntsu in compMentsu.syuntsuList {
            let num = syuntsu.identifierTile.getNumber()
            if (num != 2 && num != 8) {
                return false
            }
        }
        
        for kotsu in compMentsu.kotsuList {
            let num = kotsu.identifierTile.getNumber()
            if (num != 1 && num != 9) {
                return false
            }
        }
        
        return true
    }
    
    func isHonitu() -> Bool {
        var hasJihai = false
        var type = ""
        
        for mentsu in compMentsu.getAllMentsu() {
            if (mentsu.identifierTile.getNumber() == 0) {
                hasJihai = true
            } else if (type.isEmpty) {
                type = mentsu.identifierTile.getType()
            } else if (type != mentsu.identifierTile.getType()) {
                return false
            }
        }
        return hasJihai
    }
    
    func isTinitu() -> Bool {
        
        let allMentsu = compMentsu.getAllMentsu()
        let type = allMentsu[0].identifierTile.getType()
        
        for mentsu in allMentsu {
            if(type != mentsu.identifierTile.getType()) {
                return false
            }
        }
        
        return true
    }
    
    
}

