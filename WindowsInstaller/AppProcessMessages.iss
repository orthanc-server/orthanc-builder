// https://stackoverflow.com/a/44840244/881731
// https://stackoverflow.com/a/32266687/881731

type
  TMsg = record
    hwnd: HWND;
    message: UINT;
    wParam: Longint;
    lParam: Longint;
    time: DWORD;
    pt: TPoint;
  end;
 
const
  PM_REMOVE      = 1;
 
function PeekMessage(var lpMsg: TMsg; hWnd: HWND; wMsgFilterMin, wMsgFilterMax, wRemoveMsg: UINT): BOOL;
external 'PeekMessageA@user32.dll stdcall';

function TranslateMessage(const lpMsg: TMsg): BOOL;
external 'TranslateMessage@user32.dll stdcall';

function DispatchMessage(const lpMsg: TMsg): Longint;
external 'DispatchMessageA@user32.dll stdcall';
 

procedure AppProcessMessages();
var
  Msg: TMsg;
begin
  while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end;
end;
