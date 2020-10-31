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

; ��������
_ProcWinMain            proto :HWND,:UINT,:WPARAM,:LPARAM
_CreateDIBitmap			proto :HWND, :DWORD
_PaintGameFrame			proto :HWND,:DWORD
_PaintMap				proto :HWND, :DWORD
_PaintPlayer			proto :HWND, :DWORD
_PaintEnemy				proto :HWND, :DWORD
_PaintObjectAtPos		proto :DWORD,:DWORD,:DWORD,:HWND,:DWORD
_InitResources			proto



getMatrixIndex			proto :DWORD, :DWORD, :DWORD, :DWORD
getIndexPos				proto :DWORD, :DWORD, :DWORD				; ����ĳ��Index��X,Y �ֱ���eax��ecx
changeMapPosTo			proto :DWORD, :DWORD, :DWORD				; �ı��ͼĳһλ�õĵ���
getPicOfMapType			proto :DWORD								; ����ĳһ���ε�ͼƬ·��ָ��
actualPosToPaintWindowPos proto :DWORD, :DWORD

startGame				proto :DWORD								; ����Ϸ��ʼ����Դ׼��
initMap					proto :DWORD								; ��ʼ��������ͼ�����ļ�����
initPlayer				proto :DWORD								; ��ʼ�����
initEnemy				proto :DWORD								; ��ʼ������

updateStatus			proto										; ������Ϸ״̬









ID_TIMER_BEAT			equ 1 ; TODO: �������ս��Ĳ���timer�����Ⱦࣩ
MAX_PATH_LENGTH			equ 100
; ��Ϸ״̬
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
; ��ͼ���
GRID_SIZE				equ 50
PAINT_WINDOW_WIDTH		equ 9
PAINT_WINDOW_HEIGHT		equ 9
; ��ͼ���Ͷ���
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
	hInstance				dd ? ; ʵ�����
	hWinMain				dd ? ; ���ھ��
	hWindowHDC				dd ?
	; ��Դ���
	hPlayerBmp				dd ?
	hDirtyFloorBmp			dd ?

	; ��Ϸ״̬
	mapMatrix				dd MAP_WIDTH * MAP_HEIGHT dup(0)
	level					dd ?
	player					Player <>
	enemys					Enemy MAX_ENEMY_NUM dup(<>)
	dwBaseTick				dd ? ; ��һ�����ĵ�ʱ���

	; ��ͼ״̬
	paintWindowPosX			dd ?
	paintWindowPosY			dd ?


; ��������
.const
	szClassName				db 'Window', 0
	szBgmFilePath			db 'media\\bgm.wav', 0
	szPlayerPicPath			db 'image\\Cadence.bmp', 0
	szDirtyFloorPicPath		db 'image\\Dirty_Floor.bmp', 0