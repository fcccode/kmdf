#include <ntddk.h>
#include <wdf.h>

#define DEV_NAME L"\\Device\\MyDriver"
#define SYM_NAME L"\\DosDevices\\MyDriver"

#define IOCTL_SET CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_NEITHER, FILE_ANY_ACCESS)
#define IOCTL_GET CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_NEITHER, FILE_ANY_ACCESS)

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

void IrpIOCTL(WDFQUEUE Queue, WDFREQUEST Request, size_t OutputBufferLength, size_t InputBufferLength, ULONG IoControlCode)
{
  ULONG len;
  UCHAR *buf;
  WDFMEMORY memory;
  
  switch(IoControlCode){
  case IOCTL_SET:
    DbgPrint("IOCTL_SET");
    WdfRequestRetrieveUnsafeUserInputBuffer(Request, InputBufferLength, &buf, &len);
    WdfRequestProbeAndLockUserBufferForRead(Request, buf, len, &memory);
    buf = WdfMemoryGetBuffer(memory, NULL);
    memcpy(szBuffer, buf, InputBufferLength);
    DbgPrint("Buffer: %s, Length:%d", szBuffer, InputBufferLength);
    WdfRequestSetInformation(Request, InputBufferLength);
    break;
  case IOCTL_GET:
    DbgPrint("IOCTL_GET");
    WdfRequestRetrieveUnsafeUserOutputBuffer(Request, OutputBufferLength, &buf, &len);
    WdfRequestProbeAndLockUserBufferForWrite(Request, buf, len, &memory);
    buf = WdfMemoryGetBuffer(memory, NULL);
    memcpy(buf, szBuffer, OutputBufferLength);
    len = strlen(szBuffer) + 1;
    WdfRequestSetInformation(Request, len);
    break;
  }
  WdfRequestComplete(Request, STATUS_SUCCESS);
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
  
  WdfDeviceInitSetIoType(pDeviceInit, WdfDeviceIoBuffered);
  WDF_FILEOBJECT_CONFIG_INIT(&file_cfg, IrpFileCreate, IrpFileClose, NULL);
  WdfDeviceInitSetFileObjectConfig(pDeviceInit, &file_cfg, WDF_NO_OBJECT_ATTRIBUTES);
  WdfDeviceCreate(&pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, &device);
  WdfDeviceCreateSymbolicLink(device, &szSymName);
  
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
