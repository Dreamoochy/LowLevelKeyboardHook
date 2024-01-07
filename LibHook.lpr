library LibHook;

{$mode ObjFPC}{$H+}

uses
  Windows, Messages;

const
  WH_KEYBOARD_LL = 13;
  WM_HOOK_NOTIFY = WM_USER + 100;

type
  PKBDLLHOOKSTRUCT = ^TKBDLLHOOKSTRUCT;
  TKBDLLHOOKSTRUCT = packed record
    vkCode      : DWORD;
    scanCode    : DWORD;
    flags       : DWORD;
    time        : DWORD;
    dwExtraInfo : ULONG_PTR;
  end;

var
  hParentWnd : HANDLE;
  hKeybHook  : HHOOK;

function LLKeybHookProc( nCode: integer; wPar: WPARAM; lPar: LPARAM ): LRESULT; stdcall;
var
  isOK        : Boolean;
  pHookStruct : PKBDLLHOOKSTRUCT absolute lPar;

begin
  isOK := ( nCode >= 0 )
          and ( pHookStruct > Pointer(0) )
          and ( pHookStruct^.vkCode in [VK_LCONTROL, VK_RCONTROL] )
          and ( ( wPar = WM_KEYDOWN ) or ( wPar = WM_KEYUP ) );

  if ( not isOK ) then Exit( CallNextHookEx( hKeybHook, nCode, wPar, lPar) );

  PostMessage( hParentWnd, WM_HOOK_NOTIFY, wPar, 0 );
  Result := 0;
end;

procedure ClearHandles();
begin
  hParentWnd := INVALID_HANDLE_VALUE;
  hKeybHook  := 0;
end;

function InstallHook( hWnd: HANDLE ): boolean; stdcall;
begin
  Result := False;
  if ( hParentWnd <> INVALID_HANDLE_VALUE ) then Exit;

  hKeybHook := SetWindowsHookEx( WH_KEYBOARD_LL, @LLKeybHookProc, hInstance, 0 );

  if ( hKeybHook = 0 ) then Exit;

  hParentWnd := hWnd;

  Result := True;
end;

function UninstallHook(): boolean; stdcall;
begin
  if ( hKeybHook <> 0 ) then begin
    Result := UnhookWindowsHookEx( hKeybHook );
    if ( not Result ) then Exit;

    ClearHandles();
  end
  else
    Result := False;
end;

exports
  InstallHook,
  UninstallHook;

Procedure ProcessDetach(dllParam : PtrInt);
Begin
  UninstallHook();
End;

begin
  DLL_PROCESS_DETACH_Hook := @ProcessDetach;
  ClearHandles();
end.


