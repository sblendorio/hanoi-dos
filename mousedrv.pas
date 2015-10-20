
UNIT MouseDrv;

INTERFACE

Uses Dos, Crt;

PROCEDURE Mouse(m1, m2, m3, m4: Integer);
PROCEDURE Mouse_reset;
FUNCTION  Mouse_exists : Boolean;
PROCEDURE Mouse_show;
PROCEDURE Mouse_hide;
FUNCTION  Mouse_down : Integer;
FUNCTION  Mouse_up : Integer;
PROCEDURE Mouse_getpos(var mx, my : Integer);
PROCEDURE Mouse_setpos(mx, my : Integer);


IMPLEMENTATION
Var  regs : Registers;


PROCEDURE Mouse(m1, m2, m3, m4: Integer);
BEGIN
  regs.ax := m1;
  regs.bx := m2;
  regs.cx := m3;
  regs.dx := m4;
  intr($33, regs);
END;


PROCEDURE Mouse_reset;
BEGIN
  Mouse(0, 0, 0, 0);
END;


FUNCTION  Mouse_exists : Boolean;
Var
    ms           : Pointer;
    msseg, msoff : Word;
    ad           : Byte;
BEGIN
  msseg := MemW[$00:($33 * 4 + 2)];
  msoff := MemW[$00:($33 * 4)];
  ms := Ptr(msseg, msoff);
  ad := Mem[msseg:msoff];

  if ( (ms <> Nil)  and (ad <> $CF)) then
      Mouse_Exists := TRUE
  else
      Mouse_Exists := FALSE;
END;


PROCEDURE Mouse_show;
BEGIN
  if ( Mouse_exists ) then
     Mouse(1, 0, 0, 0);
END;


PROCEDURE Mouse_hide;
BEGIN
  if ( Mouse_exists ) then
     Mouse(2, 0, 0, 0);
END;


FUNCTION  Mouse_down : Integer;
BEGIN
  if ( Mouse_exists ) then
     Mouse(3, 0, 0, 0);
  Mouse_Down := (regs.bx and 3);
END;


FUNCTION Mouse_up : Integer;
BEGIN
  if ( Mouse_exists ) then
     Mouse(6, 0, 0, 0);
  Mouse_Up := regs.bx ;
END;

PROCEDURE Mouse_getpos(var mx, my : Integer);
BEGIN
  if ( Mouse_exists ) then
     Mouse (3, 0, 0, 0);
  mx := (regs.cx div 8) + 1;
  my := (regs.dx div 8) + 1;
END;

PROCEDURE Mouse_setpos(mx, my : Integer);
BEGIN
  if ( Mouse_exists ) then
     Mouse(4, 0, (mx - 1) * 8, (my - 1) * 8);
END;

END. { of Unit }


