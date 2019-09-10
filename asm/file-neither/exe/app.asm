.386p
.model flat, stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\masm32.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\msvcrt.inc
include c:\masm32\include\kernel32.inc

includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\masm32.lib
includelib c:\masm32\lib\msvcrt.lib
includelib c:\masm32\lib\kernel32.lib

.const
DEV_NAME        db "\\.\firstFile-Neither",0
ERR_OPEN_DRIVER db "failed to open firstFile-Neither driver !",0
SEND_MSG        db "this is test message !",0
WRITE_MSG       db "Write: %s",10,13,0
READ_MSG        db "Read: %s",10,13,0

.data?
hFile     dd ?
dwRet     dd ?
szBuffer  db  256 dup(?)

.code
start:
  invoke CreateFile, offset DEV_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
  .if eax == INVALID_HANDLE_VALUE
    invoke crt_printf, offset ERR_OPEN_DRIVER
    invoke ExitProcess, 0
  .endif
  mov hFile, eax

  invoke wsprintf, offset szBuffer, offset SEND_MSG
  invoke StrLen, offset szBuffer
  mov dwRet, eax
  invoke crt_printf, offset WRITE_MSG, offset szBuffer
  invoke WriteFile, hFile, offset szBuffer, dwRet, offset dwRet, 0
  invoke crt_memset, offset szBuffer, 0, 255
  invoke ReadFile, hFile, offset szBuffer, 255, offset dwRet, 0
  invoke crt_printf, offset READ_MSG, offset szBuffer
  invoke CloseHandle, hFile

  invoke ExitProcess, 0
end start
