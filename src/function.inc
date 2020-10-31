include windows.inc 
include user32.inc 
include kernel32.inc 
include gdi32.inc
include msvcrt.inc
include comdlg32.inc
include comctl32.inc
INCLUDE winmm.inc
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
_PaintObjectAtPos		proto :DWORD,:DWORD,:DWORD,:HWND,:DWORD
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









ID_TIMER_BEAT			equ 1 ; TODO: 或许最终节拍不用timer（不等距）
MAX_PATH_LENGTH			equ 100
; 游戏状态
; beat
BEAT_INTERVAL			equ 1000  ; ms
TOLERANCE_INTERVAL		equ 200   ; ms

; map
MAP_WIDTH				equ 14
MAP_HEIGHT				equ 14

; enemy
MAX_ENEMY_NUM			equ 100

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
PAINT_WINDOW_WIDTH		equ 9
PAINT_WINDOW_HEIGHT		equ 9
; 地图类型定义
MAP_TYPE_DIRTY_FLOOR	equ 0







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
	ALIGN				dword
	posX				dd ?
	posY				dd ?
	health				dd ?
	attack				dd ?
	attackRangeType		dd ?
	nextStep			dd ?
	moveType			dd ?
	hBmp				dd ?
Enemy ends












.data
	hInstance				dd ? ; 实例句柄
	hWinMain				dd ? ; 窗口句柄
	hWindowHDC				dd ?
	; 资源句柄
	hPlayerBmp				dd ?
	hDirtyFloorBmp			dd ?

	; 游戏状态
	mapMatrix				dd MAP_WIDTH * MAP_HEIGHT dup(0)
	level					dd ?
	player					Player <>
	enemys					Enemy MAX_ENEMY_NUM dup(<>)
	dwBaseTick				dd ? ; 上一个节拍的时间戳

	; 绘图状态
	paintWindowPosX			dd ?
	paintWindowPosY			dd ?


; 常量定义
.const
	szClassName				db 'Window', 0
	szBgmFilePath			db 'media\\bgm.wav', 0
	szPlayerPicPath			db 'image\\Cadence.bmp', 0
	szDirtyFloorPicPath		db 'image\\Dirty_Floor.bmp', 0
