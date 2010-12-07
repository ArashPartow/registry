(*************************************************************************)
(*                                                                       *)
(*                  Win32 Registry Monitor Tool                          *)
(*                                                                       *)
(* Author: Arash Partow - 2006                                           *)
(* URL: http://www.partow.net/programming/registrymonitor/index.html     *)
(*                                                                       *)
(* Note:                                                                 *)
(* 1. Currently keys that require monitoring must be statically added to *)
(*    the MainFrm unit (line 85), also remembering to increment the      *)
(*    variable MaxMonitoredRegKey.                                       *)
(*                                                                       *)
(* 2. For the tool to work properly it must be executed in a privileged  *)
(*    mode such as administrator.                                        *)
(*                                                                       *)
(* 3. The tool is not invariant to concurrent registry changes hence may *)
(*    provide an incorrect access output if more than one thread or      *)
(*    process is modifying the registry at any one time.                 *)
(*                                                                       *)
(* 4. Techniques and patterns used in the tool were taken from the MSDN  *)
(*    and borland.public.delphi.winapi.                                  *)
(*                                                                       *)
(*                                                                       *)
(* Copyright notice:                                                     *)
(* Free use of the Simple Win32 Registry Monitor Tool is permitted under *)
(* the guidelines and in accordance with the most current version of the *)
(* Common Public License.                                                *)
(* http://www.opensource.org/licenses/cpl.php                            *)
(*                                                                       *)
(*************************************************************************)

unit MainFrm;

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
  ExtCtrls,
  RegistryWatchDog;


type
  TMainForm = class(TForm)
    StartButton     : TButton;
    CloseButton     : TButton;
    RegistryKeyList : TListBox;
    AccessLog       : TMemo;
    Bevel1          : TBevel;
    Label1          : TLabel;
    Label2          : TLabel;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);

  private
    RegistryWatchdogList : TList;
    procedure NotificationEvent(Report : TStringList);
  public

  end;

  TRegKeyInfo = Record
    RootKey : HKey;
    Key     : String;
  end;

const MaxMonitoredRegKey = 2;
const MonitoredRegKey : array [1..MaxMonitoredRegKey] of TRegKeyInfo = (
                                                                        (RootKey : HKEY_CURRENT_USER;  Key : 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'),
                                                                        (RootKey : HKEY_LOCAL_MACHINE; Key : 'SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce')
                                                                       );
var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegistryWatchdogList := TList.Create;
end;


procedure TMainForm.StartButtonClick(Sender: TObject);
var
  i : Integer;
begin
  if not assigned(RegistryWatchdogList) then exit;
  for i := 1 to MaxMonitoredRegKey do
  begin
    RegistryKeyList.Items.Add(RootKeyToString(MonitoredRegKey[i].RootKey) + '\' + MonitoredRegKey[i].Key);
    RegistryWatchdogList.Add(TRegistryWatchdog.Create(MonitoredRegKey[i].RootKey,MonitoredRegKey[i].Key,NotificationEvent));
  end;
  for i := 0 to RegistryWatchdogList.Count - 1 do
  begin
    TRegistryWatchdog(RegistryWatchdogList[i]).Resume;
  end;
end;


procedure TMainForm.CloseButtonClick(Sender: TObject);
var
  i : Integer;
begin
  if not Assigned(RegistryWatchdogList) then exit;
  for i := 0 to RegistryWatchdogList.Count - 1 do
  begin
    TRegistryWatchdog(RegistryWatchdogList[i]).Terminate;
    TRegistryWatchdog(RegistryWatchdogList[i]).Free;
  end;
  RegistryWatchdogList.Free;
  Close;
end;


procedure TMainForm.NotificationEvent(Report : TStringList);
begin
  AccessLog.Lines.AddStrings(Report);
  Application.ProcessMessages;
end;


end.
