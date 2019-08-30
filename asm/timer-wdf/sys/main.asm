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

include c:\masm32\Macros\Strings.mac
include c:\masm32\include\w2k\ntdef.inc
include c:\masm32\include\w2k\ntstatus.inc
include c:\masm32\include\w2k\ntddk.inc
include c:\masm32\include\w2k\ntoskrnl.inc
include c:\masm32\include\w2k\ntddkbd.inc
include c:\masm32\include\wxp\wdm.inc
include c:\masm32\include\wdf\umdf\1.9\wudfddi_types.inc
include c:\masm32\include\wdf\kmdf\1.9\wdf.inc
include c:\masm32\include\wdf\kmdf\1.9\wdftypes.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfglobals.inc
include c:\masm32\include\wdf\kmdf\1.9\wdffuncenum.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfobject.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfdevice.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfdriver.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfrequest.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfio.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfcore.inc
include c:\masm32\include\wdf\kmdf\1.9\wdfmemory.inc
include c:\masm32\include\wdf\kmdf\1.9\wdftimer.inc

includelib c:\masm32\lib\wxp\i386\BufferOverflowK.lib 
includelib c:\masm32\lib\wxp\i386\ntoskrnl.lib 
includelib c:\masm32\lib\wxp\i386\hal.lib 
includelib c:\masm32\lib\wxp\i386\wmilib.lib 
includelib c:\masm32\lib\wxp\i386\sehupd.lib 
includelib C:\masm32\lib\wdf\kmdf\i386\1.9\wdfldr.lib
includelib C:\masm32\lib\wdf\kmdf\i386\1.9\wdfdriverentry.lib

public DriverEntry
IOCTL_TIMER_START  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_TIMER_STOP   equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_BUFFERED, FILE_ANY_ACCESS)

.const
DEV_NAME word "\","D","e","v","i","c","e","\","f","i","r","s","t","T","i","m","e","r","-","W","D","F",0
SYM_NAME word "\","D","o","s","D","e","v","i","c","e","s","\","f","i","r","s","t","T","i","m","e","r","-","W","D","F",0
MSG db "KMDF driver tutorial for Timer-WDF",0

.data
dwTimerCnt  DWORD ?
hTimer      WDFTIMER ?
bExitTimer  BOOLEAN ?

.code
;//*** timer routine
OnTimer proc Timer:WDFTIMER
  local timeout:qword
  local stTimeCnt:LARGE_INTEGER
  
  inc dwTimerCnt
  invoke DbgPrint, $CTA0("OnTimer: %d"), dwTimerCnt

  .if bExitTimer == TRUE
    invoke DbgPrint, $CTA0("Stop timer")
  .else
    lea ebx, timeout
    mov (dword ptr [ebx + 0]), 1000
    mov (dword ptr [ebx + 4]), 0
    invoke WDF_REL_TIMEOUT_IN_MS, timeout
    lea ebx, timeout
    mov (dword ptr [ebx + 0]), eax
    mov (dword ptr [ebx + 4]), edx
    invoke WdfTimerStart, hTimer, timeout
    
    ;//or stTimeCnt.HighPart, -1
    ;//mov stTimeCnt.LowPart, -10000000
    ;//invoke WdfTimerStart, hTimer, stTimeCnt.QuadPart
  .endif
  ret
OnTimer endp

;//*** process CreateFile()
IrpFileCreate proc Device:WDFDEVICE, Request:WDFREQUEST, FileObject:WDFFILEOBJECT
  invoke DbgPrint, $CTA0("IrpFieCreate")
  invoke WdfRequestComplete, Request, STATUS_SUCCESS
  ret
IrpFileCreate endp

;//*** process CloseHandle()
IrpFileClose proc FileObject:WDFFILEOBJECT
  invoke DbgPrint, $CTA0("IrpFieClose")
  ret
IrpFileClose endp

;//*** process DeviceIoControl()
IrpIOCTL proc uses ebx edx Queue:WDFQUEUE, Request:WDFREQUEST, OutputBufferLength:DWORD, InputBufferLength:DWORD, IoControlCode:DWORD
  local timeout:qword
  local stTimeCnt:LARGE_INTEGER
  
  .if IoControlCode == IOCTL_TIMER_START
    invoke DbgPrint, $CTA0("_IOCTL_TIMER_START")
    mov bExitTimer, FALSE
    mov dwTimerCnt, 0
    
    lea ebx, timeout
    mov (dword ptr [ebx + 0]), 1000
    mov (dword ptr [ebx + 4]), 0
    invoke WDF_REL_TIMEOUT_IN_MS, timeout
    lea ebx, timeout
    mov (dword ptr [ebx + 0]), eax
    mov (dword ptr [ebx + 4]), edx
    invoke WdfTimerStart, hTimer, timeout
    
    ;//or stTimeCnt.HighPart, -1
    ;//mov stTimeCnt.LowPart, -10000000
    ;//invoke WdfTimerStart, hTimer, stTimeCnt.QuadPart
  .elseif IoControlCode == IOCTL_TIMER_STOP
    invoke DbgPrint, $CTA0("_IOCTL_TIMER_STOP")
    mov bExitTimer, TRUE
  .endif
  invoke WdfRequestComplete, Request, STATUS_SUCCESS
  ret
IrpIOCTL endp

;//*** system will vist this routine when it needs to add new device
AddDevice proc Driver:WDFDRIVER, pDeviceInit:PWDFDEVICE_INIT
  local device:WDFDEVICE
  local file_cfg:WDF_FILEOBJECT_CONFIG
  local ioqueue_cfg:WDF_IO_QUEUE_CONFIG
  local suDevName:UNICODE_STRING
  local szSymName:UNICODE_STRING
  local timer_cfg:WDF_TIMER_CONFIG
  local timer_attribute:WDF_OBJECT_ATTRIBUTES
  
  invoke DbgPrint, offset MSG
  invoke RtlInitUnicodeString, addr suDevName, offset DEV_NAME
  invoke RtlInitUnicodeString, addr szSymName, offset SYM_NAME
  invoke WdfDeviceInitAssignName, pDeviceInit, addr suDevName
  
  invoke WdfDeviceInitSetIoType, pDeviceInit, WdfDeviceIoBuffered
  invoke WDF_FILEOBJECT_CONFIG_INIT, addr file_cfg, offset IrpFileCreate, offset IrpFileClose, NULL
  invoke WdfDeviceInitSetFileObjectConfig, pDeviceInit, addr file_cfg, WDF_NO_OBJECT_ATTRIBUTES
  invoke WdfDeviceCreate, addr pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, addr device
  invoke WdfDeviceCreateSymbolicLink, device, addr szSymName
  
  invoke WDF_TIMER_CONFIG_INIT, addr timer_cfg, OnTimer
  ;//invoke WDF_TIMER_CONFIG_INIT_PERIODIC, addr timer_cfg, OnTimer, 1000
  invoke WDF_OBJECT_ATTRIBUTES_INIT, addr timer_attribute
  lea eax, timer_attribute
  push device
  pop (WDF_OBJECT_ATTRIBUTES ptr [eax]).ParentObject
  
  mov hTimer, 0
  invoke WdfTimerCreate, addr timer_cfg, addr timer_attribute, addr hTimer

  invoke WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE, addr ioqueue_cfg, WdfIoQueueDispatchSequential
  lea eax, ioqueue_cfg
  mov (WDF_IO_QUEUE_CONFIG ptr [eax]).EvtIoDeviceControl, offset IrpIOCTL
  invoke WdfIoQueueCreate, device, addr ioqueue_cfg, WDF_NO_OBJECT_ATTRIBUTES, WDF_NO_HANDLE
  ret
AddDevice endp

;//*** driver entry
DriverEntry proc pOurDriver:PDRIVER_OBJECT, pOurRegistry:PUNICODE_STRING
  local config:WDF_DRIVER_CONFIG
  
  invoke WDF_DRIVER_CONFIG_INIT, addr config, AddDevice
  invoke WdfDriverCreate, pOurDriver, pOurRegistry, WDF_NO_OBJECT_ATTRIBUTES, addr config, WDF_NO_HANDLE
  ret
DriverEntry endp
end DriverEntry
.end
