unit uVenta;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.DateTimeCtrls, FMX.Objects,
  FMX.Layouts, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Platform
  // Para la rotacion del movil.
    , FMX.DialogService; // Para los Dialogos

type
  TfrmVenta = class(TForm)
    ToolBar1: TToolBar;
    BtnLimpiar: TButton;
    BtnAtras: TButton;
    LTitulo: TLabel;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    Image1: TImage;
    DEFecha: TDateEdit;
    EIdProducto: TEdit;
    ENoPiesas: TEdit;
    menLog: TMemo;
    LTotal: TLabel;
    BtnAgregar: TButton;
    Panel2: TPanel;
    Button2: TButton;
    Panel3: TPanel;
    BtnCobrar: TButton;
    BtnCancelar: TButton;
    procedure BtnAgregarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnAtrasClick(Sender: TObject);
    procedure ValidarCampos(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnCobrarClick(Sender: TObject);
    procedure BtnCancelarClick(Sender: TObject);
    procedure LimpiarCampos();
    procedure BtnLimpiarClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmVenta: TfrmVenta;
  Total: integer = 0;
  txtMemLog: string;
  varDialogo: Boolean;

implementation

uses uMain;
{$R *.fmx}

procedure TfrmVenta.BtnAgregarClick(Sender: TObject);
var
  Producto: string;
  Marca: string;
  Precio: integer;
  Cantidad: integer;
  Importe: integer;
  Inventario: integer;
begin
  if frmLogin.tblProducto.Locate('idProducto', EIdProducto.Text, []) then
  begin
    Producto := frmLogin.tblProducto.FieldByName('nombre').AsString;
    Marca := frmLogin.tblProducto.FieldByName('marca').AsString;
    Precio := frmLogin.tblProducto.FieldByName('precio').AsInteger;
    Cantidad := ENoPiesas.Text.ToInteger;
    Importe := Cantidad * Precio;
    Total := Total + Importe;

    menLog.Lines.Add(Producto + ' ' + Marca + '                       ' +
      Cantidad.ToString + '                             $' + Importe.ToString);

    LTotal.Text := 'TOTAL: ' + Total.ToString + '$';

    // Actualizar Datos en el inventario.
    Inventario := frmLogin.tblProducto.FieldByName('cantidad').AsInteger;
    frmLogin.tblProducto.Edit;
    frmLogin.tblProducto.FieldByName('cantidad').Value :=
      (Inventario - Cantidad).ToString;

    frmLogin.tblVenta.Append;
    frmLogin.tblVenta.FieldByName('fecha').Value := DEFecha.Date;
    frmLogin.tblVenta.FieldByName('cantidad').Value := Cantidad.ToString;
    frmLogin.tblVenta.FieldByName('total').Value := Importe.ToString;
    frmLogin.tblVenta.FieldByName('idProducto').Value :=
      EIdProducto.Text.ToInteger;
    frmLogin.tblVenta.FieldByName('idUsuario').Value :=
      frmLogin.tblUsuario.FieldByName('idUsuario').AsInteger;
    ENoPiesas.Text := '';
    EIdProducto.Text := '';
  end
  else
  begin
    ShowMessage('Este producto no se encuentra en el inventario.');
  end;
end;

procedure TfrmVenta.BtnAtrasClick(Sender: TObject);
begin
  varDialogo := false;
  close;
end;

// Cancelar los cambios y restaurar los datos originales.
procedure TfrmVenta.BtnCancelarClick(Sender: TObject);
begin
  if menLog.Text = txtMemLog then
  begin
    ShowMessage('Cuenta vacía');
  end
  else
  begin
    frmLogin.tblProducto.Cancel;
    frmLogin.tblVenta.Cancel;
    ShowMessage('La venta fue cancelada');
    LimpiarCampos;
  end;
end;

// Aplicar los cambios en el registro de la base de datos.
procedure TfrmVenta.BtnCobrarClick(Sender: TObject);
begin
  if (menLog.Text = txtMemLog) then
  begin
    ShowMessage('Cuenta vacía');
  end
  else
  begin
    frmLogin.tblProducto.Post;
    frmLogin.tblVenta.Post;
    ShowMessage('Venta exitosa.');
    LimpiarCampos;
  end;

end;

procedure TfrmVenta.BtnLimpiarClick(Sender: TObject);
begin
  EIdProducto.Text := '';
  ENoPiesas.Text := '';
end;

procedure TfrmVenta.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if menLog.Text = txtMemLog then
  begin
    varDialogo := true;
  end
  else
  begin
    TDialogService.MessageDialog
      ('¿Estás seguro/a de que deseas salir de la venta? La venta se cancelará. ',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        case AResult of
          mrYES:
            begin
              frmLogin.tblProducto.Cancel;
              frmLogin.tblVenta.Cancel;
              ShowMessage('La venta fue cancelada');
              LimpiarCampos;
              varDialogo := true; // Salir.
{$IF DEFINED(ANDROID)}
              close;
{$ENDIF}
            end;
          mrNo:
            begin
              varDialogo := false; // Permanece en la ventana.
            end;
        end; // Fin del case.
      end); // Fin del Dialogo.
  end; // Fin del if.
  CanClose := varDialogo;
end;

procedure TfrmVenta.FormCreate(Sender: TObject);
begin
  menLog.Lines.Add
    ('--------------------------------------------------------------------------------------');
  DEFecha.Date := Now;
  menLog.Lines.Add('FECHA: ' + FormatDateTime('dd/mm/yyyy', DEFecha.Date));
  menLog.Lines.Add
    ('--------------------------------------------------------------------------------------');
  menLog.Lines.Add('DESCRIPCIÓN' + '                 ' + 'CANTIDAD' +
    '                 ' + 'IMPORTE');
  menLog.Lines.Add
    ('--------------------------------------------------------------------------------------');

  txtMemLog := menLog.Text;
end;

procedure TfrmVenta.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    varDialogo := false;
  end;
end;

procedure TfrmVenta.FormResize(Sender: TObject);
var
  s: IFMXScreenService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, s)
  then
  begin
    case s.GetScreenOrientation of
      // Portrait Orientation: Mostrar imagenes.
      TScreenOrientation.Portrait:
        begin
          Image1.Visible := true;
        end;

      // Landscape Orientation: Ocultar imagenes.
      TScreenOrientation.Landscape:
        begin
          Image1.Visible := false;
        end;

      // InvertedPortrait Orientation: Mostrar imagenes.
      TScreenOrientation.InvertedPortrait:
        begin
          Image1.Visible := true;
        end;

      // InvertedLandscape Orientation: Ocultar imagenes.
      TScreenOrientation.InvertedLandscape:
        begin
          Image1.Visible := false;
        end;
    end;
  end;
end;

// Si todos los campos están llenos, habilitar el botón, de lo contrario, deshabilítar.
procedure TfrmVenta.ValidarCampos(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  BtnAgregar.Enabled := (EIdProducto.Text <> '') and (ENoPiesas.Text <> '');
end;

procedure TfrmVenta.LimpiarCampos();
begin
  EIdProducto.Text := '';
  ENoPiesas.Text := '';
  Total := 0;
  menLog.Lines.Clear;
  menLog.Text := txtMemLog;

  LTotal.Text := 'TOTAL:'
end;

end.
