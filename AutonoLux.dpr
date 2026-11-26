program AutonoLux;

uses
  Forms,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uConfiguracion in 'uConfiguracion.pas' {frmConfiguracion},
  uConsumo in 'uConsumo.pas' {frmConsumo},
  uIluminacion in 'uIluminacion.pas' {frmIluminacion},
  uContador in 'uContador.pas' {frmContador},
  uMapa in 'uMapa.pas' {frmMapa};

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConfiguracion, frmConfiguracion);
  Application.CreateForm(TfrmConsumo, frmConsumo);
  Application.CreateForm(TfrmIluminacion, frmIluminacion);
  Application.CreateForm(TfrmContador, frmContador);
  Application.CreateForm(TfrmMapa, frmMapa);
  Application.Run;
end.
