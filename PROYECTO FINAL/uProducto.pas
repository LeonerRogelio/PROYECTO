unit uProducto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Layouts, FMX.Objects, FMX.Edit,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.FMXUI.Wait,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, FMX.ListBox, FMX.DialogService
  // Para los Dialogos
{$IFDEF ANDROID}
    , Androidapi.JNI.Widget, Androidapi.Helpers;
{$ENDIF}

type
  TfrmProducto = class(TForm)
    ToolBar1: TToolBar;
    BtnLimpiar: TButton;
    BtnAtras: TButton;
    LTitulo: TLabel;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    Image4: TImage;
    LSubTitulo: TLabel;
    Panel2: TPanel;
    ECodigo: TEdit;
    ENombre: TEdit;
    ECantidad: TEdit;
    EPrecio: TEdit;
    EMarca: TEdit;
    Panel3: TPanel;
    BtnAgregarP: TButton;
    Panel4: TPanel;
    Label1: TLabel;
    ETipo: TComboBox;
    procedure BtnAtrasClick(Sender: TObject);
    procedure BtnLimpiarClick(Sender: TObject);
    procedure BtnAgregarPClick(Sender: TObject);
    procedure VaciarCampos();
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowMessageToast(const pMsg: String; pDuration: Integer);
  end;

var
  frmProducto: TfrmProducto;

implementation

uses uMain;

{$R *.fmx}

procedure TfrmProducto.ShowMessageToast(const pMsg: String; pDuration: Integer);
begin
{$IFDEF ANDROID}
  TThread.Synchronize(nil,
    procedure
    begin
      TJToast.JavaClass.makeText(TAndroidHelper.Context,
        StrToJCharSequence(pMsg), pDuration).show
    end);
{$ENDIF}
end;

procedure TfrmProducto.BtnAgregarPClick(Sender: TObject);
var
  duracion: Integer;
begin
  if ((ECodigo.Text <> '') and (ENombre.Text <> '') and (ECantidad.Text <> '')
    and (EPrecio.Text <> '') and (EMarca.Text <> '') and
    (ETipo.Items.Text <> '')) then
  begin
    if frmLogin.tblProducto.Locate('idProducto;nombre;marca;tipo',
      VarArrayOf([ECodigo.Text, ENombre.Text, EMarca.Text, ETipo.Items.Text]
      ), []) then
    begin
      var
      varCantidad := frmLogin.tblProducto.FieldByName('cantidad').AsInteger;
      varCantidad := varCantidad + ECantidad.Text.ToInteger();

      frmLogin.tblProducto.Edit;
      frmLogin.tblProducto.FieldByName('cantidad').Value :=
        varCantidad.ToString;
      frmLogin.tblProducto.FieldByName('precio').Value := EPrecio.Text;
      frmLogin.tblProducto.Post;

      VaciarCampos;
{$IFDEF ANDROID}
      // duracion := TJToast.JavaClass.LENGTH_LONG // Mensaje largo
      duracion := TJToast.JavaClass.LENGTH_SHORT; // Mensaje Corto
      ShowMessageToast
        ('El producto se ha registrado con éxito en el inventario.', duracion);
{$ENDIF}
    end
    else
    begin
      if frmLogin.tblProducto.Locate('idProducto',
        VarArrayOf([ECodigo.Text]), []) then
      begin
        ShowMessage
          ('Este código del producto ya está ocupado por otro producto');
      end
      else
      begin
        frmLogin.tblProducto.Append;
        frmLogin.tblProducto.FieldByName('idProducto').Value :=
          ECodigo.Text.ToInteger;
        frmLogin.tblProducto.FieldByName('nombre').Value :=
          UpperCase(ENombre.Text);
        frmLogin.tblProducto.FieldByName('cantidad').Value := ECantidad.Text;
        frmLogin.tblProducto.FieldByName('precio').Value := EPrecio.Text;
        frmLogin.tblProducto.FieldByName('marca').Value :=
          UpperCase(EMarca.Text);
        frmLogin.tblProducto.FieldByName('tipo').Value := ETipo.Selected.Text;
        frmLogin.tblProducto.Post;
        VaciarCampos();
{$IFDEF ANDROID}
        // duracion := TJToast.JavaClass.LENGTH_LONG // Mensaje largo
        duracion := TJToast.JavaClass.LENGTH_SHORT; // Mensaje Corto
        ShowMessageToast
          ('El producto se ha registrado con éxito en el inventario.',
          duracion);
{$ENDIF}
      end;

    end;
  end
  else
  begin
    ShowMessage
      ('No has introducido los datos necesarios. Por favor, proporciona la información solicitada')
  end;
end;

// Para cerrar el frm.
procedure TfrmProducto.BtnAtrasClick(Sender: TObject);
begin
  VaciarCampos;
  close;
end;

// Para limpiar los campos del frm.
procedure TfrmProducto.BtnLimpiarClick(Sender: TObject);
var
  duracion: Integer;
begin
  VaciarCampos();
{$IFDEF ANDROID}
  // duracion := TJToast.JavaClass.LENGTH_LONG // Mensaje largo
  duracion := TJToast.JavaClass.LENGTH_SHORT; // Mensaje Corto
  ShowMessageToast('Campos vacíos.', duracion);
{$ENDIF}
end;

procedure TfrmProducto.FormKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    VaciarCampos;
    close;
  end;
end;

// Limpia los campos del frame.
procedure TfrmProducto.VaciarCampos();
begin
  ENombre.Text := '';
  ECodigo.Text := '';
  ECantidad.Text := '';
  EPrecio.Text := '';
  EMarca.Text := '';
  ETipo.ItemIndex := -1;
end;

end.
