program RCP;

uses
  System.StartUpCopy,
  FMX.Forms,
  uMain in 'uMain.pas' {frmLogin},
  vkbdhelper in 'vkbdhelper.pas',
  uRegistrar in 'uRegistrar.pas' {frmRegistro},
  uMenu in 'uMenu.pas' {frmMenu},
  uProducto in 'uProducto.pas' {frmProducto},
  uInventario in 'uInventario.pas' {frmInventario},
  uVenta in 'uVenta.pas' {frmVenta},
  uRegistroDeVentas in 'uRegistroDeVentas.pas' {frmRegistroV};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmRegistro, frmRegistro);
  Application.CreateForm(TfrmMenu, frmMenu);
  Application.CreateForm(TfrmProducto, frmProducto);
  Application.CreateForm(TfrmInventario, frmInventario);
  Application.CreateForm(TfrmVenta, frmVenta);
  Application.CreateForm(TfrmRegistroV, frmRegistroV);
  Application.Run;
end.
