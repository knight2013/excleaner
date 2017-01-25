unit frmEditorUn;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Mask, ToolEdit, SOA_Lib;

type
  TfrmEditor = class(TForm)
    lbxEditor: TListBox;
    Bevel1: TBevel;
    btnOK: TButton;
    btnCancel: TButton;
    lblEditThisListBox: TLabel;
    btnAdd: TButton;
    btnDelete: TButton;
    btnEdit: TButton;
    lblStringToEdit: TLabel;
    edtEditor: TEdit;
    btnBrowse: TButton;
    dlgOpen: TOpenDialog;
    dlgDirOpen: TDirectoryEdit;
    procedure FormShow(Sender: TObject);
    procedure lbxEditorClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditor: TfrmEditor;

implementation

uses frmMainUn;

{$R *.dfm}

function GetFileMarks(AFileName: string): string;
var i: integer;
    strhex1: string[2];
    strhex2: char;
    TempFile: Text;
begin
   Result := '*' + ExtractFileExt(AFileName) + '=';
   Assign(TempFile, AFileName);
   {$I-}
   Reset(TempFile);
   if IOResult <> 0
    then begin
        {$I+}
        Exit;
    end;

     for i := 0 to vLengthMark - 1 do
       begin
         Read(TempFile, strhex2);
         Result := Result + '$' + IntToHex(Ord(strhex2), 2);
       end;

   CloseFile(TempFile);
end;


procedure TfrmEditor.FormShow(Sender: TObject);
begin
  if Tag = 0 then btnBrowse.Enabled := False;
  btnAdd.Caption := cAdd;
  btnDelete.Caption := cDelete;
  btnEdit.Caption := cEdit;
  lblEditThisListBox.Caption := cEditThisListBox;
  lblStringToEdit.Caption := cStringToEdit;
  btnCancel.Caption := cCancel;

end;

procedure TfrmEditor.lbxEditorClick(Sender: TObject);
begin
  if lbxEditor.ItemIndex < 0 then Exit;
  edtEditor.Text := lbxEditor.Items[lbxEditor.ItemIndex];
end;

procedure TfrmEditor.btnAddClick(Sender: TObject);
begin
  if Length(Trim(edtEditor.Text)) > 0 then lbxEditor.Items.Add( edtEditor.Text );
  edtEditor.Clear;
end;

procedure TfrmEditor.btnEditClick(Sender: TObject);
begin
  if lbxEditor.ItemIndex < 0 then Exit;
  if Length(Trim(edtEditor.Text)) > 0 then lbxEditor.Items[lbxEditor.ItemIndex] := edtEditor.Text;
  edtEditor.Clear;
end;

procedure TfrmEditor.btnDeleteClick(Sender: TObject);
begin
  if lbxEditor.ItemIndex < 0 then Exit;
  lbxEditor.Items.Delete(lbxEditor.ItemIndex);
end;

procedure TfrmEditor.btnBrowseClick(Sender: TObject);
begin

  if Tag = 1 then
    begin
      dlgDirOpen.DoClick;
      if dlgDirOpen.LongName <> 'dlgDirOpen' then
      edtEditor.Text := dlgDirOpen.LongName;
    end;

  if Tag = 2 then
    begin
      if dlgOpen.Execute then
      edtEditor.Text := GetFileMarks(dlgOpen.FileName);
    end;


end;

end.
