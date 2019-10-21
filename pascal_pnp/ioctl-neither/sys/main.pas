unit main;

interface
  uses
    DDDK;
    
  const
    DEV_NAME = '\Device\MyDriver';
    SYM_NAME = '\DosDevices\MyDriver';
    IOCTL_SET = (FILE_DEVICE_UNKNOWN shl 16) or (FILE_ANY_ACCESS shl 14) or ($800 shl 2) or (METHOD_NEITHER);
    IOCTL_GET = (FILE_DEVICE_UNKNOWN shl 16) or (FILE_ANY_ACCESS shl 14) or ($801 shl 2) or (METHOD_NEITHER);

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

procedure IrpIOCTL(Queue:WDFQUEUE; Request:WDFREQUEST; OutputBufferLength:ULONG; InputBufferLength:ULONG; IoControlCode:ULONG); stdcall;
var
  len: ULONG;
  buf: Pointer;
  memory: WDFMEMORY;

begin
  if IoControlCode = IOCTL_SET then begin
    DbgPrint('IOCTL_SET', []);
    WdfRequestRetrieveUnsafeUserInputBuffer(Request, InputBufferLength, @buf, @len);
    WdfRequestProbeAndLockUserBufferForRead(Request, buf, len, @memory);
    buf:= WdfMemoryGetBuffer(memory, Nil);
    memcpy(@szBuffer, buf, InputBufferLength);
    DbgPrint('Buffer: %s, Length:%d', [@szBuffer, InputBufferLength]);
    WdfRequestSetInformation(Request, InputBufferLength);
  end
  else if IoControlCode = IOCTL_GET then begin
    DbgPrint('IOCTL_GET', []);
    WdfRequestRetrieveUnsafeUserOutputBuffer(Request, OutputBufferLength, @buf, @len);
    WdfRequestProbeAndLockUserBufferForWrite(Request, buf, len, @memory);
    buf:= WdfMemoryGetBuffer(memory, Nil);
    memcpy(buf, @szBuffer, OutputBufferLength);
    len:= strlen(@szBuffer) + 1;
    WdfRequestSetInformation(Request, len);
  end;
  WdfRequestComplete(Request, STATUS_SUCCESS);
end;

function AddDevice(pOurDriver:WDFDRIVER; pDeviceInit:PWDFDEVICE_INIT):NTSTATUS; stdcall;
var
  device: WDFDEVICE;
  suDevName: UNICODE_STRING;
  szSymName: UNICODE_STRING;
  file_cfg: WDF_FILEOBJECT_CONFIG;
  ioqueue_cfg: WDF_IO_QUEUE_CONFIG;

begin
  WdfDeviceInitSetIoType(pDeviceInit, WdfDeviceIoBuffered);
  WDF_FILEOBJECT_CONFIG_INIT(@file_cfg, @IrpFileCreate, @IrpFileClose, Nil);
  WdfDeviceInitSetFileObjectConfig(pDeviceInit, @file_cfg, WDF_NO_OBJECT_ATTRIBUTES);
  
  RtlInitUnicodeString(@suDevName, DEV_NAME);
  RtlInitUnicodeString(@szSymName, SYM_NAME);
  WdfDeviceInitAssignName(pDeviceInit, @suDevName);
  WdfDeviceCreate(@pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, @device);
  WdfDeviceCreateSymbolicLink(device, @szSymName);
  
  WDF_IO_QUEUE_CONFIG_INIT_DEFAULT_QUEUE(@ioqueue_cfg, WdfIoQueueDispatchSequential);
  ioqueue_cfg.EvtIoDeviceControl:= @IrpIOCTL;
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
