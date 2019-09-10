del /s /q app.exe
c:\masm32\bin\ml /c /coff /Cp /Zi /Zd "app.asm"
c:\masm32\bin\link /SUBSYSTEM:CONSOLE /VERSION:4.0 /OUT:"app.exe" "app.obj"
del /s /q app.ilk
del /s /q app.obj