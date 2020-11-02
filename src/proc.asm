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
	invoke LoadImage, hInstance, addr szStoneWallZonePicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hStoneWallZoneBmp, eax
	invoke LoadImage, hInstance, addr szDirtyWallPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hDirtyWallBmp, eax
	invoke LoadImage, hInstance, addr szDirtyWallZonePicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hDirtyWallZoneBmp, eax
	invoke LoadImage, hInstance, addr szSlimeOrangePicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hSlimeOrangeBmp, eax
	invoke LoadImage, hInstance, addr szBatPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hBatBmp, eax
	invoke LoadImage, hInstance, addr szHealthHeartPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHealthHeartBmp, eax
	invoke LoadImage, hInstance, addr szHeartBigPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHeartBigBmp, eax
	invoke LoadImage, hInstance, addr szHeartSmallPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHeartSmallBmp, eax
	ret
_InitResources endp






_DestroyResources proc
	invoke DeleteObject, hPlayerBmp
	invoke DeleteObject, hDirtyFloorBmp
	invoke DeleteObject, hStoneWallBmp
	invoke DeleteObject, hStoneWallZoneBmp
	invoke DeleteObject, hDirtyWallBmp
	invoke DeleteObject, hDirtyWallZoneBmp
	invoke DeleteObject, hSlimeOrangeBmp
	invoke DeleteObject, hBatBmp
	invoke DeleteObject, hHeartBigBmp
	invoke DeleteObject, hHeartSmallBmp
	invoke DeleteObject, hHealthHeartBmp
	ret
_DestroyResources endp






startGame proc _level
	mov paintCount, 0
	mov beatIntervalIndex, 0
	mov eax, beatIntervalIndex
	mov eax, [beatIntervalsStage1 + eax]
	mov currentBeatInterval, eax
	add beatIntervalIndex, type DWORD
	mov currentBeatCount, 0
	invoke PlaySound, offset szBgmFilePath, NULL, SND_ASYNC or SND_FILENAME or SND_LOOP

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
	invoke changeMapPosTo, 2,1, MAP_TYPE_DIRTY_WALL
	invoke changeMapPosTo, 3,1, MAP_TYPE_DIRTY_WALL
	invoke changeMapPosTo, 2,2, MAP_TYPE_DIRTY_WALL
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
	invoke getMatrixIndex, posY, posX, MAP_WIDTH, MAP_HEIGHT
	shl eax, 2
	mov eax, [mapMatrix + eax]
	.if eax != MAP_TYPE_DIRTY_FLOOR
		mov eax, 1
		ret
	.endif
	
	; TODO: check enemy's collision
	mov eax, player.posX
	mov ecx, player.posY
	.if (eax == posX) && (ecx == posY)
		mov eax, 3
		ret
	.endif
	
	; TODO: attack range
	invoke getEnemyAtPos, posX, posY
	.if eax != 0
		mov eax, 2
		ret
	.endif
	
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
	local @nextPosX, @nextPosY, @collisionType
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
			invoke getMatrixIndex, @nextPosY, @nextPosX, MAP_WIDTH, MAP_HEIGHT
			shl eax, 2
			mov eax, [mapMatrix + eax]
			.if eax == MAP_TYPE_DIRTY_WALL
				invoke changeMapPosTo, @nextPosX, @nextPosY, MAP_TYPE_DIRTY_FLOOR
			.endif
		.elseif @collisionType == 2 ; enemy
			; attack the enemy
			invoke getEnemyAtPos, @nextPosX, @nextPosY
			mov edx, eax
			mov eax, (Enemy ptr [edx]).health
			.if eax <= player.attack
				mov (Enemy ptr [edx]).health, 0
			.else
				mov eax, player.attack
				sub (Enemy ptr [edx]).health, eax
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
	local @nextPosX, @nextPosY, @collisionType, @cnt, @prevTickCnt
	mov edi, offset enemys
	mov @cnt, 0

	.while(@cnt < MAX_ENEMY_NUM)
		mov eax, (Enemy ptr [edi]).health
		.if (eax == 0)
			jmp continue
		.endif
		mov eax, (Enemy ptr [edi]).tickCnt
		mov @prevTickCnt, eax
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
			mov eax, @prevTickCnt
			mov (Enemy ptr [edi]).tickCnt, eax
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
	.if player.health == 0
		invoke PostMessage, hWinMain, WM_QUIT, NULL, NULL
	.endif
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
		mov eax, hStoneWallZoneBmp
	.elseif mapType == MAP_TYPE_DIRTY_WALL
		mov eax, hDirtyWallZoneBmp
	.endif
	ret
getPicOfMapType endp






initPlayer proc _level
	.if _level == FIRST_LEVEL
		mov player.posX, 0
		mov player.posY, 0
		mov player.health, 4
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
	invoke _PaintHealthHeart, hWnd, hDC
	mov edx, currentBeatInterval
	sub edx, TOLERANCE_COUNT
	.if currentBeatCount == TOLERANCE_COUNT
	;	invoke _PaintHeart,hWnd, hDC, 0 
	.elseif currentBeatCount == edx
	;	invoke _PaintHeart,hWnd, hDC, 1
	.endif
	popad
	ret
_PaintGameFrame endp







_PaintMap proc hWnd, hDC
	local @posX, @posY, @actualPosX, @actualPosY
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
			invoke getPicOfMapType, eax
			invoke _PaintObjectAtPos, @posY, @posX, eax, NONEED_SHIFT, hWnd, hDC
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
	local @actualPosY, @posX, @posY
	invoke actualPosToPaintWindowPos, player.posX, player.posY
	mov @posX, eax
	mov @posY, ecx
	invoke _PaintObjectAtPos, @posY, @posX, hPlayerBmp, NEED_SHIFT, hWnd, hDC
	mov eax, player.posY
	mov @actualPosY, eax
	inc @actualPosY
	inc @posY
	.while @posY < PAINT_WINDOW_HEIGHT-1
		; re paint map
		invoke getMatrixIndex, @actualPosY, player.posX, MAP_WIDTH, MAP_HEIGHT
		shl eax, 2
		mov eax, [mapMatrix + eax]
		invoke getPicOfMapType, eax
		invoke _PaintObjectAtPos, @posY, @posX, eax, NONEED_SHIFT, hWnd, hDC
		inc @actualPosY
		inc @posY
	.endw
	ret
_PaintPlayer endp




_PaintEnemy	proc uses edi hWnd, hDC
	local @cnt, @actualPosY, @posX, @posY
	mov @cnt, 0
	mov edi, offset enemys
	.while (@cnt < MAX_ENEMY_NUM)
		mov eax, (Enemy ptr [edi]).health
		.if eax > 0
			mov eax, (Enemy ptr [edi]).posY
			mov @actualPosY, eax
			invoke actualPosToPaintWindowPos, (Enemy ptr [edi]).posX, (Enemy ptr [edi]).posY
			mov @posX, eax
			mov @posY, ecx
			invoke _PaintObjectAtPos, @posY, @posX, (Enemy ptr [edi]).hBmp, NEED_SHIFT, hWnd, hDC
			; re paint map
			inc @actualPosY
			inc @posY
			.while @posY < PAINT_WINDOW_HEIGHT-1
				mov eax, @actualPosY
				mov edx, (Enemy ptr [edi]).posX
				.if (eax != player.posY) || (edx != player.posX)
					invoke getMatrixIndex, @actualPosY, (Enemy ptr [edi]).posX, MAP_WIDTH, MAP_HEIGHT
					shl eax, 2
					mov eax, [mapMatrix + eax]
					invoke getPicOfMapType, eax
					invoke _PaintObjectAtPos, @posY, @posX, eax, NONEED_SHIFT, hWnd, hDC
				.endif
				inc @actualPosY
				inc @posY
			.endw
		.endif
		add edi, type Enemy
		inc @cnt
	.endw
	ret
_PaintEnemy endp

_PaintHealthHeart proc hWnd, hDC
	local @posX, @posY
	local @hDCmem
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	invoke SelectObject, @hDCmem, hHealthHeartBmp

	mov @posY, 1
	mov @posX, PAINT_WINDOW_WIDTH*GRID_SIZE
	xor ecx, ecx
	.while (ecx < player.health)
		sub @posX, HEALTH_HEART_WIDTH
		RGB 255, 255, 255
		push ecx
		invoke TransparentBlt, hDC, @posX, @posY, HEALTH_HEART_WIDTH, HEALTH_HEART_HEIGHT, @hDCmem, 0, 0, HEALTH_HEART_WIDTH, HEALTH_HEART_HEIGHT, eax
		pop ecx
		inc ecx
	.endw
	invoke DeleteDC, @hDCmem
	ret
_PaintHealthHeart endp

_PaintHeart proc hWnd, hDC, heartType
	local @posX, @posY
	local @hDCmem
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	.if heartType == 1
		invoke SelectObject, @hDCmem, hHeartBigBmp
	.else
		invoke SelectObject, @hDCmem, hHeartSmallBmp
	.endif
	mov @posY, PAINT_WINDOW_HEIGHT*GRID_SIZE
	sub @posY, HEART_HEIGHT
	mov @posX, PAINT_WINDOW_WIDTH*GRID_SIZE/2
	sub @posX, HEART_WIDTH/2
	RGB 255,255,255
	invoke TransparentBlt, hDC, @posX, @posY, HEART_WIDTH, HEART_HEIGHT, @hDCmem, 0, 0, HEART_WIDTH, HEART_HEIGHT, eax
	invoke DeleteDC, @hDCmem
	ret
_PaintHeart endp


_PaintObjectAtPos proc row, col, objectHBmp, shift, hWnd, hDC
	local @hDCmem
	local @posX, @posY, @w, @h
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	; calc x, y
	mov eax, GRID_SIZE
	mul col
	mov @posX, eax
	mov eax, GRID_SIZE
	mul row
	mov @posY, eax
	.if (shift == NEED_SHIFT)
		mov eax, paintCount
		test eax, 01h
		jz _even
		add @posY, 5
		_even:
	.endif
	

	invoke GetObject, objectHBmp, type BITMAP, offset bitmapbuffer
	mov eax, bitmapbuffer.bmWidth
	mov @w, eax
	mov eax, bitmapbuffer.bmHeight
	mov @h, eax
	add @posY, GRID_SIZE
	sub @posY, eax
	
	invoke SelectObject, @hDCmem, objectHBmp
	RGB 255, 255, 255
	invoke TransparentBlt, hDC, @posX, @posY, @w, @h, @hDCmem, 0, 0, @w, @h, eax
	invoke DeleteDC, @hDCmem
	ret
_PaintObjectAtPos endp





_ProcWinMain proc uses ebx edi esi hWnd,uMsg,wParam,lParam
		local @stPS:PAINTSTRUCT
		local @hDC
		local @stPos:POINT

		mov	eax, uMsg
		.if eax == WM_KEYDOWN
			; >= next_beat - tolerance or < tolerance
			mov eax, currentBeatInterval
			sub eax, TOLERANCE_COUNT
			.if (currentBeatCount > eax) || (currentBeatCount < TOLERANCE_COUNT) 
				mov eax, wParam
				.if eax == 37 ; left
					mov player.nextStep, STEP_LEFT
				.elseif eax == 38 ; up
					mov player.nextStep, STEP_UP
				.elseif eax == 39 ; right
					mov player.nextStep, STEP_RIGHT
				.elseif eax == 40 ; down
					mov player.nextStep, STEP_DOWN
				.endif
			.elseif
				; miss
				invoke MessageBeep, -1
			.endif

		.elseif	eax == WM_TIMER
			; TODO: update status
			mov	eax,wParam
			.if	eax == ID_TIMER_BEAT
				inc currentBeatCount
				mov eax, currentBeatInterval
				.if eax == currentBeatCount ; on the beat
					mov currentBeatCount, 0
					; get next interval
					.if beatIntervalIndex == sizeof beatIntervalsStage1
						mov beatIntervalIndex, 0
					.endif
					mov eax, beatIntervalIndex
					mov eax, [beatIntervalsStage1 + eax]
					mov currentBeatInterval, eax
					add beatIntervalIndex, type DWORD
				.elseif currentBeatCount == TOLERANCE_COUNT
					inc paintCount
					invoke updateStatus
				.endif

			.else
				; Other timer
			.endif
			invoke InvalidateRect,hWnd,NULL,TRUE

;********************************************************************
		.elseif	eax ==	WM_PAINT
			invoke BeginPaint,hWnd,addr @stPS
			mov @hDC, eax
			invoke _PaintGameFrame, hWnd, @hDC 
			invoke EndPaint,hWnd,addr @stPS
		
		.elseif	eax ==	WM_CREATE
			invoke SetTimer, hWnd,ID_TIMER_BEAT,BEAT_INTERVAL,NULL
			invoke _InitResources
			invoke startGame, FIRST_LEVEL
;********************************************************************
		
		.elseif	eax ==	WM_CLOSE
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