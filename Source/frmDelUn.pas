unit frmDelUn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, StrUtils;

type
  TfrmDel = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    imgDel: TImage;
    pnlDirectory: TPanel;
    Label2: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  procedure ShowProcessWindow(aText: string);
  end;

var
  frmDel: TfrmDel;

implementation

uses frmMainUn;

{$R *.DFM}

procedure TfrmDel.ShowProcessWindow(aText: string);
var aOneWidth, aCountToStay: integer;
    aLeftStay, aRightStay: string;
begin

aText := 'D:\Documents and Settings\LocalService\Local Settings\Application Data\Microsoft\Credentials\S-1-5-19\\Application Data\Microsoft\Credentials\LULU\';

  if Application.FindComponent('frmDel') = nil then Exit;

  if  Canvas.TextWidth(aText) > pnlDirectory.Width then
   begin
      aOneWidth :=  Canvas.TextWidth(aText) div length(aText);
      aCountToStay := (pnlDirectory.Width div aOneWidth) - (aOneWidth * 3); //три точки
      aLeftStay := LeftStr(aText, aCountToStay div 2);
      aRightStay := RightStr(aText, aCountToStay div 2);
      frmDel.pnlDirectory.Caption := aLeftStay + '...' + aRightStay;
   end
  else
      frmDel.pnlDirectory.Caption := aText;

  pnlDirectory.Repaint;
  frmMain.BtnCancelDetect;
  //ShowMessage('s');
  //frmMain.Close;
end;

procedure TfrmDel.Button1Click(Sender: TObject);
begin
  SendMessage(frmMain.Handle, CM_BTNCANCEL, 0, 0);
end;

procedure TfrmDel.FormCreate(Sender: TObject);
begin
  Label2.Caption := cFoldersIsClearingNow;
  Button1.Caption := cCancel;
end;

end.

