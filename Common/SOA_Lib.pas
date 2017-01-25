{v0.57}
//������� 04.10.2003
//������ SOA_Lib ��� ������ � �� BDE + CashUpdates
//soft_of_AVI (C) 2003

unit SOA_Lib;

interface
uses
  DB, Windows, SysUtils, DBTables, DBGrids, RxStrUtils, DateUtil,Classes, Forms;

const
  slRus = 0;	   // ��������� ��������� ����������
  slEng = 1;

  gndBeforeDay = 0;   // ���������� ����
  gndAfterDay = 1;    // ��������� ����

var
  slCurrID : string; // ������� ��� ����������� ���� �������

  slProgrammPath: string; // ���������� ���� � ���������

procedure TextOutToCell(Grid: TDBGrid; Rect: TRect; Column: TColumn);                //������� ����� � ������� (����� ���� WordWrap)
procedure RefreshQueryMy(Database: TDataBase; Dataset : TDataSet; KeyField : string);//�������� ������, �������� �������
procedure ApplyUpdatesQueryMy(Database: TDataBase; Query: TQuery);	             //�������� ��� � ���� ������ ��� �������
procedure ApplyUpdatesStoredMy(Database: TDataBase; StoredProc: TStoredProc);        //�������� ��� � ���� ������ ��� �������� ���������
procedure SetLayout(slLayout: integer);                                              //���������� ��������� ����������
 function GetLayout: integer;                                     //��������� ��������� ����������
 function CheckINN(INN: String): integer;                         //��������� ���
 function CheckPensNum(PenNum:string):integer;                    //��������� ����. �����
 function LogInFromCmd(DataBase: TDataBase):string;               //��������� LOG IN �� ��������� ������
 function GetLastDayOfMonth(Date: TDateTime): TDateTime;          //��������� ���� ������
 function GetNextDay(Date: TDateTime; IncDec: byte): TDateTime;   //���������/����������� ����
 function GetNMonth(vMonth, vYear: integer): integer;             //�������� nmonth ����������
 function GetNMonthYear(vNMonth: integer): integer;                //�������� ��� �� nmonth ����������
 function GetNMonthMonth(vNMonth, vYear: integer): integer;        //�������� ����� �� nmonth ����������
 function TwoNumber(n: integer): string; 
 function DateToStrMy(vDate: TDateTime): string;
 function StrToDateMy(vDate: string): TDateTime;
 function ExtractFilePathWiwoutBin(AApp: TApplication): string;    //�������� ���� � ��������� �� EXE � BIN
implementation


procedure TextOutToCell(Grid: TDBGrid; Rect: TRect; Column: TColumn);
 begin
 with Grid.Canvas do
  case Column.Alignment of
   taRightJustify: TextRect(Rect, Rect.Right - 3 - Grid.Canvas.TextWidth(Column.Field.Text),Rect.Top + 2,Column.Field.Text);
   taLeftJustify:  TextRect(Rect, Rect.Left + 2,Rect.Top+2,Column.Field.Text);
   taCenter:       TextRect(Rect, Rect.Left + ( (Rect.Right - Rect.Left) div 2 - Grid.Canvas.TextWidth(Column.Field.Text) div 2 ), Rect.Top+2,Column.Field.Text);
 end;
end;


procedure RefreshQueryMy(Database: TDataBase; Dataset : TDataSet; KeyField : string);  //�������� ������, �������� �������
var       CurID : string;
begin
DataSet.Open;
  {���� ������ �� ������ ��� ������� ����� ��� �� 3 �����}
  if (not DataSet.IsEmpty) and (DataSet.RecordCount>0) and (slCurrID ='')
    then CurID := DataSet.FieldByName(KeyField).AsString
    else CurID := slCurrID;

   DataSet.Active := False;
   DataSet.Active := True;

   if CurID<>'' then DataSet.Locate(KeyField, CurID, []);
end;
procedure SetLayout(slLayout: integer);
var
 Layout: array[0.. KL_NAMELENGTH] of char;
begin
 case slLayout of
 slRus: LoadKeyboardLayout( StrCopy(Layout,'00000419'),KLF_ACTIVATE);
 slEng: LoadKeyboardLayout(StrCopy(Layout,'00000409'),KLF_ACTIVATE);
 end;
end;

function GetLayout: integer;
var
 Layout: array[0.. KL_NAMELENGTH] of char;
 glStr: string;
 grResult: integer;
begin
  grResult := 1;
  GetKeyboardLayoutName(Layout);
  glStr := Layout;
  if glStr = '00000419' then grResult := slRus;
  if glStr = '00000409' then grResult := slEng;
  GetLayout := grResult;
end;

{
��������� ������������ ���
���������� 0 - ��
           1 - � 10-�� ��������� ��� ������
           2 - � 12-�� ��������� ��� ������
           3 - � 12-�� ��������� ��� ������
           4 - ���������� ���� � ��� ��������
}

function CheckINN(INN: String): integer;
type
    TINNCo = array[1..12] of Byte;
const
    INN10: TINNCo = (2, 4, 10, 3, 5, 9, 4, 6, 8, 0, 0, 0);
    INN12_1: TINNCo = (7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0, 0);
    INN12_2: TINNCo = (3, 7, 2, 4, 10, 3, 5, 9, 4, 6, 8, 0);
var
    INNB: TINNCo;
    i: Integer;
function GetINNCheckSum(INN: TINNCo; Co: TINNCo; CoLen: Byte): Integer;
var
    i: Integer;
begin
    Result := 0;
    for i := 1 to CoLen do
        Inc(Result, INN[i]*Co[i]);
    Result := Result mod 11;
    Result := Result mod 10;
end;
begin
    INN := Trim(INN);
    CheckINN := 0;
    try
    // �������� ����� ��� (10 ���� 12)
        if (Length(INN) in [10, 12]) then
					begin
          // ������ ���� ��� ��, �� ��������� ������ � ������ ����
		        for i := 1 to High(INNB) do
    		        if i <= Length(INN) then INNB[i] := StrToInt(INN[i]) else	INNB[i] := 0;

        if Length(INN) = 10 then
        begin
            if StrToInt(INN[10]) <> GetINNCheckSum(INNB, INN10, 9) then
             begin
//              MessageDlg('� 10-�� ��������� ��� ������', mtError, [mbOK],0);
					    CheckINN := 1;
             end;
        end
        else
        begin
            i := GetINNCheckSum(INNB, INN12_1, 10);
            if StrToInt(INN[11]) <> i then
              begin
  //              MessageDlg('� 12-�� ��������� ��� ������', mtError, [mbOK],0);
 	  				    CheckINN := 2;
              end
            else
            begin
                INNB[11] := i;
                if StrToInt(INN[12]) <> GetINNCheckSum(INNB, INN12_2, 11) then
                 begin
//                    MessageDlg('� 12-�� ��������� ��� ������', mtError, [mbOK],0);
      					    CheckINN := 3;
                 end;
            end;
        end;
          // �����  ���� ��� ��, �� ��������� ������ � ������ ����
          end
        else
          begin
          // ������ ���� ��� �����, �� ������� ������ �� ������
//           MessageDlg('���������� ���� � ��� ��������', mtError, [mbOK],0);
           CheckINN := 4;
          // ����� ���� ��� �����, �� ������� ������ �� ������
         end;

      //  Result := True
    except
//        Result := False
    end;
 end;
{
��������� ������������ ����������� ������
���������� 0 - ��
					 1 - ������
}
function CheckPensNum(PenNum:string):integer;
var InSum, ControlNum: string;
	  i, inv, cnv,errCode, Sum, icnv: integer;

begin
  ControlNum := '987654321';                   {����������� �����}
       InSum := copy(PenNum,length(PenNum)-1,2); {����������� ����� �����}
                Val(InSum, icnv, errCode);     {�� ������ -> �����}
         Sum := 0;                             {������� �����}
     for i:=1 to length(PenNum)-1 do
       begin
               Val(PenNum[i], inv, errCode);    {�� ������ -> �����}
          Val(ControlNum[i], cnv, errCode);    {�� ������ -> �����}
          sum := sum+ (inv * cnv);             {�������������}
       end;                                    {������� ������� �� ������� �� 101}
       sum := sum mod 101;
       if (sum = icnv) and (length(PenNum)=11) then CheckPensNum := 0 else CheckPensNum := 1;
end;

function LogInFromCmd(DataBase: TDataBase):string;
  var dbname, usr, psw:string[30];
begin
	DataBase.Connected:=false;
	DataBase.Close;
  DataBase.Params.Clear;
  DataBase.LoginPrompt:=false;

  dbname:=GetCmdLineArg('DB', ['/','-']);
  if length(dbname)>0 then DataBase.AliasName := dbname;

  usr:=GetCmdLineArg('usr', ['/','-']);
  if length(usr)>0 then DataBase.Params.Add('USER NAME='+usr)
  									else DataBase.LoginPrompt:=true;
  if (not DataBase.LoginPrompt)then
  begin
  	psw:=GetCmdLineArg('psw', ['/','-']);
	  if (length(psw)>0) then DataBase.Params.Add('PASSWORD='+psw)
    										else DataBase.LoginPrompt:=true;
  end;
	DataBase.Open;
  Result := usr;
end;

function GetLastDayOfMonth(Date: TDateTime): TDateTime;
var Day, Month, Year : word;
    LastDay : integer;
begin
  LastDay := 31;
  DecodeDate(Date, Year, Month, Day);
  while (StrToDate('01.01.1900') = ( StrToDateFmtDef('dd.mm.yyyy', IntToStr(LastDay) +'.'+ IntToStr(Month) +'.'+ IntToStr(Year), StrToDate('01.01.1900')) ))
			and (LastDay>28) do
    begin
      LastDay := LastDay - 1;
    end;
  Result := StrToDate( IntToStr(LastDay) +'.'+ IntToSTr(Month) +'.'+ IntToStr(Year) );

end;

function GetNextDay(Date: TDateTime; IncDec: byte): TDateTime;
var Day, Month, Year : word;
    lDay, lMonth, lYear: word;
begin
  DecodeDate(Date, Year, Month, Day);

case IncDec of

0: begin
  Day := Day - 1;

   if Day <1 then
     begin
      Day := 1;
      Month := Month - 1;
      if Month < 1 then
        begin
         Month := 12;
         Year := Year - 1;
       end;

      Date := StrToDate( IntToStr(01) +'.'+ IntToSTr(Month) +'.'+ IntToStr(Year) );
      Date := GetLastDayOfMonth(Date);
      DecodeDate(Date, Year, Month, Day);
    end;
   end;
1: begin
  Day := Day + 1;

  DecodeDate(Date, lYear, lMonth, lDay);

   if Day >lDay then
     begin
      Day := lDay;
      Month := Month + 1;
      if Month > 12 then
        begin
         Month := 1;
         Year := Year + 1;
       end;
     end;
   end;
 end;
  Result := StrToDate( IntToStr(Day) +'.'+ IntToSTr(Month) +'.'+ IntToStr(Year) );

end;

procedure ApplyUpdatesQueryMy(Database: TDataBase; Query: TQuery);
begin
    Database.StartTransaction;
    try
      if not (Database.IsSQLBased)
         and not (Database.TransIsolation = tiDirtyRead)
         then
           Database.TransIsolation := tiDirtyRead;
           Query.ApplyUpdates;
           Database.Commit;
    except
      Database.Rollback;
      raise;
    end;
    Query.CommitUpdates;
end;

procedure ApplyUpdatesStoredMy(Database: TDataBase; StoredProc: TStoredProc);
begin
    Database.StartTransaction;
    try
      if not (Database.IsSQLBased)
         and not (Database.TransIsolation = tiDirtyRead)
         then
           Database.TransIsolation := tiDirtyRead;
           StoredProc.ApplyUpdates;
           Database.Commit;
    except
      Database.Rollback;
      raise;
    end;
    StoredProc.CommitUpdates;
end;

function GetNMonth(vMonth, vYear: integer): integer;
begin
  Result := 12 * vYear + vMonth - 1;
end;

function GetNMonthYear(vNMonth: integer): integer;
begin
  Result := Round((vNMonth + 1)/12);
end;

function GetNMonthMonth(vNMonth, vYear: integer): integer;
begin
  Result := vNMonth - 12 * vYear + 1;
end;

function TwoNumber(n: integer): string;
var t: string;
    l: integer;
begin
  str(n, t);
  l := length(t);
  TwoNumber := Copy('00', 1, 2-l) + t;
end;


function StrToDateMy(vDate: string): TDateTime;
var d, m, y: word;
begin
  Result := 0;
  if length(vDate) < 10 then Exit;
  {dd.mm.yyyy}
  d := StrToInt(Copy(vDate, 1, 2));
  m := StrToInt(Copy(vDate, 4, 2));
  y := StrToInt(Copy(vDate, 7, 4));
  Result := EncodeDate(y, m, d);
end;

function DateToStrMy(vDate: TDateTime): string;
var d, m, y: word;
begin
  {dd.mm.yyyy}
  DecodeDate(vDate, y, m, d);
  Result := TwoNumber(d)+'.'+TwoNumber(m)+'.'+TwoNumber(y);
end;


function ExtractFilePathWiwoutBin(AApp: TApplication): String;
// In  - C:\Prog\Bin\File.exe
// Out - C:\Prog\
begin
 slProgrammPath := Copy(ExtractFilePath(AApp.ExeName), 1, Length(ExtractFilePath(AApp.ExeName))-4);
 Result := slProgrammPath;
end;

end.
