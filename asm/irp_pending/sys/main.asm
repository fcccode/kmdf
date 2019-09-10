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
IOCTL_PENDING_IT      equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_BUFFERED, FILE_ANY_ACCESS)
IOCTL_NOT_PENDING_IT  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_BUFFERED, FILE_ANY_ACCESS)

.const
DEV_NAME word "\","D","e","v","i","c","e","\","f","i","r","s","t","I","r","p","P","e","n","d","i","n","g",0
SYM_NAME word "\","D","o","s","D","e","v","i","c","e","s","\","f","i","r","s","t","I","r","p","P","e","n","d","i","n","g",0
MSG db "KMDF driver tutorial for Irp Pending",0

.code
;//*** process cancel irp
IrpCancel proc Request:WDFREQUEST
  invoke DbgPrint, $CTA0("IrpCancel")
  invoke WdfRequestCompleteWithInformation, Request, STATUS_CANCELLED, 0
  ret
IrpCancel endp

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
  
  .if IoControlCode == IOCTL_PENDING_IT
    invoke DbgPrint, $CTA0("_IOCTL_PENDING_IT")
    invoke WdfRequestMarkCancelable, Request, IrpCancel
  .elseif IoControlCode == IOCTL_NOT_PENDING_IT
    invoke DbgPrint, $CTA0("_IOCTL_NOT_PENDING_IT")
    invoke WdfRequestComplete, Request, STATUS_SUCCESS
  .endif
  ret
IrpIOCTL endp

;//*** system will vist this routine when it needs to add new device
AddDevice proc Driver:WDFDRIVER, pDeviceInit:PWDFDEVICE_INIT
  local device:WDFDEVICE
  local file_cfg:WDF_FILEOBJECT_CONFIG
  local ioqueue_cfg:WDF_IO_QUEUE_CONFIG
  local suDevName:UNICODE_STRING
  local szSymName:UNICODE_STRING
  
  invoke DbgPrint, offset MSG
  invoke RtlInitUnicodeString, addr suDevName, offset DEV_NAME
  invoke RtlInitUnicodeString, addr szSymName, offset SYM_NAME
  invoke WdfDeviceInitAssignName, pDeviceInit, addr suDevName
  
  invoke WdfDeviceInitSetIoType, pDeviceInit, WdfDeviceIoBuffered
  invoke WDF_FILEOBJECT_CONFIG_INIT, addr file_cfg, offset IrpFileCreate, offset IrpFileClose, NULL
  invoke WdfDeviceInitSetFileObjectConfig, pDeviceInit, addr file_cfg, WDF_NO_OBJECT_ATTRIBUTES
  invoke WdfDeviceCreate, addr pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, addr device
  invoke WdfDeviceCreateSymbolicLink, device, addr szSymName

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
