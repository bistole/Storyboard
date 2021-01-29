This introduction helps you compile backend into windows DLL file and link it with Storyboard Windows version.

Install requirement:
---

1. Install [Go](https://golang.org/doc/install)

    Default instlall path is: `C:\GO`

2. Install [TDM-GCC-64](https://jmeubank.github.io/tdm-gcc/)

    Propbably we can use other compiler such as MinGW to compile go project into DLL file.

    Default install path is: `C:\TDM-GCC-64`

3. Install [Visual Studio 2019 Community](https://visualstudio.microsoft.com/vs/community/)

    Default install path is: `C:\Program Files (x86)\Microsoft Visual Studio\2019\Community`

Setup environment:
---

Append installed software path to environment variable `PATH` (Maybe already set by installing software)

- `C:\go\bin`
- `C:\TDM-GCC-64\bin`

Build & Copy Backend
---

Run `init_win.bat` to setup command line environment. The command maybe different between different version of `Microsoft Visual Studio`

Run `build_win.bat` to create `libBackend.dll`, `libBackend.lib`, `libBackend_msvc.h` which are required by flutter windows version.

Run `copy_win.bat` to copy required files to `%PROJECT_HOME%/windows`.

Run
---

Go to PROEJCT_HOME and run:
> flutter run -d windows

