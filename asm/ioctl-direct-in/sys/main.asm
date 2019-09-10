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
IOCTL_DIRECT_GET  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 800h, METHOD_IN_DIRECT, FILE_ANY_ACCESS)
IOCTL_DIRECT_SET  equ CTL_CODE(FILE_DEVICE_UNKNOWN, 801h, METHOD_IN_DIRECT, FILE_ANY_ACCESS)

.const
DEV_NAME word "\","D","e","v","i","c","e","\","f","i","r","s","t","I","O","C","T","L","-","D","i","r","e","c","t","-","I","n",0
SYM_NAME word "\","D","o","s","D","e","v","i","c","e","s","\","f","i","r","s","t","I","O","C","T","L","-","D","i","r","e","c","t","-","I","n",0
MSG db "KMDF driver tutorial for Device IOCTL-Direct-In",0

.data
szBuffer byte 1024 dup(0)

.code
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
IrpIOCTL proc Queue:WDFQUEUE, Request:WDFREQUEST, OutputBufferLength:DWORD, InputBufferLength:DWORD, IoControlCode:DWORD
  local memory:WDFMEMORY
  local mdl:PMDL
  
  .if IoControlCode == IOCTL_DIRECT_SET
    invoke DbgPrint, $CTA0("_IOCTL_DIRECT_SET")
    invoke WdfRequestRetrieveInputWdmMdl, Request, addr mdl
	  MmGetSystemAddressForMdlSafe mdl, LowPagePriority
	  invoke memcpy, offset szBuffer, eax, InputBufferLength
	  invoke DbgPrint, $CTA0("Buf: %s, Len:%d"), offset szBuffer, InputBufferLength
	  invoke WdfRequestSetInformation, Request, InputBufferLength
  .elseif IoControlCode == IOCTL_DIRECT_GET
    invoke DbgPrint, $CTA0("_IOCTL_DIRECT_GET")
    invoke WdfRequestRetrieveOutputWdmMdl, Request, addr mdl
	  MmGetSystemAddressForMdlSafe mdl, LowPagePriority
	  invoke memcpy, eax, offset szBuffer, OutputBufferLength
	  invoke WdfRequestSetInformation, Request, OutputBufferLength
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
