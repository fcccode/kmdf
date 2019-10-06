#include <ntddk.h>
#include <wdf.h>

NTSTATUS AddDevice(WDFDRIVER pOurWDF, PWDFDEVICE_INIT pDeviceInit)
{
  WDFDEVICE device;
  UNICODE_STRING usDeviceName;
 
  DbgPrint("Hello, world!");
  RtlInitUnicodeString(&usDeviceName, L"\\Device\\MyDriver");
  WdfDeviceInitAssignName(pDeviceInit, &usDeviceName);
  return WdfDeviceCreate(&pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
}

NTSTATUS DriverEntry(PDRIVER_OBJECT pOurDriver, PUNICODE_STRING pRegistry)
{
  WDF_DRIVER_CONFIG config;

  WDF_DRIVER_CONFIG_INIT(&config, AddDevice);
  return WdfDriverCreate(pOurDriver, pRegistry, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
}
