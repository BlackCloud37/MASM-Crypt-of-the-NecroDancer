.386
.model flat, stdcall
option casemap :none
include function.inc

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ICO_MAIN equ 1000h
ID_TIMER equ 1

BEAT_INTERVAL equ 1000  ;ms
TOLERANCE_INTERVAL equ 200 ;ms


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data?

hInstance dd ?
hWinMain dd	?
dwBaseTick dword ?
dbTestString db 20 dup(?)

.const
szClassName db 'Window',0
szBgmFilePath db '.\media\bgm.wav',0
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 代码段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.code
_ProcWinMain proc uses ebx edi esi hWnd,uMsg,wParam,lParam
		local @stPS:PAINTSTRUCT
		mov	eax, uMsg
		.if eax == WM_KEYDOWN
			; TODO: handle it 
			invoke GetTickCount
			sub eax, dwBaseTick ; TODO: maybe should use uMsg's time here?
			.if (eax > BEAT_INTERVAL - TOLERANCE_INTERVAL)
				mov eax, wParam
				.if eax == 37 ; left
					invoke MessageBeep, -1
				.elseif eax == 38 ; up
					invoke MessageBeep, -1
				.elseif eax == 39 ; right
					invoke MessageBeep, -1
				.elseif eax == 40 ; down
					invoke MessageBeep, -1
				.endif
			.endif

		.elseif	eax == WM_TIMER
			; TODO: update status
			invoke GetTickCount
			mov dwBaseTick, eax

			; and then re-paint
			invoke InvalidateRect,hWnd,NULL,TRUE

;********************************************************************
		.elseif	eax ==	WM_PAINT
			invoke BeginPaint,hWnd,addr @stPS
			; TODO: paint current status
			invoke EndPaint,hWnd,addr @stPS
		
		.elseif	eax ==	WM_CREATE
			; TODO: do init here
			; TODO: play music
			invoke SetTimer,hWnd,ID_TIMER,BEAT_INTERVAL,NULL
			invoke GetTickCount
			invoke PlaySound, offset szBgmFilePath, NULL, SND_ASYNC or SND_FILENAME or SND_LOOP
			mov dwBaseTick, eax
;********************************************************************
		
		.elseif	eax ==	WM_CLOSE
			; TODO: do destroy here
			invoke KillTimer,hWnd,ID_TIMER
			invoke DestroyWindow,hWinMain
			invoke PostQuitMessage,NULL
;********************************************************************
		.else
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
			ret
		.endif
;********************************************************************
		xor	eax,eax
		ret

_ProcWinMain endp



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
			100,100,250,270,\
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
