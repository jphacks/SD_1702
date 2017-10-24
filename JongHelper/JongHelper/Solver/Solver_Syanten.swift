import Foundation

class Syanten {
    

    //変数定義したい
    var mentu: Int=0      //メンツ数
    var toitu: Int=0        //トイツ数
    var kouho: Int=0        //ターツ数
    var temp: Int=0        //シャンテン数（計算用）
    var syanten_normal: Int = 0    //シャンテン数（結果用）
    var tmp: [Int] = [Int](repeating: 0, count: 34)
    var gomi: [Tile] = []
    
    init(hand: [Tile]) {
        
        for tile in hand {
            tmp[tile.getCode()] += 1
        }
    }
    
    // シャンテン数を返す
    func getSyantenNum() -> Int {
        return min(getKokusiSyantenNum(), getTiitoituSyantenNum(), getNormalSyantenNum().syanten_normal)
    }
    
    //国士無双のシャンテン数を返すyo///////////////////////////////////////
    func getKokusiSyantenNum()->Int{
        var toituflag = false, syanten_kokusi = 13
        //老頭牌
        
        for i in 0 ..< 34 {
            if (Tile(rawValue: i)?.isYaochu())! {
                if (tmp[i] > 0) {
                    syanten_kokusi -= 1
                }
                if (tmp[i] >= 2 && !toituflag) {
                    toituflag  = true
                }
            }
        }
        //頭
        syanten_kokusi -= toituflag ? 1 : 0
        return syanten_kokusi
    }

    //チートイツのシャンテン数を返すyo/////////////////////////////
    func getTiitoituSyantenNum()->Int{
        var toitu = 0, syanten_tiitoi = 6
        //トイツ数を数える
        for i in 0..<34{
            if(tmp[i] >= 2) {toitu += 1}
            if(tmp[i] == 4) {toitu -= 1}
        }
        syanten_tiitoi -= toitu
        return syanten_tiitoi
    }

    //普通にシャンテン数考えるyo/////////////////////////////////////
    func getNormalSyantenNum()->(syanten_normal:Int,gomi:Array<Tile>){
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
        return (syanten_normal, gomi);    //最終的な結果
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
                gomi = []
                for k in 0..<34{
                    if(tmp[k] == 1) {
                        gomi.append(Tile(rawValue: k)!)
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
