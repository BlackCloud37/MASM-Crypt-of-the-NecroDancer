.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code
rand proc uses ebx lower, upper
	local @r
	mov eax, randMask
	mov ecx, 1103515245
	mul ecx
	add eax, 12345
	mov randMask, eax
	mov ecx, eax
	shl eax, 16
	shr ecx, 16
	or eax, ecx
	and eax, 65535
	mov @r, eax

	mov eax, upper
	mov cx, ax
	mov eax, lower
	mov dx, ax
	sub cx, dx
	
	mov eax, @r

	xor dx, dx
	div cx
	mov eax, lower
	add dx, ax
	movzx eax, dx
	ret
rand endp

_InitResources proc
	invoke LoadImage, hInstance, addr szStartMenuPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hStartMenuBmp, eax
	invoke LoadImage, hInstance, addr szEndMenuPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hEndMenuBmp, eax
	invoke LoadImage, hInstance, addr szWinMenuPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hWinMenuBmp, eax
	invoke LoadImage, hInstance, addr szRedMaskPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hRedMaskBmp, eax
	
	invoke LoadImage, hInstance, addr szPlayerPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hPlayerBmp, eax
	invoke LoadImage, hInstance, addr szDirtyFloorPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hDirtyFloorBmp, eax
	invoke LoadImage, hInstance, addr szStoneWallPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hStoneWallBmp, eax
	invoke LoadImage, hInstance, addr szStoneWallZonePicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hStoneWallZoneBmp, eax
	invoke LoadImage, hInstance, addr szStoneWallZone1PicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hStoneWallZone1Bmp, eax
	invoke LoadImage, hInstance, addr szDirtyWallPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hDirtyWallBmp, eax
	invoke LoadImage, hInstance, addr szDirtyWallZonePicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hDirtyWallZoneBmp, eax
	invoke LoadImage, hInstance, addr szDirtyWallZone1PicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hDirtyWallZone1Bmp, eax
	invoke LoadImage, hInstance, addr szDirtyWallZone2PicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hDirtyWallZone2Bmp, eax
	invoke LoadImage, hInstance, addr szBedrockWallZonePicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hBedrockWallZoneBmp, eax
	invoke LoadImage, hInstance, addr szGoldenWallZonePicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hGoldenWallZoneBmp, eax
	invoke LoadImage, hInstance, addr szTrapPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hTrapBmp, eax
	invoke LoadImage, hInstance, addr szStairsPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hStairsBmp, eax
	invoke LoadImage, hInstance, addr szSlimeBluePicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hSlimeBlueBmp, eax
	invoke LoadImage, hInstance, addr szSlimeOrangePicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hSlimeOrangeBmp, eax
	invoke LoadImage, hInstance, addr szBatPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hBatBmp, eax
	invoke LoadImage, hInstance, addr szSkeletonPicPath, IMAGE_BITMAP, GRID_SIZE, GRID_SIZE, LR_LOADFROMFILE
	mov hSkeletonBmp, eax
	invoke LoadImage, hInstance, addr szHealthHeartPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHealthHeartBmp, eax
	invoke LoadImage, hInstance, addr szEnemyHeartPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hEnemyHeartBmp, eax
	invoke LoadImage, hInstance, addr szEnemyEmptyHeartPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hEnemyEmptyHeartBmp, eax
	invoke LoadImage, hInstance, addr szHealthEmptyHeartPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHealthEmptyHeartBmp, eax
	invoke LoadImage, hInstance, addr szHeartBigPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHeartBigBmp, eax
	invoke LoadImage, hInstance, addr szHeartSmallPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hHeartSmallBmp, eax
	invoke LoadImage, hInstance, addr szMaskPicPath, IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE
	mov hMaskBmp, eax
	invoke GetTickCount
	mov randMask, eax
	ret
_InitResources endp






_DestroyResources proc
	invoke DeleteObject, hStartMenuBmp
	invoke DeleteObject, hWinMenuBmp
	invoke DeleteObject, hEndMenuBmp
	invoke DeleteObject, hRedMaskBmp
	invoke DeleteObject, hPlayerBmp
	invoke DeleteObject, hDirtyFloorBmp
	invoke DeleteObject, hStoneWallBmp
	invoke DeleteObject, hStoneWallZoneBmp
	invoke DeleteObject, hStoneWallZone1Bmp
	invoke DeleteObject, hDirtyWallBmp
	invoke DeleteObject, hDirtyWallZoneBmp
	invoke DeleteObject, hDirtyWallZone1Bmp
	invoke DeleteObject, hDirtyWallZone2Bmp
	invoke DeleteObject, hBedrockWallZoneBmp
	invoke DeleteObject, hGoldenWallZoneBmp
	invoke DeleteObject, hTrapBmp
	invoke DeleteObject, hStairsBmp
	invoke DeleteObject, hSlimeOrangeBmp
	invoke DeleteObject, hSlimeBlueBmp
	invoke DeleteObject, hBatBmp
	invoke DeleteObject, hHeartBigBmp
	invoke DeleteObject, hHeartSmallBmp
	invoke DeleteObject, hHealthHeartBmp
	invoke DeleteObject, hHealthEmptyHeartBmp
	invoke DeleteObject, hEnemyEmptyHeartBmp
	invoke DeleteObject, hEnemyHeartBmp
	invoke DeleteObject, hMaskBmp
	ret
_DestroyResources endp






startGame proc uses edi
	mov ecx, 0
	mov edi, offset mapMatrix
	.while (ecx < sizeMap)
		mov eax, [_C_mapMatrix + ecx]
		mov [edi + ecx], eax
		add ecx, type dword
	.endw
	mov ecx, 0
	mov edi, offset player
	.while (ecx < sizeof _C_player)
		mov eax, dword ptr [_C_player + ecx]
		mov [edi + ecx], eax
		add ecx, type dword
	.endw
	mov ecx, 0
	mov edi, offset enemys
	.while (ecx < sizeEnemys)
		mov eax, dword ptr [_C_enemys + ecx]
		mov [edi + ecx], eax
		add ecx, type dword
	.endw


	mov gameStatus, STATUS_PLAYING
	mov paintCount, 0
	mov beatIntervalIndex, 0
	mov eax, beatIntervalIndex
	mov eax, [beatIntervalsStage1 + eax]
	mov currentBeatInterval, eax
	add beatIntervalIndex, type DWORD
	mov currentBeatCount, 0
	invoke SetTimer, _hWnd,ID_TIMER_BEAT,BEAT_INTERVAL,NULL
	invoke PlaySound, offset szBgmFilePath, NULL, SND_ASYNC or SND_FILENAME or SND_LOOP
	invoke updateStatus
	ret
startGame endp


winGame proc
	mov gameStatus, STATUS_WIN
	invoke KillTimer,_hWnd,ID_TIMER_BEAT
	invoke InvalidateRect,_hWnd,NULL,FALSE
	ret
winGame endp

endGame proc
	mov gameStatus, STATUS_END_MENU
	invoke KillTimer,_hWnd,ID_TIMER_BEAT
	invoke InvalidateRect,_hWnd,NULL,FALSE
	ret
endGame endp





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











checkCollision proc posX, posY
	invoke getMapTypeAtPos, posX, posY
	.if eax == MAP_TYPE_TRAP || eax == MAP_TYPE_STAIRS
		mov eax, 0
		ret
	.endif
	.if eax != MAP_TYPE_DIRTY_FLOOR
		mov eax, 1
		ret
	.endif
	
	mov eax, player.posX
	mov ecx, player.posY
	.if (eax == posX) && (ecx == posY)
		mov eax, 3
		ret
	.endif
	
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
	.while (@cnt < sizeEnemys)
		mov eax, (Enemy ptr [edi]).posX
		mov ecx, (Enemy ptr [edi]).posY
		mov edx, (Enemy ptr [edi]).health
		.if (edx != 0 ) && (eax == posX) && (ecx == posY)
			mov eax, edi
			ret
		.endif
		add edi, type Enemy
		add @cnt, type Enemy
	.endw
	mov eax, 0
	ret
getEnemyAtPos endp



getMapTypeAtPos proc posX, posY
	invoke getMatrixIndex, posY, posX, MAP_WIDTH, MAP_HEIGHT
	.if eax == -1
		mov eax, -1
		ret
	.endif
	shl eax, 2
	mov eax, [mapMatrix + eax]
	ret
getMapTypeAtPos endp



updatePlayer proc
	local @nextPosX, @nextPosY, @collisionType
	invoke getMapTypeAtPos, player.posX, player.posY
	.if (eax == MAP_TYPE_TRAP)
		mov player.health, 0
	.elseif (eax == MAP_TYPE_STAIRS)
		invoke winGame
	.endif
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
			; dig the wall
			invoke getMapTypeAtPos, @nextPosX, @nextPosY
			.if eax == MAP_TYPE_DIRTY_WALL || eax == MAP_TYPE_DIRTY_WALL1 || eax == MAP_TYPE_DIRTY_WALL2
				invoke changeMapPosTo, @nextPosX, @nextPosY, MAP_TYPE_DIRTY_FLOOR
			.endif
		.elseif @collisionType == 2 ; enemy
			; attack the enemy
			;invoke PlaySound, offset szAttackFilePath, NULL, SND_ASYNC or SND_FILENAME
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
	local @try
	mov eax, STEP_NONE
	.if moveType == ENEMY_MOVETYPE_STOP
		
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
		.if tickCnt == 0
			mov @try, 0
			.while(@try < 10)
				invoke rand, 1, 5
				.if (eax == STEP_UP)
					mov eax, posX
					mov ecx, posY
					dec ecx
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_UP
						ret
					.endif
				.elseif (eax == STEP_DOWN)
					mov eax, posX
					mov ecx, posY
					inc ecx
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_DOWN
						ret
					.endif
				.elseif (eax == STEP_LEFT)
					mov eax, posX
					mov ecx, posY
					dec eax
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_LEFT
						ret
					.endif
				.elseif (eax == STEP_RIGHT)
					mov eax, posX
					mov ecx, posY
					inc eax
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_RIGHT
						ret
					.endif
				.endif
				inc @try
			.endw
			mov ecx, 1
		.else
			mov ecx, 0
		.endif
	.elseif moveType == ENEMY_MOVETYPE_FOLLOW
		.if tickCnt == 0
			invoke rand, 0, 2
			.if eax == 0
				mov eax, player.posX
				.if eax < posX
					mov eax, posX
					mov ecx, posY
					dec eax
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_LEFT
						ret
					.else
						jmp up_down
					.endif
				.elseif eax > posX
					mov eax, posX
					mov ecx, posY
					inc eax
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_RIGHT
						ret
					.else
						jmp up_down
					.endif
				.endif
				up_down:
				mov eax, player.posY				
				.if eax < posY
					mov eax, STEP_UP
				.elseif eax > posY
					mov eax, STEP_DOWN
				.endif
			.elseif eax == 1
				mov eax, player.posY
				.if eax < posY
					mov eax, posX
					mov ecx, posY
					dec ecx
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_UP
						ret
					.else
						jmp left_right
					.endif
				.elseif eax > posY
					mov eax, posX
					mov ecx, posY
					inc ecx
					invoke checkCollision, eax, ecx
					.if eax == 0 || eax == 3
						mov ecx, 1
						mov eax, STEP_DOWN
						ret
					.else
						jmp left_right
					.endif
				.endif
				left_right:
				mov eax, player.posX
				.if eax < posX
					mov eax, STEP_LEFT
				.elseif eax > posX
					mov eax, STEP_RIGHT
				.endif
			.endif
			mov ecx, 1
		.else
			mov ecx, 0
		.endif
	.elseif moveType == ENEMY_MOVETYPE_BS ; blue slime
		.if tickCnt == 0
			mov eax, STEP_UP
			mov ecx, tickCnt
			inc ecx
		.elseif tickCnt == 1
			mov eax, STEP_NONE
			mov ecx, tickCnt
			inc ecx
		.elseif tickCnt == 2
			mov eax, STEP_DOWN
			mov ecx, tickCnt
			inc ecx
		.elseif tickCnt == 3
			mov eax, STEP_NONE
			mov ecx, 0
		.else
			mov ecx, 0
		.endif
	.endif
	ret
decideNextStep endp


updateEnemy proc uses edi
	local @nextPosX, @nextPosY, @collisionType, @cnt, @prevTickCnt, @rangeX, @rangeY, @hDCmem,@hDC, @stPS
	mov edi, offset enemys
	mov @cnt, 0

	.while(@cnt < sizeEnemys)
		mov eax, paintWindowPosX
		add eax, PAINT_WINDOW_WIDTH
		mov @rangeX, eax
		mov eax, paintWindowPosY
		add eax, PAINT_WINDOW_HEIGHT
		mov @rangeY, eax
		mov eax, (Enemy ptr [edi]).posX
		mov ecx, (Enemy ptr [edi]).posY
		.if eax < paintWindowPosX || eax >= @rangeX || ecx < paintWindowPosY || ecx >= @rangeY
			jmp continue
		.endif
		invoke getMapTypeAtPos, eax, ecx
		.if (eax == MAP_TYPE_TRAP)
			mov (Enemy ptr [edi]).health, 0
		.endif

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
			.if @collisionType == 1 ; wall
				;jmp continue
			.elseif @collisionType == 2 ; enemy
				;jmp continue
			.elseif @collisionType == 3 ; player
				; paint RED
				invoke InvalidateRect,_hWnd,NULL,FALSE
				mov attacked, TRUE
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
			mov eax,(Enemy ptr [edi]).moveType
			.if eax == ENEMY_MOVETYPE_CIRCLE
				mov eax, @prevTickCnt
				mov (Enemy ptr [edi]).tickCnt, eax
			.endif
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
		add @cnt, type Enemy
	.endw

	ret	
updateEnemy endp

updateStatus proc
	invoke updatePlayer
	invoke updateEnemy
	.if player.health == 0
		invoke endGame
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
	ret
updateStatus endp






getPicOfMapType proc mapType
	.if mapType == MAP_TYPE_DIRTY_FLOOR
		mov eax, hDirtyFloorBmp
	.elseif mapType == MAP_TYPE_STONE_WALL
		mov eax, hStoneWallZone1Bmp
	.elseif mapType == MAP_TYPE_BRICK_WALL
		mov eax, hStoneWallZoneBmp
	.elseif mapType == MAP_TYPE_DIRTY_WALL
		mov eax, hDirtyWallZoneBmp
	.elseif mapType == MAP_TYPE_DIRTY_WALL1
		mov eax, hDirtyWallZone1Bmp
	.elseif mapType == MAP_TYPE_DIRTY_WALL2
		mov eax, hDirtyWallZone2Bmp
	.elseif mapType == MAP_TYPE_BRICK_WALL
		mov eax, hStoneWallZoneBmp
	.elseif mapType == MAP_TYPE_BEDROCK
		mov eax, hBedrockWallZoneBmp
	.elseif mapType == MAP_TYPE_GOLDEN_WALL
		mov eax, hGoldenWallZoneBmp
	.elseif mapType == MAP_TYPE_TRAP
		mov eax, hTrapBmp
	.elseif mapType == MAP_TYPE_STAIRS
		mov eax, hStairsBmp
	.endif
	ret
getPicOfMapType endp


getPicOfEnemyType proc enemyType
	.if enemyType == ENEMY_TYPE_BAT
		mov eax, hBatBmp
	.elseif enemyType == ENEMY_TYPE_SLIME_ORANGE
		mov eax, hSlimeOrangeBmp
	.elseif enemyType == ENEMY_TYPE_SLIME_BLUE
		mov eax, hSlimeBlueBmp
	.elseif enemyType == ENEMY_TYPE_SKELETON
		mov eax, hSkeletonBmp
	.endif
	ret
getPicOfEnemyType endp











_PaintStartMenu	proc hWnd, hDC
	local @hDCmem
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	invoke SelectObject, @hDCmem, hStartMenuBmp
	invoke StretchBlt, hDC, 0, 0, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE, @hDCmem, 0, 0, 800, 450, SRCCOPY
	invoke DeleteDC, @hDCmem
	ret
_PaintStartMenu	endp

_PaintWinMenu	proc hWnd, hDC
	local @hDCmem
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	invoke SelectObject, @hDCmem, hWinMenuBmp
	invoke StretchBlt, hDC, 0, 0, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE, @hDCmem, 0, 0, 800, 450, SRCCOPY
	invoke DeleteDC, @hDCmem
	ret
_PaintWinMenu	endp

_PaintEndMenu	proc hWnd, hDC
	local @hDCmem
	invoke CreateCompatibleDC, hDC
	mov @hDCmem, eax
	invoke SelectObject, @hDCmem, hEndMenuBmp
	invoke StretchBlt, hDC, 0, 0, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE, @hDCmem, 0, 0, 800, 450, SRCCOPY
	invoke DeleteDC, @hDCmem
	ret
_PaintEndMenu	endp


_PaintGameFrame	proc hWnd, hDC
	pushad
	invoke _PaintMap, hWnd, hDC
	invoke _PaintHealthHeart, hWnd, hDC
	mov edx, currentBeatInterval
	sub edx, TOLERANCE_COUNT
	.if (currentBeatCount == 0)
		invoke _PaintHeart,hWnd, hDC, 1
	.else 
		invoke _PaintHeart, hWnd, hDC, 0
	.endif
	popad
	ret
_PaintGameFrame endp



_PaintEnemyAtPos proc posX, posY, hWnd, hDC, maskAlpha
	local @posX, @posY, @maxHealth, @health
	local @hDCmem
	invoke getEnemyAtPos, posX, posY
	.if eax != 0
		mov edx, eax
		mov eax, (Enemy ptr [edx]).health
		mov @health, eax
		mov eax, (Enemy ptr [edx]).maxHealth
		mov @maxHealth, eax
		.if @health > 0
			push edx
			invoke actualPosToPaintWindowPos, (Enemy ptr [edx]).posX, (Enemy ptr [edx]).posY
			pop edx
			mov @posX, eax
			mov @posY, ecx
			invoke getPicOfEnemyType, (Enemy ptr [edx]).hType
			invoke _PaintObjectAtPos, @posY, @posX, eax, NEED_SHIFT, hWnd, hDC, maskAlpha
			
			.if maskAlpha >= 64
				ret
			.endif
			; paint health
			invoke CreateCompatibleDC, hDC
			mov @hDCmem, eax
			
			; calc Y
			mov eax, @posY
			mov edx, GRID_SIZE
			mul edx
			sub eax, E_HEART_SIZE
			mov @posY, eax
			
			mov eax, @posX
			mov edx, GRID_SIZE
			mul edx
			add eax, GRID_SIZE/2
			
			mov edx, @maxHealth
			test edx, 01h
			jz _even
			sub eax, E_HEART_SIZE/2
			_even:
			mov edx, @maxHealth
			inc edx
			shr edx, 1
			push eax
			mov eax, E_HEART_SIZE
			mul edx
			mov edx, eax
			pop eax
			add eax, edx
			mov @posX, eax
			invoke SelectObject, @hDCmem, hEnemyHeartBmp
			xor ecx, ecx
			.while (ecx < @health)
				sub @posX, E_HEART_SIZE+1
				RGB 255, 255, 255
				push ecx
				invoke TransparentBlt, hDC, @posX, @posY, E_HEART_SIZE, E_HEART_SIZE, @hDCmem, 0, 0, E_HEART_SIZE, E_HEART_SIZE, eax
				pop ecx
				inc ecx
			.endw
			push ecx
			invoke SelectObject, @hDCmem, hEnemyEmptyHeartBmp
			pop ecx
			.while (ecx < @maxHealth)	
				sub @posX, E_HEART_SIZE+1
				RGB 255, 255, 255
				push ecx
				invoke TransparentBlt, hDC, @posX, @posY, E_HEART_SIZE, E_HEART_SIZE, @hDCmem, 0, 0, E_HEART_SIZE, E_HEART_SIZE, eax
				pop ecx
				inc ecx
			.endw
			invoke DeleteDC, @hDCmem
		.endif
	.endif
	ret
_PaintEnemyAtPos endp



_PaintMap proc uses ebx edi hWnd, hDC
	local @posX, @posY, @actualPosX, @actualPosY, @alpha, @dist, @cnt, @testX, @testY
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
			
			; calc distance and alpha
			mov @dist, 0
			mov eax, @actualPosX
			.if player.posX > eax
				mov eax, player.posX
				sub eax, @actualPosX
			.else 
				sub eax, player.posX
			.endif
			add @dist, eax
			mov eax, @actualPosY
			.if player.posY > eax
				mov eax, player.posY
				sub eax, @actualPosY
			.else
				sub eax, player.posY
			.endif
			add @dist, eax

			.if @dist <= 1
				mov @alpha, 0
			.elseif @dist == 2
				mov @alpha, 31
			.elseif @dist == 3
				mov @alpha, 63
			.elseif @dist == 4
				mov @alpha, 127
			.else
				mov @alpha, 200
			.endif



			mov @cnt, 0
			mov eax, @actualPosX
			mov @testX, eax
			mov eax, @actualPosY
			mov @testY, eax
			.if @testX == 0 || @testX == MAP_WIDTH-1 || @testY == 0 || @testY == MAP_HEIGHT-1
				mov @cnt, 8
			.else
				dec @testX
				dec @testY
				mov ebx, @testX
				add ebx, 3
				mov edi, @testY
				add edi, 3
				.while(@testX < ebx)
					mov @testY, edi
					sub @testY, 3
					.while(@testY < edi)
						mov eax, @testX
						mov ecx, @testY
						.if @actualPosX == eax && @actualPosY == ecx
							inc @testY
							.continue
						.endif
						invoke getMapTypeAtPos, @testX, @testY
						.if eax >= MAP_TYPE_SOLID_START && eax < MAP_TYPE_SOLID_END ; solid
							inc @cnt
						.endif
						inc @testY
					.endw
					inc @testX
				.endw
			.endif

			.if @cnt >= 8
				mov @alpha, 255
			.endif

			invoke getMapTypeAtPos, @actualPosX, @actualPosY
			invoke getPicOfMapType, eax
			invoke _PaintObjectAtPos, @posY, @posX, eax, NONEED_SHIFT, hWnd, hDC, @alpha
			
			mov eax, @actualPosX
			mov ecx, @actualPosY
			.if eax == player.posX && ecx == player.posY
				invoke _PaintPlayer, hWnd, hDC
			.endif
			invoke _PaintEnemyAtPos, @actualPosX, @actualPosY, hWnd, hDC, @alpha
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
	local @posX, @posY
	invoke actualPosToPaintWindowPos, player.posX, player.posY
	mov @posX, eax
	mov @posY, ecx
	invoke _PaintObjectAtPos, @posY, @posX, hPlayerBmp, NEED_SHIFT, hWnd, hDC, 0
	ret
_PaintPlayer endp





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
		sub @posX, HEALTH_HEART_WIDTH+2
		RGB 255, 255, 255
		push ecx
		invoke TransparentBlt, hDC, @posX, @posY, HEALTH_HEART_WIDTH, HEALTH_HEART_HEIGHT, @hDCmem, 0, 0, HEALTH_HEART_WIDTH, HEALTH_HEART_HEIGHT, eax
		pop ecx
		inc ecx
	.endw
	push ecx
	invoke SelectObject, @hDCmem, hHealthEmptyHeartBmp
	pop ecx
	.while (ecx < player.maxHealth)	
		sub @posX, HEALTH_HEART_WIDTH+2
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


_PaintObjectAtPos proc row, col, objectHBmp, shift, hWnd, hDC, maskAlpha
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
	
	; mask
	invoke SelectObject, @hDCmem, hMaskBmp
	mov eax, maskAlpha
	mov bf.SourceConstantAlpha, al
	mov bf.BlendOp, AC_SRC_OVER
	mov bf.AlphaFormat, 0
	mov bf.BlendFlags, 0
	mov edx, bf
	invoke AlphaBlend, hDC, @posX, @posY, @w, @h, @hDCmem, 0, 0, @w, @h, edx
	invoke DeleteDC, @hDCmem
	ret
_PaintObjectAtPos endp





_ProcWinMain proc uses ebx edi esi hWnd,uMsg,wParam,lParam
		local @stPS:PAINTSTRUCT
		local @hDC, @_hDC, @hBmp
		local @stPos:POINT

		mov	eax, uMsg
		.if eax == WM_KEYDOWN
			.if gameStatus == STATUS_PLAYING
				; >= next_beat - tolerance or < tolerance
				mov eax, currentBeatInterval
				sub eax, TOLERANCE_COUNT
				.if ((currentBeatCount >= eax) || (currentBeatCount <= TOLERANCE_COUNT))
				;.if TRUE
					.if (isUpdated == FALSE)
						mov eax, wParam
						.if eax == VK_LEFT ; left
							mov player.nextStep, STEP_LEFT
						.elseif eax == VK_UP ; up
							mov player.nextStep, STEP_UP
						.elseif eax == VK_RIGHT ; right
							mov player.nextStep, STEP_RIGHT
						.elseif eax == VK_DOWN ; down
							mov player.nextStep, STEP_DOWN
						.endif
						mov isUpdated, TRUE
						mov isMiss, TRUE
						inc paintCount
						invoke updateStatus
						invoke InvalidateRect,hWnd,NULL,FALSE
					.endif
				.else
					; miss
					.if isUpdated == FALSE
						inc paintCount
						invoke updateStatus
					.endif
					invoke MessageBeep, -1
					mov isUpdated, TRUE
					mov isMiss, TRUE
					invoke InvalidateRect,hWnd,NULL,FALSE
				.endif
			.elseif gameStatus == STATUS_START_MENU
				.if wParam == VK_ESCAPE
					invoke PostMessage, hWinMain, WM_QUIT, NULL, NULL
				.endif
				invoke startGame
			.elseif gameStatus == STATUS_WIN || gameStatus == STATUS_END_MENU
				mov gameStatus, STATUS_START_MENU
				invoke InvalidateRect,hWnd,NULL,FALSE
			.endif
		.elseif	eax == WM_TIMER
			.if gameStatus == STATUS_PLAYING
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
				;.elseif currentBeatCount == 1
					.if isUpdated == FALSE
						inc paintCount
						invoke updateStatus
					.endif
					mov isUpdated, FALSE
					mov isMiss, FALSE
				.endif
			.endif
			invoke InvalidateRect,hWnd,NULL,FALSE
;********************************************************************
		.elseif	eax ==	WM_PAINT
			invoke BeginPaint,hWnd,addr @stPS
			mov @hDC, eax
			.if gameStatus == STATUS_START_MENU
				invoke _PaintStartMenu, hWnd, @hDC
			.elseif gameStatus == STATUS_END_MENU
				invoke _PaintEndMenu, hWnd, @hDC
			.elseif gameStatus == STATUS_WIN
				invoke _PaintWinMenu, hWnd, @hDC
			.elseif gameStatus == STATUS_PLAYING
				.if attacked == TRUE
					mov attacked, FALSE
					invoke CreateCompatibleDC, @hDC
					mov @_hDC, eax
					invoke SelectObject, @_hDC, hRedMaskBmp
					mov eax, 127
					mov bf.SourceConstantAlpha, al
					mov bf.BlendOp, AC_SRC_OVER
					mov bf.AlphaFormat, 0
					mov bf.BlendFlags, 0
					mov edx, bf
					invoke AlphaBlend, @hDC, 0, 0, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE, @_hDC, 0, 0, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE, edx
					invoke DeleteDC, @_hDC
				.else
					invoke CreateCompatibleDC, @hDC
					mov @_hDC, eax
					invoke CreateCompatibleBitmap, @hDC, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE
					mov @hBmp, eax
					invoke SelectObject, @_hDC, @hBmp
					invoke _PaintGameFrame, hWnd, @_hDC
				
					invoke BitBlt, @hDC, 0, 0, PAINT_WINDOW_WIDTH*GRID_SIZE, PAINT_WINDOW_HEIGHT*GRID_SIZE, @_hDC, 0, 0, SRCCOPY
					invoke DeleteDC, @_hDC
					invoke DeleteObject, @hBmp
				.endif
			.endif
			
			invoke EndPaint,hWnd,addr @stPS
		
		.elseif	eax ==	WM_CREATE
			mov eax, hWnd
			mov _hWnd, eax
			invoke _InitResources
			mov gameStatus, STATUS_START_MENU
			
;********************************************************************
		
		.elseif	eax ==	WM_CLOSE
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