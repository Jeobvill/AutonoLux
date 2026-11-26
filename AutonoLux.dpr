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
  uBitacora in 'Formas\uBitacora.pas' {frmBitacora},
  uAxelComun in 'Formas\uAxelComun.pas',
  uLogin in 'Formas\uLogin.pas' {frmLogin},
  uReporte in 'Formas\uReporte.pas' {frmReporte},
  uAcerca in 'Formas\uAcerca.pas' {frmAcerca},
  uCalcBase in 'Formas\uCalcBase.pas',
  uCalcSergio in 'Formas\uCalcSergio.pas',
  uCalcDaniel in 'Formas\uCalcDaniel.pas',
  uCalcJesus in 'Formas\uCalcJesus.pas',
  uCalcAxel in 'Formas\uCalcAxel.pas',
  uVideo in 'Formas\uVideo.pas',
  uVisor in 'Formas\uVisor.pas';

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
  Application.CreateForm(TfrmLogin, frmLogin);
  Application.CreateForm(TfrmReporte, frmReporte);
  Application.CreateForm(TfrmAcerca, frmAcerca);
  Application.Run;
end.
