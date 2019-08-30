/*====================================================================================
 Copyright (c) 2015 by Steward Fu
 All rights reserved
 2015/05/01
====================================================================================*/
#include <ntddk.h>
#include <wdf.h>
 
/*====================================================================================
description:
 call this function to add new device
 
parameter:
 Driver: our driver data
 pDeviceInit: point to device initial data
 
return:
 status
====================================================================================*/
NTSTATUS AddDevice(IN WDFDRIVER Driver, IN PWDFDEVICE_INIT pDeviceInit)
{
 NTSTATUS status;
 WDFDEVICE device;
  
 status = WdfDeviceCreate(&pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
 if(!NT_SUCCESS(status)) {
  KdPrint(("WdfDeviceCreate failed: 0x%x\n", status));
 }
 return status;
}
 
/*====================================================================================
description:
 main driver entry point
 
parameter:
 pDriverObject: pointer to our driver structure
 pRegistryPath: pointer to our driver location in registry
 
return:
 status
====================================================================================*/
NTSTATUS DriverEntry(PDRIVER_OBJECT pDriverObject, PUNICODE_STRING pRegistryPath)
{
 WDF_DRIVER_CONFIG config;
 NTSTATUS status;
  
 DbgPrint("Steward's driver tutorial, Hello, world!\r\n");
 WDF_DRIVER_CONFIG_INIT(&config, AddDevice);
 status = WdfDriverCreate(pDriverObject, pRegistryPath, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
 if(!NT_SUCCESS(status)){
  DbgPrint("WdfDriverCreate failed: 0x%x\n", status);
 }
 return status;
}
