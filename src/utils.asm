.386 
.model flat,stdcall 
option casemap:none

include function.inc

.code








_CreateDIBitmap proc hWnd, lpFileData
	local @lpBitmapInfo, @lpBitmapBits
	local @dwWidth, @dwHeight
	local @hDc, @hBitmap
	pushad
	mov @hBitmap, 0
	mov esi, lpFileData
	mov eax, BITMAPFILEHEADER.bfOffBits [esi]
	add eax, esi
	mov @lpBitmapBits, eax
	add esi, sizeof BITMAPFILEHEADER
	mov @lpBitmapInfo, esi
	.if BITMAPINFO.bmiHeader.biSize [esi] == sizeof BITMAPCOREHEADER
		movzx eax, BITMAPCOREHEADER.bcWidth [esi]
		movzx eax, BITMAPCOREHEADER.bcHeight [esi]
	.else
		mov eax, BITMAPINFOHEADER.biWidth [esi]
		mov ebx, BITMAPINFOHEADER.biHeight [esi]
	.endif
	mov @dwWidth, eax
	mov @dwHeight, ebx
	invoke GetDC, hWnd
	push eax
	invoke CreateCompatibleDC, eax
	mov @hDc, eax
	pop eax
	push eax
	invoke CreateCompatibleBitmap, eax, @dwWidth, @dwHeight
	mov @hBitmap, eax
	invoke SelectObject, @hDc, @hBitmap
	pop eax
	invoke ReleaseDC, hWindowHDC, eax
	invoke SetDIBitsToDevice, @hDc, 0, 0, @dwWidth, @dwHeight,\
		   0, 0, 0, @dwHeight, \
		   @lpBitmapBits, @lpBitmapInfo, DIB_RGB_COLORS
	.if eax == 0
		invoke DeleteObject, @hBitmap
		mov @hBitmap, 0
	.endif
	invoke DeleteDC, @hDc
	popad
	mov eax, @hBitmap
	ret
_CreateDIBitmap endp
end