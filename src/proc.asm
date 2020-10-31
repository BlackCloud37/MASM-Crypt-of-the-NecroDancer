.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code

_InitResources proc
	invoke LoadImage, hInstance, addr szPlayerPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hPlayerBmp, eax
	invoke LoadImage, hInstance, addr szDirtyFloorPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hDirtyFloorBmp, eax
	ret
_InitResources endp






_DestroyResources proc
	invoke DeleteObject, hPlayerBmp
	invoke DeleteObject, hDirtyFloorBmp
	ret
_DestroyResources endp






startGame proc _level
	invoke initMap, _level
	invoke initPlayer, _level
	; Enemy
	invoke initEnemy, _level
	; Others
	mov paintWindowPosX, 0
	mov paintWindowPosY, 0
	ret
startGame endp








getMatrixIndex proc row, col, matWidth, matHeight
	; invalid pos
	mov eax, matWidth
	mov ecx, matHeight
	.if (col < 0) || (col >= eax) || (row < 0) || (row >= ecx)
		mov eax, -1
	.else ; return row*width+col
		mov eax, row
		mul matWidth
		add eax, col
	.endif
	ret
getMatrixIndex endp 











changeMapPosTo proc posX, posY, mapType
	invoke getMatrixIndex, posY, posX, MAP_WIDTH, MAP_HEIGHT
	shl eax, 2
	mov edx, mapType
	mov [mapMatrix + eax], edx
	ret
changeMapPosTo endp






initEnemy proc _level
	ret
initEnemy endp





initMap proc _level
	local @posX, @posY, @index
	; TODO: ¶ÁÎÄ¼þ
	mov @posY, 0
	.while (@posY < MAP_HEIGHT)
		mov @posX, 0
		push ecx
		.while (@posX < MAP_WIDTH)
			push ecx
			invoke changeMapPosTo, @posX, @posY, MAP_TYPE_DIRTY_FLOOR
			inc @posX
			pop ecx
		.endw
		inc @posY
		pop ecx
	.endw
	ret
initMap endp





updateStatus proc
	; TODO: player
	.if player.nextStep == STEP_UP
		dec player.posY
	.elseif player.nextStep == STEP_RIGHT
		inc player.posX
	.elseif player.nextStep == STEP_DOWN
		inc player.posY
	.elseif player.nextStep == STEP_LEFT
		dec player.posX
	.endif
	mov player.nextStep, STEP_NONE

	; Paint window
	mov eax, player.posX
	mov paintWindowPosX, eax
	mov ecx, (PAINT_WINDOW_WIDTH-1)/2
	.if paintWindowPosX < ecx
		mov paintWindowPosX, 0
	.else
		sub paintWindowPosX, ecx
	.endif
	.if paintWindowPosX > (MAP_WIDTH - PAINT_WINDOW_WIDTH)
		mov paintWindowPosX, MAP_WIDTH - PAINT_WINDOW_WIDTH
	.endif
	
	mov eax, player.posY
	mov paintWindowPosY, eax
	mov ecx, (PAINT_WINDOW_HEIGHT-1)/2
	.if paintWindowPosY < ecx
		mov paintWindowPosY, 0
	.elseif
		sub paintWindowPosY, ecx
	.endif
	.if paintWindowPosY > (MAP_HEIGHT - PAINT_WINDOW_HEIGHT)
		mov paintWindowPosY, MAP_HEIGHT - PAINT_WINDOW_HEIGHT
	.endif

updateStatus endp






getPicOfMapType proc mapType
	.if mapType == MAP_TYPE_DIRTY_FLOOR
		mov eax, hDirtyFloorBmp
	.endif
	ret
getPicOfMapType endp






initPlayer proc _level
	.if _level == FIRST_LEVEL
		mov player.posX, 0
		mov player.posY, 0
		mov player.health, 5
		mov player.attack, 1
		mov player.attackRangeType, ATTACK_MODE_NORMAL
		mov player.nextStep, STEP_NONE
		mov player.coinCount, 0
	.endif
	ret
initPlayer endp








_PaintGameFrame	proc hWnd, hDC
	pushad
	invoke _PaintMap, hWnd, hDC
	invoke _PaintPlayer, hWnd, hDC
	; TODO: Paint Enemy
	; TODO: Paint Other
	popad
	ret
_PaintGameFrame endp







_PaintMap proc hWnd, hDC
	local @posX, @posY, @type, @actualPosX, @actualPosY
	mov @posY, 0
	.while (@posY < PAINT_WINDOW_HEIGHT)
		mov @posX, 0
		push ecx
		.while(@posX < PAINT_WINDOW_WIDTH)
			push ecx
			mov eax, @posX
			mov @actualPosX, eax
			mov eax, paintWindowPosX
			add @actualPosX, eax
			mov eax, @posY
			mov @actualPosY, eax
			mov eax, paintWindowPosY
			add @actualPosY, eax
			invoke getMatrixIndex, @actualPosY, @actualPosX, MAP_WIDTH, MAP_HEIGHT
			shl eax, 2
			mov eax, [mapMatrix + eax]
			mov  @type, eax
			invoke getPicOfMapType, @type
			invoke _PaintObjectAtPos, @posY, @posX, eax, hWnd, hDC
			pop ecx
			inc @posX
		.endw
		inc @posY
		pop ecx
	.endw
	ret
_PaintMap endp




actualPosToPaintWindowPos proc actPosX, actPosY
	local @windowPosX, @windowPosY
	mov eax, actPosX
	sub eax, paintWindowPosX
	mov @windowPosX, eax
	
	mov eax, actPosY
	sub eax, paintWindowPosY
	mov @windowPosY, eax
	
	mov eax, @windowPosX
	mov ecx, @windowPosY
	ret
actualPosToPaintWindowPos endp




_PaintPlayer proc hWnd, hDC
	invoke actualPosToPaintWindowPos, player.posX, player.posY
	invoke _PaintObjectAtPos, ecx, eax, hPlayerBmp, hWnd, hDC
	ret
_PaintPlayer endp




_PaintEnemy	proc hWnd, hDC
	ret
_PaintEnemy endp




_PaintObjectAtPos proc row, col, objectHBmp, hWnd, hDC
	local @hDCmem
	local @posX, @posY
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	mov eax, hDirtyFloorBmp
	invoke SelectObject, @hDCmem, objectHBmp
	; calc x, y
	mov eax, GRID_SIZE
	mul col
	mov @posX, eax
	mov eax, GRID_SIZE
	mul row
	mov @posY, eax
	invoke BitBlt, hDC, @posX, @posY, GRID_SIZE, GRID_SIZE, @hDCmem, 0, 0, SRCCOPY
	invoke DeleteDC, @hDCmem
	ret
_PaintObjectAtPos endp





_ProcWinMain proc uses ebx edi esi hWnd,uMsg,wParam,lParam
		local @stPS:PAINTSTRUCT
		local @hDC
		local @stPos:POINT

		mov	eax, uMsg
		.if eax == WM_KEYDOWN
			; TODO: handle it 
			invoke GetTickCount
			sub eax, dwBaseTick ; TODO: maybe should use uMsg's time here?
			.if (eax > BEAT_INTERVAL - TOLERANCE_INTERVAL)
				mov eax, wParam
				.if eax == 37 ; left
					invoke MessageBeep, 0
					mov player.nextStep, STEP_LEFT
				.elseif eax == 38 ; up
					invoke MessageBeep, 0
					mov player.nextStep, STEP_UP
				.elseif eax == 39 ; right
					invoke MessageBeep, 0
					mov player.nextStep, STEP_RIGHT
				.elseif eax == 40 ; down
					invoke MessageBeep, 0
					mov player.nextStep, STEP_DOWN
				.endif
			.elseif
				; miss
				invoke MessageBeep, -1
			.endif

		.elseif	eax == WM_TIMER
			; TODO: update status
			mov	eax,wParam
			.if	eax ==	ID_TIMER_BEAT
				invoke GetTickCount
				mov dwBaseTick, eax
			.else
				; Other timer
			.endif
			invoke updateStatus
			; and then re-paint
			invoke InvalidateRect,hWnd,NULL,TRUE

;********************************************************************
		.elseif	eax ==	WM_PAINT
			invoke BeginPaint,hWnd,addr @stPS
			; TODO: paint current status
			mov @hDC, eax
			invoke _PaintGameFrame, hWnd, @hDC 
			invoke EndPaint,hWnd,addr @stPS
		
		.elseif	eax ==	WM_CREATE
			; TODO: do init here
			; TODO: play music
			invoke SetTimer,hWnd,ID_TIMER_BEAT,BEAT_INTERVAL,NULL
			invoke GetTickCount
			invoke PlaySound, offset szBgmFilePath, NULL, SND_ASYNC or SND_FILENAME or SND_LOOP
			invoke _InitResources
			invoke startGame, FIRST_LEVEL
			mov dwBaseTick, eax
;********************************************************************
		
		.elseif	eax ==	WM_CLOSE
			; TODO: do destroy here
			invoke KillTimer,hWnd,ID_TIMER_BEAT
			invoke DestroyWindow,hWinMain
			invoke PostQuitMessage,NULL
			invoke _DestroyResources
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