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

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; Equ 等值定义
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
ID_TIMER equ 1

BEAT_INTERVAL equ 1000  ;ms
TOLERANCE_INTERVAL equ 200 ;ms


;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
; 数据段
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
.data?
hInstance dd ? ; 实例句柄
hWinMain dd	? ; 窗口句柄
dwBaseTick dword ? ; 上一个节拍的时间戳

.const
szClassName db 'Window',0
szBgmFilePath db '.\media\bgm.wav',0

_ProcWinMain               proto :HWND,:UINT,:WPARAM,:LPARAM