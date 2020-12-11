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
go run
```

You can also compile and run as executable file.
```
cd $PROJECT_HOME/backend
go build -buildmode=exe
./backend 
```

Run frontend
---

```
cd $PROJECT_HOME
flutter run -d macos
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

References
===

Go package layout: https://medium.com/@benbjohnson/standard-package-layout-7cdbc8391fc1#.ds38va3pp

Testing HTTP Server in Go: https://blog.questionable.services/article/testing-http-handlers-go/

Flutter MethodChannel: https://stablekernel.com/article/flutter-platform-channels-quick-start/

