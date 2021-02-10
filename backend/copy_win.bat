@echo off
echo copy files to windows folder...
mkdir ..\windows\backend
mkdir ..\windows\runner\backend
copy libBackend.dll ..\windows\backend
copy libBackend.lib ..\windows\runner\backend
copy libBackend_msvc.h ..\windows\runner\backend\libBackend.h
