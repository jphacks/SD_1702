import Foundation

class Noten {
    
    // 狙うべき役を判定するための関数テーブル
    var yakuFuncList:[()->Float] {
        return [isReach, isIppatu, isTumo, isPinhu, isTanyao, isIpeiko, isHaku, isHatu, isTyun, isJikaze, isBakaze, isRinsyan, isTyankan, isHaitei, isHoutei, isDoubleReach, isTyanta, isHonroutou, isSansyokuDoujun, isIttuu, isToiToi, isSansyokuDoukou, isSanankou, isSankantu, isSyousangen, isTitoitu, isRyanpeiko, isJuntyan, isHonitu, isTinitu, isDora, isSuankou, isSuankouTanki,  isDaisangen, isTuiso,  isSyoususi, isDaisusi, isRyuisou, isTyurenPoutou,  isJunseiTyurenpoutou, isTinroutou, isSukantu, isTenhou, isTihou, isKokusi, isKokusi13]
    }
    
    // 作業用変数
    var tmp: [Int] = []
    // 入力された各牌の数の配列
    var inputtedTiles: [Int]
    
    // ---- 状況に関するプロパティ -------
    var genSituation = GeneralSituation()
    var perSituation = PersonalSituation()
    
    // ------- 通常の和了の形におけるシャンテン数の計算のためのグローバル変数的な ------
    var mentu = 0      //メンツ数
    var toitu = 0        //トイツ数
    var kouho = 0        //ターツ数
    var temp = 0        //シャンテン数（計算用）
    var syanten_normal: Int = 0    //シャンテン数（結果用）
    var gomi_normal: [Tile] = []
    
    // イニシャライズ
    init(inputtedTiles: [Int], genSituation: GeneralSituation, perSituation: PersonalSituation) {
        self.inputtedTiles = inputtedTiles
        self.genSituation = genSituation
        self.perSituation = perSituation
    }
    
    // 作業用配列の初期化関数
    func initTmp() {
        tmp = inputtedTiles
    }
    
    // 狙えそうな役のリストを返すメソッド
    func getYakuCandidate() -> [(Yaku, Float)] {
        var yakuList: [(Yaku, Float)] = []
        
        for i in 0 ..< yakuFuncList.count {
            initTmp()
            if(yakuFuncList[i]() > 0) {
                yakuList.append((Yaku(rawValue: i)!, yakuFuncList[i]()))
            }
        }
        
        return yakuList
    }
    
    // シャンテン数を返す
    func getSyantenNum() ->(syanten_min:Int,gomi_min:Array<Tile>) {
        let syanten_min = min(getKokusiSyantenNum().syanten, getTiitoituSyantenNum().syanten, getNormalSyantenNum().syanten)
        
        if (syanten_min == getKokusiSyantenNum().syanten){
            print(getKokusiSyantenNum().gomi)
            return (syanten_min, getKokusiSyantenNum().gomi)
        }else if (syanten_min == getTiitoituSyantenNum().syanten){
            return (syanten_min,getTiitoituSyantenNum().gomi)
        }else{
            return (syanten_min,getNormalSyantenNum().gomi)
        }
    }
    
    //国士無双のシャンテン数を返すyo///////////////////////////////////////
    func getKokusiSyantenNum()->(syanten:Int, gomi:Array<Tile>){
        var toituflag = false, syanten_kokusi = 13
        
        initTmp()
        
        //老頭牌
        for i in 0 ..< 34 {
            if (Tile(rawValue: i)?.isYaochu())! {
                if (tmp[i] > 0) {
                    syanten_kokusi -= 1
                    tmp[i] -= 1
                }
                
                
                if (tmp[i] >= 1 && !toituflag) {
                    toituflag  = true
                    tmp[i] -= 1
                }
            }
        }
        
        var gomi_kokusi: [Tile]  = []
        
        for k in 0..<34{
            if(tmp[k] == 1) {
                gomi_kokusi.append(Tile(rawValue: k)!)
            }
        }
        //頭
        syanten_kokusi -= toituflag ? 1 : 0
        return (syanten_kokusi,gomi_kokusi);
    }
    
    //チートイツのシャンテン数を返すyo/////////////////////////////
    func getTiitoituSyantenNum()->(syanten:Int, gomi:Array<Tile>){
        var toitu = 0, syanten_tiitoi = 6
        
        initTmp()
        
        //トイツ数を数える
        for i in 0..<34{
            if(tmp[i] >= 2) {
                toitu += 1
                tmp[i] -= 2
            }
            if(tmp[i] == 2) {toitu -= 1}
        }
        
        var gomi_tiitoi: [Tile] = []
        
        syanten_tiitoi -= toitu
        for k in 0..<34{
            if(tmp[k] == 1) {
                gomi_tiitoi.append(Tile(rawValue: k)!)
            }
        }
        return (syanten_tiitoi,gomi_tiitoi);
    }
    
    //普通にシャンテン数考えるyo/////////////////////////////////////
    func getNormalSyantenNum() -> (syanten:Int, gomi:Array<Tile>) {
        
        initTmp()
        
        mentu = 0
        toitu = 0
        kouho = 0
        temp = 0
        syanten_normal = 8;
        
        for i in 0..<34{
            //頭ありと仮定して計算
            if(2 <= tmp[i]){
                toitu += 1
                tmp[i] -= 2;
                mentu_cut(start: 0)
                
                tmp[i] += 2;
                toitu-=1
            }
            mentu_cut(start: 0)   //頭無しと仮定して計算
        }
        return (syanten_normal, gomi_normal);    //最終的な結果
    }
    
    
    //メンツ抜き出しの関数//////////////////////////
    func mentu_cut(start: Int){
        var j = 0
        //牌が見つかるまで飛ばす
        for k in start..<34{
            j = k
            if(tmp[j] > 0) {break}
        }
        
        //メンツを抜き終わったのでターツ抜きへ
        if(start > 33){
            taatu_cut(start: 0)
            return
        }
        
        //コーツ
        if(tmp[j] >= 3){
            mentu += 1;
            tmp[j] -= 3;
            mentu_cut(start: j)
            
            tmp[j] += 3;
            mentu -= 1;
        }
        //シュンツ
        if(j != 7 && j != 8 && j != 16 && j != 17 && j < 25){
            if(tmp[j + 1] > 0 && tmp[j + 2] > 0){
                mentu += 1
                tmp[j] -= 1; tmp[j + 1] -= 1; tmp[j + 2] -= 1
                mentu_cut(start: j)
                
                tmp[j] += 1; tmp[j + 1] += 1; tmp[j+2] += 1
                mentu -= 1
            }
        }
        //メンツ無しと仮定
        mentu_cut(start: j+1)
    }
    
    
    //ターツ抜き出しの関数///////////////////////////
    func taatu_cut(start: Int){
        var j=0
        //牌が見つかるまで飛ばす
        for k in start..<34{
            j=k
            if(tmp[j]>0){break}
        }
        
        //抜き出し終了
        if(start >= 34) {
            temp = 8 - mentu * 2 - kouho - toitu
            if(temp < syanten_normal){
                syanten_normal = temp
                gomi_normal = []
                for k in 0..<34{
                    if(tmp[k] == 1) {
                        gomi_normal.append(Tile(rawValue: k)!)
                    }
                }
            }
            return
        }
        
        if(mentu + kouho < 4){
            //トイツ
            if(tmp[j] == 2){
                kouho += 1
                tmp[j] -= 2
                taatu_cut(start: j)
                
                tmp[j] += 2
                kouho -= 1
            }
            
            //ペンチャンかリャンメン
            if(j != 8  && j != 17  && j < 27){
                if(tmp[j + 1] > 0){
                    kouho += 1
                    tmp[j] -= 1; tmp[j + 1]-=1
                    taatu_cut(start: j)
                    
                    tmp[j] += 1; tmp[j + 1] += 1
                    kouho -= 1
                }
            }
            
            //カンチャン
            if(j != 7 && j != 8 && j != 16 && j != 17 && j < 27){
                if(tmp[j + 2] > 0){
                    kouho += 1
                    tmp[j] -= 1; tmp[j + 2] -= 1
                    taatu_cut(start: j)
                    
                    tmp[j] += 1; tmp[j + 2] += 1
                    kouho -= 1
                }
            }
        }
        //ターツなしと仮定
        taatu_cut(start: j+1)
    }
    
    func getSyuntuCandidate() -> [Syuntu] {
        var resultList = [Syuntu]()
        
        initTmp()
        
        for i in 0 ..< 26 {
            if tmp[i - 1] > 0 && tmp[i] > 0 && tmp[i + 1] > 0 {
                let syuntu = Syuntu(
                    isOpen: false,
                    tile1: Tile(rawValue: i - 1)!,
                    tile2: Tile(rawValue: i)!,
                    tile3: Tile(rawValue: i + 1)!
                )
                
                if (syuntu.isMentu) {
                    resultList.append(syuntu)
                }
            }
        }
        
        return resultList
    }
    
    // ------ 以降，狙うべき役を判定するための関数 ------
    // リーチ等の本当は実装しなくていい関数群は列挙体との兼ね合いでfalseを返すだけの関数として定義しておく
    
    func isPinhu() -> Float {
        
        let roop = [(1, 7), (10, 16), (19, 25)]
        var count = 0
        
        for elem in roop {
            for i in elem.0 ... elem.1 {
                while tmp[i] > 0 && tmp[i - 1] > 0 && tmp[i + 1] > 0 {
                    tmp[i] -= 1
                    tmp[i - 1] -= 1
                    tmp[i + 1] -= 1
                    count += 1
                }
            }
        }
        
        if count == 3 {
            for i in 0 ... 30 {
                if (Tile(rawValue: i) != perSituation.jikaze && Tile(rawValue: i) != genSituation.bakaze) && tmp[i] == 2 {
                    count += 1
                    tmp[i] -= 2
                }
            }
        }
        
        if count == 4 {
            for i in 0 ... 26 {
                let num = Tile(rawValue: i)?.getNumber()
                if num != 1 && num != 8 && num != 9 && num != 0{
                    if tmp[i] == 1 && tmp[i + 1] == 1 {
                        count += 1
                    }
                }
            }
        }
        
        switch count {
        case 1: return 0.33
        case 2, 3, 4: return 0.66
        case 5: return 1.0
        default: return 0.0
        }
    }
    
    func isTanyao() -> Float {
        var count = 0
        
        for i in 0 ..< tmp.count {
            if !(Tile(rawValue: i)!.isYaochu()) {
                count += tmp[i]
            }
        }
        
        switch count {
        case 10: return 0.33
        case 11, 12: return 0.66
        case 13, 14: return 1.0
        default: return 0.0
        }
    }
    
    func isIpeiko() -> Float {
        
        let roop = [(1, 7), (10, 16), (19, 25)]
        
        var result: Float = 0.0
        for elem in roop {
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 && tmp[i - 1] > 0 && tmp[i + 1] > 0 {  //３種類ある
                    var sum = tmp[i] + tmp[i - 1] + tmp[i + 1]
                    if tmp[i] >= 2 && tmp[i - 1] >= 2 && tmp[i + 1] >= 2 {
                        // 0初期化は二盃口判定のための処理
                        tmp[i] = 0
                        tmp[i - 1] = 0
                        tmp[i + 1] = 0
                        result =  1.0
                    } else if sum >= 5 && result < 0.66 {
                        result =  0.66
                    } else if sum >= 4 && result < 0.33 {
                        result =  0.33
                    }
                }
            }
        }
        return result
    }
    
    func isHaku() -> Float {
        if tmp[Tile.Haku.getCode()] == 2 {
            return 0.33
        } else if tmp[Tile.Haku.getCode()] == 3 {
            return 1.0
        }
        return 0.0
    }
    
    func isHatu() -> Float {
        if tmp[Tile.Hatu.getCode()] == 2 {
            return 0.33
        } else if tmp[Tile.Hatu.getCode()] == 3 {
            return 1.0
        }
        return 0.0
    }
    
    func isTyun() -> Float {
        if tmp[Tile.Tyun.getCode()] == 2 {
            return 0.33
        } else if tmp[Tile.Tyun.getCode()] == 3 {
            return 1.0
        }
        return 0.0
    }
    
    func isJikaze() -> Float {
        if (tmp[perSituation.jikaze.getCode()] == 2) {
            return 0.33
        } else if tmp[perSituation.jikaze.getCode()] == 3 {
            return 1.0
        }
        return 0.0
    }
    
    func isBakaze() -> Float {
        if (tmp[genSituation.bakaze.getCode()] == 2) {
            return 0.33
        } else if tmp[genSituation.bakaze.getCode()] == 3 {
            return 1.0
        }
        return 0.0
    }
    
    func isTyanta() -> Float {
        var count = 0
        var count2 = 0
        for i in 0 ..< tmp.count {
            var suu = Tile(rawValue: i)!.getNumber()
            if Tile(rawValue: i)!.isYaochu() {
                count2 += 1
            }
            if suu > 6 || suu < 4 {
                count += tmp[i]
                count2 += 1
            }
        }
        if count > 12 && count2 > 18 {
            return 1.0
        }
        if count > 11 && count2 > 17 {
            return 0.66
        }
        if count > 10 && count2 > 16 {
            return 0.33
        }
        return 0.0
    }
    
    func isHonroutou() -> Float {
        var count = 0
        
        for i in 0 ..< tmp.count {
            if Tile(rawValue: i)!.isYaochu() {
                count += tmp[i]
            }
        }
        
        if count > 11 {
            return 1.0
        }
        return 0.0
    }
    
    func isSansyokuDoujun() -> Float {
        var kazu = [Int](repeating: 0, count: 7)
        var ans = 0
        for i in 0 ..< 26 {
            var suu = Tile(rawValue: i)!.getNumber()
            if(tmp[i] > 0 && suu < 8 ){
                kazu[suu - 1] += 1
                if(suu > 1){
                    kazu[suu - 2] += 1
                }
                if(suu > 2){
                    kazu[suu - 3] += 1
                }
            }
        }
        for i in 0 ..< 7{
            if(kazu[i] > ans){
                ans = kazu[i]
            }
            switch ans{
            case 6: return 0.33
            case 7,8: return 0.66
            case 9: return 1.0
            default: return 0.0
            }
        }
        return 0.0
    }
    
    func isIttuu() -> Float {
        var roop = [(0, 8), (9, 17), (18, 26)]
        
        for elem in roop {
            var count = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += 1
                }
            }
            
            switch count{
            case 7: return 0.33
            case 8: return 0.66
            case 9: return 1.0
            default: return 0.0
            }
        }
        return 0.0
    }
    
    func isSansyokuDoukou() -> Float {
        var kazu = [Int](repeating: 0, count: 9)
        var ans = 0
        for i in 0 ..< 26 {
            kazu[Tile(rawValue: i)!.getNumber() - 1] += tmp[i]
        }
        for i in 0 ..< 9{
            if(kazu[i] > ans){
                ans = kazu[i]
            }
            switch ans{
            case 6: return 0.33
            case 7,8: return 0.66
            case 9: return 1.0
            default: return 0.0
            }
        }
        return 0.0
    }
    
    func isSanankou() -> Float {
        var count = 0
        var toituflag = false
        for i in 0 ..< 33 {
            if tmp[i] > 2 {
                count += 1
            }
            if tmp[i] == 2 {
                toituflag = true
            }
        }
        if count > 2{
            return 1.0
        }
        if count > 1 {
            if toituflag{
                return 0.66
            }
            return 0.33
        }
        return 0.0
    }
    
    func isSyousangen() -> Float {
        var count = 0
        count += tmp[Tile.Haku.getCode()]
        count += tmp[Tile.Hatu.getCode()]
        count += tmp[Tile.Tyun.getCode()]
        
        switch count{
        case 5: return 0.33
        case 6,7: return 0.66
        case 8: return 1.0
        default: return 0.0
        }
    }
    
    func isTitoitu() -> Float {
        if isRyanpeiko() == 1.0 {
            return 0.0
        }
        
        let syanten_min = min(getKokusiSyantenNum().syanten, getTiitoituSyantenNum().syanten, getNormalSyantenNum().syanten)
        if syanten_min == getTiitoituSyantenNum().syanten {
            switch getTiitoituSyantenNum().syanten{
            case 3: return 0.33
            case 2: return 0.66
            case 1: return 1.0
            default: return 0.0
            }
        }
        return 0.0
    }
    
    func isRyanpeiko() -> Float {
    
        if isIpeiko() < 1.0 {
            return 0.0
        }
        
        let roop = [(1, 7), (10, 16), (19, 25)]
        
        var result: Float = 0.33
        for elem in roop {
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 && tmp[i - 1] > 0 && tmp[i + 1] > 0 {  //３種類ある
                    var sum = tmp[i] + tmp[i - 1] + tmp[i + 1]
                    if tmp[i] >= 2 && tmp[i - 1] >= 2 && tmp[i + 1] >= 2 {
                        result =  1.0
                    } else if sum >= 4 && result < 0.66 {
                        result =  0.66
                    }
                }
            }
        }
        return result
    }
    
    func isJuntyan() -> Float {
        var count = 0
        var count2 = 0
        for i in 0 ..< tmp.count {
            var suu = Tile(rawValue: i)!.getNumber()
            if suu == 1 || suu == 9 {
                count2 += 1
            }
            if suu != 0 {
                if suu > 6 || suu < 4  {
                    count += tmp[i]
                    count2 += 1
                }
            }
        }
        if count > 12 && count2 > 18 {
            return 1.0
        }
        if count > 11 && count2 > 17 {
            return 0.66
        }
        if count > 10 && count2 > 16 {
            return 0.33
        }
        return 0.0
    }
    
    func isHonitu() -> Float {
        var roop = [(0, 8), (9, 17), (18, 26)]
        var max = 0
        
        for elem in roop {
            var count = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += tmp[i]
                }
            }
            
            if count > max {
                max = count
            }
        }
        
        for i in 27 ... 33 {
            max += tmp[i]
        }
        
        switch max {
        case 10: return 0.33
        case 11, 12: return 0.66
        case 13, 14: return 1.0
        default: return 0.0
        }
    }
    
    func isTinitu() -> Float {
        var roop = [(0, 8), (9, 17), (18, 26)]
        var max = 0
        
        for elem in roop {
            var count = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += tmp[i]
                }
            }
            
            if count > max {
                max = count
            }
        }
        
        switch max {
        case 10: return 0.33
        case 11, 12: return 0.66
        case 13, 14: return 1.0
        default: return 0.0
        }
    }
    
    func isSuankou() -> Float {
        var count = 0
        var toituflag = false
        for i in 0 ... 33 {
            if tmp[i] > 2 {
                count += 1
            }
            if tmp[i] == 2 {
                toituflag = true
            }
        }
        if count > 3{
            return 1.0
        }
        if count > 2 {
            if toituflag{
                return 0.66
            }
            return 0.33
        }
        return 0.0
    }
    
    func isDaisangen() -> Float {
        var count = 0
        count += tmp[Tile.Haku.getCode()]
        count += tmp[Tile.Hatu.getCode()]
        count += tmp[Tile.Tyun.getCode()]
        
        switch count{
        case 6: return 0.33
        case 7,8: return 0.66
        case 9: return 1.0
        default: return 0.0
        }
    }
    
    func isTuiso() -> Float {
        var count = 0
        for i in 27 ... 33 {
            count += tmp[i]
        }
        if count > 9 {
            return 1.0
        }
        switch count{
        case 10: return 0.33
        case 11,12: return 0.66
        case 13: return 1.0
        default: return 0.0
        }
    }
    
    func isSyoususi() -> Float {
        var count = 0
        for i in 27 ... 30 {
            count += tmp[i]
        }
        switch count{
        case 8: return 0.33
        case 9,10: return 0.66
        case 11: return 1.0
        default: return 0.0
        }
    }
    
    func isDaisusi() -> Float {
        var count = 0
        for i in 27 ... 30 {
            count += tmp[i]
        }
        switch count{
        case 10: return 0.33
        case 11: return 0.66
        case 12: return 1.0
        default: return 0.0
        }
    }
    
    func isRyuisou() -> Float {
        var count = 0
        
        for i in 19 ..< 33 {
            if i == 19 || i == 20 || i == 21 || i == 23 || i == 25 || i == 32{
                count += tmp[i]
            }
        }
        switch count{
        case 10: return 0.33
        case 11,12: return 0.66
        case 13: return 1.0
        default: return 0.0
        }
    }
    
    func isTyurenPoutou() -> Float {
        var roop = [(0, 8), (9, 17), (18, 26)]
        for elem in roop {
            var count = 0
            var count2 = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += tmp[i]
                    count2 += 1
                }
            }
            if count >= 13 && count2 == 9 {
                return 1.0
            }
            if count >= 11 && count2 >= 8 {
                return 0.66
            }
            if count >= 10 && count2 >= 7 {
                return 0.33
            }
        }
        return 0.0
    }
    
    func isTinroutou() -> Float {
        var count = 0
        for i in 0 ..< tmp.count {
            var suu = Tile(rawValue: i)!.getNumber()
            if suu == 1 ||  suu == 9 {
                count += tmp[i]
            }
        }
        switch count{
        case 10: return 0.33
        case 11,12: return 0.66
        case 13: return 1.0
        default: return 0.0
        }
    }
    
    func isKokusi() -> Float {
        let syanten_min = min(getKokusiSyantenNum().syanten, getTiitoituSyantenNum().syanten, getNormalSyantenNum().syanten)
        if syanten_min == getKokusiSyantenNum().syanten {
            switch getKokusiSyantenNum().syanten{
            case 3: return 0.33
            case 2: return 0.66
            case 1: return 1.0
            default: return 0.0
            }
        }
        return 0.0
    }
    
    // ------ 以降，0.0を返すだけの関数 ------
    
    func isReach() -> Float {
        return 0.0
    }
    
    func isIppatu() -> Float {
        return 0.0
    }
    
    func isTumo() -> Float {
        return 0.0
    }
    
    func isRinsyan() -> Float {
        return 0.0
    }
    
    func isTyankan() -> Float {
        return 0.0
    }
    
    func isHaitei() -> Float {
        return 0.0
    }
    
    func isHoutei() -> Float {
        return 0.0
    }
    
    func isDora() -> Float {
        return 0.0
    }
    
    func isToiToi() -> Float {
        return 0.0
    }
    
    func isDoubleReach() -> Float {
        return 0.0
    }
    
    func isSankantu() -> Float {
        return 0.0
    }
    
    func isSukantu() -> Float {
        return 0.0
    }
    
    func isJunseiTyurenpoutou() -> Float {
        return 0.0
    }
    
    func isSuankouTanki() -> Float {
        return 0.0
    }
    
    func isKokusi13() -> Float {
        return 0.0
    }
    
    func isTenhou() -> Float {
        return 0.0
    }
    
    func isTihou() -> Float {
        return 0.0
    }
}

