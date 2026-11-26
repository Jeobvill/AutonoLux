program AutonoLux;

uses
  Forms,
  uPrincipal in 'Formas\uPrincipal.pas' {frmPrincipal},
  uConfiguracion in 'Formas\uConfiguracion.pas' {frmConfiguracion},
  uConsumo in 'Formas\uConsumo.pas' {frmConsumo},
  uIluminacion in 'Formas\uIluminacion.pas' {frmIluminacion},
  uContador in 'Formas\uContador.pas' {frmContador},
  uMapa in 'Formas\uMapa.pas' {frmMapa},
  uComun in 'Formas\uComun.pas',
  uMonitor in 'Formas\uMonitor.pas' {frmMonitor},
  uCalor in 'Formas\uCalor.pas' {frmCalor},
  uBitacora in 'Formas\uBitacora.pas' {frmBitacora};

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConfiguracion, frmConfiguracion);
  Application.CreateForm(TfrmConsumo, frmConsumo);
  Application.CreateForm(TfrmIluminacion, frmIluminacion);
  Application.CreateForm(TfrmContador, frmContador);
  Application.CreateForm(TfrmMapa, frmMapa);
  Application.CreateForm(TfrmMonitor, frmMonitor);
  Application.CreateForm(TfrmCalor, frmCalor);
  Application.CreateForm(TfrmBitacora, frmBitacora);
  Application.Run;
end.
