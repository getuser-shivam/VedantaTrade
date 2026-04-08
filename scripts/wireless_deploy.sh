#!/bin/bash

# VedantaTrade - Wireless Deployment Script
# This script deploys the app wirelessly to connected devices

set -e

echo "=========================================="
echo "VedantaTrade - Wireless Deployment"
echo "=========================================="
echo ""

# Parse command line arguments
PLATFORM="all"
BUILD_TYPE="debug"
DEVICE_ID=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --android)
            PLATFORM="android"
            shift
            ;;
        --ios)
            PLATFORM="ios"
            shift
            ;;
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        --profile)
            BUILD_TYPE="profile"
            shift
            ;;
        --device)
            DEVICE_ID="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --android       Deploy to Android devices only"
            echo "  --ios           Deploy to iOS devices only"
            echo "  --release       Build release version"
            echo "  --profile       Build profile version"
            echo "  --device ID     Deploy to specific device ID"
            echo "  --help          Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                              # Deploy to all devices (debug)"
            echo "  $0 --android --release          # Deploy release to Android"
            echo "  $0 --ios --device <device-id>   # Deploy to specific iOS device"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Build Type: $BUILD_TYPE"
echo "Platform: $PLATFORM"
if [ -n "$DEVICE_ID" ]; then
    echo "Device ID: $DEVICE_ID"
fi
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Error: Flutter is not installed or not in PATH"
    exit 1
fi

echo "✓ Flutter found"
flutter --version
echo ""

# Get list of available devices
echo "📱 Checking for available devices..."
flutter devices

if [ -z "$DEVICE_ID" ]; then
    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."
fi

echo ""
echo "=========================================="
echo "Building and Deploying"
echo "=========================================="
echo ""

# Build arguments
BUILD_ARGS=""
if [ "$BUILD_TYPE" = "release" ]; then
    BUILD_ARGS="--release"
elif [ "$BUILD_TYPE" = "profile" ]; then
    BUILD_ARGS="--profile"
fi

# Device arguments
DEVICE_ARGS=""
if [ -n "$DEVICE_ID" ]; then
    DEVICE_ARGS="-d $DEVICE_ID"
fi

# Platform-specific deployment
case $PLATFORM in
    android)
        echo "Deploying to Android devices..."
        flutter run $BUILD_ARGS $DEVICE_ARGS
        ;;
    ios)
        echo "Deploying to iOS devices..."
        flutter run $BUILD_ARGS $DEVICE_ARGS
        ;;
    all)
        echo "Deploying to all available devices..."
        flutter run $BUILD_ARGS $DEVICE_ARGS
        ;;
esac

echo ""
echo "=========================================="
echo "✓ Deployment complete"
echo "=========================================="
