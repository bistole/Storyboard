# Setup

This project requires `go` and `flutter` to run. 

Setup the environment variables, make sure `go` and `flutter` in PATH

```
export PATH=$HOME/Flutter/flutter/bin:/usr/local/go/bin:$HOME/go/bin:$PATH
export CGO_ENABLED=1
```

# Backend Development

Backend service is written by GoLang, the codebase is located at $PROJECT_HOME/backend

## Run backend service in command line

Easy way to run the backend service directly:

```
cd $PROJECT_HOME/backend
go run .
```

## Build and execute as executable file

You can also compile and run as executable file.

```
cd $PROJECT_HOME/backend
go build -buildmode=exe
./backend 
```

## Test

Run test for single file with following command line:

```
cd $PROJECT_HOME/backend
go test [file]
```

The file should start with `./` such as `./database/database_test.go`.

Run the following script to generate test coverage report:

```
cd $PROJECT_HOME/backend
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## Build for MacOS and Windows

MacOS version app requires backend static library before compile. Check [Backend MACOS.md](./backend/MACOS.md) for details. 

Windows version app requries backend dll before compile. Check [Backend WINDOWS.md](./backend/WINDOWS.md) for details.

## Misc: Build as static library

There is a way to test backend as a library before embed into MacOS or windows app.

```
cd $PROJECT_HOME/backend
go build -buildmode=c-archive

cd $PROJECT_HOME/c
gcc -I. main.c ../backend/backend.a -v
```

## References

Go package layout: https://medium.com/@benbjohnson/standard-package-layout-7cdbc8391fc1#.ds38va3pp

Testing HTTP Server in Go: https://blog.questionable.services/article/testing-http-handlers-go/