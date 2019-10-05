#include <ntddk.h>
#include <wdf.h>
 
void Unload(WDFDRIVER Driver)
{
}

NTSTATUS DriverEntry(PDRIVER_OBJECT pOurDriver, PUNICODE_STRING pRegistry)
{
 WDFDEVICE device;
 WDFDRIVER driver;
 PWDFDEVICE_INIT pInit;
 WDF_DRIVER_CONFIG config;
 
 DbgPrint("Hello, world!");
 WDF_DRIVER_CONFIG_INIT(&config, WDF_NO_EVENT_CALLBACK);
 config.DriverInitFlags|= WdfDriverInitNonPnpDriver;
 config.EvtDriverUnload = Unload;
 WdfDriverCreate(pOurDriver, pRegistry, WDF_NO_OBJECT_ATTRIBUTES, &config, &driver);
 pInit = WdfControlDeviceInitAllocate(driver, &SDDL_DEVOBJ_SYS_ALL_ADM_RWX_WORLD_RW_RES_R);
 WdfDeviceInitSetIoType(pInit, WdfDeviceIoBuffered);
 return WdfDeviceCreate(&pInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
}
