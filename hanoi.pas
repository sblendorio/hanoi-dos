PROGRAM Hanoi;
USES CRT,DOS,MouseDrv;
CONST Alto  = 1;
      Basso = 4;
      color:ARRAY [1..7] of byte=(Blue,DarkGray,Brown,Red,Magenta,Green,Cyan);
VAR   stack:ARRAY [1..3] of string[7];
      block:ARRAY [1..7] of string[26];
      l,scelta,ctemp:integer;
      suono,anim,usemouse,colori:byte;

FUNCTION  Repl(a:string;n:integer):string; forward;
FUNCTION  Pot(x,y:integer):integer; forward;
FUNCTION  itoa(n:integer):string; forward;
FUNCTION  atoi(s:string):integer; forward;
FUNCTION  LastChar(s:string):char; forward;
FUNCTION  InvPos(s:string;c:char):integer; forward;
FUNCTION  CurDir:string; forward;
FUNCTION  Scambia(p,d:integer):boolean; forward;
FUNCTION  Verify:boolean; forward;
FUNCTION  GetNumber:integer; forward;
FUNCTION  Input(var p,d:integer):integer; forward;
FUNCTION  MouseOk:boolean; forward;
FUNCTION  GetCursor:integer; forward;             {   Procedure e Funzioni  }
PROCEDURE SetCursor(newcursor:integer); forward;  {    tratte dal listato   }
PROCEDURE HideCursor; forward;                    {       BREAKOUT.PAS      }
PROCEDURE ShowCursor; forward;                    { dei file esempio di TP7 }
PROCEDURE Beep(freq,duration:word); forward;
PROCEDURE PlotBox(x1,y1,x2,y2:integer;bg,fg:byte;ch:char); forward;
PROCEDURE Center(col:byte;s:string); forward;
PROCEDURE PlayMelody(x:integer); forward;
PROCEDURE Pulisci(a,b:integer); forward;
PROCEDURE TextCol(n:byte); forward;
PROCEDURE TextBack(n:byte); forward;
PROCEDURE WriteColor(i:byte;s:string); forward;
PROCEDURE DispMessage(s:string); forward;
PROCEDURE LoadPrefs(var retcode:integer); forward;
PROCEDURE SavePrefs(var retcode:integer); forward;
PROCEDURE Initialize; forward;
PROCEDURE IntroScreen; forward;
PROCEDURE SelectionScreen; forward;
PROCEDURE PrintBlock(n:byte); forward;
PROCEDURE WriteBoolean(v:byte); forward;
PROCEDURE ResetGame; forward;
PROCEDURE Visual; forward;
PROCEDURE MoveBlock(p,d:integer); forward;
PROCEDURE Game; forward;
PROCEDURE Preferences; forward;
PROCEDURE InfoScreen; forward;
PROCEDURE Esci; forward;
PROCEDURE ExitScreen; forward;

FUNCTION Repl;
VAR i:integer;
    b:string;
BEGIN
     b:='';
     IF n > 0 THEN
        FOR i:=1 TO n DO
            b:=b+a;
     Repl:=b;
END;

FUNCTION Pot;
VAR i,pt:integer;
BEGIN
     pt:=1;
     FOR i:=1 TO ABS(y) DO pt:=pt*x;
     Pot:=pt;
END;

FUNCTION itoa;
VAR s:string;
BEGIN
     Str(n,s);
     itoa := s;
END;

FUNCTION atoi;
VAR n,err:integer;
BEGIN
     Val(s,n,err);
     atoi := n;
END;

FUNCTION LastChar;
BEGIN
     LastChar := s[Length(s)];
END;

FUNCTION InvPos;
VAR i,p:integer;
BEGIN
     p := 0;
     IF Length(s) > 0 THEN
        FOR i := 1 TO Length(s) DO
            IF s[i] = c THEN p := i;
     InvPos := p;
END;

FUNCTION CurDir;
BEGIN
     curdir := Copy(ParamStr(0),1,InvPos(ParamStr(0),'\'));
END;

FUNCTION Scambia;
VAR valida:boolean;
    a,b:integer;
BEGIN
     a := atoi(LastChar(stack[p]));
     b := atoi(LastChar(stack[d])); IF b = 0 THEN b := 100;
     IF (a <> 0) and (a < b) THEN BEGIN
        stack[d] := stack[d] + LastChar(stack[p]);
        stack[p] := Copy(stack[p],1,Length(stack[p])-1);
        valida := True;
     END
     ELSE valida := False;
     Scambia := valida;
END;

FUNCTION Verify;
VAR vince:boolean;
    i:integer;
BEGIN
     vince := False;
     FOR i:=2 TO 3 DO
         IF Length(stack[i]) = l THEN vince := True;
     Verify := vince;
END;

FUNCTION GetNumber;
VAR kp:boolean;
    n,md,x,y:integer;
    c:char;
BEGIN
     md := 0;
     c  := ' ';
     REPEAT
           IF MouseOk THEN REPEAT UNTIL Mouse_Down = 0;
           REPEAT
                 kp := KeyPressed;
                 IF MouseOk THEN md := Mouse_Down;
           UNTIL kp OR (md <> 0);
           DispMessage('');
           IF MouseOk and (md <> 0) THEN BEGIN
              Mouse_GetPos(x,y);
              IF (y >= 16) and (y <= 24) THEN BEGIN
                 IF (x >= 02) and (x <= 27) THEN c := '1';
                 IF (x >= 28) and (x <= 53) THEN c := '2';
                 IF (x >= 54) and (x <= 79) THEN c := '3';
              END
              ELSE IF (((x >= 68) and (x <= 75)) and ((y >= 9) and (y <= 11))) THEN c := #27;
           END;
           IF kp THEN c := ReadKey;
           IF Pos(c,'123'#27) = 0 THEN BEGIN
              IF md = 0 THEN DispMessage('Tasto non valido') ELSE DispMessage('Mouse fuori range');
              Beep(110,1);
           END;
     UNTIL Pos(c,'123'#27) <> 0;
     n := atoi(c); IF c = #27 THEN n := -1;
     GetNumber := n;
END;

FUNCTION Input;
BEGIN
     GotoXY(64,6); WriteColor(Magenta,'  ');
     GotoXY(64,7); Write('  ');
     GotoXY(64,6);
     REPEAT
           GotoXY(64,6);
           p := GetNumber;
           IF (Length(stack[p]) = 0) and (p <> -1) THEN BEGIN
              DispMessage('La base n.'+itoa(p)+' Љ vuota');
              Beep(110,1);
           END;
     UNTIL (Length(stack[p]) <> 0) or (p = -1);
     IF p = -1 THEN BEGIN
        Input := 1;
        Exit;
     END;
     GotoXY(64,6); WriteColor(Magenta,itoa(p));
     GotoXY(64,7);
     d := GetNumber;
     IF d = -1 THEN BEGIN
        Input := 1;
        Exit;
     END;
     GotoXY(64,7); WriteColor(Magenta,itoa(d));
     Input := 0;
END;

FUNCTION MouseOk;
BEGIN
     MouseOk := Mouse_Exists and (usemouse=1);
END;

FUNCTION GetCursor;
VAR
   Reg : Registers;
BEGIN
     Reg.AH := 3;
     Reg.BH := 0;
     Intr($10, Reg);
     GetCursor := Reg.CX;
END;

PROCEDURE SetCursor;
VAR
  Reg : Registers;
BEGIN
    Reg.AH := 1;
    Reg.BH := 0;
    Reg.CX := newcursor;
    Intr($10, Reg);
END;

PROCEDURE HideCursor;
BEGIN
     IF GetCursor <> $2000 THEN BEGIN
        ctemp := GetCursor;
        SetCursor($2000);
     END;
END;

PROCEDURE ShowCursor;
BEGIN
     IF (ctemp <> 0) and (ctemp <> $2000) THEN SetCursor(ctemp);
END;

PROCEDURE Beep;
BEGIN
     IF suono=1 THEN BEGIN
        Sound(freq);
        Delay(duration*200);
        NoSound;
     END;
END;

PROCEDURE PlotBox;
VAR i,j:integer;
BEGIN
     TextBack(bg);
     TextCol(fg);
     FOR i:=1 TO 2 DO
         FOR j:=y1 TO y2 DO BEGIN
             IF i=1 THEN GotoXY(x1,j) ELSE GotoXY(x2,j);
             Write(ch);
         END;
     GotoXY(x1,y1); Write(Repl(ch,x2-x1+1));
     GotoXY(x1,y2); Write(Repl(ch,x2-x1+1));
END;

PROCEDURE Center;
VAR t:byte;
BEGIN
     t := (80-Length(s)) div 2;
     GotoXY(t+1,WhereY);
     TextCol(col); Write(s);
END;

PROCEDURE PlayMelody;
VAR a:ARRAY [1..12,1..2] of word;
    i:integer;
BEGIN
     a[01,1]:= 440; a[01,2]:=1;   a[07,1]:= 495; a[07,2]:=1;
     a[02,1]:= 495; a[02,2]:=1;   a[08,1]:= 523; a[08,2]:=1;
     a[03,1]:= 523; a[03,2]:=2;   a[09,1]:= 658; a[09,2]:=1;
     a[04,1]:= 495; a[04,2]:=2;   a[10,1]:= 495; a[10,2]:=1;
     a[05,1]:= 440; a[05,2]:=2;   a[11,1]:= 523; a[11,2]:=1;
     a[06,1]:= 440; a[06,2]:=1;   a[12,1]:= 440; a[12,2]:=2;
     FOR i:=1 TO 12 DO Beep(a[i,1] div x,a[i,2]);
END;

PROCEDURE Pulisci;
VAR i:integer;
BEGIN
     Window(5,a,76,b);
     TextBack(LightGray); ClrScr;
     Window(1,1,80,25);
END;

PROCEDURE TextCol;
VAR bl:integer;
BEGIN
     IF n >= 128 THEN BEGIN
        n  := n-128;
        bl := blink;
     END
     ELSE bl := 0;
     IF colori=1 THEN
        TextColor(n+bl)
     ELSE
        IF n = LightGray THEN TextColor(Black+bl) ELSE TextColor(LightGray+bl);
END;

PROCEDURE TextBack;
BEGIN
     IF colori=1 THEN
        TextBackGround(n)
     ELSE
        IF n = LightGray THEN TextBackGround(Black) ELSE TextBackGround(LightGray);
END;

PROCEDURE WriteColor;
BEGIN
     TextCol(i);
     Write(s);
END;

PROCEDURE DispMessage;
VAR wd,cx,cy:byte;
BEGIN
     cx := WhereX; cy := WhereY;
     wd := ((78-Length(s)) div 2)+3;
     IF s='' THEN wd := 3;
     IF MouseOk THEN Mouse_Hide;
     TextBack(Red);
     GotoXY(3,25);  WriteColor(LightGray,Repl(#32,77));
     GotoXY(wd,25); WriteColor(LightGray,s);
     WriteColor(LightGray+blink,'_');
     TextBack(LightGray); TextCol(Red);
     IF MouseOk THEN Mouse_Show;
     GotoXY(cx,cy);
END;

PROCEDURE LoadPrefs;
VAR f:text;
    config,par:string;
BEGIN
     retcode  := 0;
     suono    := 1;
     anim     := 1;
     usemouse := 1;
     colori   := 1;
     par := ParamStr(1);
     {$I-}
     Assign(f,curdir+'HANOI.INI');
     Reset(f);
     Close(f);
     {$I+}
     retcode := IOResult;
     IF retcode = 0 THEN BEGIN
        Assign(f,curdir+'HANOI.INI');
        Reset(f);
        ReadLn(f,config);
        Close(f);
        suono    := atoi(config[1]);
        anim     := atoi(config[2]);
        usemouse := atoi(config[3]);
        colori   := atoi(config[4]);
     END;
     IF (par = '/b') or (par = '/B') THEN colori := 0;
     IF (par = '/c') or (par = '/C') THEN colori := 1;
END;

PROCEDURE SavePrefs;
VAR f:text;
BEGIN
     retcode := 0;
     {$I-}
     Assign(f,curdir+'HANOI.INI');
     Rewrite(f);
     Close(f);
     {$I+}
     retcode := IOResult;
     IF retcode = 0 THEN BEGIN
        Assign(f,curdir+'HANOI.INI');
        Rewrite(f);
        WriteLn(f,suono,anim,usemouse,colori);
        Close(f);
     END;
END;

PROCEDURE Initialize;
VAR rc:integer;
BEGIN
     l := 2;
     scelta := 1;
     LoadPrefs(rc);
END;

PROCEDURE IntroScreen;
BEGIN
     TextBack(LightGray);
     IF scelta=1 THEN BEGIN
        ClrScr;
        PlotBox(3,2,78,24,LightGray,Red,#219);
        PlotBox(4,2,77,24,LightGray,Red,#219);
     END
     ELSE Pulisci(3,23);
     GotoXY(36,04); WriteColor(LightCyan,'Torri di');
     TextCol(Yellow);
     GotoXY(24,06); Write('ЫЫ  ЫЫ   ЫЫ   ЫЫ  ЫЫ  ЫЫЫЫ  ЫЫЫЫ');
     GotoXY(24,07); Write('ЫЫ  ЫЫ  ЫЫЫЫ  ЫЫЫ ЫЫ ЫЫ  ЫЫ  ЫЫ ');
     GotoXY(24,08); Write('ЫЫ  ЫЫ ЫЫ  ЫЫ ЫЫЫЫЫЫ ЫЫ  ЫЫ  ЫЫ ');
     GotoXY(24,09); Write('ЫЫЫЫЫЫ ЫЫЫЫЫЫ ЫЫ ЫЫЫ ЫЫ  ЫЫ  ЫЫ ');
     GotoXY(24,10); Write('ЫЫ  ЫЫ ЫЫ  ЫЫ ЫЫ  ЫЫ ЫЫ  ЫЫ  ЫЫ ');
     GotoXY(24,11); Write('ЫЫ  ЫЫ ЫЫ  ЫЫ ЫЫ  ЫЫ ЫЫ  ЫЫ  ЫЫ ');
     GotoXY(24,12); Write('ЫЫ  ЫЫ ЫЫ  ЫЫ ЫЫ  ЫЫ  ЫЫЫЫ  ЫЫЫЫ');
     GotoXY(29,14); WriteColor(LightCyan,'by Francesco Sblendorio');
END;

PROCEDURE SelectionScreen;
VAR c:char;
    m,err:integer;
BEGIN
     GotoXY(32,16); WriteColor(Blue,'Fai la tua scelta');
     GotoXY(17,17); WriteColor(Blue,'Per cambiare il numero dei blocchi usa "+" e "-"');
     GotoXY(57,17); WriteColor(White,'+');
     GotoXY(63,17); WriteColor(White,'-');
     m := 0;
     WHILE (m<1) or (m>4) DO BEGIN
           TextCol(DarkGray);
           GotoXY(21,19); Write('1. Comincia il gioco. Numero blocchi: ');
           WriteColor(White,itoa(l)+' '); TextCol(DarkGray);
           GotoXY(21,20); Write('2. Cambia le preferenze               ');
           GotoXY(21,21); Write('3. Informazioni sul programma         ');
           GotoXY(21,22); Write('4. Esci                               ');
           c := ReadKey;
           Val(c,m,err);
           IF (c = '+') and (l < 7) THEN Inc(l);
           IF (c = '-') and (l > 1) THEN Dec(l);
           IF c = #13 THEN m := 1;
           IF c = #27 THEN m := 4;
     END;
     scelta := m;
END;

PROCEDURE PrintBlock;
VAR s:string;
BEGIN
     TextBack(LightGray);
     WriteColor(color[n],block[n]);
END;

PROCEDURE WriteBoolean;
BEGIN
     CASE v OF
          0: WriteColor(Black,'No');
          1: WriteColor(White,'SЌ');
     END;
END;

PROCEDURE ResetGame;
VAR i,j:integer;
    c:char;
BEGIN
     j := -1;
     IF colori=1 THEN c := #219;
     FOR i:=1 TO 7 DO BEGIN
         IF colori=0 THEN BEGIN
            j := (j+1) MOD 4;
            IF j = 3 THEN c := #219 ELSE c := Chr(176+j);
         END;
         block[i]:=Repl(#32,(7-i)*2)+Repl(c,4*i-2)+Repl(#32,(7-i)*2);
     END;
     FOR i:=1 TO 3 DO stack[i] := '';
     FOR i:=l DOWNTO 1 DO stack[1] := stack[1] + itoa(i);
     TextBack(LightGray);
     ClrScr;
     PlotBox(1,1,80,24,LightGray,Red,#219);
     GotoXY(1,2); InsLine;
     GotoXY(1,2); Write(#219,Repl(#32,78),#219);
     TextCol(LightGray);
     TextBack(Black);
     GotoXY(2,24); Write(Repl(#32,13),'1',Repl(#32,25),'2',Repl(#32,25),'3',Repl(#32,12));
     TextBack(LightGray);
     GotoXY(7,4); WriteColor(Brown,'Situazione corrente');
     GotoXY(7,6); WriteColor(Blue,'Mosse Effettuate:');
     GotoXY(7,7); Write('Mosse Minime    : ');
     WriteColor(White,itoa(Pot(2,l)-1));
     GotoXY(60,4); WriteColor(Red,'Muove');
     GotoXY(60,6); WriteColor(Magenta,'Da:');
     GotoXY(60,7); Write('A :');
     IF MouseOk THEN BEGIN
        TextBack(Black);
        GotoXY(68,09); WriteColor(LightGray,Repl(#223,8));
        GotoXY(68,10); IF colori=1 THEN WriteColor(Red,'  EXIT  ') ELSE WriteColor(LightGray,'  EXIT  ');
        GotoXY(68,11); WriteColor(LightGray,Repl(#220,8));
     END;
     TextBack(Red); GotoXY(2,25); WriteColor(LightGray,#16);
     DispMessage('');
END;

PROCEDURE Visual;
VAR k,i,j:integer;
    b:string;
BEGIN
     IF MouseOK THEN Mouse_Hide;
     FOR i:=1 TO 3 DO BEGIN
         b := stack[i];
         k := Length(b);
         IF k <> 0 THEN
            FOR j:=1 TO k DO BEGIN
                GotoXY(2+(26*(i-1)),24-j);
                PrintBlock(atoi(b[j]));
         END;
         GotoXY(2+(26*(i-1)),23-k); Write(Repl(#32,26));
     END;
     IF MouseOK THEN Mouse_Show;
END;

PROCEDURE MoveBlock;
VAR xStart,xEnd:integer;
    yStart,yEnd:integer;
    b,Dx,i:integer;
BEGIN
     yStart := 24-Length(stack[p]);
     yEnd   := 24-Length(stack[d]);
     xStart := 2+(26*(p-1));
     xEnd   := 2+(26*(d-1));
     Dx     := d-p;
     b      := atoi(LastChar(stack[d]));
     TextBack(LightGray);
     FOR i := yStart-2 DOWNTO 14 DO BEGIN
         GotoXY(xStart,i);   PrintBlock(b);
         GotoXY(xStart,i+1); Write(Repl(#32,26));
         Delay(40);
     END;
     Delay(60);
     IF Dx > 0 THEN BEGIN
        FOR i := xStart TO xEnd-1 DO BEGIN
            GotoXY(i,14); Write(#32); PrintBlock(b);
            Delay(25);
        END;
     END
     ELSE BEGIN
        FOR i := xStart-1 DOWNTO xEnd DO BEGIN
            GotoXY(i,14); PrintBlock(b); Write(#32);
            Delay(25);
        END;
     END;
     Delay(75);
     FOR i := 15 TO yEnd DO BEGIN
         GotoXY(xEnd,i);   PrintBlock(b);
         GotoXY(xEnd,i-1); Write(Repl(#32,26));
         Delay(40);
     END;
END;

PROCEDURE Game;
VAR p,d,mosse,min:integer;
    c:char;
    valida:boolean;
BEGIN
     ResetGame;
     IF MouseOk THEN BEGIN
        Mouse_Reset;
        Mouse_SetPos(40,10);
        Mouse_Show;
     END;
     mosse := 0;
     min := Pot(2,l)-1;
     Visual;
     WHILE (not Verify) DO BEGIN
           REPEAT
                 ShowCursor;
                 IF Input(p,d) = 1 THEN BEGIN
                    HideCursor;
                    IF MouseOk THEN Mouse_Hide;
                    Exit;
                 END;
                 valida := Scambia(p,d);
                 IF not valida THEN BEGIN
                    IF p <> d THEN
                       DispMessage(itoa(p)+' '#26' '+itoa(d)+': Un blocco non pu• andare sopra uno pi— piccolo')
                    ELSE
                       DispMessage('Errore: partenza = destinazione');
                    Beep(110,1);
                 END
                 ELSE BEGIN
                      Delay(300);
                      HideCursor;
                      Inc(mosse);
                 END;
           UNTIL valida;
           IF anim=1 THEN BEGIN
              DispMessage('Muove da '+itoa(p)+' a '+itoa(d));
              MoveBlock(p,d);
              DispMessage('');
           END;
           IF mosse <= min THEN TextCol(White) ELSE TextCol(Red);
           GotoXY(25,6); Write(mosse);
           Visual;
     END;
     IF MouseOk THEN Mouse_Hide;
     GotoXY(1,10);
     IF mosse = min THEN BEGIN
        Center(Red,'P E R F E T T O');
        DispMessage('Hai vinto');
        PlayMelody(Alto);
     END
     ELSE BEGIN
        Center(DarkGray,'Ok, ma hai superato il numero minimo di mosse');
        DispMessage('Puoi far meglio, provaci ancora!');
        PlayMelody(Basso);
     END;
     GotoXY(20,13); WriteColor(White,'-- Premi un tasto per tornare al menu --');
     c := ReadKey;
END;

PROCEDURE Preferences;
VAR c:char;
    i,rc:integer;
    col,col1:byte;
BEGIN
     col := colori;
     Pulisci(3,23);
     PlotBox(25,4,55,6,LightGray,White,#42);
     PlotBox(26,4,54,6,LightGray,White,#42);
     GotoXY(1,5); Center(LightCyan,'Torri di Hanoi');
     GotoXY(1,9); Center(Blue,'* Preferenze *');
     GotoXY(21,11); WriteColor(Yellow,'1.  '); WriteColor(Brown,'Attivazione del suono');
     GotoXY(21,13); WriteColor(Yellow,'2.  '); WriteColor(Brown,'Attivazione dell''animazione');
     GotoXY(21,15); WriteColor(Yellow,'3.  '); WriteColor(Brown,'Attivazione dell''uso del mouse');
     GotoXY(21,17); WriteColor(Yellow,'4.  '); WriteColor(Brown,'Visualizzazione dei colori');
     GotoXY(21,19); WriteColor(Yellow,'5.  '); WriteColor(Brown,'Registra le preferenze');
     GotoXY(21,21); WriteColor(Yellow,'6.  '); WriteColor(Brown,'Ritorna al menu principale');
     REPEAT
           GotoXY(58,11); WriteBoolean(suono);
           GotoXY(58,13); WriteBoolean(anim);
           GotoXY(58,15); WriteBoolean(usemouse);
           GotoXY(58,17); WriteBoolean(col);
           c := ReadKey; i := atoi(c);
           IF (c = #27) or (c = #13) THEN i := 6;
           IF (i >= 1) and (i <= 6) THEN BEGIN
              GotoXY(58,19); Write('    ');
           END;
           GotoXY(58,19);
           CASE i OF
                1 : suono    := 1-suono;
                2 : anim     := 1-anim;
                3 : usemouse := 1-usemouse;
                4 : col      := 1-col;
                5 : BEGIN
                         col1 := colori;
                         colori := col;
                         SavePrefs(rc);
                         colori := col1;
                         IF rc = 0 THEN
                            WriteColor(Red,'Ok')
                         ELSE BEGIN
                            Beep(110,1);
                            WriteColor(Red,'Err');
                         END;
                    END;
           END;
     UNTIL i = 6;
     IF colori <> col THEN scelta := 1;
     colori := col;
END;

PROCEDURE InfoScreen;
VAR i:integer;
    c,d:char;
BEGIN
     Pulisci(3,23);
     IF colori=1 THEN d := #219 ELSE d := #177;
     PlotBox(25,5,59,11,LightGray,Black,d);
     PlotBox(25,5,60,11,LightGray,Black,d);
     TextBack(Red);
     FOR i := 4 TO 10 DO BEGIN
         GotoXY(23,i);
         Write(Repl(#32,36));
     END;
     IF colori=1 THEN i := White ELSE i := LightGray;
     GotoXY(01,5); Center(i,'Torri di Hanoi');
     GotoXY(01,7); Center(i,'Written by');
     GotoXY(01,8); Center(i,'Francesco Sblendorio');
     GotoXY(01,9); Center(i,'in 1996');
     TextBack(LightGray);
     GotoXY(07,14); WriteColor(Blue,'Questo programma Љ  stato scritto in '); WriteColor(White,'Borland Turbo Pascal 7.0');
     GotoXY(07,16); WriteColor(Blue,'Le routine di gestione mouse sono di '); WriteColor(White,'Paolo Agostini');
     GotoXY(01,22); Center(Red,'* Premi un tasto per tornare al menu *');
     c := ReadKey; d := #0;
     IF c = #0 THEN d := ReadKey;
END;

PROCEDURE Esci;
VAR c:char;
BEGIN
     Pulisci(16,23);
     GotoXY(1,18); Center(Red,'Sei sicuro di voler uscire?');
     GotoXY(1,20); Center(White,'(S/N)');
     REPEAT
           c := UpCase(ReadKey);
     UNTIL Pos(c,'S1N0'#27) <> 0;
     CASE c OF
          'S','1'     :  scelta := 4;
          'N','0',#27 :  scelta := -1;
     END;
END;

PROCEDURE ExitScreen;
BEGIN
     TextBack(Black); TextCol(LightGray);
     ClrScr;
END;

BEGIN    { Main Program }
     HideCursor;
     Initialize;
     IntroScreen;
     scelta := -1;
     REPEAT
           IF scelta = -1 THEN Pulisci(16,23) ELSE IntroScreen;
           SelectionScreen;
           CASE scelta OF
                1 : Game;
                2 : Preferences;
                3 : InfoScreen;
                4 : Esci;
           END;
     UNTIL (scelta = 4);
     ExitScreen;
     ShowCursor;
END.