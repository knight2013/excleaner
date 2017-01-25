unit frmLangUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TfrmLang = class(TForm)
    Bevel1: TBevel;
    btnOK: TButton;
    btnCancel: TButton;
    listLang: TListBox;
    procedure listLangDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmLang: TfrmLang;

implementation

{$R *.dfm}

procedure TfrmLang.listLangDblClick(Sender: TObject);
begin
  btnOK.Click();
end;

end.
