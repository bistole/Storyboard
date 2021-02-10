@echo off
echo Build libBackend.dll file...
set CGO_ENABLED=1
set GOOS=windows
set GOARCH=amd64
go build -o libBackend.dll -buildmode=c-shared

echo Change header file...
powershell -Command "(gc libBackend.h) -replace '__SIZE_TYPE__', 'size_t' | %%{$_ -replace 'typedef (.*) _Complex ', '//typedef $1 _Complex '} | out-file libBackend_msvc.h"

echo Very Slow...Create libBackend.def...
dumpbin /exports libBackend.dll > libBackend.log
echo LIBRARY LIBBACKEND > libBackend.def
echo EXPORTS >> libBackend.def
for /f "skip=19 tokens=4" %%A in (libBackend.log) do echo %%A >> libBackend.def

echo Create libBackend.lib...
lib /def:libBackend.def /out:libBackend.lib /machine:x64