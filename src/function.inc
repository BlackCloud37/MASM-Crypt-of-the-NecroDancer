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
_PaintGameFrame			proto :HWND,:DWORD
_PaintMap				proto :HWND, :DWORD
_PaintPlayer			proto :HWND, :DWORD
_PaintEnemy				proto :HWND, :DWORD
_PaintHealthHeart		proto :HWND, :DWORD
_PaintHeart				proto :HWND, :DWORD, :DWORD
_PaintObjectAtPos		proto :DWORD,:DWORD,:DWORD,:DWORD,:HWND,:DWORD
_InitResources			proto



getMatrixIndex			proto :DWORD, :DWORD, :DWORD, :DWORD
getIndexPos				proto :DWORD, :DWORD, :DWORD				; 返回某个Index的X,Y 分别在eax和ecx
changeMapPosTo			proto :DWORD, :DWORD, :DWORD				; 改变地图某一位置的地形
getPicOfMapType			proto :DWORD								; 返回某一地形的图片路径指针
getPicOfEnemyType		proto :DWORD
actualPosToPaintWindowPos proto :DWORD, :DWORD

startGame				proto :DWORD								; 做游戏开始的资源准备


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
MAP_WIDTH				equ 28
MAP_HEIGHT				equ 28

; enemy
;MAX_ENEMY_NUM			equ 10

; level
FIRST_LEVEL				equ 1
SECOND_LEVEL			equ 2

; player

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
PAINT_WINDOW_WIDTH		equ 12
PAINT_WINDOW_HEIGHT		equ 9
NEED_SHIFT				equ 1
NONEED_SHIFT			equ 0
WINDOW_HEIGHT			equ 492
WINDOW_WIDTH			equ 620

; 地图类型定义
MAP_TYPE_DIRTY_FLOOR	equ 0
MAP_TYPE_STONE_WALL		equ 2
MAP_TYPE_DIRTY_WALL		equ 1
MAP_TYPE_BEDROCK		equ 3
MAP_TYPE_GOLDEN_WALL		equ 4
MAP_TYPE_TRAP			equ 5
MAP_TYPE_STAIRS			equ 6

; enemy
ENEMY_TYPE_BAT			equ 0
ENEMY_TYPE_SLIME_ORANGE equ 1
ENEMY_TYPE_SLIME_BLUE	equ 2
ENEMY_TYPE_SKELETON		equ 3

ENEMY_MOVETYPE_RANDOM   equ 0
ENEMY_MOVETYPE_CIRCLE   equ 1
ENEMY_MOVETYPE_STOP		equ 2
ENEMY_MOVETYPE_FOLLOW   equ 3


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
	hWindowHDC				dd ?
	; 资源句柄
	hPlayerBmp				dd ?
	hDirtyFloorBmp			dd ?
	hStoneWallBmp			dd ?
	hStoneWallZoneBmp		dd ?
	hDirtyWallBmp			dd ?
	hDirtyWallZoneBmp		dd ?
	hBedrockWallZoneBmp		dd ?
	hTrapBmp				dd ?
	hStairsBmp				dd ?
	hGoldenWallZoneBmp		dd ?
	hSlimeOrangeBmp			dd ?
	hBatBmp					dd ?
	hHealthHeartBmp			dd ?
	hHealthEmptyHeartBmp	dd ?
	hEnemyHeartBmp			dd ?
	hEnemyEmptyHeartBmp		dd ?
	hHeartBigBmp			dd ?
	hHeartSmallBmp			dd ?
	bitmapbuffer			BITMAP <>
	
	; 游戏状态
	mapMatrix				dd 3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3
							dd 3 ,4 ,4 ,4 ,4 ,4 ,4 ,4 ,1 ,1 ,1 ,2 ,1 ,1 ,1 ,1 ,1 ,1 ,3 ,3 ,2 ,1 ,1 ,1 ,1 ,1 ,1 ,3
							dd 3 ,4 ,0 ,0 ,0 ,0 ,0 ,4 ,1 ,3 ,1 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,2 ,2 ,1 ,0 ,0 ,0 ,1 ,1 ,3
							dd 3 ,4 ,0 ,0 ,0 ,0 ,0 ,4 ,1 ,3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,1 ,1 ,0 ,0 ,0 ,0 ,1 ,3
							dd 3 ,4 ,0 ,0 ,0 ,0 ,0 ,4 ,1 ,3 ,1 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,1 ,0 ,0 ,2 ,2 ,0 ,1 ,3
							dd 3 ,4 ,0 ,0 ,0 ,0 ,0 ,4 ,1 ,3 ,2 ,1 ,1 ,1 ,1 ,1 ,0 ,0 ,1 ,1 ,1 ,0 ,0 ,2 ,2 ,0 ,1 ,3
							dd 3 ,4 ,0 ,0 ,0 ,0 ,0 ,4 ,1 ,3 ,3 ,1 ,0 ,0 ,0 ,1 ,1 ,0 ,1 ,1 ,1 ,0 ,0 ,1 ,1 ,0 ,1 ,3
							dd 3 ,4 ,4 ,4 ,0 ,4 ,4 ,4 ,1 ,3 ,3 ,1 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,1 ,1 ,0 ,1 ,1 ,1 ,1 ,3 ,3 ,1 ,0 ,0 ,0 ,1 ,1 ,0 ,1 ,1 ,1 ,1 ,2 ,1 ,1 ,1 ,2 ,3
							dd 3 ,1 ,1 ,1 ,0 ,1 ,1 ,1 ,1 ,2 ,2 ,1 ,1 ,1 ,1 ,1 ,1 ,0 ,1 ,1 ,1 ,2 ,2 ,2 ,2 ,2 ,2 ,3
							dd 3 ,1 ,1 ,0 ,0 ,0 ,0 ,1 ,1 ,2 ,2 ,1 ,1 ,1 ,1 ,1 ,1 ,0 ,0 ,0 ,1 ,1 ,1 ,1 ,0 ,1 ,2 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,1 ,1 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,1 ,0 ,0 ,5 ,0 ,1 ,1 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,1 ,0 ,0 ,5 ,0 ,1 ,1 ,0 ,0 ,0 ,0 ,1 ,1 ,1 ,1 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,2 ,1 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,1 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,1 ,0 ,0 ,1 ,1 ,1 ,2 ,2 ,2 ,1 ,1 ,0 ,0 ,0 ,0 ,0 ,1 ,3
							dd 3 ,2 ,0 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,2 ,1 ,5 ,5 ,2 ,2 ,1 ,1 ,1 ,1 ,1 ,0 ,1 ,3
							dd 3 ,2 ,0 ,1 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,1 ,5 ,5 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,0 ,1 ,3
							dd 3 ,2 ,0 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,2 ,3 ,1 ,1 ,1 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,1 ,3 ,3 ,3 ,2 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,3 ,3 ,3 ,2 ,1 ,0 ,5 ,0 ,1 ,0 ,0 ,2 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,6 ,0 ,0 ,1 ,3 ,3 ,3 ,2 ,1 ,0 ,0 ,0 ,1 ,1 ,0 ,1 ,0 ,1 ,3
							dd 3 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,3 ,3 ,3 ,2 ,1 ,1 ,0 ,0 ,0 ,2 ,0 ,2 ,0 ,1 ,3
							dd 3 ,1 ,1 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,0 ,1 ,3 ,3 ,3 ,2 ,2 ,1 ,0 ,0 ,0 ,2 ,0 ,0 ,0 ,1 ,3
							dd 3 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,1 ,3 ,3 ,3 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,2 ,3
							dd 3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,3

	level					dd ?
	player					Player <5,5,4,4,1,ATTACK_MODE_NORMAL,STEP_NONE,0>
	enemys					Enemy <3,3,4,4,1,STEP_NONE,ENEMY_MOVETYPE_FOLLOW,0,ENEMY_TYPE_BAT>
	
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
; 常量定义
.const
	szClassName				db 'Window', 0
	szBgmFilePath			db 'media\\bgm.wav', 0
	szPlayerPicPath			db 'image\\Cadence.bmp', 0
	szDirtyFloorPicPath		db 'image\\Dirty_Floor.bmp', 0
	szStoneWallPicPath		db 'image\\Stone_Wall.bmp', 0
	szDirtyWallPicPath		db 'image\\Dirty_Wall.bmp', 0
	szDirtyWallZonePicPath	db 'image\\Dirty_Wall_Zone.bmp', 0
	szStoneWallZonePicPath	db 'image\\Stone_Wall_Zone.bmp', 0
	szBedrockWallZonePicPath db 'image\\Bedrock_Wall_Zone.bmp',0
	szGoldenWallZonePicPath	db 'image\\Golden_Wall_Zone.bmp',0
	szTrapPicPath			db 'image\\Trap.bmp',0
	szStairsPicPath			db 'image\\Stairs.bmp',0
	szSlimeOrangePicPath	db 'image\\Slime_Orange.bmp', 0
	szBatPicPath			db 'image\\Bat.bmp', 0


	szHealthHeartPicPath	db 'image\\Health_Heart.bmp', 0
	szHealthEmptyHeartPicPath db 'image\\Health_Empty_Heart.bmp', 0
	szEnemyHeartPicPath		db 'image\\Enemy_Heart.bmp', 0
	szEnemyEmptyHeartPicPath db 'image\\Enemy_Empty_Heart.bmp', 0
	szHeartSmallPicPath		db 'image\\Heart_Small.bmp', 0
	szHeartBigPicPath		db 'image\\Heart_Big.bmp', 0
	
	beatIntervalsStage1	    dd 5
	;mapDataStage1			DWORD 