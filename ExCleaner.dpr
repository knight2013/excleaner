program ExCleaner;

uses
  Forms,
  frmMainUn in 'Source\frmMainUn.pas' {frmMain},
  libPgp in 'Common\libPgp.pas',
  frmDelUn in 'Source\frmDelUn.pas' {frmDel},
  libLinks in 'Common\libLinks.pas',
  frmEditorUn in 'Source\frmEditorUn.pas' {frmEditor},
  SOA_Lib in 'Common\SOA_Lib.pas',
  uVersion in 'Common\uVersion.pas',
  frmLangUn in 'Source\frmLangUn.pas' {frmLang};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
