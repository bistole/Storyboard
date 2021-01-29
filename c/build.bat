cd ../backend

echo build backend lib...
go build -o libBackend.dll -buildmode=c-shared

echo change header file...
powershell -Command "(gc libBackend.h) -replace '__SIZE_TYPE__', 'size_t' | %%{$_ -replace 'typedef (.*) _Complex ', '//typedef $1 _Complex '} | out-file libBackend.h.mvc"

echo copy file...
copy libBackend.dll ..\c
copy libBackend.h.mvc ..\c\libBackend.h

echo cleanup...
del libBackend.dll libBackend.h libBackend.h.mvc

cd ../c
echo config compiling environment...
set VSPATH="\Program Files (x86)\Microsoft Visual Studio\2019\Community"
%VSPATH%\vc\Auxiliary\Build\vcvars64.bat

echo create libBackend.def from dll...
echo may take a while...
@echo off
dumpbin /exports libBackend.dll > libBackend.log
echo LIBRARY LIBBACKEND > libBackend.def
echo EXPORTS >> libBackend.def
for /f "skip=19 tokens=4" %A in (libBackend.log) do echo %A >> libBackend.def
@echo on

echo create libBackend.lib from def...
lib /def:libBackend.def /out:libBackend.lib /machine:x64

echo compile main.exe...
cl /MD main.cpp libBackend.lib legacy_stdio_definitions.lib

echo cleanup...
del libBackend.log libBackend.def libBackend.exp libBackend.lib main.obj
