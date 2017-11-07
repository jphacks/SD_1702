import Foundation

class Noten {
    
    // 狙うべき役を判定するための関数テーブル
    var yakuFuncList:[()->Bool] {
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
    func getYakuCandidate() -> [Yaku] {
        var yakuList: [Yaku] = []
        
        initTmp()
        
        for i in 0 ..< yakuFuncList.count {
            if(yakuFuncList[i]()) {
                yakuList.append(Yaku(rawValue: i)!)
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
    
    func isPinhu() -> Bool {
        
        for i in 0 ..< tmp.count {
            if tmp[i] > 2 {
                return false
            }
        }
        
        return true
    }
    
    func isTanyao() -> Bool {
        var count = 0
        
        for i in 0 ..< tmp.count {
            if !(Tile(rawValue: i)!.isYaochu()) {
                count += tmp[i]
            }
        }
        
        if count >= 10 {
            return true
        }
        return false
    }
    
    func isIpeiko() -> Bool {
        var roop = [(1, 7), (10, 16), (19, 25)]
        
        for elem in roop {
            for i in elem.0 ... elem.1 {
                var count = 0
                count += tmp[i] > 0 ? 1 : 0
                count += tmp[i - 1] > 0 ? 1 : 0
                count += tmp[i + 1] > 0 ? 1 : 0
                if count >= 2 {
                    if tmp[i - 1] + tmp[i] + tmp[i + 1] >= 4 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func isHaku() -> Bool {
        if (tmp[Tile.Haku.getCode()] >= 2) {
            return true
        }
        return false
    }
    
    func isHatu() -> Bool {
        if (tmp[Tile.Hatu.getCode()] >= 2) {
            return true
        }
        return false
    }
    
    func isTyun() -> Bool {
        if (tmp[Tile.Tyun.getCode()] >= 2) {
            return true
        }
        return false
    }
    
    func isJikaze() -> Bool {
        if (tmp[perSituation.jikaze.getCode()] >= 2) {
            return true
        }
        return false
    }
    
    func isBakaze() -> Bool {
        if (tmp[genSituation.bakaze.getCode()] >= 2) {
            return true
        }
        return false
    }
    
    func isTyanta() -> Bool {
        return false
    }
    
    func isHonroutou() -> Bool {
        var count = 0
        
        for i in 0 ..< tmp.count {
            if Tile(rawValue: i)!.isYaochu() {
                count += tmp[i]
            }
        }
        
        if count > 11 {
            return true
        }
        return false
    }
    
    func isSansyokuDoujun() -> Bool {
        var kazu = [Int](repeating: 0, count: 7)
        for i in 0 ..< 26 {
            if(tmp[i] > 0 && Tile(rawValue: i)!.getNumber() < 8 ){
                kazu[Tile(rawValue: i)!.getNumber()-1] += 1
                
                if(Tile(rawValue: i)!.getNumber()>1){
                    kazu[Tile(rawValue: i)!.getNumber()-2] += 1
                }
                if(Tile(rawValue: i)!.getNumber()>2){
                    kazu[Tile(rawValue: i)!.getNumber()-3] += 1
                }
            }
        }
        for i in 0 ..< 7{
            if(kazu[i] > 5){
                return true
            }
        }
        return false
    }
    
    func isIttuu() -> Bool {
        var roop = [(0, 8), (9, 17), (18, 26)]
        
        for elem in roop {
            var count = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += 1
                }
            }
            
            if count >= 7 {
                return true
            }
        }
        return false
    }
    
    func isSansyokuDoukou() -> Bool {
        var kazu = [Int](repeating: 0, count: 9)
        for i in 0 ..< 26 {
            kazu[Tile(rawValue: i)!.getNumber() - 1] += tmp[i]
        }
        for i in 0 ..< 9{
            if kazu[i] > 6 {
                return true
            }
        }
        return false
    }
    
    func isSanankou() -> Bool {
        var count = 0
        for i in 0 ..< 33 {
            if tmp[i] > 2 {
                count += 1
            }
        }
        if count > 1 {
            return true
        }
        return false
    }
    
    func isSyousangen() -> Bool {
        var count = 0
        count += tmp[Tile.Haku.getCode()]
        count += tmp[Tile.Hatu.getCode()]
        count += tmp[Tile.Tyun.getCode()]
        if count > 4 {
            return true
        }
        return false
    }
    
    func isTitoitu() -> Bool {
        let syanten_min = min(getKokusiSyantenNum().syanten, getTiitoituSyantenNum().syanten, getNormalSyantenNum().syanten)
        if syanten_min == getTiitoituSyantenNum().syanten {
            return true
        }
        initTmp()
        return false
    }
    
    func isRyanpeiko() -> Bool {
        return false
    }
    
    func isJuntyan() -> Bool {
        return false
    }
    
    func isHonitu() -> Bool {
        var roop = [(0, 8), (9, 17), (18, 26)]
        
        for elem in roop {
            var count = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += tmp[i]
                }
            }
            
            for i in 27 ... 33 {
                count += tmp[i]
            }
            
            if count >= 10 {
                return true
            }
        }
        return false
    }
    
    func isTinitu() -> Bool {
        var roop = [(0, 8), (9, 17), (18, 26)]
        
        for elem in roop {
            var count = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += tmp[i]
                }
            }
            
            if count >= 10 {
                return true
            }
        }
        return false
    }
    
    func isSuankou() -> Bool {
        var count = 0
        for i in 0 ... 33 {
            if tmp[i] > 2 {
                count += 1
            }
        }
        if count > 2 {
            return true
        }
        return false
    }
    
    func isDaisangen() -> Bool {
        var count = 0
        count += tmp[Tile.Haku.getCode()]
        count += tmp[Tile.Hatu.getCode()]
        count += tmp[Tile.Tyun.getCode()]
        
        if count > 5 {
            return true
        }
        return false
    }
    
    func isTuiso() -> Bool {
        var count = 0
        for i in 27 ... 33 {
            count += tmp[i]
        }
        if count > 9 {
            return true
        }
        
        return false
    }
    
    func isSyoususi() -> Bool {
        var count = 0
        for i in 27 ... 30 {
            count += tmp[i]
        }
        if count > 7 {
            return true
        }
        
        return false
    }
    
    func isDaisusi() -> Bool {
        var count = 0
        for i in 27 ... 30 {
            count += tmp[i]
        }
        if count > 9 {
            return true
        }
        return false
    }
    
    func isRyuisou() -> Bool {
        var count = 0
        
        for i in 19 ..< 33 {
            if i == 19 || i == 20 || i == 21 || i == 23 || i == 25 || i == 32{
                count += tmp[i]
            }
        }
            
        if count >= 10 {
            return true
        }
        return false
    }
    
    func isTyurenPoutou() -> Bool {
        var roop = [(0, 8), (9, 17), (18, 26)]
        
        for elem in roop {
            var count = 0
            var count2 = 0
            for i in elem.0 ... elem.1 {
                if tmp[i] > 0 {
                    count += tmp[i]
                    count += 1
                }
            }
            
            if count >= 10 && count2 >= 7 {
                return true
            }
        }
        return false
    }
    
    func isTinroutou() -> Bool {
        var count = 0
        for i in 0 ..< tmp.count {
            if Tile(rawValue: i)!.getNumber() == 1 ||  Tile(rawValue: i)!.getNumber() == 9 {
                count += tmp[i]
            }
        }
        if count > 9 {
            return true
        }
        return false
    }
    
    func isKokusi() -> Bool {
        let syanten_min = min(getKokusiSyantenNum().syanten, getTiitoituSyantenNum().syanten, getNormalSyantenNum().syanten)
        if syanten_min == getKokusiSyantenNum().syanten {
            return true
        }
        return false
    }
    
    // ------ 以降，falseを返すだけの関数 ------
    
    func isReach() -> Bool {
        return false
    }
    
    func isIppatu() -> Bool {
        return false
    }
    
    func isTumo() -> Bool {
        return false
    }
    
    func isRinsyan() -> Bool {
        return false
    }
    
    func isTyankan() -> Bool {
        return false
    }
    
    func isHaitei() -> Bool {
        return false
    }
    
    func isHoutei() -> Bool {
        return false
    }
    
    func isDora() -> Bool {
        return false
    }
    
    func isToiToi() -> Bool {
        return false
    }
    
    func isDoubleReach() -> Bool {
        return false
    }
    
    func isSankantu() -> Bool {
        return false
    }
    
    func isSukantu() -> Bool {
        return false
    }
    
    func isJunseiTyurenpoutou() -> Bool {
        return false
    }
    
    func isSuankouTanki() -> Bool {
        return false
    }
    
    func isKokusi13() -> Bool {
        return false
    }
    
    func isTenhou() -> Bool {
        return false
    }
    
    func isTihou() -> Bool {
        return false
    }
}

