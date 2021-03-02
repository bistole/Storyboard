# Storyboard

`Storyboard` try to create universe application for both desktop and mobile devices.
Which can backup the data from multiple devices into one server which is desktop.

`'Storyboard` use `Go` build backend and use `Flutter` as front-end.

Setup
===

This project requires `go` and `flutter` to run. 


Setup the environment variables, make sure

```
export PATH=$HOME/Flutter/flutter/bin:/usr/local/go/bin:$HOME/go/bin:$PATH
export CGO_ENABLED=1
```

Run backend service
----

```
cd $PROJECT_HOME/backend
go run .
```

You can also compile and run as executable file.
```
cd $PROJECT_HOME/backend
go build -buildmode=exe
./backend 
```

Run frontend - macOS
---

```
cd $PROJECT_HOME
flutter run -d macos
```

Run frontend - Windows
---

Should follow the [Instruction](https://flutter.dev/docs/get-started/install/windows`)

In order to build backend, also need to install [TDM64-GCC](https://jmeubank.github.io/tdm-gcc/download/)


```
cd $PROJECT_HOME
flutter run -d windows
```

Run frontend - emulator - android
---

Solve android licenses:
```
flutter doctor --android-licenses
```

First need to fix android command line issue for java9 and above:

```
export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_AVD_HOME=$HOME/.android/avd
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$PATH
````

Display the available avd and start it
```
emulator -list-avds
emulator @devicename

```

Check the devices is connected and run app on this device.
```
flutter devices
flutter run -d "devicename"
```

Run frontend - emulator - ios
---

```
open -a Simulator
flutter devices
flutter run -d "device name"
```


Test
===

Since backend was writtend by `Go` and frontend is written by `Flutter/Dart`.  The whole project can only be tested separately for now. 

Frontend
---

Test a single file:

```
flutter test [file]
```

`lcov` is required for generate testing coverage report in Flutter. Check [Link](https://stackoverflow.com/questions/50789578/how-can-the-code-coverage-data-from-flutter-tests-be-displayed) for details.

```
flutter test --coverage
/usr/local/bin/genhtml coverage/lcov.info -o coverage/html
```

Backend
---

Test a single file:

```
cd $PROJECT_HOME/backend
go test [file]
```

The file should start with `./` such as `./database/database_test.go`.

In order to generate testing coverage report for frontend, run the following script:

```
cd $PROJECT_HOME/backend
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

Deploy
====

Change the version in pubspec.yaml

Android
----

Upload to internal
> cd $PROJECT_HOME/android
> flutter build apk
> fastlane android internal

Promote to alpha
> SUPPLY_VERSION_CODE=5 fastlane android alpha

Misc
===

Build backend as static library
---
```
cd $PROJECT_HOME/backend
go build -buildmode=c-archive

cd $PROJECT_HOME/c
gcc -I. main.c ../backend/backend.a -v
```

Programming windows version on mac
----

Install vcpkg - 
https://docs.microsoft.com/en-us/cpp/build/install-vcpkg

Integrate with vc - 
./vcpkg integrate install

References
===

Go package layout: https://medium.com/@benbjohnson/standard-package-layout-7cdbc8391fc1#.ds38va3pp

Testing HTTP Server in Go: https://blog.questionable.services/article/testing-http-handlers-go/

Flutter MethodChannel: https://stablekernel.com/article/flutter-platform-channels-quick-start/