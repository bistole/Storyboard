# Android

Check setup details on official document: 
https://flutter.dev/docs/get-started/install/macos#android-setup

## Setup

Need to setup command line environment for android development:

```
export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jre/jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
export ANDROID_AVD_HOME=$HOME/.android/avd
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$PATH
````

## Run in emulator

Display the available avd and start:
```
emulator -list-avds
emulator @devicename
```

Check the connected device list and run app on specific device.
```
flutter devices
flutter run -d "devicename"
```

## Deployment

Make sure change version in `pubspec.yaml`. Notice `buildnum` should always increase for each deployment in version format: `major.minor.bugfix+buildnum`.

### Upload to internal

Submit new deployment:

```
cd $PROJECT_HOME/android
flutter build apk
fastlane android internal
```

Promote app to alpha/beta/release lane:

```
SUPPLY_VERSION_CODE=xxx fastlane android alpha
```

SUPPLY_VERSION_CODE is the build number in pubspec.yaml


## Trouble shooting for Java9

Solve Android licenses issue:

```
flutter doctor --android-licenses
```

# iOS

Check setup details on official document: 
https://flutter.dev/docs/get-started/install/macos#ios-setup

## Run in simulator

Open a simulator:

```
open -a Simulator
```

Check the connected device list and run app on specific device.
```
flutter devices
flutter run -d "devicename"
```

## Deployment

Make sure change version in `pubspec.yaml`. Notice `buildnum` should always increase for each deployment in version format: `major.minor.bugfix+buildnum`.

Upload to TestFlight

```
cd $PROJECT_HOME/ios
flutter build ios --release --no-codesign
fastlane ios alpha
```

Upload dSYM to crashlytics

```
fastlane ios crash
```



