unit frmMainUn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, StrUtils, IniFiles, ShellApi, XPMan,
  RxGIF, libLinks, libPgp, ComCtrls, StrHlder, Animate, GIFCtrl, frmLangUn;


const
  CM_BTNCANCEL = WM_APP + 400;


type
  TArray = array of string;

type
  TfrmMain = class(TForm)
    btnClear: TButton;
    btnExit: TButton;
    Bevel1: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    cbxSubFolders: TCheckBox;
    cbxDir: TCheckBox;
    cbxReadOnly: TCheckBox;
    cbxEmptyRecycled: TCheckBox;
    Bevel2: TBevel;
    XPManifest1: TXPManifest;
    cbxSkipMarked: TCheckBox;
    cbxDeleteToRecycled: TCheckBox;
    memExt: TStrHolder;
    memDir: TStrHolder;
    memMark: TStrHolder;
    lblEditExt: TLabel;
    lblEditFoldersForClean: TLabel;
    lblEditMark: TLabel;
    lblDeleteFolders: TLabel;
    memDeleteFolders: TStrHolder;
    RxGIFAnimator1: TRxGIFAnimator;
    lblEditLang: TLabel;
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Label2Click(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure CMBtnCancel(var Message: TMessage); message CM_BTNCANCEL;
    procedure btnEditExtClick(Sender: TObject);
    procedure btnEditFoldersForCleanClick(Sender: TObject);
    procedure btnEditMarkClick(Sender: TObject);
    procedure lblDeleteFoldersClick(Sender: TObject);
    procedure lblEditLangClick(Sender: TObject);
    procedure lblEditExtMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblEditExtMouseLeave(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure FullClear;
    procedure DeleteFiles (CurrDir: String; CurrExt: TStrings);
    procedure DeleteFiles2(CurrDir: String; CurrExt: TStrings);
    procedure DeleteEmptyDirectoryes(CurrDir: TStrings);
    procedure ClearDirectories(DirList: TStrings);
    procedure BtnCancelDetect;
     function GetDirectoryList(BeginDir: string; var DirectoryArray : TArray): integer;
     function GetStringsFromIni(AIniFile: TIniFile; AOptions: string; AStrings: TStrings): integer;
     function SetStringsFromIni(AIniFile: TIniFile; AOptions: string; AStrings: TStrings): integer;
    procedure EmptyRecycled;
    procedure RefreshCaptions;
    procedure OpenEditor(ATag: integer; ACaption: String; ATStrings: TStrings);
    function GetFreeSpaceOnDisk: Int64;
  end;

const
  cAppName = 'ExCleaner';

function SHEmptyRecycleBin(Wnd:HWND; pszRootPath:PChar; dwFlags:DWORD):HRESULT; stdcall;

var
  frmMain: TfrmMain;
  vShowWarning : boolean = True;
  vShowErrors : boolean = True;
  vLang: string = 'russian.ini';
  vLengthMark : byte = 7;

  cFileExtensionForDelete : string = 'Расширения удаляемых файлов';
  cFoldersForClearing : string = 'Очищаемые папки';
  cIncludeSubFolders : string = 'Вложенные папки';
  cClearSpecFolder: string = 'Очищать папки';
  cIncludeReadOnly : string = 'Файлы Только чтение';
  cEmptyRecycled : string = 'Очистить корзину';
  cSkipMarked : string = 'Пропускать по отпечатку';
  cClear : string = 'Очистить';
  cExit : string = 'Выход';
  cCancel : string = 'Отмена';
  cFoldersIsClearingNow : string = 'Папки очищаются...';
  cAYouReadyToDelete : string = 'Вы точно хотите удалить все файлы из папки';
  cSearching : string = 'Поиск...';
  cErrorOndeleting : string = 'Ошибка при удалении';
  cFolder : string = 'Папка';
  cNotExists : string = 'не существует';
  cEmptyRecycledNow : string = 'Очищаю корзину...';
  cFileMarkToSkip : string = 'Отпечаток нужных файлов';
  cSkipForMarkedFiles : string = 'Пропуск файла по отпечатку';
  cDeleteToRecycled : string = 'Удалять в корзину';

  cAdd : string = 'Добавить';
  cDelete : string = 'Удалить';
  cEdit : string = 'Изменить';
  cEditThisListBox : string = 'Отредактируйте данные в окне';
  cStringToEdit : string = 'Строка для редактирования';
  cDeleteFolders : string = 'Удаление папок';

  cChoiceLang : string = 'Выберите язык(RUS)';

implementation

uses frmDelUn, frmEditorUn, uVersion;

{$R *.DFM}

function TfrmMain.GetFreeSpaceOnDisk: Int64;
var FreeSize: Int64;
    i: byte;
    RootPath: PAnsiChar;
    RootStr: string;
begin

  Result := 0;

  for i := 1 to 254 do
  begin
     RootStr := String( Chr( Ord('a') + i  - 1) + ':');
     RootPath := PAnsiChar( RootStr ) ;
     if (GetDriveType( RootPath ) = DRIVE_FIXED) or (GetDriveType( RootPath ) = DRIVE_RAMDISK) then
     begin
        Result := Result + DiskFree(i);
     end;
  end;

end;


function SHEmptyRecycleBin; external shell32 name 'SHEmptyRecycleBinA';

function TfrmMain.GetStringsFromIni(AIniFile: TIniFile; AOptions: string; AStrings: TStrings): integer;
var vCount, i: integer;
begin
  AStrings.Clear;
  vCount := AIniFile.ReadInteger(AOptions, 'Count', 0);
  for i := 0 to vCount - 1 do  AStrings.Add( AIniFile.ReadString(AOptions, 'Item[' + IntToStr(i) + ']', '') );
  Result := vCount;
end;

function TfrmMain.SetStringsFromIni(AIniFile: TIniFile; AOptions: string; AStrings: TStrings): integer;
var i: integer;
begin

  AIniFile.WriteInteger(AOptions, 'Count', AStrings.Count);
  for i := 0 to AStrings.Count - 1 do AIniFile.WriteString(AOptions, 'Item[' + IntToStr(i) + ']', AStrings[i]) ;
  Result := AStrings.Count;
end;

procedure TfrmMain.EmptyRecycled;
begin
 SHEmptyRecycleBin(0,nil,1 or 4);
end;

// Get directory list and return count directory
function TfrmMain.GetDirectoryList(BeginDir: string; var DirectoryArray: TArray ): integer;
var
   TempDirectoryArray, _TempDirectoryArray: TArray;
   CurrDir: string;
   SearchRec: TSearchRec;
   i, tCount, _tCount, dCount : integer;
begin
   CurrDir := BeginDir;
   tCount := 0;
   _tCount := 0;
   dCount := 0;

   SetLength(TempDirectoryArray, dCount + 1);
   SetLength(_TempDirectoryArray, dCount + 1);

   _TempDirectoryArray[tCount] := CurrDir;
   inc(_tCount);
      repeat

        for i := 0 to _tCount - 1 do
          begin

            SetLength(TempDirectoryArray, dCount + 1);
            SetLength(DirectoryArray, dCount + 1);

            DirectoryArray[ dCount ] := _TempDirectoryArray[i];
            TempDirectoryArray[tCount] := _TempDirectoryArray[i];
           inc(dCount);
           inc(tCount);
        end;
        _tCount := 0;

        for i := 0 to tCount -1 do
          begin
           FindFirst(TempDirectoryArray[i]+'\*.*', faDirectory + faSysFile + faArchive + faHidden + SysUtils.faReadOnly, SearchRec);
             repeat

             frmDel.ShowProcessWindow(cSearching);
{              if Application.FindComponent('frmDel') <> nil then
                  begin
                    frmDel.pnlDirectory.Caption := cSearching;
                    frmDel.pnlDirectory.Repaint;
                    BtnCancelDetect;
                   end;}

              if (not FileExists( TempDirectoryArray[i]+'\'+SearchRec.Name)) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
                begin
                   SetLength(_TempDirectoryArray, _tCount + 1);

                  _TempDirectoryArray[_tCount]:= TempDirectoryArray[i]+'\'+SearchRec.Name;
                  inc(_tCount);
                end;
            until FindNext(SearchRec) <> 0;
            FindClose(SearchRec);
          end;
          tCount := 0;
      until (_tCount = 0) {or (_tCount >= MAX_COUNT_DIRECTORY) or (dCount >= MAX_COUNT_DIRECTORY)};

{ if (_tCount >= MAX_COUNT_DIRECTORY) or (dCount >= MAX_COUNT_DIRECTORY)
   then ShowMessage('Count directories > MAX_COUNT_DIRECTORY ('+IntToStr(MAX_COUNT_DIRECTORY)+')');}

   Result := dCount;
end;

//Проверка на отпечаток файла и на его доступнсть
//
//0 - файл НЕ сходен по отпечатку
//1 - файл ходен по отпечатку
//2 - ошибка обращения к файлу
//
function IsFileSkipped(AFileName, AExt: string): byte;
var IniFile: TIniFile;
    ReturnValue: string;
    i: integer;
    strhex1: string[2];
    strhex2: char;
    TempFile: Text;
begin
   Result := 0;
   Assign(TempFile, AFileName);
   {$I-}
   Reset(TempFile);
   if IOResult <> 0
    then begin
        {$I+}
        Result := 2;
        Exit;
    end;


   IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\mark.ini');
   ReturnValue := IniFile.ReadString('Main', AExt, 'empty');
   if ReturnValue <> 'empty' then
   begin
     for i := 1 to length(ReturnValue) - 1 do
       begin
         strhex1 := copy(ReturnValue, (i-1) * 3 + 2, 2);
         Read(TempFile, strhex2);
         if strhex1 = '' then Break;
         if StrToInt('$'+strhex1) = Ord(strhex2)
           then Result := 1
           else begin
                 Result := 0;
                 Break;
                end;

       end;
   end;

   CloseFile(TempFile);
   IniFile.Free;
end;

procedure TfrmMain.DeleteFiles(CurrDir: String; CurrExt: TStrings);
var vmemExt, vcurExt: string;
    vCountChar: integer;
    SearchRec: TSearchRec;
    bIsSkipped: byte;

    vNumExt: integer;

begin

  frmDel.ShowProcessWindow(CurrDir);
{  if Application.FindComponent('frmDel') <> nil then
    begin
     frmDel.pnlDirectory.Caption := CurrDir;
     frmDel.pnlDirectory.Repaint;
     BtnCancelDetect;
    end;}

  if CurrExt.Count  = 0 then Exit;
  for vNumExt := 0 to CurrExt.Count  - 1 do
  begin
    //vCountChar := GetNextWord(vmemExt, vCountChar, vcurExt) + 1;
    //FindFirst(CurrDir + '\' +vcurExt, faAnyFile, SearchRec);
    FindFirst(CurrDir + '\' +CurrExt[vNumExt], faAnyFile, SearchRec);
    repeat
      if FileExists(CurrDir + '\' + SearchRec.Name) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
       begin
        if cbxReadOnly.Checked then
         if GetFileAttributes(PChar(CurrDir + '\' + SearchRec.Name)) <> FILE_ATTRIBUTE_NORMAL then
           SetFileAttributes(PChar(CurrDir + '\' + SearchRec.Name), FILE_ATTRIBUTE_NORMAL);

        //Поиск отпечатка
        bIsSkipped := IsFileSkipped(CurrDir + '\' + SearchRec.Name, CurrExt[vNumExt]);
        if (bIsSkipped = 1) and  cbxSkipMarked.Checked
          then
            begin
              if vShowWarning then ShowMessage(cSkipForMarkedFiles + ': ' + SearchRec.Name + ' (' + CurrExt[vNumExt] + ')!')
            end
          else
             //Фйл доступен
             if (bIsSkipped <> 2) then
               begin
                 //Удаление в корзину
                 if cbxDeleteToRecycled.Checked
                   then ToRecycle(0, CurrDir + '\' + SearchRec.Name)
                   else DeleteFile(CurrDir + '\' + SearchRec.Name);
               end;

          if FileExists(CurrDir + '\' + SearchRec.Name) then
            begin
               if vShowWarning then  ShowMessage(cErrorOndeleting + ' '+CurrDir + '\' +SearchRec.Name);
            end;
       end;
    until FindNext(SearchRec) <> 0;
    FindClose(SearchRec);
    SearchRec.Name := '';
  end;
end;

procedure TfrmMain.DeleteEmptyDirectoryes(CurrDir: TStrings);
var i: integer;
   sr: TSearchRec;
begin
for i := 0 to CurrDir.Count - 1 do
begin

    if DirectoryExists(CurrDir[i]) then
      begin
       //Удаление в корзину
       if cbxDeleteToRecycled.Checked
         then ToRecycle(0, CurrDir[i])
         else RemoveDir(CurrDir[i]);
      end
    else
       if vShowWarning then ShowMessage(cErrorOndeleting + ' ' + CurrDir[i]);


  if DirectoryExists(CurrDir[i]) then
   begin
     if vShowWarning then ShowMessage(cErrorOndeleting + ' '+CurrDir[i]);
   end;
end;
end;

procedure TfrmMain.ClearDirectories(DirList: TStrings);
var
   DirectoryArray : TArray;
   i,vCountChar : integer;
   vmemDir, vcurDir: string;

   vNumDir: integer;

   vMaskAll: TStringList;
begin

  vMaskAll := TStringList.Create;
  vMaskAll.Add('*.*');

  if DirList.Count = 0 then Exit;
  for vNumDir := 0 to DirList.Count - 1 do
  begin
    //vmemDir := DirList;
    //vCountChar := GetNextWord(vmemDir, vCountChar, vcurDir) + 1;
    if DirectoryExists(DirList[vNumDir]) then
      begin
        for i := GetDirectoryList(DirList[vNumDir], DirectoryArray) - 1 downto 0  do
          begin
            DeleteFiles2(DirectoryArray[i], vMaskAll);

          if i>0 then
            begin
              if cbxReadOnly.Checked then
               if GetFileAttributes(PChar(DirectoryArray[i])) <> FILE_ATTRIBUTE_NORMAL then
                 SetFileAttributes(PChar(DirectoryArray[i]), FILE_ATTRIBUTE_NORMAL);
              RemoveDir(PCHar(DirectoryArray[i]));
            end;
          end
       end
    else
      begin
        if vShowWarning then ShowMessage(cFolder + ' ' + DirList[vNumDir] + ' ' + cNotExists);
      end;
  end;
  vMaskAll.Free;

end;

procedure TfrmMain.DeleteFiles2(CurrDir: String; CurrExt: TStrings);
var
   DirectoryArray : TArray;
   i : integer;
begin
    for i := 0 to GetDirectoryList(CurrDir, DirectoryArray) - 1 do
      DeleteFiles(DirectoryArray[i], CurrExt);
end;

procedure TfrmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;


procedure TfrmMain.FullClear;
var FreeSize : Longint;
begin
  frmDel := TfrmDel.Create(Application);
  frmDel.Caption := frmMain.Caption;
  frmDel.Show;
  frmDel.Repaint;

  if not cbxSubFolders.Checked
      then DeleteFiles(GetCurrentDir, memExt.Strings)
      else DeleteFiles2(GetCurrentDir, memExt.Strings);

        if cbxDir.Checked then
         begin
           if vShowWarning then
               if MessageBox(frmDel.Handle, PChar(cAYouReadyToDelete+': ' +#13+ memDir.CommaText+#13+ memDeleteFolders.CommaText), PChar(Application.Title), MB_YESNO) = ID_YES
                 then
                   begin
                     ClearDirectories(memDir.Strings);
                     ClearDirectories(memDeleteFolders.Strings);
                     DeleteEmptyDirectoryes(memDeleteFolders.Strings);
                   end;

           if not vShowWarning
             then
               begin
                 ClearDirectories(memDir.Strings);
                 ClearDirectories(memDeleteFolders.Strings);
                 DeleteEmptyDirectoryes(memDeleteFolders.Strings);
               end;

         end;//***if cbxDir.Checked then

  if cbxEmptyRecycled.Checked then
    begin

      frmDel.ShowProcessWindow(cEmptyRecycledNow);

{     frmDel.pnlDirectory.Caption := cEmptyRecycledNow;
      frmDel.Repaint;}

      EmptyRecycled;
    end;
  frmDel.Free;
end;

function GetCountStrings(AStrings: TStrings): String;
begin
  Result := ' (' + IntToStr(AStrings.Count) + ')';
end;

function AddReturnChar(AStr: string): string;
begin
  Result := AnsiReplaceStr(AStr, '|', #$0A#$0D);
end;

procedure TfrmMain.RefreshCaptions;
begin

  lblEditExt.Caption := AddReturnChar(cFileExtensionForDelete + GetCountStrings(memExt.Strings));
  lblEditFoldersForClean.Caption := AddReturnChar(cFoldersForClearing + GetCountStrings(memDir.Strings));
  lblEditMark.Caption := AddReturnChar(cFileMarkToSkip + GetCountStrings(memMark.Strings));
  lblDeleteFolders.Caption := AddReturnChar(cDeleteFolders + GetCountStrings(memDeleteFolders.Strings));

  cbxSubFolders.Caption := AddReturnChar(cIncludeSubFolders);
  cbxDir.Caption := AddReturnChar(cClearSpecFolder);
  cbxReadOnly.Caption := AddReturnChar(cIncludeReadOnly);
  cbxEmptyRecycled.Caption := AddReturnChar(cEmptyRecycled);
  cbxSkipMarked.Caption := AddReturnChar(cSkipMarked);
  cbxDeleteToRecycled.Caption := AddReturnChar(cDeleteToRecycled);
  btnClear.Caption := AddReturnChar(cClear);
  btnExit.Caption := AddReturnChar(cExit);

  lblEditLang.Caption :=  AddReturnChar(cChoiceLang);
end;

procedure LoadInterface;
var
    IniFile: TIniFile;
    TempFile: System.Text;
    TempStr : string;
    i, vCountMem: integer;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\ExCleaner.ini');
  vLang := IniFile.ReadString('Options', 'Language', 'russian');
  IniFile.Free;

  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\'+vLang+'.lang');
  cFileExtensionForDelete := IniFile.ReadString('Interface', 'FileExtensionForDelete', cFileExtensionForDelete);
  cFoldersForClearing := IniFile.ReadString('Interface', 'FoldersForClearing', cFoldersForClearing);
  cIncludeSubFolders := IniFile.ReadString('Interface', 'IncludeSubFolders', cIncludeSubFolders);
  cClearSpecFolder := IniFile.ReadString('Interface', 'ClearSpecFolder', cClearSpecFolder);
  cIncludeReadOnly := IniFile.ReadString('Interface', 'IncludeReadOnly', cIncludeReadOnly);
  cEmptyRecycled := IniFile.ReadString('Interface', 'EmptyRecycled', cEmptyRecycled);
  cSkipMarked := IniFile.ReadString('Interface', 'SkipMarked', cSkipMarked);
  cClear := IniFile.ReadString('Interface', 'Clear', cClear);
  cExit := IniFile.ReadString('Interface', 'Exit', cExit);
  cCancel := IniFile.ReadString('Interface', 'Cancel', cCancel);
  cFoldersIsClearingNow := IniFile.ReadString('Interface', 'FoldersIsClearingNow', cFoldersIsClearingNow);
  cAYouReadyToDelete := IniFile.ReadString('Interface', 'AYouReadyToDelete', cAYouReadyToDelete);
  cSearching := IniFile.ReadString('Interface', 'Searching', cSearching);
  cErrorOndeleting := IniFile.ReadString('Interface', 'ErrorOndeleting', cErrorOndeleting);
  cFolder := IniFile.ReadString('Interface', 'Folder', cFolder);
  cNotExists := IniFile.ReadString('Interface', 'NotExists', cNotExists);
  cEmptyRecycledNow := IniFile.ReadString('Interface', 'EmptyRecycledNow', cEmptyRecycledNow);
  cFileMarkToSkip := IniFile.ReadString('Interface', 'FileMarkToSkip', cFileMarkToSkip);
  cSkipForMarkedFiles := IniFile.ReadString('Interface', 'SkipForMarkedFiles', cSkipForMarkedFiles);
  cDeleteToRecycled := IniFile.ReadString('Interface', 'DeleteToRecycled', cDeleteToRecycled);

  cAdd := IniFile.ReadString('Interface', 'Add', cAdd);
  cDelete := IniFile.ReadString('Interface', 'Delete', cDelete);
  cEdit := IniFile.ReadString('Interface', 'Edit', cEdit);
  cEditThisListBox := IniFile.ReadString('Interface', 'EditThisListBox', cEditThisListBox);
  cStringToEdit := IniFile.ReadString('Interface', 'EditThisListBox', cEditThisListBox);
  cDeleteFolders := IniFile.ReadString('Interface', 'DeleteFolders', cDeleteFolders);

  cChoiceLang := IniFile.ReadString('Interface', 'ChoiceLang', cChoiceLang);

  IniFile.Free;


end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
    IniFile: TIniFile;
    TempFile: System.Text;
    TempStr : string;
    i, vCountMem: integer;
begin
  Application.Title := cAppName + ' ' + GetVersionStr(1);
  Caption := Application.Title;
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\ExCleaner.ini');
  cbxSubFolders.Checked := IniFile.ReadBool('Options', 'Clearing subfolders', False);
  cbxDir.Checked := IniFile.ReadBool('Options', 'Clearing directoryes', False);
  cbxReadOnly.Checked := IniFile.ReadBool('Options', 'Delete read only', False);
  cbxEmptyRecycled.Checked := IniFile.ReadBool('Options', 'Empty Recycled Bin', False);
  cbxSkipMarked.Checked := IniFile.ReadBool('Options', 'Skip Marked', False);
  cbxDeleteToRecycled.Checked :=  IniFile.ReadBool('Options', 'Delete To Recycled', False);
  vShowWarning := IniFile.ReadBool('Options', 'Show warning', True);
  vShowErrors := IniFile.ReadBool('Options', 'Show errors', True);
  vLang := IniFile.ReadString('Options', 'Language', 'russian');
  vLengthMark := IniFile.ReadInteger('Options', 'Length mark', 7);

  GetStringsFromIni(IniFile, 'memExt', memExt.Strings);
  GetStringsFromIni(IniFile, 'memDir', memDir.Strings);
  GetStringsFromIni(IniFile, 'memDeleteFolders', memDeleteFolders.Strings);
  GetStringsFromIni(IniFile, 'memMark', memMark.Strings);

  IniFile.Free;

  LoadInterface;

  RefreshCaptions();

  if ParamCount > 0 then
    if ParamStr(1) = '>' then
      begin
        ShowWindow(Application.Handle, SW_MINIMIZE);
        FullClear;
        Halt;
      end;

end;

procedure TfrmMain.btnClearClick(Sender: TObject);
begin
//  SaveMarkToDisk;
  if Application.FindComponent('frmDel') <> nil
   then begin
    frmDel.BringToFront;
    Exit;
   end;
  FullClear;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var IniFile : TIniFile;
    i: integer;
    TempFile: System.Text;
begin
  IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\ExCleaner.ini');
  IniFile.WriteBool('Options', 'Clearing subfolders', cbxSubFolders.Checked);
  IniFile.WriteBool('Options', 'Clearing directoryes', cbxDir.Checked);
  IniFile.WriteBool('Options', 'Delete read only', cbxReadOnly.Checked);
  IniFile.WriteBool('Options', 'Empty Recycled Bin', cbxEmptyRecycled.Checked);
  IniFile.WriteBool('Options', 'Skip Marked', cbxSkipMarked.Checked);
  IniFile.WriteBool('Options', 'Delete To Recycled', cbxDeleteToRecycled.Checked);

  SetStringsFromIni(IniFile, 'memExt', memExt.Strings);
  SetStringsFromIni(IniFile, 'memDir', memDir.Strings);
  SetStringsFromIni(IniFile, 'memDeleteFolders', memDeleteFolders.Strings);
  SetStringsFromIni(IniFile, 'memMark', memMark.Strings);

  IniFile.Free;
//  SaveMarkToDisk;
end;

procedure TfrmMain.Label2Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'mailto:soa_project@mail.ru', nil, nil, SW_SHOWNA);
end;

procedure TfrmMain.Label3Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'www.soaproject.hut.ru', nil, nil, SW_SHOWNA);
end;

procedure TfrmMain.CMBtnCancel(var Message: TMessage);
begin
  Halt;
end;

procedure TfrmMain.BtnCancelDetect;
  var
    Msg : TMsg;
  begin
    While PeekMessage(Msg,0,0,0,PM_REMOVE) do begin
      if (Msg.Message = WM_KEYDOWN) and (Msg.wParam=9) then frmDel.Button1.SetFocus;

      if Msg.Message = WM_QUIT then begin
        halt;
        Abort;
      end;
      TranslateMessage(Msg);
      DispatchMessage(Msg);
    end;
end;

procedure TfrmMain.OpenEditor(ATag: integer; ACaption: String; ATStrings: TStrings);
begin
  frmEditor := TfrmEditor.Create(Application);


  frmEditor.Tag := ATag;
  frmEditor.Caption := ACaption;

  frmEditor.lbxEditor.Clear;
  frmEditor.lbxEditor.Items.AddStrings( ATStrings );

  if frmEditor.ShowModal = mrOk then
    begin
      ATStrings.Clear;
      ATStrings.AddStrings( frmEditor.lbxEditor.Items );
    end;
  frmEditor.Free;

  RefreshCaptions();
end;

procedure TfrmMain.btnEditExtClick(Sender: TObject);
begin
  OpenEditor(0, lblEditExt.Caption, memExt.Strings);
end;

procedure TfrmMain.btnEditFoldersForCleanClick(Sender: TObject);
begin
  OpenEditor(1, lblEditFoldersForClean.Caption, memDir.Strings);
end;

procedure TfrmMain.btnEditMarkClick(Sender: TObject);
begin
  OpenEditor(2, lblEditMark.Caption, memMark.Strings);
end;

procedure TfrmMain.lblDeleteFoldersClick(Sender: TObject);
begin
  OpenEditor(1, lblDeleteFolders.Caption, memDeleteFolders.Strings);
end;

procedure TfrmMain.lblEditLangClick(Sender: TObject);
var frmLang: TfrmLang;
    SearchRec : TSearchRec;
    currDirStr: string;
    IniFile: TIniFile;
begin
  frmLang := TfrmLang.Create(Application);

  frmLang.Caption := cChoiceLang;

  frmLang.btnCancel.Caption := cCancel;

  frmLang.listLang.Clear;

  currDirStr :=ExtractFilePath(Application.ExeName);

  FindFirst(currDirStr + '\*.lang', faAnyFile, SearchRec);
  repeat
    if FileExists(currDirStr + '\' + SearchRec.Name) and (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin
        frmLang.listLang.Items.Add(
          Copy(SearchRec.Name, 1, Length(SearchRec.Name)- Length(ExtractFileExt(SearchRec.Name)))
         );
      end;
  until FindNext(SearchRec) <> 0;
  FindClose(SearchRec);

  if frmLang.ShowModal = mrOk then
    begin
      if frmLang.listLang.ItemIndex <> -1 then
        begin
        IniFile := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\ExCleaner.ini');
        IniFile.WriteString('Options', 'Language', frmLang.listLang.Items[frmLang.listLang.ItemIndex]);
        IniFile.Free;
        end;

        LoadInterface();

    end;
  frmLang.Free;

  RefreshCaptions();
end;

procedure TfrmMain.lblEditExtMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  TLabel(Sender).Font.Color := clBlue;
end;

procedure TfrmMain.lblEditExtMouseLeave(Sender: TObject);
begin
   TLabel(Sender).Font.Color := clNavy
end;

end.
