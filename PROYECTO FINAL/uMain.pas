unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, FMX.Platform,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client

{$IFDEF ANDROID}
  /// Helpers for Android implementations by FMX.
    , FMX.Helpers.Android
  // Java Native Interface permite a programas
  // ejecutados en la JVM interactue con otros lenguajes.
    , Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.Net,
  Androidapi.JNI.JavaTypes, Androidapi.Helpers
  // Obtiene datos de telefonia del dispositivo
    , Androidapi.JNI.Telephony, Androidapi.JNI.Widget;
{$ENDIF}

type
  TfrmLogin = class(TForm)
    ToolBar1: TToolBar;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    BtnLimpiar: TButton;
    BtnSalir: TButton;
    LTitulo: TLabel;
    Image1: TImage;
    LCorreoElectronico: TLabel;
    ECorreo: TEdit;
    LPassword: TLabel;
    EPassword: TEdit;
    CheckMP: TCheckBox;
    BtnIniciar: TButton;
    Panel2: TPanel;
    BtnOlvidasteTuPassword: TButton;
    Label1: TLabel;
    BtnRegistrar: TButton;
    LUsuario: TLabel;
    DB: TFDConnection;
    tblUsuario: TFDTable;
    tblProducto: TFDTable;
    tblVenta: TFDTable;
    Timer1: TTimer;
    procedure BtnSalirClick(Sender: TObject);
    procedure BtnLimpiarClick(Sender: TObject);
    procedure CheckMPChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure BtnRegistrarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BtnIniciarClick(Sender: TObject);
    procedure BtnOlvidasteTuPasswordClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure EditsKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);

    // Para validar campos.
  private
    { Private declarations }
  public
    { Public declarations }
    procedure SendSMS(target, message: string);
    procedure ShowMessageToast(const pMsg: String; pDuration: Integer);

  var
    segundos: Integer;

  var
    dbFileName: string;
  end;

var
  frmLogin: TfrmLogin;
  varContador: Integer = 0;

implementation

uses
  uRegistrar, // Para conectar con el frm.
  uMenu,
  System.IOUtils; // Para hacer uso de TPath.

{$R *.fmx}

{ *******************Esto se ejecuta al iniciar el programa/app siempre para establecer la BD.******** }
procedure TfrmLogin.FormCreate(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  // Ubicacion de la bd en Windows.
  dbFileName := 'E:\Proyecto\db\puntoVenta.db;
{$ELSE}
  // Ubicacion de la bd en Android.
    dbFileName := TPath.Combine(TPath.GetDocumentsPath, 'puntoVenta.db');
{$ENDIF}
  // Asignar la base de datos.
  DB.Params.Database := dbFileName;
  try
    DB.Connected := true; // Conectarse a la BD.
    tblUsuario.Active := true; // Ativar la tabla.
    tblProducto.Active := true; // Ativar la tabla.
    tblVenta.Active := true; // Ativar la tabla.
    DB.Open;
    tblUsuario.Open;
    tblProducto.Open;
    tblVenta.Open;
  except
    // Se ejecuta si ocurre una falla al intentar conectarse a la BD.
    on E: Exception do
      ShowMessage('Error de conexion');
  end;
end;

{ ********************************Para el Desplege alertas del tipo Toast***************************** }
procedure TfrmLogin.ShowMessageToast(const pMsg: String; pDuration: Integer);
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

{ ******************************************Inicio de sesión****************************************** }
procedure TfrmLogin.BtnIniciarClick(Sender: TObject);
begin
  // Buscar Registro con el correo y contraseña ingresados.
  if tblUsuario.Locate('correo;password',
    VarArrayOf([ECorreo.Text, EPassword.Text]), []) then
  begin
{$IF DEFINED(MSWINDOWS)}
    frmMenu.ShowModal;
{$ELSE}
    frmMenu.show;
{$ENDIF}
    ECorreo.Text := '';
    EPassword.Text := '';
    CheckMP.IsChecked := false;
  end
  else
  begin
    ShowMessage
      ('El correo electronico o el password es inválido, verifica la información y prueba nuevamente.');
    // Número de intentos de inicio de sesión.
    varContador := varContador + 1;
    // Verificación de intentos de inicio de sesión.
    if (varContador = 3) then
    begin
      BtnIniciar.Enabled := false; // Bloquear el botón
      Timer1.Enabled := true; // Habilitar el temporizador
      segundos := 20; // Establecer el número de segundos para el temporizador
      varContador := 0; // Reiniciar contador.
      EPassword.Text := '';
    end;

  end;
end;

{ ******************************Para limpiar todos los campos del Login.****************************** }
procedure TfrmLogin.BtnLimpiarClick(Sender: TObject);
var
  duracion: Integer;
begin
  ECorreo.Text := '';
  EPassword.Text := '';
  CheckMP.IsChecked := false;
{$IFDEF ANDROID}
  // duracion := TJToast.JavaClass.LENGTH_LONG // Mensaje largo
  duracion := TJToast.JavaClass.LENGTH_SHORT; // Mensaje Corto
  ShowMessageToast('Campos vacíos.', duracion);
{$ENDIF}
end;

{ *************************************Para los mensajes de texto************************************* }
procedure TfrmLogin.SendSMS(target, message: string);
var
  smsManager: JSmsManager; // Declarar administrador de mensajes
  smsTo: JString; // Variable destinatario del SMS
  duracion: Integer;
begin
  try
    // inicializar administrador de mensajes
    smsManager := TJSmsManager.JavaClass.getDefault;
    // convertir target a tipo Jstring tipo de dato usado por JNI
    smsTo := StringToJString(target);
    // pasar parametros a administrador para enviar mensaje
    smsManager.sendTextMessage(smsTo, nil, StringToJString(message), nil, nil);
{$IFDEF ANDROID}
    // duracion := TJToast.JavaClass.LENGTH_LONG // Mensaje largo
    duracion := TJToast.JavaClass.LENGTH_SHORT; // Mensaje Corto
    ShowMessageToast('Mensaje enviado', duracion);
{$ENDIF}
  except
    on E: Exception do
      ShowMessage(E.ToString);
  end;
end;

procedure TfrmLogin.Timer1Timer(Sender: TObject);
begin
  BtnIniciar.Text := Format('Iniciar sesión (%d)', [segundos]);
  Dec(segundos); // Descontar un segundo
  if segundos >= 1 then
  begin
    BtnIniciar.Enabled := false; // Bloquear el botón
    Timer1.Enabled := true; // Habilitar el temporizador
  end
  else
  begin
    BtnIniciar.Enabled := true; // Desbloquear el botón
    Timer1.Enabled := false; // Deshabilitar el temporizador
    BtnIniciar.Text := 'Iniciar sesión';
  end;
end;

// Para enviar un SMS al numero de telefono que esta en la BD con la contraseña.
procedure TfrmLogin.BtnOlvidasteTuPasswordClick(Sender: TObject);
var
  varCelular: String; // Contendra el número registrado.
  varMensaje: String; // Contendra la nueva contraseña.
begin
  // Verificar si exixte el correo electronico ingresado.
  if tblUsuario.Locate('correo', ECorreo.Text, []) then
  begin
    // Obtener los datos originales de la BD.
    varCelular := tblUsuario.FieldByName('telefono').aSString;
    varMensaje := tblUsuario.FieldByName('password').aSString;

    // Llamar a SendSMS que recibe 2 paramentros
    // target: Destinatario de SMS; message: contenido del SMS;
    // Modificar. poner los datos de la base de datos, numero de telefono y la contraseña
    SendSMS(varCelular, 'Tu contraseña es: ' + varMensaje);
  end
  else
  begin
    ShowMessage
      ('No se encontró información, Si aún no tiene una cuenta, regístrese');
  end;
end;

procedure TfrmLogin.BtnRegistrarClick(Sender: TObject);
begin
{$IF DEFINED(MSWINDOWS)}
  frmRegistro.ShowModal;
{$ELSE}
  frmRegistro.show;
{$ENDIF}
  ECorreo.Text := '';
  EPassword.Text := '';
  CheckMP.IsChecked := false;
end;

{ *****************************Para terminar con la ejecucion del programa**************************** }
procedure TfrmLogin.BtnSalirClick(Sender: TObject);
begin
  DB.close;
  tblUsuario.close;
  tblProducto.close;
  tblVenta.close;
  close;
end;

{ *************************Para mostrar la contraseña escrita por el usuario.************************* }
procedure TfrmLogin.CheckMPChange(Sender: TObject);
begin
  EPassword.Password := not CheckMP.IsChecked;
end;

{ ********Si todos los campos están llenos, habilitar el botón, de lo contrario, deshabilítar.******** }
procedure TfrmLogin.EditsKeyUp(Sender: TObject; var Key: Word;
var KeyChar: Char; Shift: TShiftState);
begin
  if segundos = 0 then
  begin
    BtnIniciar.Enabled := (ECorreo.Text <> '') and (EPassword.Text <> '');
  end;
end;

{ **********************************Activa y desactiva las imagenes********************************** }
procedure TfrmLogin.FormResize(Sender: TObject);
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

end.
