program AutonoLux;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uConfiguracion in 'uConfiguracion.pas' {frmConfiguracion},
  uConsumo in 'uConsumo.pas' {frmConsumo};

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConfiguracion, frmConfiguracion);
  Application.CreateForm(TfrmConsumo, frmConsumo);
  Application.Run;
end.
