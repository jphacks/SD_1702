//
//  Hand.swift
//  
//
//  Created by oike toshiyuki on 2017/10/17.
//

//
import Foundation

// 手牌 14枚
class Hand {
    
    // 面前手かどうか
    var isOpenHand = false
    
    // ----- 上がり状態に関するプロパティ -----
    // 上がれるかどうか
    var isAgari = false
    // 上がりの形のセット　これをcalculator に投げることで得点を得ることができる
    var agariSet = Set<CompMentu>()
    // チートイかどうか
    var isTitoitu = false
    // いま積もった牌 点数計算に必要
    var tumo = Tile.null
    
    // ----- テンパイ状態に関するプロパティ -----
    // テンパイ時に返すものは，これを捨ててこれを引いたら，この点数で上がれるよ
    // テンパイしているかどうか
    var isTenpai = false
    // テンパイ形のセット tenpai: toituList, syuntuList, kotuList, uki, wait
    var tenpaiSet = Set<Tenpai>()
    
    // ---- 状況に関するプロパティ -------
    var genSituation = GeneralSituation()
    var perSituation = PersonalSituation()
    
    // ----- ノーテン状態に関するプロパティ -----
    var syantenNum = 99
    
    // 不正な手かどうか
    var invalidHand = false
    
    // 作業用変数
    var tmpTiles = [Int]()
    // 入力された各牌の数の配列
    var inputtedTiles = [Int](repeating: 0, count: 34)
    // 入力された面子リスト
    var inputteFuroList = [Mentu]()
    
    // 面前手の場合はこっちでイニシャライズ
    init(inputtedTiles: [Tile], tumo: Tile, genSituation: GeneralSituation, perSituation: PersonalSituation) {
        isOpenHand = false
        
        for tile in inputtedTiles {
            if (self.inputtedTiles[tile.getCode()] < 4) {
                self.inputtedTiles[tile.getCode()] += 1
            } else {
                invalidHand = true
                break
            }
        }
        if (!invalidHand) {
            getCompMentuSet()
        }
        self.tumo = tumo
        self.genSituation = genSituation
        self.perSituation = perSituation
    }
    
    // 点数, 役のタプルを返す関数
    func getScore(addHan: Int) -> (Int, Int, Int, [NormalYaku]) {
        // 点数 (点数，飜，符）と役のタプル
        var score = (0, 0, 0, [NormalYaku]())
        
        for agari in agariSet {
            let calculator = Calculator(compMentu: agari, generalSituation: genSituation, personalSituation: perSituation, addHan: addHan)
            if(score.0 < calculator.score) {
                score.0 = calculator.score
                score.1 = calculator.han
                score.2 = calculator.fu
                score.3 = calculator.normalYakuList
            }
        }
        
        return score
    }

    // テンパイ時に，これを捨ててこれを引いたら，この点数で上がれるよ　を返す
    func getTenpaiData() -> [TenpaiData] {
        var result = [TenpaiData]()
        
        for tenpai in tenpaiSet {
            for mati in tenpai.getWait() {
                var suteTile = tenpai.suteTile
                let compMentu = CompMentu(tenpai: tenpai, tumo: mati, isOpenHand: false)
                let calculator = Calculator(compMentu: compMentu ,generalSituation: genSituation, personalSituation: perSituation, addHan: 0)
                
                let score = calculator.score
                
                if result.count == 0 {
                    result.append(TenpaiData(sute: tenpai.suteTile, mati: [(mati, score)]))
                } else {
                    var flag1 = true
                    
                    for (i, elem) in result.enumerated() {
                        if elem.suteTile == tenpai.suteTile {
                            var flag2 = true
                            
                            for (j, matiTile) in elem.matiTiles.enumerated() {
                                if matiTile.0 == mati && matiTile.1 < score {
                                    result[i].matiTiles[j] = (mati, score)
                                    flag2 = false
                                    break
                                }
                            }
                            
                            if flag2 {
                                result[i].matiTiles.append((mati, score))
                            }
                            flag1 = false
                        }
                    }
                    
                    if flag1 {
                        result.append(TenpaiData(sute: tenpai.suteTile, mati: [(mati, score)]))
                    }
                }
            }
        }
        
        return result
    }
    
    // 作業用配列の初期化用関数
    func initTmp() {
        tmpTiles = inputtedTiles
    }
    
    func getCompMentuSet() {
        
        
        initTmp()
        
        //頭の候補を探してストック
        let toituList: [Toitu] = Toitu.findJantoCandidate(tiles: tmpTiles)
        
        // 七対子に対する処理
        if (toituList.count == 7) {
            isAgari = true
            var titoi = [Toitu]()
            titoi.append(contentsOf: toituList)
            // 上がりの形に追加
        } else if (toituList.count == 6) {
            isTenpai = true
            // テンパイ形に追加
        }
        
        // 副露している場合は副露している面子をあらかじめ追加しておく
        //if (isOpenHand) {
        //    mentuCandidate = inputtedMentuList
        //}
        
        // 頭確定のメンツ探索
        if (toituList.count != 0) {
            for toitu in toituList {
                
                if toitu.identifierTile == Tile.p3 {
                    print("toitu:p3")
                }
                
                searchPriorityKotu(janto: toitu)
                searchPrioritySyuntu(janto: toitu)
            }
        }
        // 頭なしのメンツ探索
        searchPriorityKotu()
        searchPrioritySyuntu()
        
        //多面チャンを探していく (浮き牌の数によって余りを何個許容するか変わることに注意)
        for tenpai in tenpaiSet {
            let tmp = tenpai.getSyuntuList() //浮き牌と同じ順子を取ってくる
            let oneTypeSyuntuList = tmp.0 // 浮き牌と同じタイプの順子のリスト
            var decidedMentuList = tmp.1 // 残った部分のリスト
            var tiles = [Tile]()
            for syuntu in oneTypeSyuntuList {
                if (!syuntu.isOpen) { //鳴いている面子は絡めないようにする
                    tiles.append(syuntu.identifierTile)
                    tiles.append(Tile(rawValue: syuntu.identifierTile.getCode() - 1)!)
                    tiles.append(Tile(rawValue: syuntu.identifierTile.getCode() + 1)!)
                }
            }
            
            for uki in tenpai.ukiList {
                tiles.append(uki)
            }
            tiles.append(tenpai.suteTile)
                
            tmpTiles = encodeTiles(tiles: tiles)
            let _tmpTiles = tmpTiles
            
            for i in 1 ..< 26 {
                tmpTiles = _tmpTiles
                decidedMentuList = tmp.1
                
                decidedMentuList.append(contentsOf: serchSyuntuCandidate(start: i, end: 26))
                decidedMentuList.append(contentsOf: serchSyuntuCandidate(start: 1, end: i))
                
                
                let ukiList = getRemainderTiles()
                if ukiList.count < 4 {
                    for (i, elem) in ukiList.enumerated() {
                        var arr = ukiList
                        arr.remove(at: i)
                        let tenpai = Tenpai(mentuList: decidedMentuList, ukiList: arr, suteTile: ukiList[i])
                        if(tenpai.isTenpai) {
                            tenpaiSet.insert(tenpai)
                        }
                    }
                }
            }
        }
    }
    
    func countRemainderTiles() -> Int {
        return tmpTiles.reduce(0) {(num1: Int, num2: Int) -> Int in num1 + num2 }
    }
    
    func getRemainderTiles() -> [Tile] {
        var ukiList = [Tile]()
        for i in 0 ..< tmpTiles.count {
            while(tmpTiles[i] > 0) {
                ukiList.append(Tile(rawValue: i)!)
                tmpTiles[i] -= 1
            }
        }
        return ukiList
    }
    

    
    func serchSyuntuCandidate(start: Int, end: Int) -> [Mentu] {
        var resultList = [Mentu]()
        
        for i in start ..< end {
            while tmpTiles[i - 1] > 0 && tmpTiles[i] > 0 && tmpTiles[i + 1] > 0 {
                let syuntu = Syuntu(
                    isOpen: false,
                    tile1: Tile(rawValue: i - 1)!,
                    tile2: Tile(rawValue: i)!,
                    tile3: Tile(rawValue: i + 1)!
                )
                
                if (syuntu.isMentu) {
                    resultList.append(syuntu)
                    tmpTiles[i - 1] -= 1
                    tmpTiles[i] -= 1
                    tmpTiles[i + 1] -= 1
                } else {
                    break
                }
            }
        }
        
        return resultList
    }
    
    func serchKotuCandidate() -> [Mentu] {
        var resultList = [Mentu]()
        
        for i in 0 ..< tmpTiles.count {
            if (tmpTiles[i] >=  3) {
                resultList.append(Kotu(isOpen: false, identifierTile: Tile(rawValue: i)!))
                tmpTiles[i] -= 3
            }
        }
        
        return resultList
    }
    
    func encodeTiles(tiles :[Tile]) -> [Int] {
        var resultList = [Int](repeating: 0, count: 34)
        
        for tile in tiles {
            resultList[tile.getCode()] += 1
        }
        
        return resultList
    }
    
    func searchPriorityKotu(janto: Toitu) {
        initTmp()
        
        var mentuCandidate = [Mentu]()
        
        tmpTiles[janto.identifierTile.getCode()] -= 2
        mentuCandidate.append(janto)
        
        mentuCandidate.append(contentsOf: serchKotuCandidate())
        mentuCandidate.append(contentsOf: serchSyuntuCandidate(start: 1, end: 26))
        
        
        var ukiNum = countRemainderTiles()
        
        if (ukiNum == 0) {
            isAgari = true
            agariSet.insert(CompMentu(mentuList: mentuCandidate, tumo: tumo, isOpenHand: false))
        } else if (ukiNum < 4) {
            let ukiList = getRemainderTiles()
            for (i, elem) in ukiList.enumerated() {
                var arr = ukiList
                arr.remove(at: i)
                let tenpai = Tenpai(mentuList: mentuCandidate, ukiList: arr, suteTile: ukiList[i])
                if(tenpai.isTenpai) {
                    tenpaiSet.insert(tenpai)
                    isTenpai = true
                }
            }
        }
    }
    
    func searchPriorityKotu()  {
        initTmp()
        
        var mentuCandidate = [Mentu]()
        
        mentuCandidate.append(contentsOf: serchKotuCandidate())
        mentuCandidate.append(contentsOf: serchSyuntuCandidate(start: 1, end: 26))
        
        let ukiNum = countRemainderTiles()
        if (ukiNum < 2) {
            let ukiList = getRemainderTiles()
            var arr = ukiList
            for (i, elem) in ukiList.enumerated() {
                arr.remove(at: i)
                let tenpai = Tenpai(mentuList: mentuCandidate, ukiList: arr, suteTile: ukiList[i])
                if(tenpai.isTenpai) {
                    tenpaiSet.insert(tenpai)
                    isTenpai = true
                }
            }
        }
    }
    
    func searchPrioritySyuntu(janto: Toitu) {
        initTmp()
        
        var mentuCandidate = [Mentu]()
        
        tmpTiles[janto.identifierTile.getCode()] -= 2
        mentuCandidate.append(janto)
        
        mentuCandidate.append(contentsOf: serchSyuntuCandidate(start: 1, end: 26))
        mentuCandidate.append(contentsOf: serchKotuCandidate())
        
        var ukiNum = countRemainderTiles()
        if (ukiNum == 0) {
            isAgari = true
            agariSet.insert(CompMentu(mentuList: mentuCandidate, tumo: tumo, isOpenHand: isOpenHand))
        } else if (ukiNum < 4) {
            let ukiList = getRemainderTiles()
            for (i, elem) in ukiList.enumerated() {
                var arr = ukiList
                arr.remove(at: i)
                let tenpai = Tenpai(mentuList: mentuCandidate, ukiList: arr, suteTile: ukiList[i])
                
                if(tenpai.isTenpai) {
                    tenpaiSet.insert(tenpai)
                    isTenpai = true
                }
            }
        }
    }
    
    func searchPrioritySyuntu() {
        initTmp()
        
        var mentuCandidate = [Mentu]()
        
        mentuCandidate.append(contentsOf: serchSyuntuCandidate(start: 1, end: 26))
        mentuCandidate.append(contentsOf: serchKotuCandidate())
        
        let ukiNum = countRemainderTiles()
        if (ukiNum < 2) {
            let ukiList = getRemainderTiles()
            var arr = ukiList
            for (i, elem) in ukiList.enumerated() {
                arr.remove(at: i)
                let tenpai = Tenpai(mentuList: mentuCandidate, ukiList: arr, suteTile: ukiList[i])
                
                if(tenpai.isTenpai) {
                    tenpaiSet.insert(tenpai)
                    isTenpai = true
                }
            }
        }
    }
}


