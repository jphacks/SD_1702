import Foundation

class Syanten {
    
    
    //変数定義したい
    var mentu: Int=0      //メンツ数
    var toitu: Int=0        //トイツ数
    var kouho: Int=0        //ターツ数
    var temp: Int=0        //シャンテン数（計算用）
    var syanten_normal: Int = 0    //シャンテン数（結果用）
    var tmp: [Int] = [Int](repeating: 0, count: 34)
    var tmp2: [Int] = [Int](repeating: 0, count: 34)
    var tmp3: [Int] = [Int](repeating: 0, count: 34)
    var gomi_normal: [Tile] = []
    var gomi_kokusi: [Tile] = []
    var gomi_tiitoi: [Tile] = []
    var gomi_min: [Tile] = []
    var gomi: [Tile] = []
    
    init(hand: [Tile]) {
        
        for tile in hand {
            tmp[tile.getCode()] += 1
            tmp2[tile.getCode()] += 1
            tmp3[tile.getCode()] += 1
        }
    }
    
    // シャンテン数を返す
    func getSyantenNum() ->(syanten_min:Int,gomi_min:Array<Tile>) {
        let syanten_min = min(getKokusiSyantenNum().syanten_kokusi, getTiitoituSyantenNum().syanten_tiitoi, getNormalSyantenNum().syanten_normal)
        
        print(getKokusiSyantenNum().syanten_kokusi)
        if (syanten_min == getKokusiSyantenNum().syanten_kokusi){
            print(getKokusiSyantenNum().gomi_kokusi)
            return (syanten_min,getKokusiSyantenNum().gomi_kokusi)
        }else if (syanten_min == getTiitoituSyantenNum().syanten_tiitoi){
            return (syanten_min,getTiitoituSyantenNum().gomi_tiitoi)
        }else{
            return (syanten_min,getNormalSyantenNum().gomi_normal)
        }
    }
    
    //国士無双のシャンテン数を返すyo///////////////////////////////////////
    func getKokusiSyantenNum()->(syanten_kokusi:Int,gomi_kokusi:Array<Tile>){
        var toituflag = false, syanten_kokusi = 13
        //老頭牌
        for i in 0 ..< 34 {
            if (Tile(rawValue: i)?.isYaochu())! {
                if (tmp[i] > 0) {
                    syanten_kokusi -= 1
                    tmp2[i] -= 1
                }
                if (tmp[i] >= 2 && !toituflag) {
                    toituflag  = true
                    tmp2[i] -= 1
                }
            }
        }
        gomi_kokusi = []
        for k in 0..<34{
            if(tmp2[k] == 1) {
                gomi_kokusi.append(Tile(rawValue: k)!)
            }
        }
        //頭
        syanten_kokusi -= toituflag ? 1 : 0
        return (syanten_kokusi,gomi_kokusi);
    }
    
    //チートイツのシャンテン数を返すyo/////////////////////////////
    func getTiitoituSyantenNum()->(syanten_tiitoi:Int,gomi_tiitoi:Array<Tile>){
        var toitu = 0, syanten_tiitoi = 6
        //トイツ数を数える
        for i in 0..<34{
            if(tmp[i] >= 2) {
                toitu += 1
                tmp3[i] -= 2
            }
            if(tmp[i] == 4) {toitu -= 1}
        }
        syanten_tiitoi -= toitu
        for k in 0..<34{
            if(tmp3[k] == 1) {
                gomi_tiitoi.append(Tile(rawValue: k)!)
            }
        }
        return (syanten_tiitoi,gomi_tiitoi);
    }
    
    //普通にシャンテン数考えるyo/////////////////////////////////////
    func getNormalSyantenNum()->(syanten_normal:Int,gomi_normal:Array<Tile>){
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
                mentu_cut(i: 0)
                
                tmp[i] += 2;
                toitu-=1
            }
            mentu_cut(i: 0)   //頭無しと仮定して計算
        }
        return (syanten_normal, gomi_normal);    //最終的な結果
    }
    
    
    //メンツ抜き出しの関数//////////////////////////
    func mentu_cut(i: Int){
        var j = 0
        //牌が見つかるまで飛ばす
        for k in i..<34{
            j = k
            if(tmp[j] > 0) {break}
        }
        
        //メンツを抜き終わったのでターツ抜きへ
        if(i > 33){
            taatu_cut(i: 0)
            return
        }
        
        //コーツ
        if(tmp[j] >= 3){
            mentu += 1;
            tmp[j] -= 3;
            mentu_cut(i: j)
            
            tmp[j] += 3;
            mentu -= 1;
        }
        //シュンツ
        if(j != 7 && j != 8 && j != 16 && j != 17 && j < 25){
            if(tmp[j + 1] > 0 && tmp[j + 2] > 0){
                mentu += 1
                tmp[j] -= 1; tmp[j + 1] -= 1; tmp[j + 2] -= 1
                mentu_cut(i: j)
                
                tmp[j] += 1; tmp[j + 1] += 1; tmp[j+2] += 1
                mentu -= 1
            }
        }
        //メンツ無しと仮定
        mentu_cut(i: j+1)
    }
    
    
    //ターツ抜き出しの関数///////////////////////////
    func taatu_cut(i: Int){
        var j=0
        //牌が見つかるまで飛ばす
        for k in i..<34{
            j=k
            if(tmp[j]>0){break}
        }
        
        //抜き出し終了
        if(i >= 34) {
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
                taatu_cut(i: j)
                
                tmp[j] += 2
                kouho -= 1
            }
            
            //ペンチャンかリャンメン
            if(j != 8  && j != 17  && j < 27){
                if(tmp[j + 1] > 0){
                    kouho += 1
                    tmp[j] -= 1; tmp[j + 1]-=1
                    taatu_cut(i: j)
                    
                    tmp[j] += 1; tmp[j + 1] += 1
                    kouho -= 1
                }
            }
            
            //カンチャン
            if(j != 7 && j != 8 && j != 16 && j != 17 && j < 27){
                if(tmp[j + 2] > 0){
                    kouho += 1
                    tmp[j] -= 1; tmp[j + 2] -= 1
                    taatu_cut(i: j)
                    
                    tmp[j] += 1; tmp[j + 2] += 1
                    kouho -= 1
                }
            }
        }
        //ターツなしと仮定
        taatu_cut(i: j+1)
    }
    
}

