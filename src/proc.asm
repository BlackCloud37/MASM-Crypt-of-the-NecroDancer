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
	invoke LoadImage, hInstance, addr szStoneWallPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hStoneWallBmp, eax
	invoke LoadImage, hInstance, addr szSlimeOrangePicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hSlimeOrangeBmp, eax
	invoke LoadImage, hInstance, addr szBatPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hBatBmp, eax
	ret
_InitResources endp






_DestroyResources proc
	invoke DeleteObject, hPlayerBmp
	invoke DeleteObject, hDirtyFloorBmp
	invoke DeleteObject, hStoneWallBmp
	invoke DeleteObject, hSlimeOrangeBmp
	invoke DeleteObject, hBatBmp
	ret
_DestroyResources endp






startGame proc _level
	invoke initMap, _level
	invoke initPlayer, _level
	; Enemy
	invoke initEnemy, _level
	; Others
	invoke updateStatus
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








initMap proc _level
	local @posX, @posY
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
	invoke changeMapPosTo, 1,1, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 1,2, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 1,3, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 2,1, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 3,1, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 3,3, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 5,5, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 5,6, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 5,7, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 7,6, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 8,6, MAP_TYPE_STONE_WALL
	invoke changeMapPosTo, 9,6, MAP_TYPE_STONE_WALL
	ret
initMap endp

initEnemy proc uses edi _level
	mov edi, offset enemys
	mov (Enemy ptr [edi]).posX, 4
	mov (Enemy ptr [edi]).posY, 4
	mov (Enemy ptr [edi]).health, 1
	mov (Enemy ptr [edi]).attack, 1
	mov (Enemy ptr [edi]).nextStep, STEP_NONE
	mov (Enemy ptr [edi]).moveType, ENEMY_MOVETYPE_CIRCLE
	mov (Enemy ptr [edi]).tickCnt, 0
	mov eax, hSlimeOrangeBmp
	mov (Enemy ptr [edi]).hBmp, eax
	ret
initEnemy endp


checkCollision proc posX, posY
	local @enemy
	invoke getMatrixIndex, posY, posX, MAP_WIDTH, MAP_HEIGHT
	shl eax, 2
	mov eax, [mapMatrix + eax]
	.if eax == MAP_TYPE_STONE_WALL
		mov eax, 1
		ret
	.endif
	; TODO: attack range
	invoke getEnemyAtPos, posX, posY
	.if eax != 0
		mov eax, 2
		ret
	.endif
	; TODO: check enemy collision
	mov eax, 0 ; no collision
	ret
checkCollision endp






getEnemyAtPos proc uses edi posX, posY
	local @cnt
	mov @cnt, 0
	mov edi, offset enemys
	.while (@cnt < MAX_ENEMY_NUM)
		mov eax, (Enemy ptr [edi]).posX
		mov ecx, (Enemy ptr [edi]).posY
		mov edx, (Enemy ptr [edi]).health
		.if (edx != 0 ) && (eax == posX) && (ecx == posY)
			mov eax, edi
			ret
		.endif
		add edi, type Enemy
		inc @cnt
	.endw
	mov eax, 0
	ret
getEnemyAtPos endp







updatePlayer proc
	local @nextPosX, @nextPosY, @collisionType, @pEnemy
	.if (player.nextStep == STEP_NONE)
		ret
	.endif
	mov eax, player.posX
	mov @nextPosX, eax
	mov eax, player.posY
	mov @nextPosY, eax

	.if (player.nextStep == STEP_UP) && (player.posY >= 1)
		dec @nextPosY
	.endif

	.if (player.nextStep == STEP_RIGHT) && (player.posX < MAP_WIDTH - 1)
		inc @nextPosX
	.endif

	.if (player.nextStep == STEP_DOWN) && (player.posY < MAP_HEIGHT - 1)
		inc @nextPosY
	.endif
	
	.if (player.nextStep == STEP_LEFT) && (player.posX >= 1)
		dec @nextPosX
	.endif

	invoke checkCollision, @nextPosX, @nextPosY
	mov @collisionType, eax
	.if @collisionType != 0
		.if @collisionType == 1 ; wall
			; TODO: dig the wall
		.elseif @collisionType == 2 ; enemy
			; attack the enemy
			invoke getEnemyAtPos, @nextPosX, @nextPosY
			mov @pEnemy, eax
			mov eax, (Enemy ptr [@pEnemy]).health
			.if eax <= player.attack
				mov (Enemy ptr [@pEnemy]).health, 0
			.else
				mov eax, player.attack
				sub (Enemy ptr [@pEnemy]).health, eax
			.endif
		.endif
		mov eax, player.posX
		mov @nextPosX, eax
		mov eax, player.posY
		mov @nextPosY, eax
	.endif

	mov player.nextStep, STEP_NONE
	mov eax, @nextPosX
	mov player.posX, eax
	mov eax, @nextPosY
	mov player.posY, eax
	ret
updatePlayer endp

decideNextStep proc moveType, posX, posY, tickCnt
	.if moveType == ENEMY_MOVETYPE_STOP
		mov eax, STEP_NONE
	.elseif moveType == ENEMY_MOVETYPE_CIRCLE
		.if tickCnt == 0
			mov eax, STEP_LEFT
			mov ecx, tickCnt
			inc ecx
		.elseif tickCnt == 1
			mov eax, STEP_UP
			mov ecx, tickCnt
			inc ecx
		.elseif tickCnt == 2
			mov eax, STEP_RIGHT
			mov ecx, tickCnt
			inc ecx
		.elseif tickCnt == 3
			mov eax, STEP_DOWN
			mov ecx, 0
		.else
			mov ecx, 0
		.endif
	.elseif moveType == ENEMY_MOVETYPE_RANDOM
		;TODO
	.endif
	ret
decideNextStep endp


updateEnemy proc uses edi
	local @nextPosX, @nextPosY, @collisionType, @cnt
	mov edi, offset enemys
	mov @cnt, 0

	.while(@cnt < MAX_ENEMY_NUM)
		mov eax, (Enemy ptr [edi]).health
		.if (eax == 0)
			jmp continue
		.endif
		invoke decideNextStep, (Enemy ptr [edi]).moveType, (Enemy ptr [edi]).posX, (Enemy ptr [edi]).posY, (Enemy ptr [edi]).tickCnt
		mov (Enemy ptr [edi]).nextStep, eax
		mov (Enemy ptr [edi]).tickCnt, ecx		
		.if (eax == STEP_NONE)
			jmp continue
		.endif
		mov eax, (Enemy ptr [edi]).posX
		mov @nextPosX, eax
		mov eax, (Enemy ptr [edi]).posY
		mov @nextPosY, eax
		mov eax, (Enemy ptr [edi]).nextStep
		mov edx, (Enemy ptr [edi]).posY
		.if (eax == STEP_UP) && (edx >= 1)
			dec @nextPosY
		.endif
		mov eax, (Enemy ptr [edi]).nextStep
		mov edx, (Enemy ptr [edi]).posX
		.if (eax == STEP_RIGHT) && (edx < MAP_WIDTH - 1)
			inc @nextPosX
		.endif
		mov eax, (Enemy ptr [edi]).nextStep
		mov edx, (Enemy ptr [edi]).posY
		.if (eax == STEP_DOWN) && (edx < MAP_HEIGHT - 1)
			inc @nextPosY
		.endif
		mov eax, (Enemy ptr [edi]).nextStep
		mov edx, (Enemy ptr [edi]).posX
		.if (eax == STEP_LEFT) && (edx >= 1)
			dec @nextPosX
		.endif

		invoke checkCollision, @nextPosX, @nextPosY
		mov @collisionType, eax
		.if @collisionType != 0
			.if @collisionType == 1 ; wall
				; TODO: dig the wall
				jmp continue
			.elseif @collisionType == 2 ; enemy
				jmp continue
			.elseif @collisionType == 3 ; player
				; attack the player
				mov eax, player.health
				mov edx, (Enemy ptr [edi]).attack
				.if eax <= edx
					mov player.health, 0
				.else
					mov eax, edx
					sub player.health, eax
				.endif
			.endif
			;cancel move
			mov eax, (Enemy ptr [edi]).posX
			mov @nextPosX, eax
			mov eax, (Enemy ptr [edi]).posY
			mov @nextPosY, eax
		.endif

		mov (Enemy ptr [edi]).nextStep, STEP_NONE
		mov eax, @nextPosX
		mov (Enemy ptr [edi]).posX, eax
		mov eax, @nextPosY
		mov (Enemy ptr [edi]).posY, eax
		continue:
		add edi, type Enemy
		inc @cnt
	.endw

	ret	
updateEnemy endp

updateStatus proc
	; TODO: Åö×²¼ì²â
	
	invoke updatePlayer
	
	; TODO: Update Enemy and Map
	invoke updateEnemy
	; Update paint window
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
	.elseif mapType == MAP_TYPE_STONE_WALL
		mov eax, hStoneWallBmp
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
	invoke _PaintEnemy, hWnd, hDC
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




_PaintEnemy	proc uses edi hWnd, hDC
	local @cnt
	mov @cnt, 0
	mov edi, offset enemys
	.while (@cnt < MAX_ENEMY_NUM)
		mov eax, (Enemy ptr [edi]).health
		.if eax > 0 ; BUG
			invoke actualPosToPaintWindowPos, (Enemy ptr [edi]).posX, (Enemy ptr [edi]).posY
			invoke _PaintObjectAtPos, ecx, eax, (Enemy ptr [edi]).hBmp, hWnd, hDC
		.endif
		add edi, type Enemy
		inc @cnt
	.endw
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