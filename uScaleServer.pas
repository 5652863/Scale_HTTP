unit uScaleServer;

interface
uses clSimpleHttpServer,Classes,clHttpUtils,clHttpHeader,clHeaderFieldList,clHttpRequest,
clSocketUtils, clUtils, clTranslator;

type
TclHttpResponseHeaderExt = class(TclHttpResponseHeader)
  private
    FAccessControlAllowOrigin: string;
    FAccessControlAllowMethods: string;
    FAccessControlAllowHeaders: string;
    FAccessControlAllowPrivateNetwork: string;
    procedure SetAccessControlAllowHeaders(const Value: string);
    procedure SetAccessControlAllowMethods(const Value: string);
    procedure SetAccessControlAllowOrigin(const Value: string);
    procedure SetAccessControlAllowPrivateNetwork(const Value: string);
  protected
    procedure RegisterFields; override;
    procedure InternalParseHeader(AFieldList: TclHeaderFieldList); override;
    procedure InternalAssignHeader(AFieldList: TclHeaderFieldList); override;
  public
    procedure Clear; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AccessControlAllowOrigin: string read FAccessControlAllowOrigin write SetAccessControlAllowOrigin;
    property AccessControlAllowHeaders: string read FAccessControlAllowHeaders write SetAccessControlAllowHeaders;
    property AccessControlAllowMethods: string read FAccessControlAllowMethods write SetAccessControlAllowMethods;
    property AccessControlAllowPrivateNetwork : string read FAccessControlAllowPrivateNetwork write SetAccessControlAllowPrivateNetwork;
  end;


 TclSimpleHttpServerExt = class(TclSimpleHttpServer)
  private
    procedure SetResponseHeader(const Value: TclHttpResponseHeaderExt);
    function GetResponseHeader: TclHttpResponseHeaderExt;
  public
  constructor Create(AOwner: TComponent); override;
  property ResponseHeader: TclHttpResponseHeaderExt read GetResponseHeader write SetResponseHeader;
 end;


 TScaleServerHTTP = class
   private
    FPort: integer;
    FHTTPServer: TclSimpleHttpServerExt;
   public
   constructor Create;
   destructor Destroy;
   procedure Init(aIni : TStringList);
   procedure ExecuteListen;
   property HTTPServer: TclSimpleHttpServerExt read FHTTPServer;
   property Port : integer read FPort;
 end;
implementation
uses sysutils,uScale;

{ TScaleServerHTTP }

constructor TScaleServerHTTP.Create;
begin
 FHTTPServer := TclSimpleHttpServerExt.Create(nil);
 FHTTPServer.ServerName := 'Scale server';
 FHTTPServer.SessionTimeOut := 600;
end;

destructor TScaleServerHTTP.Destroy;
begin
 FreeAndNil(FHTTPServer);
end;

procedure TScaleServerHTTP.ExecuteListen;
var
  lport : integer;
  httpRequest : TclHttpRequest;
  //httpRequest : TStringList;
  d : double;
  lfs : TFormatSettings;
  s : string;
  stream: TStream;
  buffer: TclByteArray;
begin
try

  httpRequest := TclHttpRequest.Create(nil);
  //httpRequest := TStringList.Create;
  try
    lport := HTTPServer.Listen(Port);
    //if HTTPServer.RequestUri = '' then exit;
    try
    HTTPServer.AcceptRequest(httpRequest);
    except
      on e : exception
       do begin
         Exit; //если будет raise Exception то сервер дохнет
         if e.InheritsFrom(EclSocketError) and ((e as EclSocketError).ErrorCode = TimeoutOccurredCode)
          then exit
          else raise Exception.Create(e.Message);
       end;
    end;

    if (HTTPServer.RequestMethod = 'OPTIONS')
    then
    begin
     HTTPServer.ResponseHeader.ContentType := 'text/html';
     HTTPServer.ResponseHeader.AccessControlAllowOrigin := '*';
     HTTPServer.ResponseHeader.AccessControlAllowHeaders := 'origin, x-requested-with, content-type, x-csrf-token';
     HTTPServer.ResponseHeader.AccessControlAllowMethods := 'GET, POST, OPTIONS';
     HTTPServer.ResponseHeader.AccessControlAllowPrivateNetwork := 'true';
     HTTPServer.SendResponse(200, '', '');
    end
    else

    if (HTTPServer.RequestMethod = 'GET')
        and (HTTPServer.RequestUri = '/weight')
    then
    begin
       HTTPServer.ResponseVersion := hvHttp1_1;
       HTTPServer.ResponseHeader.ContentType := 'application/json';
       HTTPServer.ResponseHeader.AccessControlAllowOrigin := '*';
       //HTTPServer.ResponseHeader.AccessControlAllowPrivateNetwork := 'true';
       HTTPServer.KeepConnection := False;
    //  if random(100) < 50 then begin
        if not ScaleProvider.GetLocalWeight('Main',d,s) then raise Exception.Create('Error: Could not open port '+s);
     // end
     // else d := 999;

      d := d ;
      lfs.DecimalSeparator := '.';
      HTTPServer.SendResponse(200, 'OK', '{"state": "S","weight":'+FloatToStr(d,lfs)+',"unit":"kg"}');
    end else
    begin
       HTTPServer.ResponseVersion := hvHttp1_1;
       HTTPServer.ResponseHeader.ContentType := 'text/html';
       HTTPServer.KeepConnection := False;

       HTTPServer.SendResponse(200, 'OK', 'Error: unkhown uri');
    end;
  finally httpRequest.Free; end;
except
 on e : exception
 do begin
       HTTPServer.ResponseVersion := hvHttp1_1;
       HTTPServer.ResponseHeader.ContentType := 'text/html';
       HTTPServer.KeepConnection := False;
       HTTPServer.SendResponse(200, 'OK', 'Error: '+e.Message);

 end;
end;
end;

procedure TScaleServerHTTP.Init(aIni: TStringList);
begin
   if not TryStrToInt(aIni.Values['http_port'],FPort)
    then raise exception.Create('Не указан http_port в ini файле');
    ScaleProvider.registerScale('Main', aIni);
end;

{ TclSimpleHttpServerExt }

constructor TclSimpleHttpServerExt.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FResponseHeader.Free;
  FResponseHeader := TclHttpResponseHeaderExt.Create();
end;


function TclSimpleHttpServerExt.GetResponseHeader: TclHttpResponseHeaderExt;
begin
 Result := inherited ResponseHeader as TclHttpResponseHeaderExt;
end;

procedure TclSimpleHttpServerExt.SetResponseHeader(
  const Value: TclHttpResponseHeaderExt);
begin
  inherited ResponseHeader := Value;
end;

{ TclHttpResponseHeaderExt }

procedure TclHttpResponseHeaderExt.Assign(Source: TPersistent);
var
  Src: TclHttpResponseHeaderExt;
begin
  BeginUpdate();
  try
    inherited Assign(Source);

    if (Source is TclHttpResponseHeaderExt) then
    begin
      Src := (Source as TclHttpResponseHeaderExt);
      AccessControlAllowOrigin := Src.AccessControlAllowOrigin;
      AccessControlAllowHeaders := Src.AccessControlAllowHeaders;
      AccessControlAllowMethods := Src.AccessControlAllowMethods;
      AccessControlAllowPrivateNetwork := Src.AccessControlAllowPrivateNetwork;
    end;
  finally
    EndUpdate();
  end;
end;

procedure TclHttpResponseHeaderExt.Clear;
begin
  BeginUpdate();
  try
    inherited Clear();
    AccessControlAllowOrigin := '';
    AccessControlAllowHeaders := '';
    AccessControlAllowMethods := '';
    AccessControlAllowPrivateNetwork := '';
  finally
    EndUpdate();
  end;
end;

procedure TclHttpResponseHeaderExt.InternalAssignHeader(
  AFieldList: TclHeaderFieldList);
begin
  AFieldList.AddField('Access-Control-Allow-Origin', AccessControlAllowOrigin);
  AFieldList.AddField('Access-Control-Allow-Headers', AccessControlAllowHeaders);
  AFieldList.AddField('Access-Control-Allow-Methods', AccessControlAllowMethods);
  AFieldList.AddField('Access-Control-Allow-Private-Network', AccessControlAllowPrivateNetwork);

  inherited InternalAssignHeader(AFieldList);
end;

procedure TclHttpResponseHeaderExt.InternalParseHeader(
  AFieldList: TclHeaderFieldList);
begin
  inherited InternalParseHeader(AFieldList);

  AccessControlAllowOrigin := AFieldList.GetFieldValue('Access-Control-Allow-Origin');
  AccessControlAllowHeaders := AFieldList.GetFieldValue('Access-Control-Allow-Headers');
  AccessControlAllowMethods := AFieldList.GetFieldValue('Access-Control-Allow-Methods');
  AccessControlAllowPrivateNetwork := AFieldList.GetFieldValue('Access-Control-Allow-Private-Network');
end;

procedure TclHttpResponseHeaderExt.RegisterFields;
begin
  inherited RegisterFields();

  RegisterField('Access-Control-Allow-Origin');
  RegisterField('Access-Control-Allow-Headers');
  RegisterField('Access-Control-Allow-Methods');
  RegisterField('Access-Control-Allow-Private-Network');
end;

procedure TclHttpResponseHeaderExt.SetAccessControlAllowHeaders(
  const Value: string);
begin
  if (FAccessControlAllowHeaders <> Value) then
  begin
    FAccessControlAllowHeaders := Value;
    Update();
  end;

end;

procedure TclHttpResponseHeaderExt.SetAccessControlAllowMethods(
  const Value: string);
begin
  if (FAccessControlAllowMethods <> Value) then
  begin
    FAccessControlAllowMethods := Value;
    Update();
  end;
end;

procedure TclHttpResponseHeaderExt.SetAccessControlAllowOrigin(
  const Value: string);
begin
  if (FAccessControlAllowOrigin <> Value) then
  begin
    FAccessControlAllowOrigin := Value;
    Update();
  end;
end;

procedure TclHttpResponseHeaderExt.SetAccessControlAllowPrivateNetwork(
  const Value: string);
begin
  if (FAccessControlAllowPrivateNetwork <> Value) then
  begin
    FAccessControlAllowPrivateNetwork := Value;
    Update();
  end;
end;

end.
