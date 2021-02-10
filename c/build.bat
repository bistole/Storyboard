echo Copy files to folder c
copy ../backend/libBackend.dll libBackend.dll
copy ../backend/libBackend.lib libBackend.lib
copy ../backend/libBackend_msvc.h libBackend.h

echo Compile main.exe...
cl /MD main.cpp libBackend.lib legacy_stdio_definitions.lib

echo Clean up...
del main.obj
