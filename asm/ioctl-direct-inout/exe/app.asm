.386p
.model flat, stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\masm32.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\w2k\ntddkbd.inc
include c:\masm32\Macros\Strings.mac
 
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\masm32.lib
includelib c:\masm32\lib\msvcrt.lib
includelib c:\masm32\lib\kernel32.lib

IOCTL_GET equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_OUT_DIRECT, FILE_ANY_ACCESS)
IOCTL_SET equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_IN_DIRECT, FILE_ANY_ACCESS)
 
.const
DEV_NAME db "\\.\MyDriver",0
 
.data?
hFile    dd ?
dwRet    dd ?
szBuffer db 255 dup(?)
 
.code
start:
  invoke CreateFile, offset DEV_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
  .if eax == INVALID_HANDLE_VALUE
    invoke crt_printf, $CTA0("failed to open mydriver")
    invoke ExitProcess, -1
  .endif
  
  mov hFile, eax
  invoke wsprintf, offset szBuffer, $CT0("I am error")
  invoke StrLen, offset szBuffer
  inc eax
  mov dwRet, eax
  invoke crt_printf, $CTA0("SET: %s, %d\n"), offset szBuffer, dwRet
  invoke DeviceIoControl, hFile, IOCTL_SET, offset szBuffer, dwRet, NULL, 0, offset dwRet, NULL
  invoke crt_memset, offset szBuffer, 0, 255
  invoke DeviceIoControl, hFile, IOCTL_GET, NULL, 0, offset szBuffer, 255, offset dwRet, NULL
  invoke crt_printf, $CTA0("GET: %s, %d\n"), offset szBuffer, dwRet
  invoke CloseHandle, hFile
  invoke ExitProcess, 0
  
end start
