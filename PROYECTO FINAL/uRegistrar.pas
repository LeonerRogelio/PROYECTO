unit uRegistrar;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.Layouts,
  FMX.Platform,
  FMX.DialogService, // Para los Dialogos.
  Data.DB;

type
  TfrmRegistro = class(TForm)
    ToolBar1: TToolBar;
    BtnLimpiar: TButton;
    BtnAtras: TButton;
    LTitulo: TLabel;
    Panel1: TPanel;
    VertScrollBox1: TVertScrollBox;
    Image1: TImage;
    ENombre: TEdit;
    EApellidoP: TEdit;
    CheckMP: TCheckBox;
    BtnRegistrarme: TButton;
    LUsuario: TLabel;
    Panel2: TPanel;
    EApellidoM: TEdit;
    ETel: TEdit;
    ECorreo: TEdit;
    EPassword: TEdit;
    EPassword2: TEdit;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Label1: TLabel;
    Check8: TCheckBox;
    CheckMin: TCheckBox;
    CheckMay: TCheckBox;
    CheckCEsp: TCheckBox;
    CheckDig: TCheckBox;
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnAtrasClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure LimpiarCampos();
    procedure FormResize(Sender: TObject);
    procedure CheckMPChange(Sender: TObject);
    procedure EPasswordKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char;
      Shift: TShiftState);
    procedure BtnLimpiarClick(Sender: TObject);
    procedure BtnRegistrarmeClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmRegistro: TfrmRegistro;
  varDialogo: Boolean;

implementation

uses uMain;

{$R *.fmx}

// Inisializar las variables que se necesitan al crear el frm.
procedure TfrmRegistro.BtnAtrasClick(Sender: TObject);
begin
  varDialogo := false;
  close;
end;

// vkHardwareBack del movil. Mostrara el dialogo antes de salir.
procedure TfrmRegistro.FormKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkHardwareBack then
  begin
    varDialogo := false;
  end;
end;

// Ocultar imagenes.
procedure TfrmRegistro.FormResize(Sender: TObject);
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

procedure TfrmRegistro.BtnLimpiarClick(Sender: TObject);
begin
  LimpiarCampos;
end;

procedure TfrmRegistro.BtnRegistrarmeClick(Sender: TObject);
begin
  if ((ENombre.Text <> '') and (EApellidoP.Text <> '') and
    (EApellidoM.Text <> '') and (ECorreo.Text <> '') and (EPassword.Text <> '')
    and (EPassword2.Text <> '') and (ETel.Text <> '')) then
  begin
    if EPassword.Text = EPassword2.Text then
    begin
      if ((Check8.IsChecked = true) and (CheckMin.IsChecked = true) and
        (CheckMay.IsChecked = true) and (CheckCEsp.IsChecked = true) and
        (CheckDig.IsChecked = true)) then
      begin

        if frmLogin.tblUsuario.Locate('correo', VarArrayOf([ECorreo.Text]), [])
        then
        begin
          ShowMessage
            ('Lo siento, pero el Correo que has ingresado ya está en uso. Por favor, elige un correo diferente para continuar.');
          ECorreo.Text := '';
        end
        else
        begin
          frmLogin.tblUsuario.Append;
          frmLogin.tblUsuario.FieldByName('nombre').Value :=
            UpperCase(ENombre.Text);
          frmLogin.tblUsuario.FieldByName('apellidoP').Value :=
            UpperCase(EApellidoP.Text);
          frmLogin.tblUsuario.FieldByName('apellidoM').Value :=
            UpperCase(EApellidoM.Text);
          frmLogin.tblUsuario.FieldByName('telefono').Value := ETel.Text;
          frmLogin.tblUsuario.FieldByName('correo').Value :=
            LowerCase(ECorreo.Text);
          frmLogin.tblUsuario.FieldByName('password').Value := EPassword.Text;
          frmLogin.tblUsuario.Post;
          ShowMessage
            ('¡Felicidades! El registro se ha realizado con éxito. ¡Bienvenido/a a nuestro sistema! Ahora puedes disfrutar los servicios disponibles.');
          LimpiarCampos; // (Metodos) Limpiar campos.
          close; // Salir.
        end;
      end
      else
      begin
        ShowMessage
          ('La contraseña ingresada es incorrecta. Por favor, verifica y vuelve a intentarlo.')
      end;
    end
    else
    begin
      // Las contraseñas no coinciden
      ShowMessage
        ('Las contraseñas no coinciden. Por favor, inténtalo de nuevo');
    end;
  end
  else
  begin
    ShowMessage
      ('No has introducido los datos necesarios. Por favor, proporciona la información solicitada')
  end;
end;

procedure TfrmRegistro.CheckMPChange(Sender: TObject);
begin
  EPassword.Password := not CheckMP.IsChecked;
  EPassword2.Password := not CheckMP.IsChecked;
end;

{ Validar la contraseña constantemente que se presiona una tecla en el edit.
  Para verificar que la contraseña cumpla con los requerimientos. }
procedure TfrmRegistro.EPasswordKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
begin
  var
  cMayuscula := 0;
  var
  cMinuscula := 0;
  var
  cDigito := 0;
  var
  cCE := 0;
  var
  i := 0;

  for i := 0 to Length(EPassword.Text) - 1 do
  begin
    var
    c := EPassword.Text.Chars[i];
    case c of
      'A' .. 'Z':
        Inc(cMayuscula);
      'a' .. 'z':
        Inc(cMinuscula);
      '0' .. '9':
        Inc(cDigito);
    else
      Inc(cCE);
    end;
  end;
  Check8.IsChecked := Length(EPassword.Text) >= 8;
  CheckMin.IsChecked := cMinuscula > 0;
  CheckMay.IsChecked := cMayuscula > 0;
  CheckDig.IsChecked := cDigito > 0;
  CheckCEsp.IsChecked := cCE > 0;
end;

// Preguntar antes si desea salir si hay datos infresados.
procedure TfrmRegistro.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if (ENombre.Text = '') and (EApellidoP.Text = '') and (EApellidoM.Text = '')
    and (ECorreo.Text = '') and (EPassword.Text = '') and (EPassword2.Text = '')
    and (ETel.Text = '') then
  begin
    varDialogo := true;
  end
  else
  begin
    TDialogService.MessageDialog
      ('¿Estás seguro/a de que deseas salir sin guardar? Toda la información no guardada se perderá.',
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        case AResult of
          mrYES:
            begin
              LimpiarCampos; // (Metodo) Limpiar campos
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

// Metodo para limpiar campos del frame.
procedure TfrmRegistro.LimpiarCampos();
begin
  ENombre.Text := '';
  EApellidoP.Text := '';
  EApellidoM.Text := '';
  ECorreo.Text := '';
  EPassword.Text := '';
  EPassword2.Text := '';
  ETel.Text := '';

  Check8.IsChecked := false;
  CheckMin.IsChecked := false;
  CheckMay.IsChecked := false;
  CheckCEsp.IsChecked := false;
  CheckDig.IsChecked := false;

  CheckMP.IsChecked := false;
end;

end.
