#!/bin/bash

# VedantaTrade - iOS Wireless Debugging Setup Script
# This script enables wireless debugging for iOS devices

set -e

echo "=========================================="
echo "VedantaTrade - iOS Wireless Debugging"
echo "=========================================="
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ Error: iOS wireless debugging requires macOS"
    echo "This script must be run on a Mac with Xcode installed"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcrun &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "Please install Xcode from the App Store"
    exit 1
fi

echo "✓ Xcode found"
echo ""

# Check if any iOS device is connected
echo "📱 Checking for iOS devices..."
DEVICES=$(xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad" | grep -v "Simulator" | head -5)

if [ -z "$DEVICES" ]; then
    echo "❌ No iOS devices found"
    echo "Please connect your iOS device via USB with trust enabled"
    echo ""
    echo "Steps to enable iOS debugging:"
    echo "1. Connect your iOS device to your Mac via USB"
    echo "2. Trust this computer on your iOS device"
    echo "3. Open Xcode > Window > Devices and Simulators"
    echo "4. Select your device and enable 'Connect via network'"
    exit 1
fi

echo "✓ iOS devices found"
echo ""
echo "$DEVICES"
echo ""

echo "=========================================="
echo "iOS Wireless Debugging Setup Instructions"
echo "=========================================="
echo ""
echo "iOS wireless debugging requires manual setup via Xcode:"
echo ""
echo "1. Connect your iOS device to your Mac via USB"
echo "2. Open Xcode"
echo "3. Go to Window > Devices and Simulators (⇧⌘2)"
echo "4. Select your iOS device from the list"
echo "5. Check the box 'Connect via network'"
echo "6. Your device will now be available for wireless debugging"
echo ""
echo "After setup, you can:"
echo "- Run flutter devices to see your device"
echo "- Run flutter run -d <device-id> to deploy wirelessly"
echo ""
echo "To verify wireless connection:"
echo "  xcrun xctrace list devices"
echo ""
echo "Note: Both your Mac and iOS device must be on the same Wi-Fi network"
echo ""

echo "=========================================="
echo "✓ iOS wireless debugging instructions provided"
echo "=========================================="
