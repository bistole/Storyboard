@echo off
echo Setup MVSC command line environment
set VSPATH="\Program Files (x86)\Microsoft Visual Studio\2019\Community"
%VSPATH%\vc\Auxiliary\Build\vcvars64.bat
