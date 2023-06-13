unit uMenu;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.Layouts;

type
  TfrmMenu = class(TForm)
    ToolBar1: TToolBar;
    BtnAtras: TButton;
    LTitulo: TLabel;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    BtnVender: TButton;
    BtnRegistro: TButton;
    BtnInventario: TButton;
    BtnAgregarP: TButton;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label1: TLabel;
    procedure BtnAtrasClick(Sender: TObject);
    procedure BtnAgregarPClick(Sender: TObject);
    procedure BtnInventarioClick(Sender: TObject);
    procedure BtnVenderClick(Sender: TObject);
    procedure BtnRegistroClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMenu: TfrmMenu;

implementation

uses uProducto, uInventario, uVenta, uRegistroDeVentas;
{$R *.fmx}

// Para mostrar frmProducto
procedure TfrmMenu.BtnAgregarPClick(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  frmProducto.ShowModal;
{$ELSE}
  frmProducto.Show;
{$ENDIF}
end;

// Para Salir del frm.
procedure TfrmMenu.BtnAtrasClick(Sender: TObject);
begin
  close;
end;

procedure TfrmMenu.BtnInventarioClick(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  frmInventario.ShowModal;
{$ELSE}
  frmInventario.Show;
{$ENDIF}
end;

procedure TfrmMenu.BtnRegistroClick(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  frmRegistroV.ShowModal;
{$ELSE}
  frmRegistroV.Show;
{$ENDIF}
end;

procedure TfrmMenu.BtnVenderClick(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  frmVenta.ShowModal;
{$ELSE}
  frmVenta.Show;
{$ENDIF}
end;

end.
