#include <ntddk.h>
#include <wdf.h>

#define DEV_NAME L"\\Device\\MyDriver"
#define SYM_NAME L"\\DosDevices\\MyDriver"

#define IOCTL_START CTL_CODE(FILE_DEVICE_UNKNOWN, 0x800, METHOD_NEITHER, FILE_ANY_ACCESS)
#define IOCTL_STOP  CTL_CODE(FILE_DEVICE_UNKNOWN, 0x801, METHOD_NEITHER, FILE_ANY_ACCESS)

ULONG bExit=0;
HANDLE pThread;

VOID MyThread(PVOID pParam)
{
  LARGE_INTEGER tt;
 
  tt.HighPart|= -1;
  tt.LowPart = (ULONG)-10000000;
  while(bExit != TRUE){
    KeDelayExecutionThread(KernelMode, FALSE, &tt);
    DbgPrint("Sleep 1s");
  }
  DbgPrint("Exit MyThread");
  PsTerminateSystemThread(STATUS_SUCCESS);
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
  HANDLE hThread;
  NTSTATUS status;
  
  switch(IoControlCode){
  case IOCTL_START:
    DbgPrint("IOCTL_START");
    bExit = 0;
    status = PsCreateSystemThread(&hThread, THREAD_ALL_ACCESS, NULL, (HANDLE)-1, NULL, MyThread, NULL);
    if(NT_SUCCESS(status)){
      ObReferenceObjectByHandle(hThread, THREAD_ALL_ACCESS, NULL, KernelMode, &pThread, NULL);
      ZwClose(hThread);
    }
    break;
  case IOCTL_STOP:
    DbgPrint("IOCTL_STOP");
    bExit = 1;
    KeWaitForSingleObject(pThread, Executive, KernelMode, FALSE, NULL);
    ObDereferenceObject(pThread);
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
