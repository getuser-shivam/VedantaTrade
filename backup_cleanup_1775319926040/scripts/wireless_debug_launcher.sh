#!/bin/bash

# VedantaTrade Wireless Debug Launcher
# This script sets up and launches wireless debugging for VedantaTrade app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_PATH="${1:-$(pwd)}"
DEBUG_PORT="${2:-8080}"
TARGET_DEVICE="${3:-}"
VERBOSE="${4:-false}"
NO_HOT_RELOAD="${5:-false}"
NO_DEBUG_LOGGING="${6:-false}"

# Print colored output
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo
    print_colored "$BLUE" "🚀 VedantaTrade Wireless Debug Launcher"
    echo "=========================================="
    echo
}

# Print status
print_status() {
    local status=$1
    local message=$2
    if [ "$status" = "success" ]; then
        print_colored "$GREEN" "✅ $message"
    elif [ "$status" = "warning" ]; then
        print_colored "$YELLOW" "⚠️  $message"
    elif [ "$status" = "error" ]; then
        print_colored "$RED" "❌ $message"
    elif [ "$status" = "info" ]; then
        print_colored "$BLUE" "ℹ️  $message"
    fi
}

# Check prerequisites
check_prerequisites() {
    print_status "info" "Checking prerequisites..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        print_status "error" "Flutter is not installed or not in PATH"
        exit 1
    else
        FLUTTER_VERSION=$(flutter --version | head -n1)
        print_status "success" "Flutter installed: $FLUTTER_VERSION"
    fi
    
    # Check Dart
    if ! command -v dart &> /dev/null; then
        print_status "error" "Dart is not installed or not in PATH"
        exit 1
    else
        DART_VERSION=$(dart --version)
        print_status "success" "Dart installed: $DART_VERSION"
    fi
    
    # Check ADB for Android debugging
    if command -v adb &> /dev/null; then
        ADB_VERSION=$(adb version | head -n1)
        print_status "success" "ADB installed: $ADB_VERSION"
    else
        print_status "warning" "ADB not found - Android debugging may not work"
    fi
    
    # Check Xcode for iOS debugging (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v xcodebuild &> /dev/null; then
            XCODE_VERSION=$(xcodebuild -version | head -n1)
            print_status "success" "Xcode installed: $XCODE_VERSION"
        else
            print_status "warning" "Xcode not found - iOS debugging may not work"
        fi
    fi
    
    # Check network connectivity
    if ping -c 1 8.8.8.8 &> /dev/null; then
        print_status "success" "Network connectivity confirmed"
    else
        print_status "warning" "Network connectivity issues detected"
    fi
    
    echo
}

# Setup wireless debugging environment
setup_wireless_environment() {
    print_status "info" "Setting up wireless debugging environment..."
    
    # Create debug directory
    DEBUG_DIR="$PROJECT_PATH/debug_wireless"
    mkdir -p "$DEBUG_DIR"
    
    # Create debug configuration
    cat > "$DEBUG_DIR/debug_config.json" << EOF
{
  "wireless_debug": {
    "enabled": true,
    "hot_reload": $([ "$NO_HOT_RELOAD" != "true" ] && echo "true" || echo "false"),
    "debug_logging": $([ "$NO_DEBUG_LOGGING" != "true" ] && echo "true" || echo "false"),
    "port": $DEBUG_PORT,
    "host": "0.0.0.0",
    "allow_remote": true,
    "auth_required": false,
    "max_connections": 5
  },
  "logging": {
    "level": $([ "$NO_DEBUG_LOGGING" != "true" ] && echo "debug" || echo "info"),
    "file": "$DEBUG_DIR/wireless_debug.log",
    "console": true,
    "network": true
  },
  "performance": {
    "profile": true,
    "memory_tracking": true,
    "cpu_tracking": true,
    "network_tracking": true
  }
}
EOF
    
    print_status "success" "Debug configuration created"
}

# Setup wireless debugging tools
setup_wireless_tools() {
    print_status "info" "Setting up wireless debugging tools..."
    
    # Create tools directory
    TOOLS_DIR="$PROJECT_PATH/debug_tools"
    mkdir -p "$TOOLS_DIR"
    
    # Create wireless debug script
    cat > "$TOOLS_DIR/start_wireless_debug.sh" << 'EOF'
#!/bin/bash

# Wireless Debug Script for VedantaTrade

echo "🚀 Starting Wireless Debug Server..."

# Load configuration
CONFIG_FILE="debug_wireless/debug_config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Debug configuration file not found"
    exit 1
fi

# Extract configuration
PORT=$(jq -r '.wireless_debug.port' "$CONFIG_FILE")
HOST=$(jq -r '.wireless_debug.host' "$CONFIG_FILE")
LOG_LEVEL=$(jq -r '.logging.level' "$CONFIG_FILE")

echo "📡 Starting debug server on $HOST:$PORT..."
echo "📝 Log level: $LOG_LEVEL"

# Kill existing Flutter processes
pkill -f "flutter" || true

# Start Flutter debug server
flutter run -d --debug --host=$HOST --port=$PORT --web-port=$((PORT + 1)) --web-hostname=$HOST \
    --web-port-debug=$((PORT + 2)) \
    --web-port-profile=$((PORT + 3)) \
    --web-port-observatory=$((PORT + 4)) \
    --verbose
EOF
    
    # Make script executable
    chmod +x "$TOOLS_DIR/start_wireless_debug.sh"
    
    print_status "success" "Wireless debugging tools created"
}

# Configure network settings
configure_network_settings() {
    print_status "info" "Configuring network settings..."
    
    # Check if running on Linux/macOS
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        # Check firewall status
        if command -v ufw &> /dev/null; then
            if ufw status | grep -q "Status: active"; then
                print_status "warning" "UFW firewall is active - may block connections"
                print_status "info" "Run: sudo ufw allow $DEBUG_PORT/tcp"
            fi
        fi
        
        # Check if port is in use
        if netstat -tuln | grep -q ":$DEBUG_PORT "; then
            print_status "warning" "Port $DEBUG_PORT is already in use"
            print_status "info" "Trying to find an available port..."
            
            # Find available port
            for port in {8081..8090}; do
                if ! netstat -tuln | grep -q ":$port "; then
                    DEBUG_PORT=$port
                    print_status "success" "Found available port: $port"
                    break
                fi
            done
        fi
    fi
    
    print_status "success" "Network settings configured"
}

# Build debug version
build_debug_version() {
    print_status "info" "Building debug version..."
    
    cd "$PROJECT_PATH"
    
    if [ "$VERBOSE" = "true" ]; then
        echo "🧹 Cleaning previous builds..."
    fi
    flutter clean
    
    if [ "$VERBOSE" = "true" ]; then
        echo "📦 Getting dependencies..."
    fi
    flutter pub get
    
    if [ "$VERBOSE" = "true" ]; then
        echo "🔨 Building debug version..."
    fi
    
    # Build debug version
    flutter build web \
        --debug \
        --web-renderer canvaskit \
        --no-sound-null-safety \
        --enable-experiment null-safety \
        --verbose
    
    if [ $? -eq 0 ]; then
        print_status "success" "Debug build completed successfully"
    else
        print_status "error" "Debug build failed"
        exit 1
    fi
    
    cd - > /dev/null
}

# Configure wireless debugging
configure_wireless_debugging() {
    print_status "info" "Configuring wireless debugging..."
    
    # Update pubspec.yaml for wireless debugging
    PUBSPEC_FILE="$PROJECT_PATH/pubspec.yaml"
    if [ -f "$PUBSPEC_FILE" ]; then
        # Check if dependencies already exist
        if ! grep -q "web_socket_channel:" "$PUBSPEC_FILE"; then
            echo "  Adding wireless debugging dependencies..."
            
            # Add dependencies to pubspec.yaml
            sed -i '/^dependencies:/a\
  # Wireless debugging dependencies\
  web_socket_channel: ^2.4.0\
  logger: ^2.0.2+1\
  network_info_plus: ^5.0.1\
  device_info_plus: ^10.1.0' "$PUBSPEC_FILE"
            
            print_status "success" "Added wireless debugging dependencies"
        else
            print_status "info" "Wireless debugging dependencies already exist"
        fi
    else
        print_status "error" "pubspec.yaml not found"
        exit 1
    fi
    
    # Create debug entry point
    DEBUG_MAIN_FILE="$PROJECT_PATH/lib/debug_main.dart"
    cat > "$DEBUG_MAIN_FILE" << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:logger/logger.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'main.dart' as app;

void main() async {
  // Initialize logger
  Logger.level = Level.debug;
  
  // Setup wireless debugging
  await _setupWirelessDebugging();
  
  // Run main app
  app.main();
}

Future<void> _setupWirelessDebugging() async {
  try {
    Logger.i('🚀 Setting up wireless debugging...');
    
    // Get device info
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final networkInfo = await NetworkInfo().getWifiIP();
    
    Logger.i('📱 Device: ${deviceInfo.model}');
    Logger.i('🌐 Network IP: $networkInfo');
    
    // Setup WebSocket for remote debugging
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://$networkInfo:8080/debug'),
    );
    
    channel.stream.listen(
      (message) {
        Logger.d('📡 Debug message: $message');
        _handleDebugMessage(message);
      },
      onError: (error) {
        Logger.e('❌ WebSocket error: $error');
      },
      onDone: () {
        Logger.i('🔌 WebSocket connection closed');
      },
    );
    
    // Setup system overlay for debug info
    await SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.red.withOpacity(0.8),
      ),
    );
    
    Logger.i('✅ Wireless debugging setup completed');
    
  } catch (e) {
    Logger.e('❌ Failed to setup wireless debugging: $e');
  }
}

void _handleDebugMessage(String message) {
  try {
    final data = jsonDecode(message);
    
    switch (data['type']) {
      case 'hot_reload':
        Logger.i('🔄 Triggering hot reload...');
        // Trigger hot reload
        break;
      case 'log_level':
        Logger.i('📝 Updating log level to ${data['level']}');
        Logger.level = _getLogLevel(data['level']);
        break;
      case 'performance':
        Logger.i('📊 Performance data: ${data['data']}');
        break;
      case 'network':
        Logger.i('🌐 Network data: ${data['data']}');
        break;
    }
    
  } catch (e) {
    Logger.e('❌ Failed to handle debug message: $e');
  }
}

Level _getLogLevel(String level) {
  switch (level.toLowerCase()) {
    case 'debug':
      return Level.debug;
    case 'info':
      return Level.info;
    case 'warning':
      return Level.warning;
    case 'error':
      return Level.error;
    default:
      return Level.info;
  }
}
EOF
    
    print_status "success" "Debug entry point created"
}

# Start wireless server
start_wireless_server() {
    print_status "info" "Starting wireless server..."
    
    cd "$PROJECT_PATH"
    
    # Start debug server
    echo "🚀 Starting Flutter debug server..."
    echo "📡 Server will be available at: http://0.0.0.0:$DEBUG_PORT"
    echo "📱 Debug console: http://localhost:$DEBUG_PORT"
    
    # Start the wireless debug script
    if [ -f "debug_tools/start_wireless_debug.sh" ]; then
        ./debug_tools/start_wireless_debug.sh &
        SERVER_PID=$!
        
        # Wait for server to start
        sleep 5
        
        # Check if server is running
        if ps -p $SERVER_PID > /dev/null; then
            print_status "success" "Wireless server started successfully (PID: $SERVER_PID)"
        else
            print_status "error" "Failed to start wireless server"
            exit 1
        fi
    else
        print_status "error" "Wireless debug script not found"
        exit 1
    fi
    
    cd - > /dev/null
}

# Connect to target device
connect_to_target_device() {
    print_status "info" "Connecting to target device..."
    
    if [ -n "$TARGET_DEVICE" ]; then
        # Connect to specific device
        flutter devices
        echo "📱 Connecting to device: $TARGET_DEVICE"
        
        flutter run -d "$TARGET_DEVICE" --debug --host=0.0.0.0 --port=$DEBUG_PORT &
        
        print_status "success" "Connected to device: $TARGET_DEVICE"
    else
        # Auto-detect and connect to available device
        echo "📱 Available devices:"
        flutter devices
        
        # Try to connect to first available device
        flutter run --debug --host=0.0.0.0 --port=$DEBUG_PORT &
        DEVICE_PID=$!
        
        print_status "success" "Connected to first available device (PID: $DEVICE_PID)"
    fi
}

# Start debugging session
start_debugging_session() {
    print_status "info" "Starting debugging session..."
    
    # Open debug console in browser
    DEBUG_URL="http://localhost:$DEBUG_PORT"
    echo "🌐 Opening debug console: $DEBUG_URL"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "$DEBUG_URL" 2>/dev/null || echo "Please open $DEBUG_URL in your browser"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        open "$DEBUG_URL"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        start "$DEBUG_URL"
    fi
    
    # Start monitoring session
    echo "📊 Starting session monitoring..."
    
    # Monitor for debug events
    while true; do
        sleep 10
        _check_session_health
    done &
    
    MONITOR_PID=$!
    
    print_status "success" "Debugging session started"
    echo "📡 Debug server: http://0.0.0.0:$DEBUG_PORT"
    echo "📱 Debug console: http://localhost:$DEBUG_PORT"
    echo "🔍 Observatory: http://localhost:$((DEBUG_PORT + 4))"
    
    echo
    print_status "info" "🎯 Wireless debugging is now active!"
    print_status "info" "💡 Use your browser to debug the app wirelessly"
    print_status "info" "📱 Connect your mobile device to the same network"
    print_status "info" "🌐 Access the debug console from any device on the network"
    echo
    
    # Wait for user interrupt
    trap 'cleanup' INT
    wait $MONITOR_PID
}

# Check session health
_check_session_health() {
    # Check if debug server is still running
    if curl -s "http://localhost:$DEBUG_PORT/health" > /dev/null 2>&1; then
        if [ "$VERBOSE" = "true" ]; then
            echo "💚 Debug server is healthy"
        fi
    else
        echo "💔 Debug server is not responding"
        echo "🔄 Attempting to restart debug server..."
        _restart_debug_server
    fi
}

# Restart debug server
_restart_debug_server() {
    echo "🔄 Restarting debug server..."
    
    # Kill existing Flutter processes
    pkill -f "flutter" || true
    
    # Wait a moment
    sleep 2
    
    # Restart server
    start_wireless_server
}

# Cleanup function
cleanup() {
    echo
    print_status "info" "🛑 Stopping wireless debugging..."
    
    # Kill all Flutter processes
    pkill -f "flutter" || true
    
    # Kill monitoring process
    if [ -n "$MONITOR_PID" ]; then
        kill $MONITOR_PID 2>/dev/null || true
    fi
    
    # Clean up debug files
    if [ -d "$PROJECT_PATH/debug_wireless" ]; then
        rm -rf "$PROJECT_PATH/debug_wireless"
    fi
    
    if [ -d "$PROJECT_PATH/debug_tools" ]; then
        rm -rf "$PROJECT_PATH/debug_tools"
    fi
    
    # Remove debug entry point
    if [ -f "$PROJECT_PATH/lib/debug_main.dart" ]; then
        rm "$PROJECT_PATH/lib/debug_main.dart"
    fi
    
    print_status "success" "Wireless debugging stopped"
    exit 0
}

# Show help
show_help() {
    echo "VedantaTrade Wireless Debug Launcher"
    echo "=================================="
    echo
    echo "Usage: $0 [PROJECT_PATH] [DEBUG_PORT] [TARGET_DEVICE] [VERBOSE] [NO_HOT_RELOAD] [NO_DEBUG_LOGGING]"
    echo
    echo "Arguments:"
    echo "  PROJECT_PATH      Path to the VedantaTrade project (default: current directory)"
    echo "  DEBUG_PORT       Debug server port (default: 8080)"
    echo "  TARGET_DEVICE     Target device ID for debugging"
    echo "  VERBOSE          Enable verbose output (true/false, default: false)"
    echo "  NO_HOT_RELOAD    Disable hot reload (true/false, default: false)"
    echo "  NO_DEBUG_LOGGING Disable debug logging (true/false, default: false)"
    echo
    echo "Examples:"
    echo "  $0                                    # Use defaults"
    echo "  $0 /path/to/vedantatrade            # Specify project path"
    echo "  $0 /path/to/vedantatrade 8081       # Specify custom port"
    echo "  $0 /path/to/vedantatrade 8080 emulator-5554  # Connect to emulator"
    echo "  $0 /path/to/vedantatrade 8080 \"\" true        # Enable verbose output"
    echo
}

# Main execution
main() {
    # Show help if requested
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    print_header
    
    # Check prerequisites
    check_prerequisites
    
    # Setup wireless debugging environment
    setup_wireless_environment
    
    # Setup wireless debugging tools
    setup_wireless_tools
    
    # Configure network settings
    configure_network_settings
    
    # Build debug version
    build_debug_version
    
    # Configure wireless debugging
    configure_wireless_debugging
    
    # Start wireless server
    start_wireless_server
    
    # Connect to target device
    connect_to_target_device
    
    # Start debugging session
    start_debugging_session
}

# Trap signals for cleanup
trap cleanup EXIT
trap cleanup INT
trap cleanup TERM

# Run main function
main "$@"
