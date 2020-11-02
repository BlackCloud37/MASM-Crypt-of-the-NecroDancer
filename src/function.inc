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
actualPosToPaintWindowPos proto :DWORD, :DWORD

startGame				proto :DWORD								; 做游戏开始的资源准备
initMap					proto :DWORD								; 初始化整个地图，从文件读入
initPlayer				proto :DWORD								; 初始化玩家
initEnemy				proto :DWORD								; 初始化敌人

updateStatus			proto										; 更新游戏状态
updatePlayer			proto										; 更新玩家状态
updateEnemy				proto										; 更新敌人状态
checkCollision			proto :DWORD, :DWORD						; 检查位置是否有实体
decideNextStep			proto :DWORD,:DWORD,:DWORD,:DWORD			; 获取敌人下一步

getEnemyAtPos			proto :DWORD, :DWORD						


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
MAP_WIDTH				equ 14
MAP_HEIGHT				equ 14

; enemy
MAX_ENEMY_NUM			equ 10

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
PAINT_WINDOW_WIDTH		equ 12
PAINT_WINDOW_HEIGHT		equ 9
NEED_SHIFT				equ 1
NONEED_SHIFT			equ 0
WINDOW_HEIGHT			equ 492
WINDOW_WIDTH			equ 620

; 地图类型定义
MAP_TYPE_DIRTY_FLOOR	equ 0
MAP_TYPE_STONE_WALL		equ 1
MAP_TYPE_DIRTY_WALL		equ 2

; enemy

ENEMY_MOVETYPE_RANDOM   equ 0
ENEMY_MOVETYPE_CIRCLE   equ 1
ENEMY_MOVETYPE_STOP		equ 2



Player struct
	posX				dd ?
	posY				dd ?
	health				dd ?
	attack				dd ?
	attackRangeType		dd ?
	nextStep			dd ?
	coinCount			dd ?
Player ends

Enemy struct
	posX				dd ?
	posY				dd ?
	health				dd ?
	attack				dd ?
	nextStep			dd ?
	moveType			dd ?
	tickCnt				dd ?
	hBmp				dd ?
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
	hSlimeOrangeBmp			dd ?
	hBatBmp					dd ?
	hHealthHeartBmp			dd ?
	hHeartBigBmp			dd ?
	hHeartSmallBmp			dd ?
	bitmapbuffer			BITMAP <>
	
	; 游戏状态
	mapMatrix				dd MAP_WIDTH * MAP_HEIGHT dup(0)
	level					dd ?
	player					Player <>
	enemys					Enemy MAX_ENEMY_NUM dup(<,,0,0,0,0,0,0>)
	dwBaseTick				dd ? ; 上一个节拍的时间戳

	; 绘图状态
	paintWindowPosX			dd ?
	paintWindowPosY			dd ?

	currentBeatCount   		dd ?
	currentBeatInterval		dd ?
	beatIntervalIndex		dd ?

	paintCount				dd ?
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
	szSlimeOrangePicPath	db 'image\\Slime_Orange.bmp', 0
	szBatPicPath			db 'image\\Bat.bmp', 0
	szHealthHeartPicPath	db 'image\\Health_Heart.bmp', 0
	szHeartSmallPicPath		db 'image\\Heart_Small.bmp', 0
	szHeartBigPicPath		db 'image\\Heart_Big.bmp', 0
	
	beatIntervalsStage1	    dd 1, 5, 6, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 6
							dd   5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 4, 5, 5, 4, 6, 5, 5, 5, 5, 6
							dd   5, 5, 5, 6, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5
							dd   5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5
							dd   5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5, 4, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 5 
							dd   5, 4, 5, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6
							dd   5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5
							dd   5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5
							dd   6, 5, 4, 5, 5, 4, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 4, 5, 4, 6, 5, 5, 5, 5, 6, 5, 5
							dd   5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5 
							dd   5, 6, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 4, 5, 4, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 6, 5
							dd  5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 6, 5, 5, 5, 5, 6
							dd  5, 5, 5, 6, 5, 5, 5, 5, 6, 5, 5
	;mapDataStage1			DWORD 