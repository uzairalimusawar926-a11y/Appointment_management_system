# Odoo Appointment App - Complete Setup Guide

## Table of Contents
1. [System Requirements](#system-requirements)
2. [Flutter Environment Setup](#flutter-environment-setup)
3. [Project Setup](#project-setup)
4. [Odoo Backend Configuration](#odoo-backend-configuration)
5. [Running the App](#running-the-app)
6. [Deployment](#deployment)

## System Requirements

### Development Machine
- **Operating System**: Windows 10/11, macOS 10.14+, or Linux
- **RAM**: Minimum 8GB (16GB recommended)
- **Storage**: 10GB free space
- **Internet Connection**: Required for initial setup

### Software Requirements
- **Flutter SDK**: 3.0.0 or higher
- **Dart SDK**: 3.0.0 or higher (comes with Flutter)
- **Android Studio**: Latest version (for Android development)
- **Xcode**: 14.0+ (for iOS development, macOS only)
- **Git**: For version control

## Flutter Environment Setup

### 1. Install Flutter SDK

#### Windows
```powershell
# Download Flutter SDK from https://flutter.dev
# Extract to C:\flutter
# Add to PATH:
setx PATH "%PATH%;C:\flutter\bin"
```

#### macOS
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
cd flutter

# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell
source ~/.zshrc
```

#### Linux
```bash
# Download Flutter SDK
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
cd flutter

# Add to PATH (add to ~/.bashrc)
export PATH="$PATH:$HOME/development/flutter/bin"

# Reload shell
source ~/.bashrc
```

### 2. Verify Flutter Installation

```bash
flutter doctor
```

This command checks your environment and displays a report. Address any issues shown.

### 3. Install Android Studio

1. Download from https://developer.android.com/studio
2. Install with default settings
3. Open Android Studio
4. Go to **Tools → SDK Manager**
5. Install Android SDK Platform 29 or higher
6. Install Android SDK Build-Tools
7. Install Android Emulator

### 4. Install Xcode (macOS only)

```bash
# Install from App Store
xcode-select --install

# Accept license
sudo xcodebuild -license accept

# Install CocoaPods
sudo gem install cocoapods
```

### 5. Configure IDE

#### VS Code (Recommended)
1. Install VS Code: https://code.visualstudio.com
2. Install Flutter extension
3. Install Dart extension

#### Android Studio
1. Install Flutter plugin: **File → Settings → Plugins**
2. Install Dart plugin

## Project Setup

### 1. Get the Project

```bash
# If using Git
git clone <repository-url>
cd odoo_appointment_app

# OR if you have the zip file
unzip odoo_appointment_app.zip
cd odoo_appointment_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

This downloads all required packages from pubspec.yaml.

### 3. Project Structure Overview

```
odoo_appointment_app/
├── android/          # Android native code
├── ios/              # iOS native code
├── lib/              # Main Flutter code
│   ├── config/       # Configuration files
│   ├── models/       # Data models
│   ├── services/     # Business logic & API
│   ├── providers/    # State management
│   ├── screens/      # UI screens
│   └── main.dart     # App entry point
├── test/             # Unit & widget tests
├── pubspec.yaml      # Dependencies
└── README.md         # Documentation
```

### 4. Configuration

#### Update App Name (Optional)

Edit `pubspec.yaml`:
```yaml
name: your_app_name
description: Your app description
```

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="Your App Name"
    ...
</application>
```

Edit `ios/Runner/Info.plist`:
```xml
<key>CFBundleName</key>
<string>Your App Name</string>
```

## Odoo Backend Configuration

### 1. Ensure API Controller is Installed

The Odoo module must have the API controller file provided with this project. Place it in your Odoo module's `controllers/` directory.

### 2. Install Required Odoo Modules

```python
# In Odoo, install:
- base
- web
- website
- portal
- Your custom appointment module
```

### 3. Configure CORS (if needed)

If your Odoo server and app are on different domains:

Edit Odoo configuration file:
```ini
[options]
...
# Add CORS headers
dbfilter = ^your_database$
# Enable proxy mode if behind nginx/apache
proxy_mode = True
```

Or add CORS middleware in your Odoo module.

### 4. Test API Endpoints

Use Postman or curl to test:

```bash
# Test login
curl -X POST https://your-server.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "call",
    "params": {
      "login": "portal@example.com",
      "password": "password"
    },
    "id": 1
  }'
```

### 5. Create Test Portal User

In Odoo:
1. Go to **Settings → Users & Companies → Users**
2. Create new user
3. Set **User Type** to "Portal"
4. Set email and password
5. Save

## Running the App

### 1. Start an Emulator/Simulator

#### Android Emulator
```bash
# List available emulators
flutter emulators

# Start an emulator
flutter emulators --launch <emulator-id>
```

Or use Android Studio: **Tools → AVD Manager → Start emulator**

#### iOS Simulator (macOS only)
```bash
# Start default simulator
open -a Simulator
```

### 2. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run in debug mode (hot reload enabled)
flutter run --debug

# Run in release mode
flutter run --release

# Run on specific device
flutter run -d <device-id>
```

### 3. Hot Reload

While the app is running:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `q` to quit

### 4. First Launch Setup

When you first launch the app:

1. **Setup Screen appears**
2. Enter your Odoo server URL (e.g., `https://your-server.odoo.com`)
3. Click "Save & Continue"
4. You'll be redirected to Login screen
5. Either login or sign up
6. Start using the app!

## Deployment

### Android (APK/AAB)

#### 1. Configure App Signing

Create `android/key.properties`:
```properties
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=key
storeFile=<path-to-keystore>
```

Generate keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias key
```

#### 2. Update build.gradle

Edit `android/app/build.gradle` - add before `android` block:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

In `android` block:
```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        ...
    }
}
```

#### 3. Build Release

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

Output files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS (IPA)

#### 1. Configure Signing

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to **Signing & Capabilities**
4. Select your Team
5. Configure Bundle Identifier

#### 2. Build Archive

```bash
flutter build ios --release
```

#### 3. Create IPA

1. Open in Xcode
2. **Product → Archive**
3. Once archived: **Window → Organizer**
4. Select archive → **Distribute App**
5. Follow wizard to create IPA

## Troubleshooting

### Common Issues

#### 1. Flutter Doctor Shows Issues

```bash
# Android license issue
flutter doctor --android-licenses

# iOS setup issue
sudo gem install cocoapods
cd ios && pod install
```

#### 2. App Won't Build

```bash
# Clean build
flutter clean

# Get dependencies again
flutter pub get

# Rebuild
flutter run
```

#### 3. Network/API Issues

- Check Odoo server URL in app
- Verify API endpoints are accessible
- Check network connectivity
- Look at logs: `flutter logs`

#### 4. Hot Reload Not Working

- Press `R` for full restart
- Stop and restart app
- Check for syntax errors

### Debug Logs

```bash
# View all logs
flutter logs

# View specific device logs
flutter logs -d <device-id>

# Filter logs
flutter logs | grep "YourTag"
```

## Development Tips

### 1. Code Organization

- Keep screens in `lib/screens/`
- Keep models in `lib/models/`
- Keep business logic in `lib/services/`
- Use providers for state management

### 2. Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Generate coverage
flutter test --coverage
```

### 3. Performance

```bash
# Profile performance
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
```

### 4. Code Quality

```bash
# Run linter
flutter analyze

# Format code
flutter format .
```

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Odoo Documentation](https://www.odoo.com/documentation)

## Support

For issues:
1. Check this guide
2. Check README.md
3. Search existing issues
4. Create new issue with details

---

Happy Coding! 🚀
