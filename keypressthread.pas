unit KeyPressThread;

{$mode ObjFPC}{$H+}

interface

uses Classes, Windows;

type

  { TKeyPressThread }

  TKeyPressThread = class( TThread )
    procedure Execute(); override;
  private
    FActive : Boolean;
  public
    Constructor Create( CreateSuspended : boolean );
    property Active: Boolean read FActive write FActive;
  end;

implementation

{ TKeyPressThread }

procedure TKeyPressThread.Execute();
var
  input: TINPUT;

begin
  input._Type        := INPUT_KEYBOARD;
  input.ki.wScan     := 0;              // hardware scan code for key
  input.ki.time      := 0;
  input.ki.ExtraInfo := 0;
  input.ki.wVk       := VK_UP;          // virtual-key code for the UP arrow key

  while ( not Terminated ) do begin
    if ( not FActive ) then begin
      sleep( 100 );
      continue;
    end;

    input.ki.dwFlags   := 0;              // 0 for key press
    SendInput( 1, @input, sizeof(TINPUT) );

    input.ki.dwFlags := KEYEVENTF_KEYUP;  // KEYEVENTF_KEYUP for key release
    SendInput( 1, @input, sizeof(TINPUT) );
  end;
end;

constructor TKeyPressThread.Create( CreateSuspended: boolean );
begin
  inherited Create( CreateSuspended );
  FActive := false;
  FreeOnTerminate := True;
end;

end.

