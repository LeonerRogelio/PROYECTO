unit uInventario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.ScrollBox, FMX.Grid, FMX.StdCtrls,
  FMX.Controls.Presentation, Data.Bind.EngExt, FMX.Bind.DBEngExt, FMX.Bind.Grid,
  System.Bindings.Outputs, FMX.Bind.Editors, Data.Bind.Components,
  Data.Bind.Grid, Data.Bind.DBScope, FMX.Layouts, FMX.Objects,
  FMX.Platform; // Para la rotacion del movil.

type
  TfrmInventario = class(TForm)
    Panel1: TPanel;
    ToolBar1: TToolBar;
    BtnAtras: TButton;
    StringGrid1: TStringGrid;
    ScrollBox1: TScrollBox;
    BindSourceDB1: TBindSourceDB;
    BindingsList1: TBindingsList;
    LinkGridToDataSourceBindSourceDB1: TLinkGridToDataSource;
    Image1: TImage;
    procedure BtnAtrasClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInventario: TfrmInventario;

implementation

uses uMain;

{$R *.fmx}

procedure TfrmInventario.BtnAtrasClick(Sender: TObject);
begin
  close;
end;

procedure TfrmInventario.FormResize(Sender: TObject);
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
