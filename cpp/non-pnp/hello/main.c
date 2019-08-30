/*====================================================================================
 Copyright (c) 2015 by Steward Fu
 All rights reserved
 2015/05/08
====================================================================================*/
#include <ntddk.h>
#include <wdf.h>
 
/*====================================================================================
description:
 unload driver
 
parameter:
 Driver: wdf driver structure
 
return:
 nothing
====================================================================================*/
void Unload(WDFDRIVER Driver)
{
}
 
/*====================================================================================
description:
 driver entry point
 
parameter:
 pDrvObj: our driver object
 pRegPath: registry path for our driver
 
return:
 status
====================================================================================*/
NTSTATUS DriverEntry(PDRIVER_OBJECT pDrvObj, PUNICODE_STRING pRegPath)
{
 WDF_DRIVER_CONFIG config;
 WDFDEVICE device;
 WDFDRIVER driver;
 NTSTATUS status;
 PWDFDEVICE_INIT pInit=NULL;
 
 DbgPrint("Steward KMDF Driver Tutorial(Non-PnP), Hello, world!\r\n");
 WDF_DRIVER_CONFIG_INIT(&config, WDF_NO_EVENT_CALLBACK);
 config.DriverInitFlags|= WdfDriverInitNonPnpDriver;
 config.EvtDriverUnload = Unload;
 
 status = WdfDriverCreate(pDrvObj, pRegPath, WDF_NO_OBJECT_ATTRIBUTES, &config, &driver);
 if(!NT_SUCCESS(status)){
  DbgPrint("WdfDriverCreate Failed: 0x%X\r\n", status);
  return status;
 }
 
 pInit = WdfControlDeviceInitAllocate(driver, &SDDL_DEVOBJ_SYS_ALL_ADM_RWX_WORLD_RW_RES_R);
 if(pInit == NULL){
  DbgPrint("WdfControlDeviceInitAllocate Failed: 0x%X\r\n", status);
  return status;
 }
 WdfDeviceInitSetIoType(pInit, WdfDeviceIoBuffered);
 
 status = WdfDeviceCreate(&pInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
 if(!NT_SUCCESS(status)){
  DbgPrint("WdfDeviceCreate Failed: 0x%X\r\n", status);
  return status;
 }
 return STATUS_SUCCESS;
}
