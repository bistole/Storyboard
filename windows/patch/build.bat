set VSPATH="\Program Files (x86)\Microsoft Visual Studio\2019\Community"
%VSPATH%\vc\Auxiliary\Build\vcvars64.bat
cl.exe /Wall /c patch.c
lib.exe /out:patch.lib patch.obj
lib.exe /export:__iob_func /export:fprintf /def patch.obj