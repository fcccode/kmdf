#include <ntddk.h>
#include <wdf.h>

#define DEV_NAME L"\\Device\\MyDriver"
#define SYM_NAME L"\\DosDevices\\MyDriver"

#define IOCTL_START CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_BUFFERED, FILE_ANY_ACCESS)
#define IOCTL_STOP  CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_BUFFERED, FILE_ANY_ACCESS)

ULONG cnt=0;
WDFTIMER hTimer;
PDEVICE_OBJECT pDevice;

VOID OnTimer(WDFTIMER Timer)
{
  cnt+= 1;
  DbgPrint("WdfTimer: %d", cnt);
}

void IrpFileCreate(WDFDEVICE Device, WDFREQUEST Request, WDFFILEOBJECT FileObject)
{  
  DbgPrint("IrpFieCreate");
  WdfRequestComplete(Request, STATUS_SUCCESS);
}

void IrpFileClose(WDFFILEOBJECT FileObject)
{
  DbgPrint("IrpFieClose");
}

void IrpIOCTL(WDFQUEUE Queue, WDFREQUEST Request, size_t OutputBufferLength, size_t InputBufferLength, ULONG IoControlCode)
{
  LARGE_INTEGER tt;
  
  switch(IoControlCode){
  case IOCTL_START:
    DbgPrint("IOCTL_START");
    cnt = 0;
    tt.HighPart = -1;
    tt.LowPart = (ULONG)-10000000;
    WdfTimerStart(hTimer, tt.QuadPart);
    break;
  case IOCTL_STOP:
    DbgPrint("IOCTL_STOP");
    WdfTimerStop(hTimer, FALSE);
    break;
  }
  WdfRequestComplete(Request, STATUS_SUCCESS);
}

NTSTATUS AddDevice(WDFDRIVER Driver, PWDFDEVICE_INIT pDeviceInit)
{
  WDFDEVICE device;
  UNICODE_STRING suDevName;
  UNICODE_STRING szSymName;
  WDF_TIMER_CONFIG timer_cfg;
  WDF_FILEOBJECT_CONFIG file_cfg;
  WDF_IO_QUEUE_CONFIG ioqueue_cfg;
  WDF_OBJECT_ATTRIBUTES timer_attribute;
  
  RtlInitUnicodeString(&suDevName, DEV_NAME);
  RtlInitUnicodeString(&szSymName, SYM_NAME);
  WdfDeviceInitAssignName(pDeviceInit, &suDevName);
  
  WdfDeviceInitSetIoType(pDeviceInit, WdfDeviceIoBuffered);
  WDF_FILEOBJECT_CONFIG_INIT(&file_cfg, IrpFileCreate, IrpFileClose, NULL);
  WdfDeviceInitSetFileObjectConfig(pDeviceInit, &file_cfg, WDF_NO_OBJECT_ATTRIBUTES);
  WdfDeviceCreate(&pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
  WdfDeviceCreateSymbolicLink(device, &szSymName);
  
  WDF_TIMER_CONFIG_INIT_PERIODIC(&timer_cfg, OnTimer, 1000);
  WDF_OBJECT_ATTRIBUTES_INIT(&timer_attribute);
  timer_attribute.ParentObject = device;
  WdfTimerCreate(&timer_cfg, &timer_attribute, &hTimer);
  
  WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&ioqueue_cfg, WdfIoQueueDispatchSequential);
  ioqueue_cfg.EvtIoDeviceControl = IrpIOCTL;
  return WdfIoQueueCreate(device, &ioqueue_cfg, WDF_NO_OBJECT_ATTRIBUTES, WDF_NO_HANDLE);
}

NTSTATUS DriverEntry(PDRIVER_OBJECT pOurDriver, PUNICODE_STRING pRegistry)
{
  WDF_DRIVER_CONFIG config;

  WDF_DRIVER_CONFIG_INIT(&config, AddDevice);
  return WdfDriverCreate(pOurDriver, pRegistry, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
}
