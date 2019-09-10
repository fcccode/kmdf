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

IOCTL_PENDING_IT      equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_NOT_PENDING_IT  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_BUFFERED, FILE_ANY_ACCESS)

.const
DEV_NAME db "\\.\firstIrpPending",0
  
.data?
hFile dd ?
dwRet dd ?
ov OVERLAPPED <?>
 
.code
start:
  ;// overlapped
  invoke CreateFile, offset DEV_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_FLAG_OVERLAPPED or FILE_ATTRIBUTE_NORMAL, 0
  .if eax == INVALID_HANDLE_VALUE
    invoke crt_printf, $CTA0("failed to open driver")
    invoke ExitProcess, 0
  .endif
  mov hFile, eax
  invoke crt_memset, offset ov, 0, sizeof OVERLAPPED
   
  ;// IOCTL_NOT_PENDING_IT
  invoke crt_printf, $CTA0("using FILE_FLAG_OVERLAPPED or FILE_ATTRIBUTE_NORMAL\n")
  invoke CreateEvent,NULL, TRUE, FALSE, NULL
  push eax
  pop ov.hEvent
  invoke crt_printf, $CTA0("_IOCTL_NOT_PENDING_IT\n")
  invoke DeviceIoControl, hFile, IOCTL_NOT_PENDING_IT, NULL, 0, NULL, 0, offset dwRet, offset ov
  invoke crt_printf, $CTA0("DeviceIoControl: 0x%x\n"), eax
  invoke GetLastError
  invoke crt_printf, $CTA0("GetLastError: 0x%x\n"), eax
  invoke crt_printf, $CTA0("Wait for complete...\n")
  invoke WaitForSingleObject, ov.hEvent, INFINITE
  invoke crt_printf, $CTA0("Complete\n\n")
  invoke CloseHandle, ov.hEvent
  
  ;// IOCTL_PENDING_IT
  invoke crt_printf, $CTA0("using FILE_FLAG_OVERLAPPED or FILE_ATTRIBUTE_NORMAL\n")
  invoke CreateEvent,NULL, TRUE, FALSE, NULL
  push eax
  pop ov.hEvent
  invoke crt_printf, $CTA0("_IOCTL_PENDING_IT\n")
  invoke DeviceIoControl, hFile, IOCTL_PENDING_IT, NULL, 0, NULL, 0, offset dwRet, offset ov
  invoke crt_printf, $CTA0("DeviceIoControl: 0x%x\n"), eax
  invoke GetLastError
  invoke crt_printf, $CTA0("GetLastError: 0x%x\n"), eax
  invoke crt_printf, $CTA0("Wait for complete...\n")
  invoke WaitForSingleObject, ov.hEvent, 1000
  .if eax == WAIT_TIMEOUT
    invoke crt_printf, $CTA0("Cancel it\n\n")
    invoke CancelIo, hFile
  .else
    invoke crt_printf, $CTA0("Complete\n\n")
  .endif
  invoke CloseHandle, ov.hEvent
  invoke CloseHandle, hFile
  
  ;// non overlapped
  invoke CreateFile, offset DEV_NAME, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
  .if eax == INVALID_HANDLE_VALUE
    invoke crt_printf, $CTA0("failed to open driver")
    invoke ExitProcess, 0
  .endif
  mov hFile, eax
  invoke crt_memset, offset ov, 0, sizeof OVERLAPPED
   
  ;// IOCTL_NOT_PENDING_IT
  invoke crt_printf, $CTA0("using FILE_ATTRIBUTE_NORMAL\n")
  invoke crt_printf, $CTA0("_IOCTL_NOT_PENDING_IT\n")
  invoke DeviceIoControl, hFile, IOCTL_NOT_PENDING_IT, NULL, 0, NULL, 0, offset dwRet, NULL
  invoke crt_printf, $CTA0("DeviceIoControl: 0x%x\n"), eax
  invoke GetLastError
  invoke crt_printf, $CTA0("GetLastError: 0x%x\n"), eax
  invoke crt_printf, $CTA0("Complete\n\n")
  
  ;// IOCTL_PENDING_IT
  invoke crt_printf, $CTA0("using FILE_ATTRIBUTE_NORMAL\n")
  invoke crt_printf, $CTA0("_IOCTL_PENDING_IT\n")
  invoke DeviceIoControl, hFile, IOCTL_PENDING_IT, NULL, 0, NULL, 0, offset dwRet, NULL
  invoke crt_printf, $CTA0("DeviceIoControl: 0x%x\n"), eax
  invoke GetLastError
  invoke crt_printf, $CTA0("GetLastError: 0x%x\n"), eax
  invoke crt_printf, $CTA0("Wait for complete...\n")
  invoke crt_printf, $CTA0("Complete\n")
  invoke CloseHandle, hFile
  invoke ExitProcess, 0
end start
