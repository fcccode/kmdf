#include <ntddk.h>
#include <wdf.h>

#define DEV_NAME L"\\Device\\MyDriver"
#define SYM_NAME L"\\DosDevices\\MyDriver"

char szBuffer[255]={0};

void IrpFileCreate(WDFDEVICE Device, WDFREQUEST Request, WDFFILEOBJECT FileObject)
{  
  DbgPrint("IrpFieCreate");
  WdfRequestComplete(Request, STATUS_SUCCESS);
}

void IrpFileClose(WDFFILEOBJECT FileObject)
{
  DbgPrint("IrpFieClose");
}

void IrpRead(WDFQUEUE Queue, WDFREQUEST Request, size_t Length)
{
  ULONG len;
  PVOID buf;
  WDFMEMORY memory;
  
  DbgPrint("IrpRead");
  WdfRequestRetrieveUnsafeUserOutputBuffer(Request, Length, &buf, &len);
  WdfRequestProbeAndLockUserBufferForWrite(Request, buf, len, &memory);
  buf = WdfMemoryGetBuffer(memory, NULL);
  len = strlen(szBuffer) + 1;
  memcpy(buf, szBuffer, len);
  WdfRequestCompleteWithInformation(Request, STATUS_SUCCESS, len);
}

void IrpWrite(WDFQUEUE Queue, WDFREQUEST Request, size_t Length)
{
  ULONG len;
  PVOID buf;
  WDFMEMORY memory;
  
  DbgPrint("IrpWrite");
  WdfRequestRetrieveUnsafeUserInputBuffer(Request, Length, &buf, &len);
  WdfRequestProbeAndLockUserBufferForRead(Request, buf, len, &memory);
  buf = WdfMemoryGetBuffer(memory, NULL);
  memcpy(szBuffer, buf, Length);
  DbgPrint("Buffer: %s, Length:%d", szBuffer, Length);
  WdfRequestCompleteWithInformation(Request, STATUS_SUCCESS, Length);
}

NTSTATUS AddDevice(WDFDRIVER Driver, PWDFDEVICE_INIT pDeviceInit)
{
  WDFDEVICE device;
  UNICODE_STRING suDevName;
  UNICODE_STRING szSymName;
  WDF_FILEOBJECT_CONFIG file_cfg;
  WDF_IO_QUEUE_CONFIG ioqueue_cfg;
  
  RtlInitUnicodeString(&suDevName, DEV_NAME);
  RtlInitUnicodeString(&szSymName, SYM_NAME);
  WdfDeviceInitAssignName(pDeviceInit, &suDevName);
  
  WdfDeviceInitSetIoType(pDeviceInit, WdfDeviceIoNeither);
  WDF_FILEOBJECT_CONFIG_INIT(&file_cfg, IrpFileCreate, IrpFileClose, NULL);
  WdfDeviceInitSetFileObjectConfig(pDeviceInit, &file_cfg, WDF_NO_OBJECT_ATTRIBUTES);
  WdfDeviceCreate(&pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
  WdfDeviceCreateSymbolicLink(device, &szSymName);
  
  WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(&ioqueue_cfg, WdfIoQueueDispatchSequential);
  ioqueue_cfg.EvtIoRead = IrpRead;
  ioqueue_cfg.EvtIoWrite = IrpWrite;
  return WdfIoQueueCreate(device, &ioqueue_cfg, WDF_NO_OBJECT_ATTRIBUTES, WDF_NO_HANDLE);
}

NTSTATUS DriverEntry(PDRIVER_OBJECT pOurDriver, PUNICODE_STRING pRegistry)
{
  WDF_DRIVER_CONFIG config;

  WDF_DRIVER_CONFIG_INIT(&config, AddDevice);
  return WdfDriverCreate(pOurDriver, pRegistry, WDF_NO_OBJECT_ATTRIBUTES, &config, WDF_NO_HANDLE);
}
