;//========================================================================================================
;//  Basically, all of files downloaded from my website can be modified or redistributed for any purpose.
;//  It is my honor to share my interesting to everybody.
;//  If you find any illeage content out from my website, please contact me firstly.
;//  I will remove all of the illeage parts.
;//  Thanks :)
;//  
;//  Steward Fu
;//  g9313716@yuntech.edu.tw
;//  https://steward-fu.github.io/website/index.htm
;//========================================================================================================*/
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

IOCTL_TIMER_START  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_TIMER_STOP   equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_BUFFERED, FILE_ANY_ACCESS)

.const
DEV_NAME  db "\\.\firstTimer-WDF",0
 
.data?
hFile     dd ?
dwRet     dd ?

.code
start:
  invoke CreateFile, offset DEV_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
  .if eax == INVALID_HANDLE_VALUE
    invoke crt_printf, $CTA0("failed to open driver")
    invoke ExitProcess, 0
  .endif
  mov hFile, eax
   
  invoke crt_printf, $CTA0("Start tiemr\n")
  invoke DeviceIoControl, hFile, IOCTL_TIMER_START, NULL, 0, NULL, 0, offset dwRet, NULL
  invoke crt_printf, $CTA0("Sleep 3s\n")
  invoke Sleep, 3000
  invoke crt_printf, $CTA0("Stop timer\n")
  invoke DeviceIoControl, hFile, IOCTL_TIMER_STOP, NULL, 0, NULL, 0, offset dwRet, NULL
 
  invoke CloseHandle, hFile
  invoke ExitProcess, 0
end start

