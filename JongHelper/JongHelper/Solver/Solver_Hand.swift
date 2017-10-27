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
    // 国士かどうか
    var isKokusi = false
    // いま積もった牌 点数計算に必要
    var tumo = Tile.null
    
    // ----- テンパイ状態に関するプロパティ -----
    // テンパイ時に返すものは，これを捨ててこれを引いたら，この点数で上がれるよ
    // テンパイしているかどうか
    var isTenpai = false
    // 国士テンパイかどうか
    var isKokusiTenpai = false
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
    
    // イニシャライざ
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
        
        self.tumo = tumo
        self.genSituation = genSituation
        self.perSituation = perSituation
        if (!invalidHand) {
            getCompMentuSet()
        }
    }
    
    // 点数, 役のリストのタプルを返す関数
    func getScore(addHan: Int) -> (score: (ron: Int, tumo: Int), fu: Int, han:  Int, yakuList: [Yaku]) {
        // 点数 (点数，飜，符）と役のタプル
        var result = (score: (ron: -1, tumo: -1), fu: -1, han: -1, yakuList: [Yaku]())
        
        if isKokusi {
            result = calcKokusi()
            return result
        }
        
        for agari in agariSet {
            let calculator = Calculator(compMentu: agari, generalSituation: genSituation, personalSituation: perSituation)
            let calcScore = calculator.calculateScore(addHan: addHan)

            if result.score.ron <= calcScore.score.ron {
                result.score = calcScore.score
                result.fu = calcScore.fu
                result.han = calcScore.han
                result.yakuList = calculator.yakuList
            }
        }
        
        return result
    }
    
    // テンパイ時に，TenpaiData (これを捨てて，これを引いたら，この点数で上がれる)　を返す
    func getTenpaiData() -> [TenpaiData] {
        var result = [TenpaiData]()
        
        if isKokusiTenpai {
            return getKokusiTenpaiData()
        }
        
        for tenpai in tenpaiSet { // テンパイ形の候補の中でループ
            for mati in tenpai.getWait() {
                let compMentu = CompMentu(tenpai: tenpai, tumo: mati, isOpenHand: false)
                
                var calculator = Calculator(compMentu: compMentu ,generalSituation: genSituation, personalSituation: perSituation)
                let ronScore = calculator.calculateScore(addHan: 0)
                
                
                perSituation.isTsumo = true
                calculator = Calculator(compMentu: compMentu ,generalSituation: genSituation, personalSituation: perSituation)
                let tumoScore = calculator.calculateScore(addHan: 0)
                
                perSituation.isTsumo = false
                
                if result.count == 0 {
                    result.append(TenpaiData(sute: tenpai.suteTile, mati: [(mati, ronScore.score.ron, tumoScore.score.tumo)]))
                } else {
                    var flag1 = true
                    
                    for (i, elem) in result.enumerated() {
                        if elem.suteTile == tenpai.suteTile {
                            var flag2 = true
                            
                            for (j, matiTile) in elem.matiTiles.enumerated() {
                                if matiTile.tile == mati {
                                    if matiTile.ron < ronScore.score.ron {
                                        result[i].matiTiles[j] = (mati, ronScore.score.ron, tumoScore.score.tumo)
                                    }
                                    flag2 = false
                                    break
                                }
                            }
                            
                            if flag2 {
                                result[i].matiTiles.append((mati, ronScore.score.ron, tumoScore.score.tumo))
                            }
                            flag1 = false
                        }
                    }
                    
                    if flag1 {
                        result.append(TenpaiData(sute: tenpai.suteTile, mati: [(mati, ronScore.score.ron, tumoScore.score.tumo)]))
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
    
    // 上がり形，テンパイ形を探索する関数
    func getCompMentuSet() {
    
        // 国士無双に対する処理
        judgeKokusi()
        
        if isKokusi {
            isAgari = true
            return
        } else if isKokusiTenpai {
            isTenpai = true
            return
        }
        
        initTmp()
        //頭の候補を探してストック
        let toituList: [Toitu] = Toitu.findJantoCandidate(tiles: tmpTiles)

        // 七対子に対する処理
        if (toituList.count == 7) {
            isAgari = true
            isTitoitu = true
            
            // 上がりの形に追加
            let compMentu = CompMentu(mentuList: toituList, tumo: tumo, isOpenHand: false)
            agariSet.insert(compMentu)
        } else if (toituList.count == 6) {
            initTmp()
            var ukiTile1: Tile! = nil
            var ukiTile2: Tile! = nil
            
            for index in 0 ..< tmpTiles.count{
                if tmpTiles[index] == 1 {
                    isTenpai = true
                    if ukiTile1 == nil {
                        ukiTile1 = Tile(rawValue: index)
                    } else {
                        ukiTile2 = Tile(rawValue: index)
                    }
                }
            }
            
            
            // テンパイ形に追加
            if ukiTile1 != nil && ukiTile2 != nil {
                var tenpai = Tenpai(mentuList: toituList, ukiList: [ukiTile1], suteTile: ukiTile2)
                tenpaiSet.insert(tenpai)
                tenpai = Tenpai(mentuList: toituList, ukiList: [ukiTile2], suteTile: ukiTile1)
                tenpaiSet.insert(tenpai)
            }
        }
        
        // 頭確定のメンツ探索
        if (toituList.count != 0) {
            for toitu in toituList {
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
    
    // 面子を抜き出した後に残った牌の数をカウントする関数
    func countRemainderTiles() -> Int {
        return tmpTiles.reduce(0) {(num1: Int, num2: Int) -> Int in num1 + num2 }
    }
    
    // 面子を抜き出した後に残った牌のリストを得る関数
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
    

    // 順子を抜き出していく関数
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
    
    // 刻子を抜き出していく関数
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
    
    // Tile型の配列で貰った手牌をInt型の配列に変換する関数
    func encodeTiles(tiles :[Tile]) -> [Int] {
        var resultList = [Int](repeating: 0, count: 34)
        
        for tile in tiles {
            resultList[tile.getCode()] += 1
        }
        
        return resultList
    }
    
    //　雀頭を確定させた状態で刻子優先探索を行う関数
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
    
    //　雀頭を決めずに刻子優先探索を行う関数
    func searchPriorityKotu()  {
        initTmp()
        
        var mentuCandidate = [Mentu]()
        
        mentuCandidate.append(contentsOf: serchKotuCandidate())
        mentuCandidate.append(contentsOf: serchSyuntuCandidate(start: 1, end: 26))
        
        let ukiNum = countRemainderTiles()
        if (ukiNum < 3) {
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
    
    // 雀頭を確定させた状態で順子優先探索を行う関数
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
    
    // 雀頭を決めずに順子優先探索を行う関数
    func searchPrioritySyuntu() {
        initTmp()
        
        var mentuCandidate = [Mentu]()
        
        mentuCandidate.append(contentsOf: serchSyuntuCandidate(start: 1, end: 26))
        mentuCandidate.append(contentsOf: serchKotuCandidate())
        
        let ukiNum = countRemainderTiles()
        if (ukiNum < 3) {
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
    
    // 国士かどうかの判定を行う関数
    func judgeKokusi() {
        var kokusi = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1]
        var count = 0
        
        initTmp()
        for i in 0 ..< tmpTiles.count {
            tmpTiles[i] -= kokusi[i]
            
            if tmpTiles[i] == -1 {
                count += 1
            }
        }
        
        if count == 0 {
            for i in 0 ..< tmpTiles.count {
                if kokusi[i] == 1 && tmpTiles[i] == 1 {
                    isKokusi = true
                }
            }
            
            // 13面待ちテンパイ
            isKokusiTenpai = true
        } else if count == 1 {
            for i in 0 ..< tmpTiles.count {
                if kokusi[i] == 1 && tmpTiles[i] == 1 {
                    isKokusiTenpai = true
                }
            }
        }
    }
    

    // 国士のテンパイ形を得る関数
    func getKokusiTenpaiData() -> [TenpaiData] {
        
        var matiTiles: [Tile] = []
        var suteTiles: [Tile] = []
        
        initTmp()
        var kokusi = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1]
        
        // 単騎待ちの処理
        for i in 0 ..< tmpTiles.count {
            tmpTiles[i] -= kokusi[i]
            if tmpTiles[i] == -1 {
                matiTiles.append(Tile(rawValue: i)!)
            }
        }
        
        // 13面待ちの処理
        if matiTiles.count == 0 {
            for i in 0 ..< kokusi.count {
                if kokusi[i] == 1 {
                    matiTiles.append(Tile(rawValue: i)!)
                }
            }
        }
        
        // 捨て牌の候補を探索
        for i in 0 ..< tmpTiles.count {
            if tmpTiles[i] > 0 {
                if kokusi[i] != 1 {
                    suteTiles.removeAll()
                    suteTiles.append(Tile(rawValue: i)!)
                    break
                } else if tmpTiles[i] > 0 {
                    suteTiles.append(Tile(rawValue: i)!)
                }
            }
        }
        
        if suteTiles.count == 1 {
            if matiTiles.count == 13 {
                var score: [(Tile, Int, Int)] = []
                if perSituation.isParent {
                    for elem in matiTiles {
                        score.append((elem, 48000 * 2, 48000 * 2))
                    }
                } else {
                    for elem in matiTiles {
                        score.append((elem, 32000 * 2, 32000 * 2))
                    }
                }
                return [TenpaiData(sute: suteTiles[0], mati: score)]
            }
            
            if perSituation.isParent {
                return [TenpaiData(sute: suteTiles[0], mati: [(matiTiles[0], 48000, 48000)])]
            }
            return [TenpaiData(sute: suteTiles[0], mati: [(matiTiles[0], 32000, 32000)])]
        }
        
        var result: [TenpaiData] = []
        for elem in suteTiles {
            if perSituation.isParent {
                result.append(TenpaiData(sute: elem, mati: [(matiTiles[0], 48000, 48000)]))
            } else {
                result.append(TenpaiData(sute: elem, mati: [(matiTiles[0], 32000, 32000)]))
            }
        }
        return result
    }
    
    // 国士の点数を計算する関数
    func calcKokusi() -> (score: (ron: Int, tumo: Int), fu: Int, han: Int, yakuList: [Yaku]) {
        
        initTmp()
        
        var kokusi = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1]
        
        for i in 0 ..< tmpTiles.count {
            tmpTiles[i] -= kokusi[i]
        }
        
        for i in 0 ..< tmpTiles.count {
            if tmpTiles[i] != 1 {
                continue
            }
            
            if (i == tumo.getCode()) {
                if perSituation.isParent {
                    return (score: (ron: 96000, tumo: 96000), fu: 0, han: 0, yakuList: [Yaku.Kokusimusou13])
                } else {
                    return (score: (ron: 64000, tumo: 64000), fu: 0, han: 0, yakuList: [Yaku.Kokusimusou13])
                }
            } else {
                if perSituation.isParent {
                    return (score: (ron: 48000, tumo: 48000), fu: 0, han: 0, yakuList: [Yaku.Kokusimusou])
                } else {
                    return (score: (ron: 32000, tumo: 32000), fu: 0, han: 0, yakuList: [Yaku.Kokusimusou])
                }
            }
        }
        return (score: (ron: 0, tumo: 0), fu: 0, han: 0, yakuList: [Yaku]())
    }
    
}


