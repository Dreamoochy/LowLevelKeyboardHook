unit main;

{$mode ObjFPC}{$H+}

interface

uses
  KeyPressThread,
  Messages,
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

const
  WM_HOOK_NOTIFY = WM_USER + 100;

type

  { TMainForm }

  TMainForm = class( TForm )
    btnHookInstall   : TButton;
    btnHookUninstall : TButton;

    procedure btnHookInstallClick  ( Sender: TObject );
    procedure btnHookUninstallClick( Sender: TObject );
    procedure FormCreate ( Sender: TObject );
    procedure FormDestroy( Sender: TObject );
  private
    FKeypressThread : TKeyPressThread;
    procedure WMHookNotify( var Message: TMessage ); message WM_HOOK_NOTIFY;
  public

  end;

var
  MainForm: TMainForm;

implementation

{$R *.lfm}

function InstallHook( hWindow: THandle ): boolean; stdcall; external 'LibHook.dll' name 'InstallHook';
function UninstallHook(): boolean; stdcall; external 'LibHook.dll' name 'UninstallHook';

{ TMainForm }

procedure TMainForm.btnHookInstallClick( Sender: TObject );
begin
  InstallHook( Self.Handle );
end;

procedure TMainForm.btnHookUninstallClick( Sender: TObject );
begin
  UninstallHook();
end;

procedure TMainForm.FormCreate( Sender: TObject );
begin
  FKeypressThread := TKeyPressThread.Create( False );
end;

procedure TMainForm.FormDestroy( Sender: TObject );
begin
  FKeypressThread.Terminate();
end;

procedure TMainForm.WMHookNotify( var Message: TMessage );
begin
  if ( not Assigned(FKeypressThread) ) then Exit;

  FKeypressThread.Active := ( Message.wParam = WM_KEYDOWN );
end;

end.

