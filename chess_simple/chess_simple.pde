int x0,y0, x1,y1;  //選択した駒の座標(x0,y0)、移動先の駒の座標(x1,y1)
int p0, q0, p1, q1;  //prev move, for en passant
int bw, side;  //手番の色(1なら白、-1なら黒)、一辺の長さ
boolean gameOver, check, promote;
int wKing=6, wQueen=5, wRook=4, wBishop=3, wKnight=2, wPawn=1;
int bKing=-6, bQueen=-5, bRook=-4, bBishop=-3, bKnight=-2, bPawn=-1;
boolean wCastQueen, wCastKing;  //白のキャスリング用
boolean bCastQueen, bCastKing;  //黒のキャスリング用
int board[][] = new int[10][10];

void setup() {
  size(400, 400);
  side=height/8;
  
  noStroke();
  textAlign(CENTER,CENTER);
  
  startPosition();
  showBoard();
}

void draw() {
  if (gameOver) {
    fill(0, 255, 0);
    if (check) text("CHECKMATE", width/2, height/2);
    else text("STALEMATE", width/2, height/2);
  }
}

void mousePressed() {
  //最初からやり直し
  if (gameOver) {startPosition();  showBoard();}
  
  if (promote) {
    int x = floor(mouseX/(width/4));
    
    if(x==0){board[x1][y1] = -5*bw;}  //Queen
    if(x==1){board[x1][y1] = -4*bw;}  //Rook
    if(x==2){board[x1][y1] = -3*bw;}  //Bishop
    if(x==3){board[x1][y1] = -2*bw;}  //Knight
    
    promote = false;
    
    check = false;
    if (Check()) {check = true;}  //king under attack
    if (mate()) {gameOver = true;}  //no legal moves
    
    showBoard();
  }
  else {  //プロモーション画面ではない時、駒を選択
    x1 = floor(mouseX/side +1); //各マスの左上の座標を定義
    y1 = floor(mouseY/side +1); //floor()で小数点以下切り捨て
    
    y1=9-y1;  //白が下段の時
    
    if (validMove(x0,y0, x1,y1) && !inCheck(x0,y0, x1,y1)) {
      check = false;  //stop showing check
      print(nf(bw,2) +": " +x0 +"," +y0 +"->" +x1 +"," +y1 +";   ");
      movePiece(x0,y0, x1,y1, true);  //move piece
      showBoard();
    }
    else {  //一度目のクリックで駒を選ぶ
      x0 = x1;
      y0 = y1;
      showBoard();
    }
  }
}

void keyPressed() {
  if (key=='r') {
    startPosition();
    showBoard();
  }
}

//初期設定
void startPosition() {
  //global variables
  y0=x0=y1=x1=-1;
  p0=q1=p1=q1=-1;
  bw = 1;
  gameOver = false;
  wCastQueen = wCastKing = false;
  bCastQueen = bCastKing = false;
  check = false;
  promote = false;
  
  //駒の配置
  for (int i=0; i<=9; i++){
    for (int j=0; j<=9; j++) {
      if(i==0||j==0||i==9||j==9) {board[i][j]=3;}  //外縁は3
      
      else if(j==2){board[i][j]=1;}  //wPawn
      else if(j==1){
        if(i==2||i==7){board[i][j]=2;}
        else if(i==3||i==6){board[i][j]=3;}
        else if(i==1||i==8){board[i][j]=4;}
        else if(i==4){board[i][j]=5;}
        else if(i==5){board[i][j]=6;}
      }
      
      else if(j==7){board[i][j]=-1;}  //bPawn
      else if(j==8){
        if(i==2||i==7){board[i][j]=-2;}
        else if(i==3||i==6){board[i][j]=-3;}
        else if(i==1||i==8){board[i][j]=-4;}
        else if(i==4){board[i][j]=-5;}
        else if(i==5){board[i][j]=-6;}
      }
      
      else {board[i][j]=0;}  //空のマスは0
    }
  }
}

//盤面の描画
void showBoard() {
  //盤面(背景とグリッド)を描画
  background(230, 170, 120);
  noStroke();
  rectMode(CORNER);
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      if ((i+j)%2 == 0) fill(240, 190, 150);  //ベージュ
      //if ((i+j)%2 == 0) fill(250, 210, 170);  //ベージュ
      else {fill(210, 130, 70);}  //茶色
      rect((i-1)*side, (j-1)*side, side, side);
    }
  }

  //駒を描画
  textSize(0.8*side);
  textAlign(CENTER,CENTER);
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) { 
      //駒の描画
      if(1<=board[i][j] && board[i][j]<=6){
        fill(255);
        if(board[i][j]==wKing){text("K",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==wQueen){text("Q",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==wRook){text("R",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==wBishop){text("B",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==wKnight){text("N",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==wPawn){text("P",i*side -side/2, (9-j)*side -side/2);}
      }
      
      if(-6<=board[i][j] && board[i][j]<=-1){
        fill(0);
        if(board[i][j]==bKing){text("K",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==bQueen){text("Q",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==bRook){text("R",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==bBishop){text("B",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==bKnight){text("N",i*side -side/2, (9-j)*side -side/2);}
        else if(board[i][j]==bPawn){text("P",i*side -side/2, (9-j)*side -side/2);}
      }
      
      //選択した駒の強調
      noStroke();
      if (i==x0 && j==y0 && board[i][j]!=0) {  //選択中のマス
        fill(255, 0, 0, 100);
        rect((i-1)*side, (8-j)*side, side, side);
      }
      else if (validMove(x0,y0, i,j) && !inCheck(x0,y0, i,j)) {  //動ける先のマスを強調
        if(bw==-1){fill(0, 0, 0, 200);}
        else if(bw==1){fill(255, 255, 255, 200);}
        ellipse((i-1)*side +side/2, (8-j)*side +side/2, side/3, side/3);
      }
    }
    
    //
    if (check && !gameOver && !promote) {
      fill(0, 255, 0);
      text("CHECK", width/2, height/2);
    }
  }
    
  //ポーンが成る時の選択画面
  if (promote && !gameOver) {
    fill(0,127,127, 200);
    rect(0, 0, 8*side, 8*side);
    
    stroke(2);
    line(2*side, 0, 2*side, 8*side);
    line(4*side, 0, 4*side, 8*side);
    line(6*side, 0, 6*side, 8*side);
    
    fill(0);
    text("Q", 1.0*side, 4.0*side);
    text("R", 3.0*side, 4.0*side);
    text("B", 5.0*side, 4.0*side);
    text("N", 7.0*side, 4.0*side);//*/
  }
}

boolean validMove(int i0, int j0, int i1, int j1) {
  if(i0<1||8<i0 || j0<1||8<j0 || i1<1||8<i1 || j1<1||8<j1){return false;}  //盤外には指せない
  if(board[i0][j0]==0){return false;}  //空マスからは指せない
  
  //成らない時のポーン
  if (board[i0][j0]==bw && !promote) {
    if (i1==i0 && j1==j0+bw && board[i0][j0+bw]==0) {return true;}  //1マス進む
    if (i1==i0 && j1==j0+2*bw && (j0==2||j0==7) && //(bw==1&&j0==7 || bw==-1&&j0==2) &&
             board[i0][j0+bw]==0 && board[i0][j0+2*bw]==0) {return true;}  //2マス進む
    
    if (abs(i1-i0)==1 && j1==j0+bw && -6<=board[i1][j1]*bw &&
        board[i1][j1]*bw<=-1) {return true;} //斜め前の相手駒を取る
    
    if ((bw==1&&j0==5 || bw==-1&&j0==4) && board[p1][q1]==-bw &&
        q1==q0-2*bw && (p1-i0)*(i1-i0)==1 && j1==j0+bw) {return true;}  //アンパッサン
  }
  
  //ナイト
  else if (board[i0][j0] == 2*bw) {
    if (abs((i1-i0)*(j1-j0))==2 && !(1<=board[i1][j1]*bw && board[i1][j1]*bw<=6)) {return true;}
  }
  
  //ビショップ
  else if (board[i0][j0] == 3*bw) { 
    if (possible(i0, j0, i1, j1, 1, 1)) {return true;}
    if (possible(i0, j0, i1, j1, 1, -1)) {return true;}
    if (possible(i0, j0, i1, j1, -1, 1)) {return true;}
    if (possible(i0, j0, i1, j1, -1, -1)) {return true;}
  }
  
  //ルック
  else if (board[i0][j0] == 4*bw) {
    if (possible(i0, j0, i1, j1, 0, 1)) {return true;}
    if (possible(i0, j0, i1, j1, 0, -1)) {return true;}
    if (possible(i0, j0, i1, j1, 1, 0)) {return true;}
    if (possible(i0, j0, i1, j1, -1, 0)) {return true;}
  }
  
  //クイーン
  else if (board[i0][j0] == 5*bw) {
    if (possible(i0, j0, i1, j1, 1, 1)) {return true;}
    if (possible(i0, j0, i1, j1, -1, 1)) {return true;}
    if (possible(i0, j0, i1, j1, 1, -1)) {return true;}
    if (possible(i0, j0, i1, j1, -1, -1)) {return true;}
    if (possible(i0, j0, i1, j1, 0, 1)) {return true;}
    if (possible(i0, j0, i1, j1, 0, -1)) {return true;}
    if (possible(i0, j0, i1, j1, 1, 0)) {return true;}
    if (possible(i0, j0, i1, j1, -1, 0)) {return true;}
  }
  
  //キング
  else if (board[i0][j0] == 6*bw) {
    if (abs(i0-i1)<=1 && abs(j0-j1)<=1 &&
        !(1<=board[i1][j1]*bw && board[i1][j1]*bw<=6)) {return true;}  //move
    
    //白のキャスリング
    if (board[i0][j0] == wKing && !check) {
      if (wCastQueen==false && board[2][1]==0 && board[3][1]==0 && board[4][1]==0 &&  //クイーンサイド
          i1==3 && j1==1 && board[1][1]==wRook && !inCheck(i0, j0, 4, 1)) {return true;}
      if (wCastKing==false && board[6][1]==0 && board[7][1]==0 &&  //キングサイド
          i1==7 && j1==1 && board[8][1]==wRook && !inCheck(i0, j0, 6, 1)) {return true;}
    }
    
    //黒のキャスリング
    if (board[i0][j0] == bKing && !check) {
      if (bCastQueen==false && board[2][8]==0 && board[3][8]==0 && board[4][8]==0 &&  //クイーンサイド
          i1==3 && j1==8 && board[1][8]==bRook && !inCheck(i0, j0, 4, 8)) {return true;}
      if (bCastKing==false && board[6][8]==0 && board[7][8]==0 &&  //キングサイド
          i1==7 && j1==8 && board[8][8]==bRook && !inCheck(i0, j0, 6, 8)) {return true;}
    }
  }
  
  return false;
}

boolean possible(int i0, int j0, int i1, int j1, int di, int dj) {
  int i=i0+di, j=j0+dj;
  
  while (1<=i&&i<=8 && 1<=j&&j<=8) {
    if (1<=board[i][j]*bw && board[i][j]*bw<=6) {return false;}  //自分の駒があれば指せない
    if (-6<=board[i][j]*bw && board[i][j]*bw<=-1) {  //相手の駒がある時
      if (i==i1 && j==j1){return true;}  //駒を取れるなら指せる
      else{return false;}  //駒を取れないなら指せない
    }
    
    if (i==i1 && j==j1){return true;}  //(i0,j0)から(i1,j1)まで駒が無ければ指せる
    i+=di; j+=dj;  //次のマスに移動
  }
  
  return false;
}

void movePiece(int i0, int j0, int i1, int j1, boolean update) {
  if (update) {p0=i0;  q0=j0;  p1=i1;  q1=j1;}  //setup prev move for en passant
  
  //Pawn
  if (board[i0][j0] == wPawn) {
    if (j1==8 && update) {promote = true;}  //駒が成る時
    else if (abs(i1-i0)==1 && j1==6 && board[i1][j1]==0) {board[i1][j1-1]=0;}  //アンパッサン
  } 
  else if (board[i0][j0] == bPawn) {
    if (j1==1 && update) {promote = true;}
    else if (abs(i1-i0)==1 && j1==3 && board[i1][j1]==0) {board[i1][j1+1]=0;}
  }
  
  //castle
  else if (board[i0][j0] == wKing) {
    if (wCastQueen==false && i1==3) {  //クイーン側のRook
      board[1][1] = 0;
      board[4][1] = wRook;
    }
    else if (wCastKing==false && i1==7) {  //キング側のRook
      board[8][1] = 0;
      board[6][1] = wRook;
    }
    
    if (update){wCastQueen=true;  wCastKing=true;}  //Kingが動いたことを記録
  }
  else if (board[i0][j0] == bKing) {
    if (bCastQueen==false && i1==3) {  //クイーン側のRook
      board[1][8] = 0;
      board[4][8] = bRook;
    }
    else if (bCastKing==false && i1==7) {  //キング側のRook
      board[8][8] = 0;
      board[6][8] = bRook;
    }
    
    if (update){bCastQueen=true;  bCastKing=true;}  //Kingが動いたことを記録
  }
  
  //Rookが動いたことを記録
  else if (board[i0][j0]==wRook && update) {
    if (wCastQueen==false && i0==1) {wCastQueen=true;}
    if (wCastKing==false && i0==8) {wCastKing=true;}
  } 
  else if (board[i0][j0]==bRook && update) {
    if (bCastQueen==false && i0==1) {bCastQueen=true;}
    if (bCastKing==false && i0==8) {bCastKing=true;}
  }
  
  board[i1][j1] = board[i0][j0];  //move piece
  board[i0][j0] = 0;  //remove original piece
  
  if (update) {
    bw = -bw;
    if (Check()) {check = true;}  //king under attack
    if (mate()) {gameOver = true;}  //no legal moves
  }
}

//自分のキングがチェックされてるか判定
boolean Check() {
  for (int i=1; i<=8; i++) {
    for (int j=1; j<=8; j++) {
      //kingに向かって指す手
      if (board[i][j]*bw==6) {
        for (int k=1; k<=8; k++) {
          for (int l=1; l<=8; l++) {
            bw = -bw;
            if (validMove(k,l, i,j)) {bw = -bw;  return true;}  //相手の手番で考える
            bw = -bw;
          }
        }
      }
    }
  }
  
  return false;
}

//自分が指した後、キングがチェックされてるか判定
boolean inCheck(int i0, int j0, int i1, int j1) {
  int[][] tmpBoard = new int[10][10];
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      tmpBoard[i][j] = board[i][j];  //一時保存
    }
  }
  
  movePiece(i0, j0, i1, j1, false);
  if (Check()) {
    for (int i=1; i<=8; i++){
      for (int j=1; j<=8; j++) {
        board[i][j] = tmpBoard[i][j];  //戻す
      }
    }
    return true;
  }
  
  for (int i=1; i<=8; i++){
    for (int j=1; j<=8; j++) {
      board[i][j] = tmpBoard[i][j];  //戻す
    }
  }
  
  return false;
}

boolean mate() {  //no valid moves
  for (int k=1; k<=8; k++) {
    for (int l=1; l<=8; l++) {
      for (int i=1; i<=8; i++) {
        for (int j=1; j<=8; j++) {
          if (validMove(k,l, i,j) && !inCheck(k,l, i,j)) return false;
        }
      }
    }
  }
  
  return true;
}
