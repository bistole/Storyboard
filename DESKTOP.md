# Setup

Backend service is required before run macos or windows version `Storyboard`.

Right now, desktop support for Flutter is in static channel with beta snapshot. Check details from [Desktop support for Flutter](https://flutter.dev/desktop).


# MacOS

Compile backend into static library before run macOS app.  Check the document from [Backend Macos](./backend/MACOS.md)

Enable MacOS desktop development by following command line:

```
cd $PROJECT_HOME
flutter config --enable-macos-desktop
```

Run app with command line:

```
cd $PROJECT_HOME
flutter run -d macos
```

## Deployment

Check `Storyboard_deploy_mgmt/README.md` for detail. It is not public yet.

# Windows

Compile backend into dynamic library (DLL) before run Windows app.  Check the document from [Backend Windows](./backend/WINDOWS.md)

Enable MacOS desktop development by following command line:

```
cd $PROJECT_HOME
flutter config --enable-windows-desktop
```

Run app with command line:

```
cd $PROJECT_HOME
flutter run -d windows
```

## Deployment

Unimplemented.