echo off
del /s /q main.sys
c:\masm32\bin\ml /c /coff /Cp "loader.asm"
echo on
c:\dddk\bin\dcc32.exe -Uc:\dddk\inc -B -CG -JP -$A-,C-,D-,G-,H-,I-,L-,P-,V-,W+,Y- main.pas
echo off
c:\dddk\bin\omf2d.exe main.obj
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEWdfFunctions=_WdfFunctions 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEWdfDriverGlobals=_WdfDriverGlobals 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEZwClose=_ZwClose@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEDbgPrint=_DbgPrint 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEExFreePool=_ExFreePool@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeSetTimer=_KeSetTimer@16 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoStopTimer=_IoStopTimer@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoCallDriver=_IoCallDriver@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoStartTimer=_IoStartTimer@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeSetTimerEx=_KeSetTimerEx@20 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEProbeForRead=_ProbeForRead@12 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CERtlZeroMemory=_RtlZeroMemory@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeCancelTimer=_KeCancelTimer@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoStartPacket=_IoStartPacket@16 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEZwOpenProcess=_ZwOpenProcess@16 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoDetachDevice=_IoDetachDevice@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoDeleteDevice=_IoDeleteDevice@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEExAllocatePool=_ExAllocatePool@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeReleaseMutex=_KeReleaseMutex@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoCsqInsertIrp=_IoCsqInsertIrp@12 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoCreateDevice=_IoCreateDevice@28 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeInitializeDpc=_KeInitializeDpc@12 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoCsqInitialize=_IoCsqInitialize@28 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoStartNextPacket=_IoStartNextPacket@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoCompleteRequest=_IoCompleteRequest@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeInitializeMutex=_KeInitializeMutex@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeInitializeTimer=_KeInitializeTimer@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeReleaseSpinLock=_KeReleaseSpinLock@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoInitializeTimer=_IoInitializeTimer@12 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEObDereferenceObject=_ObDereferenceObject@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoGetCurrentProcess=_IoGetCurrentProcess@0 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEInterlockedExchange=@InterlockedExchange@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeInitializeSpinLock=_KeInitializeSpinLock@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoCreateSymbolicLink=_IoCreateSymbolicLink@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoDeleteSymbolicLink=_IoDeleteSymbolicLink@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CERtlInitUnicodeString=_RtlInitUnicodeString@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEPsCreateSystemThread=_PsCreateSystemThread@28 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeWaitForSingleObject=_KeWaitForSingleObject@20 2>nul 
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEExAllocatePoolWithTag=_ExAllocatePoolWithTag@12 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeDelayExecutionThread=_KeDelayExecutionThread@12 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEKeServiceDescriptorTable=_KeServiceDescriptorTable 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEExAllocatePoolWithQuota=_ExAllocatePoolWithQuota@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEPsTerminateSystemThread=_PsTerminateSystemThread@4 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEObReferenceObjectByHandle=_ObReferenceObjectByHandle@24 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEIoAttachDeviceToDeviceStack=_IoAttachDeviceToDeviceStack@8 2>nul
c:\dddk\bin\omf2d.exe c:\dddk\inc\dddk.obj /U- /CEMmMapLockedPagesSpecifyCache=_MmMapLockedPagesSpecifyCache@24 2>nul
echo on
c:\dddk\bin\link.exe /entry:FxDriverEntry@8  /NOLOGO /ALIGN:64 /BASE:0x10000 /SUBSYSTEM:NATIVE /DRIVER /FORCE:UNRESOLVED /FORCE:MULTIPLE c:\dddk\inc\DDDK.obj c:\dddk\lib\ntoskrnl.lib c:\dddk\lib\wdf\kmdf\i386\1.9\wdfdriverentry.lib c:\dddk\lib\wdf\kmdf\i386\1.9\wdfldr.lib main.obj loader.obj /out:main.sys
echo off
del /s /q main.dcu
del /s /q main.obj