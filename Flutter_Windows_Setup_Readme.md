# 🚀 Flutter Development Environment Setup on Windows (Without Android Studio)

This guide walks you through setting up Flutter manually on Windows without Android Studio. You will install and configure Flutter, Java (OpenJDK), Git, Android SDK (with command-line tools only), and VS Code.

---

## 📁 Folder Structure

```
D:\hhh\FlutterDev\
├── flutter_windows_3.32.5-stable\flutter
├── Android\
│   └── Sdk\
│       ├── build-tools\
│       ├── platform-tools\
│       ├── platforms\
│       └── cmdline-tools\latest\bin
```

---

## 1️⃣ Install Prerequisites

### Git
- Download: https://git-scm.com/download/win
- Ensure it’s added to the system PATH during installation.

### OpenJDK (Microsoft Build)
- Download: https://learn.microsoft.com/en-us/java/openjdk/downloads
- Extract and set environment variables:

```env
JAVA_HOME = C:\Program Files\Microsoft\jdk-21.0.7.6-hotspot
PATH += C:\Program Files\Microsoft\jdk-21.0.7.6-hotspot\bin
```

### Visual Studio Code
- Download: https://code.visualstudio.com/
- Install Extensions:
  - Dart
  - Flutter

---

## 2️⃣ Install Flutter SDK

- Download Flutter SDK (stable): https://flutter.dev/docs/get-started/install/windows
- Extract to: `D:\hhh\FlutterDev\flutter_windows_3.32.5-stable\flutter`
- Add to PATH:

```env
PATH += D:\hhh\FlutterDev\flutter_windows_3.32.5-stable\flutter\bin
```

---

## 3️⃣ Install Android SDK Command Line Tools

### Download and Extract
- From: https://developer.android.com/studio#command-line-tools-only
- Extract into: `D:\hhh\FlutterDev\cmdline-tools`

### Run `sdkmanager`

Open CMD in:
```
D:\hhh\FlutterDev\cmdline-tools\bin
```

Run:
```sh
sdkmanager --sdk_root=D:\hhh\FlutterDev\Android\Sdk "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

This will auto-create the required Android SDK folders.

### Move and Rename Tools

Move the folder into the SDK and rename it:

```
D:\hhh\FlutterDev\Android\Sdk\cmdline-tools\latest\bin
```

Make sure this file exists:
```
D:\hhh\FlutterDev\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
```

---

## 4️⃣ Environment Variables

Set the following:

### Variables

| Variable      | Value                                                      |
|---------------|------------------------------------------------------------|
| `ANDROID_HOME`| `D:\hhh\FlutterDev\Android\Sdk`                         |
| `JAVA_HOME`   | `C:\Program Files\Microsoft\jdk-21.0.7.6-hotspot`        |

### PATH Additions

Append to system PATH:

```
D:\hhh\FlutterDev\flutter_windows_3.32.5-stable\flutter\bin
C:\Program Files\Microsoft\jdk-21.0.7.6-hotspot\bin
D:\hhh\FlutterDev\Android\Sdk\cmdline-tools\latest\bin
D:\hhh\FlutterDev\Android\Sdk\platform-tools
```

---

## 5️⃣ Accept Android Licenses

Run:

```sh
flutter doctor --android-licenses
```

Accept all licenses by typing `y` when prompted.

---

## 6️⃣ Verify Installation

Run:

```sh
flutter doctor -v
```

Ensure you see all ✅ checkmarks except for Visual Studio (unless you want Windows desktop support).

---

## 7️⃣ Create and Run a Flutter App

```sh
flutter create my_app
cd my_app
flutter run
```

For Chrome:
```sh
flutter run -d chrome
```

---

✅ **Your environment is now ready for Flutter development without Android Studio!**