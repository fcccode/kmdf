unit main;

interface
  uses
    DDDK;
    
  const
    DEV_NAME = '\Device\MyDriver';
    SYM_NAME = '\DosDevices\MyDriver';

  function __DriverEntry(pOurDriver:PDRIVER_OBJECT; pOurRegistry:PUNICODE_STRING):NTSTATUS; stdcall;

implementation
var
  szBuffer: array[0..255] of char;
  
procedure IrpFileCreate(Device:WDFDEVICE; Request:WDFREQUEST; FileObject:WDFFILEOBJECT); stdcall;
begin
  DbgPrint('IrpFileCreate', []);
  WdfRequestComplete(Request, STATUS_SUCCESS);
end;

procedure IrpFileClose(FileObject:WDFFILEOBJECT); stdcall;
begin
  DbgPrint('IrpFileClose', []);
end;

procedure IrpRead(Queue:WDFQUEUE; Request:WDFREQUEST; Length:ULONG); stdcall;
var
  mdl: PMDL;
  len: ULONG;
  dst: Pointer;

begin
  DbgPrint('IrpRead', []);
  len:= strlen(@szBuffer) + 1;
  WdfRequestRetrieveOutputWdmMdl(Request, @mdl);
  dst:= MmGetMdlVirtualAddress(mdl);
  memcpy(dst, @szBuffer, len);
  WdfRequestCompleteWithInformation(Request, STATUS_SUCCESS, len);
end;

procedure IrpWrite(Queue:WDFQUEUE; Request:WDFREQUEST; Length:ULONG); stdcall;
var
  mdl: PMDL;
  src: Pointer;

begin
  DbgPrint('IrpWrite', []);
  WdfRequestRetrieveInputWdmMdl(Request, @mdl);
  src:= MmGetMdlVirtualAddress(mdl);
  memcpy(@szBuffer, src, Length);
  DbgPrint('Buffer: %s, Length:%d', [szBuffer, Length]);
  WdfRequestCompleteWithInformation(Request, STATUS_SUCCESS, Length);
end;

function AddDevice(pOurDriver:WDFDRIVER; pDeviceInit:PWDFDEVICE_INIT):NTSTATUS; stdcall;
var
  device: WDFDEVICE;
  suDevName: UNICODE_STRING;
  szSymName: UNICODE_STRING;
  file_cfg: WDF_FILEOBJECT_CONFIG;
  ioqueue_cfg: WDF_IO_QUEUE_CONFIG;

begin
  WdfDeviceInitSetIoType(pDeviceInit, WdfDeviceIoDirect);
  WDF_FILEOBJECT_CONFIG_INIT(@file_cfg, @IrpFileCreate, @IrpFileClose, Nil);
  WdfDeviceInitSetFileObjectConfig(pDeviceInit, @file_cfg, WDF_NO_OBJECT_ATTRIBUTES);
  
  RtlInitUnicodeString(@suDevName, DEV_NAME);
  RtlInitUnicodeString(@szSymName, SYM_NAME);
  WdfDeviceInitAssignName(pDeviceInit, @suDevName);
  WdfDeviceCreate(@pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, @device);
  WdfDeviceCreateSymbolicLink(device, @szSymName);
  
  WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(@ioqueue_cfg, WdfIoQueueDispatchSequential);
  ioqueue_cfg.EvtIoRead:= @IrpRead;
  ioqueue_cfg.EvtIoWrite:= @IrpWrite;
  Result:= WdfIoQueueCreate(device, @ioqueue_cfg, WDF_NO_OBJECT_ATTRIBUTES, WDF_NO_HANDLE);
end;

function __DriverEntry(pOurDriver:PDRIVER_OBJECT; pOurRegistry:PUNICODE_STRING):NTSTATUS; stdcall;
var
  config: WDF_DRIVER_CONFIG;
  
begin
  WDF_DRIVER_CONFIG_INIT(@config, AddDevice);
  WdfDriverCreate(pOurDriver, pOurRegistry, WDF_NO_OBJECT_ATTRIBUTES, @config, WDF_NO_HANDLE);
  Result:= STATUS_SUCCESS;
end;
end.
