include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
include comdlg32.inc
include comctl32.inc
include msimg32.inc
INCLUDE winmm.inc
includelib msimg32.lib
INCLUDELIB winmm.lib
includelib user32.lib
includelib kernel32.lib 
includelib gdi32.lib
includelib msvcrt.lib
includelib comdlg32.lib
includelib comctl32.lib

; 函数声明
_ProcWinMain            proto :HWND,:UINT,:WPARAM,:LPARAM
_CreateDIBitmap			proto :HWND, :DWORD
_PaintGameFrame			proto :HWND, :DWORD
_PaintStartMenu			proto :HWND, :DWORD
_PaintEndMenu			proto :HWND, :DWORD
_PaintWinMenu			proto :HWND, :DWORD
_PaintMap				proto :HWND, :DWORD
_PaintPlayer			proto :HWND, :DWORD
_PaintHealthHeart		proto :HWND, :DWORD
_PaintHeart				proto :HWND, :DWORD, :DWORD
_PaintObjectAtPos		proto :DWORD,:DWORD,:DWORD,:DWORD,:HWND,:DWORD,:DWORD
_InitResources			proto



getMatrixIndex			proto :DWORD, :DWORD, :DWORD, :DWORD
getIndexPos				proto :DWORD, :DWORD, :DWORD				; 返回某个Index的X,Y 分别在eax和ecx
changeMapPosTo			proto :DWORD, :DWORD, :DWORD				; 改变地图某一位置的地形
getPicOfMapType			proto :DWORD								; 返回某一地形的图片路径指针
getPicOfEnemyType		proto :DWORD
actualPosToPaintWindowPos proto :DWORD, :DWORD

startGame				proto										; 做游戏开始的资源准备
winGame					proto
endGame					proto

updateStatus			proto										; 更新游戏状态
updatePlayer			proto										; 更新玩家状态
updateEnemy				proto										; 更新敌人状态
checkCollision			proto :DWORD, :DWORD						; 检查位置是否有实体
decideNextStep			proto :DWORD,:DWORD,:DWORD,:DWORD			; 获取敌人下一步

getEnemyAtPos			proto :DWORD, :DWORD						
getMapTypeAtPos			proto :DWORD, :DWORD
rand					proto :DWORD, :DWORD

RGB macro r, g, b
	xor eax, eax
	mov ah, b
	shl eax, 8
	mov ah, g
	mov al, r
endm



ID_TIMER_BEAT			equ 1 
MAX_PATH_LENGTH			equ 100
; 游戏状态
; beat
BEAT_INTERVAL			equ 100  ; ms
TOLERANCE_COUNT			equ 2

; map
MAP_WIDTH				equ 30
MAP_HEIGHT				equ 30

; enemy
STATUS_START_MENU		equ 0
STATUS_END_MENU			equ 1
STATUS_PLAYING			equ 2
STATUS_WIN				equ 3

; attack
ATTACK_MODE_NORMAL		equ 0

; step
STEP_NONE				equ 0
STEP_LEFT				equ 1
STEP_UP					equ 2
STEP_RIGHT				equ 3
STEP_DOWN				equ 4
; 绘图相关
GRID_SIZE				equ 50
HEALTH_HEART_WIDTH		equ 24
HEALTH_HEART_HEIGHT		equ 22
HEART_WIDTH				equ 80
HEART_HEIGHT			equ 82
E_HEART_SIZE			equ 12
PAINT_WINDOW_WIDTH		equ 16
PAINT_WINDOW_HEIGHT		equ 9
NEED_SHIFT				equ 1
NONEED_SHIFT			equ 0
WINDOW_HEIGHT			equ 492
WINDOW_WIDTH			equ 820

SHADOW_PERCENT			equ 51

; 地图类型定义
MAP_TYPE_DIRTY_FLOOR	equ 0

MAP_TYPE_SOLID_START    equ 1
MAP_TYPE_DIRTY_WALL		equ 1
MAP_TYPE_STONE_WALL		equ 2
MAP_TYPE_BEDROCK		equ 3
MAP_TYPE_GOLDEN_WALL	equ 4
MAP_TYPE_DIRTY_WALL1	equ 5
MAP_TYPE_DIRTY_WALL2	equ 6
MAP_TYPE_BRICK_WALL		equ 7
MAP_TYPE_SOLID_END		equ 8

MAP_TYPE_TRAP			equ 20
MAP_TYPE_STAIRS			equ 21
; enemy
ENEMY_TYPE_BAT			equ 0
ENEMY_TYPE_SLIME_ORANGE equ 1
ENEMY_TYPE_SLIME_BLUE	equ 2
ENEMY_TYPE_SKELETON		equ 3

ENEMY_MOVETYPE_RANDOM   equ 0
ENEMY_MOVETYPE_CIRCLE   equ 1
ENEMY_MOVETYPE_STOP		equ 2
ENEMY_MOVETYPE_FOLLOW   equ 3
ENEMY_MOVETYPE_BS		equ 4

Player struct
	posX				dd ?
	posY				dd ?
	health				dd ?
	maxHealth			dd ?
	attack				dd ?
	attackRangeType		dd ?
	nextStep			dd ?
	coinCount			dd ?
Player ends

Enemy struct
	posX				dd ?
	posY				dd ?
	health				dd ?
	maxHealth			dd ?
	attack				dd ?
	nextStep			dd ?
	moveType			dd ?
	tickCnt				dd ?
	hType				dd ?
Enemy ends








.data
	hInstance				dd ? ; 实例句柄
	hWinMain				dd ? ; 窗口句柄
	;hWindowHDC				dd ?
	; 资源句柄
	hStartMenuBmp			dd ?
	hEndMenuBmp				dd ?
	hWinMenuBmp				dd ?
	hRedMaskBmp				dd ?

	hPlayerBmp				dd ?
	hDirtyFloorBmp			dd ?
	hStoneWallBmp			dd ?
	hStoneWallZoneBmp		dd ?
	hStoneWallZone1Bmp		dd ?
	hDirtyWallBmp			dd ?
	hDirtyWallZoneBmp		dd ?
	hDirtyWallZone1Bmp		dd ?
	hDirtyWallZone2Bmp		dd ?
	hBedrockWallZoneBmp		dd ?
	hTrapBmp				dd ?
	hStairsBmp				dd ?
	hGoldenWallZoneBmp		dd ?
	hSlimeOrangeBmp			dd ?
	hSlimeBlueBmp			dd ?
	hBatBmp					dd ?
	hSkeletonBmp			dd ?
	hHealthHeartBmp			dd ?
	hHealthEmptyHeartBmp	dd ?
	hEnemyHeartBmp			dd ?
	hEnemyEmptyHeartBmp		dd ?
	hHeartBigBmp			dd ?
	hHeartSmallBmp			dd ?
	hMaskBmp				dd ?
	_hWnd					dd ?
	
	bitmapbuffer			BITMAP <>
	
	gameStatus				dd ?
	; 游戏状态
	mapMatrix				dd MAP_WIDTH*MAP_HEIGHT dup(?)
	player					Player <>
	enemys					Enemy 100 dup(<>)
	

	isMiss					dd ?
	isUpdated				dd ?
	; 绘图状态
	paintWindowPosX			dd ?
	paintWindowPosY			dd ?

	currentBeatCount   		dd ?
	currentBeatInterval		dd ?
	beatIntervalIndex		dd ?

	paintCount				dd ?
	randMask				dd ?
	attacked				dd ?
	bf					    BLENDFUNCTION <?>
; 常量定义
.const
	szClassName				db 'Window', 0
	szBgmFilePath			db 'media\\bgm.wav', 0
	szAttackFilePath		db 'media\\attack.wav', 0
	
	szStartMenuPicPath		db 'image\\Start_Menu.bmp',0
	szEndMenuPicPath		db 'image\\End_Menu.bmp',0
	szWinMenuPicPath		db 'image\\Win_Menu.bmp',0
	szRedMaskPicPath		db 'image\\Red.bmp',0

	szPlayerPicPath			db 'image\\Cadence.bmp', 0
	szDirtyFloorPicPath		db 'image\\Dirty_Floor.bmp', 0
	szStoneWallPicPath		db 'image\\Stone_Wall.bmp', 0
	szDirtyWallPicPath		db 'image\\Dirty_Wall.bmp', 0
	szDirtyWallZonePicPath	db 'image\\Dirty_Wall_Zone.bmp', 0
	szStoneWallZonePicPath	db 'image\\Stone_Wall_Zone.bmp', 0
	szStoneWallZone1PicPath db 'image\\Stone_Wall_Zone_1.bmp', 0
	szDirtyWallZone1PicPath	db 'image\\Dirty_Wall_Zone_1.bmp', 0
	szDirtyWallZone2PicPath	db 'image\\Dirty_Wall_Zone_2.bmp', 0
	szBedrockWallZonePicPath db 'image\\Bedrock_Wall_Zone.bmp',0
	szGoldenWallZonePicPath	db 'image\\Golden_Wall_Zone.bmp',0
	szTrapPicPath			db 'image\\Trap.bmp',0
	szStairsPicPath			db 'image\\Stairs.bmp',0

	szSlimeBluePicPath	    db 'image\\Slime_Blue.bmp', 0
	szSlimeOrangePicPath	db 'image\\Slime_Orange.bmp', 0
	szBatPicPath			db 'image\\Bat.bmp', 0
	szSkeletonPicPath		db 'image\\Skeleton.bmp', 0

	szHealthHeartPicPath	db 'image\\Health_Heart.bmp', 0
	szHealthEmptyHeartPicPath db 'image\\Health_Empty_Heart.bmp', 0
	szEnemyHeartPicPath		db 'image\\Enemy_Heart.bmp', 0
	szEnemyEmptyHeartPicPath db 'image\\Enemy_Empty_Heart.bmp', 0
	szHeartSmallPicPath		db 'image\\Heart_Small.bmp', 0
	szHeartBigPicPath		db 'image\\Heart_Big.bmp', 0
	
	szMaskPicPath			db 'image\\Mask.bmp',0

	beatIntervalsStage1		dd 5

	_C_mapMatrix			dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
							dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
							dd 3,3,2,1,5,1,5,2,1,6,1,1,1,2,2,2,3,3,1,6,1,5,1,1,3,3,3,3,3,3
							dd 3,3,6,1,0,0,0,1,2,6,0,1,2,2,2,1,1,1,1,0,0,0,0,2,3,3,3,3,3,3
							dd 3,3,1,0,0,0,0,0,0,0,0,6,1,5,0,0,0,20,0,0,20,0,0,6,3,3,3,3,3,3
							dd 3,3,6,0,0,0,1,0,0,5,1,1,1,1,2,1,0,0,0,0,0,0,0,1,1,3,3,3,3,3
							dd 3,3,2,0,0,0,0,0,0,1,1,0,0,0,6,1,0,0,0,0,0,0,0,0,6,3,3,3,3,3
							dd 3,3,1,0,0,0,0,0,0,0,1,0,0,0,5,1,0,20,0,0,0,20,0,5,1,3,3,3,3,3
							dd 3,3,5,1,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,1,3,3,3,3,3,3
							dd 3,3,2,1,1,2,2,1,6,0,2,2,6,1,1,1,1,0,5,1,1,2,0,2,3,3,3,3,3,3
							dd 3,3,3,3,3,3,3,1,5,0,2,1,1,1,1,2,2,0,1,6,3,1,1,2,3,3,3,3,3,3
							dd 3,3,3,3,3,1,1,1,2,0,6,2,1,0,0,0,0,0,1,3,3,3,3,3,3,3,3,3,3,3
							dd 3,3,3,3,3,1,1,6,0,0,0,1,1,0,0,2,20,0,1,3,3,3,3,3,3,3,3,3,3,3
							dd 3,4,4,4,4,4,1,5,0,0,0,20,1,0,0,1,0,0,5,3,3,3,3,3,3,3,3,3,3,3
							dd 3,4,0,0,0,4,1,0,0,0,0,1,1,0,0,1,0,0,5,1,5,3,1,2,2,2,3,3,3,3
							dd 3,4,0,0,0,4,5,0,0,0,0,0,0,0,20,1,2,0,0,0,1,1,6,1,2,6,1,3,3,3
							dd 3,4,0,20,0,4,6,0,0,0,2,0,0,0,0,1,2,0,0,0,0,0,0,0,0,0,1,3,3,3
							dd 3,4,0,0,0,4,2,0,0,0,1,6,2,2,1,1,1,1,1,1,1,0,20,0,20,0,6,3,3,3
							dd 3,4,0,0,0,0,0,0,0,20,1,5,1,2,2,2,1,0,0,0,1,0,0,0,0,0,1,2,3,3
							dd 3,4,4,4,4,4,2,6,0,0,0,1,1,2,2,5,1,0,0,0,1,0,5,1,2,5,5,2,3,3
							dd 3,2,2,2,2,2,2,5,0,1,2,1,1,1,2,1,1,0,0,0,1,0,1,1,1,2,3,3,3,3
							dd 3,3,3,3,3,3,3,1,0,0,2,1,1,2,1,5,1,1,1,1,1,0,2,2,1,2,3,3,3,3
							dd 3,3,3,3,3,3,3,1,0,0,0,1,1,2,2,0,0,0,0,0,0,0,5,1,1,1,2,3,3,3
							dd 3,3,3,3,3,3,3,1,6,0,0,1,1,3,6,0,0,20,0,0,0,0,7,7,7,7,7,7,3,3
							dd 3,3,3,3,3,3,3,1,5,6,1,1,3,3,2,5,0,0,0,0,0,0,0,0,0,0,0,7,3,3
							dd 3,3,3,3,3,3,3,1,1,1,1,3,3,3,3,1,1,2,1,1,1,5,7,0,0,21,0,7,3,3
							dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,7,0,0,0,0,7,3,3
							dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,7,7,7,7,7,7,3,3
							dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
							dd 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3

	sizeMap					= $ - _C_mapMatrix
	_C_player				Player <3,14,5,5,1,ATTACK_MODE_NORMAL,STEP_NONE,0>

	_C_enemys				
							Enemy <11,16,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <12,15,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,2,ENEMY_TYPE_SLIME_BLUE>
							Enemy <13,16,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <7,19,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <5,7,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <7,6,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <16,6,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <18,6,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <21,18,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <19,23,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,2,ENEMY_TYPE_SLIME_BLUE>
							Enemy <20,14,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,0,ENEMY_TYPE_SLIME_BLUE>
							Enemy <21,23,2,2,1,STEP_NONE,ENEMY_MOVETYPE_BS,2,ENEMY_TYPE_SLIME_BLUE>
							
							
							
							Enemy <17,19,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <18,19,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <19,19,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>
							Enemy <17,18,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <18,18,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <19,18,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT> 
							Enemy <17,20,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <18,20,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <19,20,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT> 
							Enemy <11,6,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <11,7,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <11,8,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>
							Enemy <12,6,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <12,7,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <12,8,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT> 
							Enemy <13,6,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <13,7,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <13,8,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT> 
							Enemy <5,5,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <4,4,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT>, <4,3,1,1,1,STEP_NONE,ENEMY_MOVETYPE_RANDOM,0,ENEMY_TYPE_BAT> 


							Enemy <9,8,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <19,8,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <14,12,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <14,14,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <17,14,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <9,17,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <19,16,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <24,25,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							Enemy <10,13,2,2,1,STEP_NONE,ENEMY_MOVETYPE_CIRCLE,0,ENEMY_TYPE_SLIME_ORANGE>
							
							Enemy <20,5,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <15,8,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <9,9,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <8,15,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <17,16,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <25,16,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <15,22,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <16,24,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <26,24,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <23,26,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <6,6,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <8,5,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <8,21,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <3,5,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
							Enemy <3,18,2,2,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_SKELETON>
	sizeEnemys				= $ - _C_enemys
