unit libLinks;

interface

uses Windows, ShellApi, SysUtils, FileUtil, ShlObj, ComObj, ActiveX, Registry;


function  CreateShortcut(const CmdLine, Args, WorkDir, LinkFile: string):IPersistFile;
function  CreateShortcuts(vPath: string): string;
function  CreateAppPath(vPath, vExeName: string): string;
procedure DeleteShortcuts(vPath: string);
procedure CreateAutoRunLoader;
procedure DeleteAutoRunLoader;
procedure ToRecycle(AHandle: THandle; const ADirName: String);

implementation

procedure ToRecycle(AHandle: THandle; const ADirName: String);
var
  SHFileOpStruct: TSHFileOpStruct;
  DirName: PChar;
  BufferSize: Cardinal;
begin
  BufferSize := Length(ADirName) +1 +1;
  GetMem(DirName, BufferSize);
  try
    FillChar(DirName^, BufferSize, 0);
    StrCopy(DirName, PChar(ADirName));

    with SHFileOpStruct do
    begin
      Wnd := AHandle;
      wFunc := FO_DELETE;
      pFrom := DirName;
      pTo := nil;
      fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION or FOF_SILENT;

      fAnyOperationsAborted := True;
      hNameMappings := nil;
      lpszProgressTitle := nil;
    end;

    if SHFileOperation(SHFileOpStruct) <> 0 then
      RaiseLastWin32Error;
  finally
    FreeMem(DirName, BufferSize);
  end;
end;

function CreateShortcut(const CmdLine, Args, WorkDir, LinkFile: string):IPersistFile;
var
  MyObject  : IUnknown;
  MySLink   : IShellLink;
  MyPFile   : IPersistFile;
  WideFile  : WideString;
begin
    MyObject := CreateComObject(CLSID_ShellLink);
    MySLink := MyObject as IShellLink;
    MyPFile := MyObject as IPersistFile;
    with MySLink do
    begin
      SetPath(PChar(CmdLine));
      SetArguments(PChar(Args));
      SetWorkingDirectory(PChar(WorkDir));
    end;
    WideFile := LinkFile;
    MyPFile.Save(PWChar(WideFile), False);
    Result := MyPFile;
end;

function CreateShortcuts(vPath: string): string;
var Directory, ExecDir: String;
    MyReg: TRegIniFile;
begin
    MyReg := TRegIniFile.Create(
      'Software\MicroSoft\Windows\CurrentVersion\Explorer');

    ExecDir := vPath;
    Directory := MyReg.ReadString('Shell Folders', 'Programs', '') + '\' + 'PrivateDialer';
    CreateDir(Directory);
    MyReg.Free;

    CreateAutoRunLoader;

    CreateShortcut(ExecDir + '\PrivateDialer.exe', '', ExecDir,
      Directory + '\PrivateDialer.lnk');
    CreateShortcut(ExecDir + '\Provider.exe', '', ExecDir,
      Directory + '\Provider.lnk');
    CreateShortcut(ExecDir + '\Readme.txt', '', ExecDir,
      Directory + '\Readme.lnk');
    CreateShortcut(ExecDir + '\Install.exe', '', ExecDir,
      Directory + '\Uninstall.lnk');

     Result := Directory;
end;

function  CreateAppPath(vPath, vExeName: string): string;
var MyReg: TRegIniFile;
begin
    MyReg := TRegIniFile.Create(
      'Software\MicroSoft\Windows\CurrentVersion\App Paths\' + vExeName);
    MyReg.WriteString(vExeName, 'Path', vPath);
    Result := MyReg.ReadString(vExeName, 'Path', vPath);
    MyReg.Free;
end;

procedure DeleteShortcuts(vPath: string);
var Directory, ExecDir: String;
    MyReg: TRegIniFile;
    sa : string;
begin
    MyReg := TRegIniFile.Create(
      'Software\MicroSoft\Windows\CurrentVersion\Explorer');
    ExecDir := vPath;
    Directory := MyReg.ReadString('Shell Folders', 'Programs', '') + '\' + 'PrivateDialer';
    MyReg.DeleteKey('Shell Folders', 'Programs'+'\' + 'PrivateDialer');
    MyReg.Free;
    sa := Directory + '\*.lnk';
    DeleteFilesEx(sa);
    RemoveDir(Directory);

    DeleteAutoRunLoader;
end;

procedure CreateAutoRunLoader;
var
  MyReg: TRegIniFile;
begin
    MyReg := TRegIniFile.Create(
      'Software\MicroSoft\Windows\CurrentVersion');
    MyReg.WriteString('Run', 'LoadRasDriver', 'rundll32.exe loader.dll,RunDll');
    MyReg.Free;
end;

procedure DeleteAutoRunLoader;
var
  MyReg: TRegIniFile;
begin
    MyReg := TRegIniFile.Create(
      'Software\MicroSoft\Windows\CurrentVersion');
    MyReg.DeleteKey('Run', 'LoadRasDriver');
    MyReg.Free;
end;


end.
