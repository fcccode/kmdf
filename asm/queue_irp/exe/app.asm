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

IOCTL_QUEUE_IT    equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED,    FILE_ANY_ACCESS)

.const
DEV_NAME db "\\.\firstQueue",0
  
.data?
cnt   dd ?
hFile dd ?
dwRet dd ?
ov OVERLAPPED <?>
 
.code
start:
  invoke CreateFile, offset DEV_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_FLAG_OVERLAPPED or FILE_ATTRIBUTE_NORMAL, 0
  .if eax == INVALID_HANDLE_VALUE
    invoke crt_printf, $CTA0("Failed to open driver")
    invoke ExitProcess, 0
  .endif
  mov hFile, eax
  invoke crt_memset, offset ov, 0, sizeof OVERLAPPED
   
  mov cnt, 3
  .while cnt > 0
    invoke CreateEvent,NULL, TRUE, FALSE, NULL
    push eax
    pop ov.hEvent
    invoke crt_printf, $CTA0("Queue it\n")
    invoke DeviceIoControl, hFile, IOCTL_QUEUE_IT, NULL, 0, NULL, 0, offset dwRet, offset ov
    invoke CloseHandle, ov.hEvent
    sub cnt, 1
  .endw
  invoke crt_printf, $CTA0("Sleep 10s\n")
  invoke Sleep, 10000
  invoke CloseHandle, hFile
  invoke crt_printf, $CTA0("Exit\n")
  invoke ExitProcess, 0
end start
