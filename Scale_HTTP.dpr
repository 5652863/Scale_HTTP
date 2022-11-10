program Scale_HTTP;

uses
  Vcl.Forms,
  uMainForm in 'uMainForm.pas' {MainForm},
  uScaleServer in 'uScaleServer.pas',
  CAS_AD_APLib_TLB in '..\..\Common\Scale\CAS_AD_APLib_TLB.pas',
  CasAD_AP_DB_EMLib_TLB in '..\..\Common\Scale\CasAD_AP_DB_EMLib_TLB.pas',
  uScale in '..\..\Common\Scale\uScale.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
