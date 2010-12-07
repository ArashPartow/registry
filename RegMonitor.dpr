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

program RegMonitor;

uses
  Forms,
  MainFrm in 'MainFrm.pas' {MainForm},
  RegistryWatchDog in 'RegistryWatchDog.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
