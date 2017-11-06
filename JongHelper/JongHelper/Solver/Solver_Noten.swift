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
    
    // ------- 通常の和了の形におけるシャンテン数の計算のためのグローバル変数的な ------
    var mentu = 0      //メンツ数
    var toitu = 0        //トイツ数
    var kouho = 0        //ターツ数
    var temp = 0        //シャンテン数（計算用）
    var syanten_normal: Int = 0    //シャンテン数（結果用）
    var gomi_normal: [Tile] = []
    
    // イニシャライズ
    init(inputtedTiles: [Int]) {
        self.inputtedTiles = inputtedTiles
    }
    
    // 作業用配列の初期化関数
    func initTmp() {
        tmp = inputtedTiles
    }
    
    // 狙えそうな役のリストを返すメソッド
    func getYakuCandidate() -> [Yaku] {
        var yakuList: [Yaku] = []
        
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
            return (syanten_min,getKokusiSyantenNum().gomi)
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
                if (tmp[i] >= 2 && !toituflag) {
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
            if(tmp[i] == 4) {toitu -= 1}
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
    
    
    // ------ 以降，狙うべき役を判定するための関数テーブル ------
    // リーチ等の本当は実装しなくていい関数群は列挙体との兼ね合いでfalseを返すだけの関数として定義しておく
    func isReach() -> Bool {
        return false
    }
    
    func isIppatu() -> Bool {
        return false
    }
    
    func isTumo() -> Bool {
        return false
    }
    
    func isPinhu() -> Bool {
        return false
    }
    
    func isTanyao() -> Bool {
        return false
    }
    
    func isIpeiko() -> Bool {
        return false
    }
    
    func isHaku() -> Bool {
        return false
    }
    
    func isHatu() -> Bool {
        return false
    }
    
    func isTyun() -> Bool {
        return false
    }
    
    func isJikaze() -> Bool {
        return false
    }
    
    func isBakaze() -> Bool {
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
    
    func isDoubleReach() -> Bool {
        return false
    }
    
    func isTyanta() -> Bool {
        return false
    }
    
    func isHonroutou() -> Bool {
        return false
    }
    
    func isSansyokuDoujun() -> Bool {
        return false
    }
    
    func isIttuu() -> Bool {
        return false
    }
    
    func isToiToi() -> Bool {
        return false
    }
    
    func isSansyokuDoukou() -> Bool {
        return false
    }
    
    func isSanankou() -> Bool {
        return false
    }
    
    func isSankantu() -> Bool {
        return false
    }
    
    func isSyousangen() -> Bool {
        return false
    }
    
    func isTitoitu() -> Bool {
        return false
    }
    
    func isRyanpeiko() -> Bool {
        return false
    }
    
    func isJuntyan() -> Bool {
        return false
    }
    
    func isHonitu() -> Bool {
        return false
    }
    
    func isTinitu() -> Bool {
        return false
    }
    
    func isDora() -> Bool {
        return false
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
    
    func isSyoususi() -> Bool {
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
    
    func isTenhou() -> Bool {
        return false
    }
    
    func isTihou() -> Bool {
        return false
    }
    
    func isKokusi() -> Bool {
        return false
    }
    
    func isKokusi13() -> Bool {
        return false
    }
    
}

