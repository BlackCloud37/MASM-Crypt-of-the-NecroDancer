.386
.model flat, stdcall
option casemap :none
include function.inc
.code

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
_WinMain proc
		local	@stWndClass:WNDCLASSEX
		local	@stMsg:MSG
		invoke	GetModuleHandle,NULL
		mov	hInstance,eax
;********************************************************************
; 注册窗口类
;********************************************************************
		invoke RtlZeroMemory,addr @stWndClass,sizeof @stWndClass
		invoke LoadCursor,0,IDC_ARROW
		mov	@stWndClass.hCursor,eax
		push hInstance
		pop	@stWndClass.hInstance
		mov	@stWndClass.cbSize, sizeof WNDCLASSEX
		mov	@stWndClass.style, CS_HREDRAW or CS_VREDRAW
		mov	@stWndClass.lpfnWndProc, offset _ProcWinMain
		mov	@stWndClass.hbrBackground, COLOR_WINDOW + 1
		mov	@stWndClass.lpszClassName, offset szClassName
		invoke	RegisterClassEx, addr @stWndClass
;********************************************************************
; 建立并显示窗口
;********************************************************************
		invoke	CreateWindowEx,WS_EX_CLIENTEDGE,\
			offset szClassName,offset szClassName,\
			WS_OVERLAPPEDWINDOW,\
			100, 100, 1024, 768,\
			NULL,NULL,hInstance,NULL
		mov	hWinMain,eax
		invoke	ShowWindow, hWinMain, SW_SHOWNORMAL
		invoke	UpdateWindow, hWinMain
;********************************************************************
; 消息循环
;********************************************************************
		.while	TRUE
			invoke	GetMessage,addr @stMsg,NULL,0,0
			.break	.if eax	== 0
			invoke	TranslateMessage, addr @stMsg
			invoke	DispatchMessage, addr @stMsg
		.endw
		ret

_WinMain	endp
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
start:
		call	_WinMain
		invoke	ExitProcess,NULL
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		end	start
