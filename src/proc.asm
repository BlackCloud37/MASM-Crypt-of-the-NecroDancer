.386 
.model flat,stdcall 
option casemap:none

include function.inc

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
					invoke MessageBeep, 0
				.elseif eax == 38 ; up
					invoke MessageBeep, 0
				.elseif eax == 39 ; right
					invoke MessageBeep, 0
				.elseif eax == 40 ; down
					invoke MessageBeep, 0
				.endif
			.elseif
				; miss
				invoke MessageBeep, -1
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
end