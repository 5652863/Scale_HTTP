unit uMainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, clSimpleHttpServer,clHttpUtils,clHttpRequest,
  uScaleServer,System.Threading;

type
  TMainForm = class(TForm)
    Button1: TButton;
    simpleServer: TclSimpleHttpServer;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FDestoying : boolean;
    Fsrv : TScaleServerHTTP;
    procedure StartTask;
  end;

var
  MainForm: TMainForm;

implementation
 uses uScale;
{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var
 d : double;
 s : string;
begin
  if not ScaleProvider.GetLocalWeight('Main',d,s) then raise Exception.Create(s);
  d := d * 1000;
  showmessage(Floattostr(d)+' гр.');
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 FDestoying := true;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
 lsl : TStringList;
begin
Fsrv := TScaleServerHTTP.Create;
lsl := TStringList.Create;
lsl.LoadFromFile(IncludeTrailingBackslash(ExtractFileDir(Application.ExeName))+'scale.ini');
Fsrv.Init(lsl);
lsl.Free;
FDestoying := false;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
Fsrv.Free;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
StartTask;
end;

procedure TMainForm.StartTask;
var
 task: ITask;
begin
  task := TTask.Create(procedure ()
      begin
        while true do
        begin
         if FDestoying then exit;
         Fsrv.ExecuteListen;
         application.ProcessMessages;
        end;
      end);
   //Запускаем задачу.
   task.Start;
end;

end.
