#!/bin/bash

# VedantaTrade - Android Wireless Debugging Setup Script
# This script enables wireless debugging for Android devices via ADB

set -e

echo "=========================================="
echo "VedantaTrade - Android Wireless Debugging"
echo "=========================================="
echo ""

# Check if ADB is available
if ! command -v adb &> /dev/null; then
    echo "❌ Error: ADB is not installed or not in PATH"
    echo "Please install Android SDK Platform Tools"
    exit 1
fi

echo "✓ ADB found"
echo ""

# Check if any device is connected via USB
echo "📱 Checking for USB-connected devices..."
DEVICES=$(adb devices | grep -w "device" | awk '{print $1}')

if [ -z "$DEVICES" ]; then
    echo "❌ No USB-connected devices found"
    echo "Please connect your Android device via USB with USB debugging enabled"
    echo ""
    echo "Steps to enable USB debugging:"
    echo "1. Go to Settings > About Phone"
    echo "2. Tap 'Build Number' 7 times to enable Developer Options"
    echo "3. Go to Settings > Developer Options"
    echo "4. Enable 'USB Debugging'"
    exit 1
fi

DEVICE_COUNT=$(echo "$DEVICES" | wc -l)
echo "✓ Found $DEVICE_COUNT USB-connected device(s)"
echo ""

# For each connected device, enable wireless debugging
for DEVICE in $DEVICES; do
    echo "------------------------------------------"
    echo "Setting up wireless debugging for device: $DEVICE"
    echo "------------------------------------------"
    
    # Get device info
    MODEL=$(adb -s $DEVICE shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    ANDROID_VERSION=$(adb -s $DEVICE shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    API_LEVEL=$(adb -s $DEVICE shell getprop ro.build.version.sdk 2>/dev/null | tr -d '\r')
    
    echo "Device Model: $MODEL"
    echo "Android Version: $ANDROID_VERSION (API $API_LEVEL)"
    echo ""
    
    # Check Android version for wireless debugging support
    if [ "$API_LEVEL" -lt 30 ]; then
        echo "⚠️  Warning: Android $ANDROID_VERSION (API $API_LEVEL) may require manual pairing"
        echo "For Android 10 and below, wireless debugging requires additional setup"
        echo ""
        
        # Try to enable wireless debugging for older devices
        echo "Attempting to enable TCP/IP mode..."
        adb -s $DEVICE tcpip 5555
        
        # Get device IP address
        IP_ADDRESS=$(adb -s $DEVICE shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | tr -d '\r')
        
        if [ -z "$IP_ADDRESS" ]; then
            echo "❌ Could not get device IP address"
            echo "Please ensure device is connected to Wi-Fi"
            continue
        fi
        
        echo "✓ Device IP: $IP_ADDRESS"
        echo "You can now disconnect USB and connect wirelessly:"
        echo "  adb connect $IP_ADDRESS:5555"
    else
        # Android 11+ supports wireless debugging pairing
        echo "✓ Android 11+ detected - supports wireless debugging pairing"
        echo ""
        
        # Enable wireless debugging on device
        echo "Enabling wireless debugging on device..."
        adb -s $DEVICE shell settings put global adb_wifi_enabled 1
        
        # Get device IP address
        IP_ADDRESS=$(adb -s $DEVICE shell ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | tr -d '\r')
        
        if [ -z "$IP_ADDRESS" ]; then
            echo "❌ Could not get device IP address"
            echo "Please ensure device is connected to Wi-Fi"
            continue
        fi
        
        echo "✓ Device IP: $IP_ADDRESS"
        echo ""
        
        # Enable TCP/IP mode
        echo "Enabling TCP/IP mode on port 5555..."
        adb -s $DEVICE tcpip 5555
        
        echo "✓ Wireless debugging enabled"
        echo ""
        echo "You can now disconnect USB and connect wirelessly:"
        echo "  adb connect $IP_ADDRESS:5555"
        echo ""
        echo "To verify connection:"
        echo "  adb devices"
    fi
    
    echo ""
done

echo "=========================================="
echo "✓ Wireless debugging setup complete"
echo "=========================================="
echo ""
echo "To connect wirelessly after disconnecting USB:"
echo "  adb connect <device-ip>:5555"
echo ""
echo "To disconnect wireless debugging:"
echo "  adb disconnect <device-ip>:5555"
echo ""
echo "To disable wireless debugging on device:"
echo "  adb shell settings put global adb_wifi_enabled 0"
echo ""
