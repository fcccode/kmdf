unit main;

interface
  uses
    DDDK;
    
  const
    DEV_NAME = '\Device\MyDriver';

  function __DriverEntry(pOurDriver:PDRIVER_OBJECT; pOurRegistry:PUNICODE_STRING):NTSTATUS; stdcall;

implementation

function AddDevice(pOurDriver:WDFDRIVER; pDeviceInit:PWDFDEVICE_INIT):NTSTATUS; stdcall;
var
  device: WDFDEVICE;
  suDevName: UNICODE_STRING;

begin
  DbgPrint('Hello, world!', []);
  RtlInitUnicodeString(@suDevName, DEV_NAME);
  WdfDeviceInitAssignName(pDeviceInit, @suDevName);
  WdfDeviceCreate(@pDeviceInit, WDF_NO_OBJECT_ATTRIBUTES, @device);
  Result:= STATUS_SUCCESS;
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
