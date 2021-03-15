# Storyboard

`Storyboard` try to create universe application for both desktop and mobile devices.
Which can backup the data from multiple devices into one server which is desktop.

`'Storyboard` use `Go` build backend and use `Flutter` as front-end.

# Setup:

This project requires `go` and `flutter` to run. 

Check [Install Flutter](https://flutter.dev/docs/get-started/install/macos) official document to setup `Flutter`.

Check [Install GoLang](https://golang.org/doc/install) to install `Go`.

Also need to remember to add `go` and `flutter` in PATH:

```
export PATH=$HOME/Flutter/flutter/bin:/usr/local/go/bin:$HOME/go/bin:$PATH
export CGO_ENABLED=1
```

# Development

Check [Backend](./BACKEND.md) for develop backend with GoLang.

Develop for MacOS or Windows, following the instruction from [Desktop Dev](./DESKTOP.md).

Develop for iOS or Android, following the instruction from [Mobile Dev](./MOBILE.md).

# Test

Since backend was writtend by `Go` and frontend is written by `Flutter/Dart`.  The whole project can only be tested separately for now. 

Check the [Backend](./BACKEND.md) for testing backend server. 

For testing front-end app which is written with `Flutter/Dart` use:

```
flutter test [file]
```

## Test coverage

`lcov` is required for generate testing coverage report in Flutter. Check [Link](https://stackoverflow.com/questions/50789578/how-can-the-code-coverage-data-from-flutter-tests-be-displayed) for details.

Briefly, just run following command to instlall it on mac:

```
brew install lcov
```

So we can run following commands to generate coverage report on cmmand line:

```
flutter test --coverage
/usr/local/bin/genhtml coverage/lcov.info -o coverage/html
```

# Deployment

## iOS and Android

Check `Deployment` section in [MOBILE](./MOBILE.md).

## MacOS

Done on anothe project: storyboard_deploy_mgmt

## Windows

Not implemented.