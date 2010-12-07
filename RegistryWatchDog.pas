(*************************************************************************)
(*                                                                       *)
(*                Simple Win32 Registry Monitor Tool                     *)
(*                                                                       *)
(* Author: Arash Partow - 2006                                           *)
(* URL: http://www.partow.net/programming/registrymonitor/index.html     *)
(*                                                                       *)
(* Copyright notice:                                                     *)
(* Free use of the Simple Win32 Registry Monitor Tool is permitted under *)
(* the guidelines and in accordance with the most current version of the *)
(* Common Public License.                                                *)
(* http://www.opensource.org/licenses/cpl.php                            *)
(*                                                                       *)
(*************************************************************************)


unit RegistryWatchDog;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  Registry;


const
  RegistryMonitorFilter = REG_NOTIFY_CHANGE_NAME       or
                          REG_NOTIFY_CHANGE_ATTRIBUTES or
                          REG_NOTIFY_CHANGE_LAST_SET   or
                          REG_NOTIFY_CHANGE_SECURITY;

type

  TRegistryKeyCache = class
  private
    FSane               : Boolean;
    FRootKey            : HKey;
    FKey                : string;
    FOriginalKeyNames   : TStringList;
    FOriginalValueNames : TStringList;

    function    GetRootKeystring : string;

  public
    constructor Create(const AKey : string; const ARootKey : HKey);
    destructor  Destroy;  override;

    function CreateAdditionalDifferenceList(KeyList,ValueList: TStringList) : Boolean;
    function CreateRemovedDifferenceList   (KeyList,ValueList: TStringList) : Boolean;
    function RefreshCache                                                   : Boolean;
    procedure GenerateDifferenceReport(Report : TStringList);

    property RootKey : string  read GetRootKeystring;
    property Key     : string  read FKey;

  end;

  TNotificationCallBack = procedure(AReport : TStringList) of object;

  TRegistryWatchdog = class(TThread)
  private
    FReg                  : TRegistry;
    FEvent                : Integer;
    FKey                  : string;
    FRootKey              : HKey;
    FNotificationCallBack : TNotificationCallBack;
    FCache                : TRegistryKeyCache;

    procedure InitThread;

  public
    constructor Create(const ARootKey  : HKey;
                       const AKey      : string;
                       const ACallBack : TNotificationCallBack);
    destructor  Destroy; override;

    property Key        : string    read FKey       write FKey;
    property RootKey    : HKey      read FRootKey   write FRootKey;

  protected
    procedure Execute; override;
  end;


function RootKeyToString(const RootKey : HKey) : string;

implementation

function RootKeyToString(const RootKey : HKey) : string;
begin
  case RootKey of
     HKEY_CLASSES_ROOT     : Result := 'HKEY_CLASSES_ROOT';
     HKEY_CURRENT_USER     : Result := 'HKEY_CURRENT_USER';
     HKEY_LOCAL_MACHINE    : Result := 'HKEY_LOCAL_MACHINE';
     HKEY_USERS            : Result := 'HKEY_USERS';
     HKEY_PERFORMANCE_DATA : Result := 'HKEY_PERFORMANCE_DATA';
     HKEY_CURRENT_CONFIG   : Result := 'HKEY_CURRENT_CONFIG';
     HKEY_DYN_DATA         : Result := 'HKEY_DYN_DATA';
    else
      Result := 'UNKNOWN';
  end
end;


{ TRegistryKeyCache }
constructor TRegistryKeyCache.Create(const AKey : string; const ARootKey : HKey);
var
  Reg : TRegistry;
begin
  FSane := False;
  Reg := TRegistry.Create;
  try
    FRootKey            := ARootKey;
    FKey                := AKey;
    Reg.RootKey := FRootKey;
    if not Reg.OpenKey(FKey, False) then exit;
    FSane                      := True;
    FOriginalKeyNames          := TStringList.Create;
    FOriginalValueNames        := TStringList.Create;
    FOriginalKeyNames.Sorted   := True;
    FOriginalValueNames.Sorted := True;
    Reg.GetKeyNames  (FOriginalKeyNames  );
    Reg.GetValueNames(FOriginalValueNames);
  finally
    Reg.Free;
  end;
end;


destructor TRegistryKeyCache.destroy;
begin
  if Assigned(FOriginalKeyNames  ) then FOriginalKeyNames  .Free;
  if Assigned(FOriginalValueNames) then FOriginalValueNames.Free;
end;

function TRegistryKeyCache.GetRootKeystring : string;
begin
  Result := RootKeyToString(FRootKey);
end;

function TRegistryKeyCache.CreateAdditionalDifferenceList(KeyList,ValueList: TStringList) : Boolean;
var
  I                 : Integer;
  Reg               : TRegistry;
  CurrentKeyNames   : TStringList;
  CurrentValueNames : TStringList;
begin
  Result := False;
  if not FSane               then exit;
  if not assigned(KeyList)   then exit;
  if not assigned(ValueList) then exit;

  Reg               := TRegistry.Create;
  CurrentKeyNames   := TStringList.Create;
  CurrentValueNames := TStringList.Create;

  try
    Reg.RootKey := FRootKey;
    if not Reg.OpenKey(FKey, False) then exit;

    Reg.GetValueNames(CurrentValueNames);
    Reg.GetKeyNames  (CurrentKeyNames);

    KeyList.Clear;
    ValueList.Clear;

    for i := 0 to CurrentValueNames.Count - 1 do
    begin
      if FOriginalValueNames.IndexOf(CurrentValueNames[i]) = -1 then
      begin
        ValueList.Add(CurrentValueNames[i]);
      end;
    end;

    for i := 0 to CurrentKeyNames.Count - 1 do
    begin
      if FOriginalKeyNames.IndexOf(CurrentKeyNames[i]) = -1 then
      begin
        KeyList.Add(CurrentKeyNames[i]);
      end;
    end;

    Result := True;
  finally
    Reg.Free;
    CurrentKeyNames.Free;
    CurrentValueNames.Free;
  end;
end;


function TRegistryKeyCache.CreateRemovedDifferenceList(KeyList,ValueList: TStringList) : Boolean;
var
  I                 : Integer;
  Reg               : TRegistry;
  CurrentKeyNames   : TStringList;
  CurrentValueNames : TStringList;
begin
  Result := False;

  if not FSane               then exit;
  if not assigned(KeyList)   then exit;
  if not assigned(ValueList) then exit;

  Reg               := TRegistry.Create;
  CurrentKeyNames   := TStringList.Create;
  CurrentValueNames := TStringList.Create;

  try
    Reg.RootKey := FRootKey;
    if not Reg.OpenKey(FKey, False) then exit;

    Reg.GetValueNames(CurrentValueNames);
    Reg.GetKeyNames  (CurrentKeyNames);

    KeyList.Clear;
    ValueList.Clear;

    for i := 0 to FOriginalValueNames.Count - 1 do
    begin
      if CurrentValueNames.IndexOf(FOriginalValueNames[i]) = -1 then
      begin
        ValueList.Add(FOriginalValueNames[i]);
      end;
    end;

    for i := 0 to FOriginalKeyNames.Count - 1 do
    begin
      if CurrentKeyNames.IndexOf(FOriginalKeyNames[i]) = -1 then
      begin
        KeyList.Add(FOriginalKeyNames[i]);
      end;
    end;

    Result := True;

  finally
    Reg.Free;
    CurrentKeyNames.Free;
    CurrentValueNames.Free;
  end;
end;


function TRegistryKeyCache.RefreshCache : Boolean;
var
  Reg : TRegistry;
begin
  Result := False;
  FSane  := False;
  Reg    := TRegistry.Create;
  try
    Reg.RootKey := FRootKey;
    if not Reg.OpenKey(FKey, False) then exit;
    FOriginalKeyNames.Clear;
    FOriginalValueNames.Clear;
    FSane                      := True;
    FOriginalKeyNames.Sorted   := True;
    FOriginalValueNames.Sorted := True;
    Reg.GetKeyNames  (FOriginalKeyNames  );
    Reg.GetValueNames(FOriginalValueNames);
    Result := True;
  finally
    Reg.Free;
  end;
end;


procedure TRegistryKeyCache.GenerateDifferenceReport(Report:TStringList);
var
  i                 : Integer;
  NewKeysList       : TStringList;
  NewValuesList     : TStringList;
  RemovedKeysList   : TStringList;
  RemovedValuesList : TStringList;
begin
  if not Assigned(Report) then exit;
  NewKeysList       := TStringList.Create;
  NewValuesList     := TStringList.Create;
  RemovedKeysList   := TStringList.Create;
  RemovedValuesList := TStringList.Create;

  try
    CreateAdditionalDifferenceList(NewKeysList,    NewValuesList    );
    CreateRemovedDifferenceList   (RemovedKeysList,RemovedValuesList);

    for i := 0 to NewKeysList.Count - 1 do
    begin
      Report.Add(Format('%s    added key "%s" to %s',[TimeToStr(Time),NewKeysList[i],(RootKeyToString(FRootKey) + '\' + FKey)]));
    end;

    for i := 0 to NewValuesList.Count - 1 do
    begin
      Report.Add(Format('%s    added value "%s" to %s',[TimeToStr(Time),NewValuesList[i],(RootKeyToString(FRootKey) + '\' + FKey)]));
    end;


    for i := 0 to RemovedKeysList.Count - 1 do
    begin
      Report.Add(Format('%s    removed key "%s" to %s',[TimeToStr(Time),RemovedKeysList[i],(RootKeyToString(FRootKey) + '\' + FKey)]));
    end;

    for i := 0 to RemovedValuesList.Count - 1 do
    begin
      Report.Add(Format('%s    removed value "%s" to %s',[TimeToStr(Time),RemovedValuesList[i],(RootKeyToString(FRootKey) + '\' + FKey)]));
    end;

    RefreshCache;
    NewKeysList.Clear;
    NewValuesList.Clear;
    RemovedKeysList.Clear;
    RemovedValuesList.Clear;

  finally
    NewKeysList.Free;
    NewValuesList.Free;
    RemovedKeysList.Free;
    RemovedValuesList.Free;
  end;
end;


{ TRegistryWatchdog }
constructor TRegistryWatchdog.Create(const ARootKey  : HKey;
                                     const AKey      : string;
                                     const ACallBack : TNotificationCallBack);
begin
  inherited Create(True);
  FReg     := TRegistry.Create;
  FRootKey := ARootKey;
  FKey     := AKey;
  FCache   := TRegistryKeyCache.Create(FKey,FRootKey);
  FNotificationCallBack := ACallBack;
end;


destructor TRegistryWatchdog.Destroy;
begin
  FReg.Free;
  inherited;
end;


procedure TRegistryWatchdog.InitThread;
begin
  FReg.RootKey := FRootKey;
  if not FReg.OpenKeyReadOnly(FKey) then
  begin
    raise Exception.Create('ERROR : Unable to open registry key ' + FKey);
  end;
  FEvent := CreateEvent(Nil, True, False, 'RegistryChangeMonitorEvent');
  RegNotifyChangeKeyValue(FReg.CurrentKey, True, RegistryMonitorFilter, FEvent, True);
end;


procedure TRegistryWatchdog.Execute;
var
  Report : TStringList;
begin
  Report := TStringList.Create;
  try
    InitThread;
    while not Terminated do
    begin
      if WaitForSingleObject(FEvent, INFINITE) = WAIT_OBJECT_0 then
      begin
        FCache.GenerateDifferenceReport(Report);
        if assigned(FNotificationCallBack) then FNotificationCallBack(Report);
        Report.Clear;
        ResetEvent(FEvent);
        RegNotifyChangeKeyValue(FReg.CurrentKey, True, RegistryMonitorFilter, FEvent, True);
      end;
    end;
  finally
    Report.Free;
  end;
end;


end.
