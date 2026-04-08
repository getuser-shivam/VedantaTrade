# Wireless Debugging Guide for VedantaTrade

This guide provides comprehensive instructions for setting up and using wireless debugging and deployment for the VedantaTrade Flutter application.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Android Wireless Debugging](#android-wireless-debugging)
- [iOS Wireless Debugging](#ios-wireless-debugging)
- [Wireless Deployment](#wireless-deployment)
- [Troubleshooting](#troubleshooting)
- [Scripts](#scripts)

---

## Overview

Wireless debugging allows you to develop and deploy the VedantaTrade app without USB cables. This setup enables:
- Faster development iterations
- Freedom to move devices during testing
- Simultaneous testing on multiple devices
- Remote debugging capabilities

---

## Prerequisites

### General Requirements
- Flutter SDK installed (>=3.0.0)
- VedantaTrade project cloned
- Development machine and devices on same Wi-Fi network

### Android Requirements
- Android device with Android 10 (API 29) or higher recommended
- USB debugging enabled in Developer Options
- ADB (Android Debug Bridge) installed
- Android SDK Platform Tools

### iOS Requirements
- Mac computer with Xcode installed
- iOS device with iOS 13 or higher
- Developer account (for iOS deployment)
- Both Mac and iOS device on same Wi-Fi network

---

## Android Wireless Debugging

### Method 1: Using the Setup Script (Recommended)

The project includes an automated script for setting up Android wireless debugging:

```bash
# Navigate to project directory
cd i:\Path\Projects\VedantaTrade

# Run the Android wireless debug setup script
bash scripts/wireless_debug_android.sh
```

### Method 2: Manual Setup

#### Step 1: Enable USB Debugging
1. Go to Settings > About Phone
2. Tap "Build Number" 7 times to enable Developer Options
3. Go to Settings > Developer Options
4. Enable "USB Debugging"

#### Step 2: Connect via USB
1. Connect your Android device to your computer via USB
2. Accept the debugging prompt on your device
3. Verify connection: `adb devices`

#### Step 3: Enable Wireless Debugging

**For Android 11+ (API 30+):**
```bash
# Enable wireless debugging on device
adb shell settings put global adb_wifi_enabled 1

# Get device IP address
adb shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1

# Enable TCP/IP mode
adb tcpip 5555

# Connect wirelessly
adb connect <device-ip>:5555
```

**For Android 10 and below (API 29 and below):**
```bash
# Enable TCP/IP mode
adb tcpip 5555

# Get device IP address
adb shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1

# Disconnect USB
adb disconnect

# Connect wirelessly
adb connect <device-ip>:5555
```

#### Step 4: Verify Wireless Connection
```bash
adb devices
```

You should see your device listed with its IP address.

### Step 5: Deploy Wirelessly
```bash
# Run the app wirelessly
flutter run -d <device-ip>:5555

# Or use the wireless deployment script
bash scripts/wireless_deploy.sh --android
```

### Disable Wireless Debugging
```bash
# Disconnect from device
adb disconnect <device-ip>:5555

# Disable wireless debugging on device
adb shell settings put global adb_wifi_enabled 0
```

---

## iOS Wireless Debugging

iOS wireless debugging requires Xcode and is set up through the Xcode interface.

### Setup Instructions

#### Step 1: Connect via USB
1. Connect your iOS device to your Mac via USB
2. Trust this computer on your iOS device when prompted

#### Step 2: Enable Wireless Debugging in Xcode
1. Open Xcode on your Mac
2. Go to **Window > Devices and Simulators** (or press `⇧⌘2`)
3. Select your iOS device from the list
4. Check the box **"Connect via network"**
5. Your device will now be available for wireless debugging

#### Step 3: Verify Connection
```bash
# List available devices
flutter devices

# Or use Xcode
xcrun xctrace list devices
```

#### Step 4: Deploy Wirelessly
```bash
# Run the app wirelessly
flutter run -d <device-id>

# Or use the wireless deployment script
bash scripts/wireless_deploy.sh --ios
```

### Important Notes
- Both your Mac and iOS device must be on the same Wi-Fi network
- Wireless debugging may be slower than USB connection
- Some features may still require USB connection for initial setup

---

## Wireless Deployment

### Using the Deployment Script

The project includes a comprehensive wireless deployment script:

```bash
# Deploy to all devices (debug build)
bash scripts/wireless_deploy.sh

# Deploy to Android only
bash scripts/wireless_deploy.sh --android

# Deploy to iOS only
bash scripts/wireless_deploy.sh --ios

# Deploy release build
bash scripts/wireless_deploy.sh --android --release

# Deploy to specific device
bash scripts/wireless_deploy.sh --device <device-id>

# Show help
bash scripts/wireless_deploy.sh --help
```

### Manual Deployment

#### Android
```bash
# Debug build
flutter run -d <device-ip>:5555

# Profile build
flutter run --profile -d <device-ip>:5555

# Release build
flutter run --release -d <device-ip>:5555
```

#### iOS
```bash
# Debug build
flutter run -d <device-id>

# Profile build
flutter run --profile -d <device-id>

# Release build
flutter run --release -d <device-id>
```

### Build Types

- **Debug**: Fast build with debugging enabled (default)
- **Profile**: Optimized build with some debugging
- **Release**: Fully optimized build for production

---

## Troubleshooting

### Android Issues

#### Device not found
```bash
# Restart ADB server
adb kill-server
adb start-server

# Check devices
adb devices
```

#### Connection refused
- Ensure device and computer are on same Wi-Fi network
- Check firewall settings on your computer
- Verify device IP address: `adb shell ip addr show wlan0`
- Try reconnecting: `adb connect <device-ip>:5555`

#### Wireless debugging not working
- Re-enable USB debugging and repeat setup
- Check Android version compatibility
- Ensure Developer Options are enabled
- Try different Wi-Fi network (avoid corporate networks with restrictions)

### iOS Issues

#### Device not visible in Xcode
- Ensure device is trusted on the computer
- Check that both devices are on same network
- Restart Xcode
- Reconnect via USB and re-enable wireless debugging

#### Deployment fails
- Ensure you have a valid developer certificate
- Check bundle identifier in iOS project settings
- Verify provisioning profiles are valid
- Clean build folder: `flutter clean`

#### Connection drops frequently
- Move closer to Wi-Fi router
- Use 5GHz Wi-Fi band if available
- Restart both Mac and iOS device
- Re-enable wireless debugging in Xcode

### General Issues

#### Flutter doesn't recognize device
```bash
# Check Flutter doctor
flutter doctor -v

# List all devices
flutter devices

# Clean Flutter cache
flutter clean
flutter pub get
```

#### Network issues
- Disable VPN temporarily
- Check router firewall settings
- Use private network (avoid public Wi-Fi)
- Ensure network allows local device communication

---

## Scripts

### Available Scripts

The project includes the following scripts for wireless debugging:

#### `scripts/wireless_debug_android.sh`
Automates Android wireless debugging setup.

**Usage:**
```bash
bash scripts/wireless_debug_android.sh
```

**Features:**
- Automatically detects connected devices
- Enables wireless debugging for Android 11+
- Provides manual setup instructions for older devices
- Displays device information (model, Android version)
- Shows connection commands

#### `scripts/wireless_debug_ios.sh`
Provides iOS wireless debugging instructions.

**Usage:**
```bash
bash scripts/wireless_debug_ios.sh
```

**Features:**
- Checks for Xcode installation
- Detects connected iOS devices
- Provides step-by-step setup instructions
- Lists available commands

#### `scripts/wireless_deploy.sh`
Deploys the app wirelessly to connected devices.

**Usage:**
```bash
bash scripts/wireless_deploy.sh [OPTIONS]
```

**Options:**
- `--android`: Deploy to Android devices only
- `--ios`: Deploy to iOS devices only
- `--release`: Build release version
- `--profile`: Build profile version
- `--device ID`: Deploy to specific device ID
- `--help`: Show help message

**Examples:**
```bash
# Deploy to all devices
bash scripts/wireless_deploy.sh

# Deploy release to Android
bash scripts/wireless_deploy.sh --android --release

# Deploy to specific device
bash scripts/wireless_deploy.sh --device emulator-5554
```

### Making Scripts Executable

On Linux/macOS, make the scripts executable:
```bash
chmod +x scripts/wireless_debug_android.sh
chmod +x scripts/wireless_debug_ios.sh
chmod +x scripts/wireless_deploy.sh
```

On Windows with Git Bash or WSL:
```bash
# The scripts should work directly with bash
bash scripts/wireless_debug_android.sh
```

---

## Best Practices

### Security
- Only use wireless debugging on trusted networks
- Disable wireless debugging when not in use
- Keep your development machine secure
- Use strong Wi-Fi passwords
- Avoid public Wi-Fi networks for debugging

### Performance
- Use debug builds for development
- Use profile builds for performance testing
- Use release builds for final testing
- Monitor network latency during wireless debugging
- Consider using USB for initial large builds

### Workflow
1. Set up wireless debugging at the start of development session
2. Use hot reload for rapid iterations
3. Test on multiple devices wirelessly
4. Disable wireless debugging when done
5. Keep scripts updated with project changes

---

## Additional Resources

- [Flutter Debugging Guide](https://flutter.dev/docs/development/tools/devtools/overview)
- [Android Wireless Debugging](https://developer.android.com/studio/command-line/adb#wireless)
- [iOS Wireless Debugging](https://developer.apple.com/documentation/xcode/connecting-a-wirelessly-enabled-ios-device-to-xcode)
- [ADB Documentation](https://developer.android.com/studio/command-line/adb)

---

## Support

For issues or questions:
- Check the [Troubleshooting](#troubleshooting) section
- Review Flutter documentation
- Check project issues on GitHub
- Contact development team

---

**Last Updated**: April 8, 2026
**Version**: 1.0.0
