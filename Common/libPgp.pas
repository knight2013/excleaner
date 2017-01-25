unit libPgp;


interface

uses SysUtils;

const
  pgpKey1  = 'ff63454623456234abc23cda523445345a5235c345cddae4a34afc32314cf5f'+
             'ff63454623456234cbc23cda523445345a5235c345cddae4a34afc32314cf5f'+
             'ff63454623456234fbc23cda523445345a5qwer345cddae4a34afc32314cf5f'+
             'ba523f2342aa34cc234123a4fffa523fcf4231afaffaacc334554ff22aaccbb2';
  pgpKey2  = 'cd6341514162341412131513141252141351213141514411ff1521f5f314cf5f'+
             'f54645dd5d4d6d6d5d62d3d4dacdc23dfdddfd5d2f4fd53df5dad5d23d14cf5f'+
             'd363454623456234cbc23cdf523f453f5a52f5f345fddae4a2323432314cf5f'+
             'ba523f2343a432c3434123a4ffacf234ac231a546456456456c66652aaccbb2';

  chrDivide = ';';


  function GetNextWord(s: string; c: integer; var ResStr: string): integer;
  function CharToChar(ch: char; sh: byte; Key: string): char;
  function StrToStr(s: string; Key: string): string;
 

implementation


function GetNextWord(s: string; c: integer; var ResStr: string): integer;
var
  i, bs, es, ms : integer;
  t : string;
begin
  bs := c;
  ms := length(s);
  es := ms;

  // найдем начало слова
  for i := c to length(s) do
    if (s[i] <> chrDivide) and (s[i] <> ' ') and (s[i] <> #$D) and (s[i] <> #$A) then
      begin
        bs := i;
        break;
      end;

  // найдем маркер конца слова
  for i := bs to length(s) do
     if (i<>bs) and ( (s[i] = chrDivide) or (i=length(s)) ) then
       begin
         ms := i;
         break;
       end;
  // найдем конец слова
  for i := ms downto bs do
    if ( (s[i] <> chrDivide) and (s[i] <> ' ') and (s[i] <> #$D) and (s[i] <> #$A)  ) then
      begin
        es := i;
        break;
      end;

  ResStr := Trim(Copy(s, bs , es - bs + 1));
  Result := ms;
end;


//  Шифрование симвода в строке
function CharToChar(ch: char; sh: byte; Key: string): char;
var b: byte;
begin
  b := Ord(ch);
  Result := Chr(b xor StrToInt('$'+Key[sh]));
end;

//  Шифрование строки
function StrToStr(s: string; Key: string): string;
var i : integer;
    r : string;
begin
    r := '';
  for i := 1 to length(s) do
    r := r + CharToChar(s[i], i, Key);
  Result := r;
end;


begin
end.
