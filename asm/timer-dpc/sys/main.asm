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
include c:\masm32\include\wdf\kmdf\1.9\wdfmemory.inc

includelib c:\masm32\lib\wxp\i386\BufferOverflowK.lib 
includelib c:\masm32\lib\wxp\i386\ntoskrnl.lib 
includelib c:\masm32\lib\wxp\i386\hal.lib 
includelib c:\masm32\lib\wxp\i386\wmilib.lib 
includelib c:\masm32\lib\wxp\i386\sehupd.lib 
includelib C:\masm32\lib\wdf\kmdf\i386\1.9\wdfldr.lib
includelib C:\masm32\lib\wdf\kmdf\i386\1.9\wdfdriverentry.lib

public DriverEntry
IOCTL_START equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_STOP  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_BUFFERED, FILE_ANY_ACCESS)

.const
DEV_NAME word "\","D","e","v","i","c","e","\","M","y","D","r","i","v","e","r",0
SYM_NAME word "\","D","o","s","D","e","v","i","c","e","s","\","M","y","D","r","i","v","e","r",0
MSG_START byte "IOCTL_START",0
MSG_STOP  byte "IOCTL_STOP",0

.data
dwTimerCnt DWORD ?
pDevice    PDEVICE_OBJECT ?
stTimerObj KTIMER <>
stTimerDPC KDPC <>

.code
OnTimer proc pDpc:PKDPC, pContext:PVOID, pArg1:PVOID, PArg2:PVOID
  inc dwTimerCnt
  invoke DbgPrint, $CTA0("DpcTimer: %d"), dwTimerCnt
  ret
OnTimer endp

IrpFileCreate proc Device:WDFDEVICE, Request:WDFREQUEST, FileObject:WDFFILEOBJECT
  invoke DbgPrint, $CTA0("IrpFieCreate")
  invoke WdfRequestComplete, Request, STATUS_SUCCESS
  ret
IrpFileCreate endp

IrpFileClose proc FileObject:WDFFILEOBJECT
  invoke DbgPrint, $CTA0("IrpFieClose")
  ret
IrpFileClose endp

IrpIOCTL proc Queue:WDFQUEUE, Request:WDFREQUEST, OutputBufferLength:DWORD, InputBufferLength:DWORD, IoControlCode:DWORD
  local stTimeCnt:LARGE_INTEGER
  
  .if IoControlCode == IOCTL_START
    invoke DbgPrint, offset MSG_START
    mov dwTimerCnt, 0
    or stTimeCnt.HighPart, -1
    mov stTimeCnt.LowPart, -10000000
    ;invoke KeSetTimer, offset stTimerObj, stTimeCnt.LowPart, stTimeCnt.HighPart, offset stTimerDPC
    invoke KeSetTimerEx, offset stTimerObj, stTimeCnt.LowPart, stTimeCnt.HighPart, 1000, offset stTimerDPC
  .elseif IoControlCode == IOCTL_STOP
    invoke DbgPrint, offset MSG_STOP
    invoke KeCancelTimer, offset stTimerObj
  .endif
  invoke WdfRequestComplete, Request, STATUS_SUCCESS
  ret
IrpIOCTL endp

AddDevice proc Driver:WDFDRIVER, pDeviceInit:PWDFDEVICE_INIT
  local device:WDFDEVICE
  local suDevName:UNICODE_STRING
  local szSymName:UNICODE_STRING
  local file_cfg:WDF_FILEOBJECT_CONFIG
  local ioqueue_cfg:WDF_IO_QUEUE_CONFIG
  
  invoke RtlInitUnicodeString, addr suDevName, offset DEV_NAME
  invoke RtlInitUnicodeString, addr szSymName, offset SYM_NAME
  invoke WdfDeviceInitAssignName, pDeviceInit, addr suDevName
  invoke WdfDeviceInitSetIoType, pDeviceInit, WdfDeviceIoBuffered
  invoke WDF_FILEOBJECT_CONFIG_INIT, addr file_cfg, offset IrpFileCreate, offset IrpFileClose, NULL
  invoke WdfDeviceInitSetFileObjectConfig, pDeviceInit, addr file_cfg, WDF_NO_OBJECT_ATTRIBUTES
  invoke WdfDeviceCreate, addr pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, addr device
  invoke WdfDeviceCreateSymbolicLink, device, addr szSymName
  invoke WdfDeviceWdmGetDeviceObject, device
  mov pDevice, eax
  invoke KeInitializeTimer, offset stTimerObj
  invoke KeInitializeDpc, offset stTimerDPC, offset OnTimer, pDevice
  invoke WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE, addr ioqueue_cfg, WdfIoQueueDispatchSequential
  lea eax, ioqueue_cfg
  mov (WDF_IO_QUEUE_CONFIG ptr [eax]).EvtIoDeviceControl, offset IrpIOCTL
  invoke WdfIoQueueCreate, device, addr ioqueue_cfg, WDF_NO_OBJECT_ATTRIBUTES, WDF_NO_HANDLE
  ret
AddDevice endp

DriverEntry proc pOurDriver:PDRIVER_OBJECT, pOurRegistry:PUNICODE_STRING
  local config:WDF_DRIVER_CONFIG
  
  invoke WDF_DRIVER_CONFIG_INIT, addr config, AddDevice
  invoke WdfDriverCreate, pOurDriver, pOurRegistry, WDF_NO_OBJECT_ATTRIBUTES, addr config, WDF_NO_HANDLE
  ret
DriverEntry endp
end DriverEntry
.end
