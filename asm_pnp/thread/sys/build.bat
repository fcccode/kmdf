del /s /q main.sys
c:\masm32\bin\ml /c /coff /Cp "main.asm"
c:\masm32\bin\link /entry:FxDriverEntry@8 /MAP /IGNORE:4078 /nologo /driver /base:0x10000 /subsystem:native /align:64 /out:"main.sys" main.obj"
del /s /q main.map
del /s /q main.obj