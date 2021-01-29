@echo off

mkdir ..\windows\runner\backend
echo building...
set CGO_ENABLED=1
set GOOS=windows
set GOARCH=amd64
go build -o libBackend.dll -buildmode=c-shared
echo change header file...
powershell -Command "(gc libBackend.h) -replace '__SIZE_TYPE__', 'size_t' | %%{$_ -replace 'typedef (.*) _Complex ', '//typedef $1 _Complex '} | out-file libBackend.h.mvc"
echo copy file...
copy libBackend.dll ..\windows\runner\backend
copy libBackend.h.mvc ..\windows\runner\backend\libBackend.h
echo cleanup...
del libBackend.lib libBackend.h libBackend.h.mvc
