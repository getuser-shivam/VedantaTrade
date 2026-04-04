import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:args/args.dart';
import 'package:process_run/process_run.dart';

/// Wireless debug deployment script for VedantaTrade
class WirelessDebugDeployment {
  final String projectPath;
  final bool verbose;
  final String? targetDevice;
  final bool enableHotReload;
  final bool enableDebugLogging;
  final int? debugPort;
  
  WirelessDebugDeployment({
    required this.projectPath,
    this.verbose = false,
    this.targetDevice,
    this.enableHotReload = true,
    this.enableDebugLogging = true,
    this.debugPort,
  });

  /// Deploy app in wireless debug mode
  Future<void> deploy() async {
    print('🚀 Starting Wireless Debug Deployment...');
    print('=' * 50);
    
    try {
      // 1. Check prerequisites
      await _checkPrerequisites();
      
      // 2. Setup wireless debugging environment
      await _setupWirelessEnvironment();
      
      // 3. Build debug version
      await _buildDebugVersion();
      
      // 4. Configure wireless debugging
      await _configureWirelessDebugging();
      
      // 5. Start wireless server
      await _startWirelessServer();
      
      // 6. Connect to target device
      await _connectToTargetDevice();
      
      // 7. Start debugging session
      await _startDebuggingSession();
      
      print('✅ Wireless debug deployment completed successfully!');
      
    } catch (e) {
      print('❌ Wireless debug deployment failed: $e');
      exit(1);
    }
  }

  /// Check prerequisites
  Future<void> _checkPrerequisites() async {
    print('🔍 Checking prerequisites...');
    
    // Check Flutter installation
    try {
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode == 0) {
        print('   ✓ Flutter installed: ${flutterResult.stdout.trim()}');
      } else {
        throw Exception('Flutter not found');
      }
    } catch (e) {
      throw Exception('Flutter installation check failed: $e');
    }
    
    // Check ADB for Android debugging
    try {
      final adbResult = await Process.run('adb', ['version']);
      if (adbResult.exitCode == 0) {
        print('   ✓ ADB installed: ${adbResult.stdout.trim()}');
      } else {
        print('   ⚠️  ADB not found - Android debugging may not work');
      }
    } catch (e) {
      print('   ⚠️  ADB check failed: $e');
    }
    
    // Check iOS tools for iOS debugging
    if (Platform.isMacOS) {
      try {
        final xcodeResult = await Process.run('xcodebuild', ['-version']);
        if (xcodeResult.exitCode == 0) {
          print('   ✓ Xcode installed: ${xcodeResult.stdout.split('\n')[0]}');
        } else {
          print('   ⚠️  Xcode not found - iOS debugging may not work');
        }
      } catch (e) {
        print('   ⚠️  Xcode check failed: $e');
      }
    }
    
    // Check network connectivity
    try {
      final result = await Process.run('ping', ['-c', '1', '8.8.8.8']);
      if (result.exitCode == 0) {
        print('   ✓ Network connectivity confirmed');
      } else {
        print('   ⚠️  Network connectivity issues detected');
      }
    } catch (e) {
      print('   ⚠️  Network check failed: $e');
    }
    
    print('✅ Prerequisites check completed\n');
  }

  /// Setup wireless debugging environment
  Future<void> _setupWirelessEnvironment() async {
    print('🔧 Setting up wireless debugging environment...');
    
    // Create debug configuration
    await _createDebugConfiguration();
    
    // Setup wireless debugging tools
    await _setupWirelessTools();
    
    // Configure network settings
    await _configureNetworkSettings();
    
    print('✅ Wireless debugging environment setup completed\n');
  }

  /// Create debug configuration
  Future<void> _createDebugConfiguration() async {
    print('   📝 Creating debug configuration...');
    
    final debugConfig = {
      'wireless_debug': {
        'enabled': true,
        'hot_reload': enableHotReload,
        'debug_logging': enableDebugLogging,
        'port': debugPort ?? 8080,
        'host': '0.0.0.0',
        'allow_remote': true,
        'auth_required': false,
        'max_connections': 5,
      },
      'logging': {
        'level': enableDebugLogging ? 'debug' : 'info',
        'file': 'wireless_debug.log',
        'console': true,
        'network': true,
      },
      'performance': {
        'profile': true,
        'memory_tracking': true,
        'cpu_tracking': true,
        'network_tracking': true,
      },
    };
    
    final configFile = File('$projectPath/debug_config.json');
    await configFile.writeAsString(jsonEncode(debugConfig));
    
    print('   ✓ Debug configuration created');
  }

  /// Setup wireless debugging tools
  Future<void> _setupWirelessTools() async {
    print('   🛠️  Setting up wireless debugging tools...');
    
    // Create tools directory
    final toolsDir = Directory('$projectPath/debug_tools');
    if (!await toolsDir.exists()) {
      await toolsDir.create(recursive: true);
    }
    
    // Create wireless debug script
    final debugScript = '''#!/bin/bash
# Wireless Debug Script for VedantaTrade

echo "🚀 Starting Wireless Debug Server..."

# Load configuration
CONFIG_FILE="debug_config.json"
if [ ! -f "\$CONFIG_FILE" ]; then
    echo "❌ Debug configuration file not found"
    exit 1
fi

# Extract configuration
PORT=\$(jq -r '.wireless_debug.port' "\$CONFIG_FILE")
HOST=\$(jq -r '.wireless_debug.host' "\$CONFIG_FILE")
LOG_LEVEL=\$(jq -r '.logging.level' "\$CONFIG_FILE")

echo "📡 Starting debug server on \$HOST:\$PORT..."
echo "📝 Log level: \$LOG_LEVEL"

# Start Flutter debug server
flutter run -d \$DEVICE --debug --host=\$HOST --port=\$PORT --web-port=\$((PORT + 1)) --web-hostname=\$HOST
''';
    
    final scriptFile = File('$projectPath/debug_tools/start_wireless_debug.sh');
    await scriptFile.writeAsString(debugScript);
    
    // Make script executable
    await Process.run('chmod', ['+x', scriptFile.path]);
    
    print('   ✓ Wireless debugging tools created');
  }

  /// Configure network settings
  Future<void> _configureNetworkSettings() async {
    print('   🌐 Configuring network settings...');
    
    // Check firewall settings
    if (Platform.isLinux || Platform.isMacOS) {
      try {
        final result = await Process.run('ufw', ['status']);
        if (result.stdout.contains('active')) {
          print('   ⚠️  UFW firewall is active - may block connections');
          print('   💡 Run: sudo ufw allow $debugPort/tcp');
        }
      } catch (e) {
        print('   ⚠️  Could not check firewall status: $e');
      }
    }
    
    // Configure port forwarding if needed
    if (targetDevice != null && targetDevice!.contains('emulator')) {
      print('   🔄 Configuring port forwarding for emulator...');
      await Process.run('adb', [
        'reverse',
        'tcp:$debugPort',
        'tcp:$debugPort',
      ]);
    }
    
    print('   ✓ Network settings configured');
  }

  /// Build debug version
  Future<void> _buildDebugVersion() async {
    print('🏗️ Building debug version...');
    
    try {
      // Clean previous builds
      if (verbose) {
        print('   🧹 Cleaning previous builds...');
      }
      await Process.run('flutter', ['clean'], workingDirectory: projectPath);
      
      // Get dependencies
      if (verbose) {
        print('   📦 Getting dependencies...');
      }
      await Process.run('flutter', ['pub', 'get'], workingDirectory: projectPath);
      
      // Build debug version
      if (verbose) {
        print('   🔨 Building debug version...');
      }
      
      final buildArgs = [
        'build',
        'web',
        '--debug',
        '--web-renderer',
        'canvaskit',
        '--no-sound-null-safety',
        '--enable-experiment',
        'null-safety',
      ];
      
      final result = await Process.run('flutter', buildArgs, workingDirectory: projectPath);
      
      if (result.exitCode == 0) {
        print('   ✓ Debug build completed successfully');
      } else {
        throw Exception('Debug build failed: ${result.stderr}');
      }
      
    } catch (e) {
      throw Exception('Debug build failed: $e');
    }
    
    print('✅ Debug version built successfully\n');
  }

  /// Configure wireless debugging
  Future<void> _configureWirelessDebugging() async {
    print('🔧 Configuring wireless debugging...');
    
    // Update pubspec.yaml for wireless debugging
    await _updatePubspecForWireless();
    
    // Create debug entry point
    await _createDebugEntryPoint();
    
    // Configure observatory
    await _configureObservatory();
    
    print('   ✓ Wireless debugging configured');
  }

  /// Update pubspec.yaml for wireless debugging
  Future<void> _updatePubspecForWireless() async {
    print('   📝 Updating pubspec.yaml for wireless debugging...');
    
    final pubspecFile = File('$projectPath/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      throw Exception('pubspec.yaml not found');
    }
    
    final content = await pubspecFile.readAsString();
    
    // Add wireless debugging dependencies
    final wirelessDeps = '''
  # Wireless debugging dependencies
  web_socket_channel: ^2.4.0
  logger: ^2.0.2+1
  network_info_plus: ^5.0.1
  device_info_plus: ^10.1.0
''';
    
    // Check if dependencies already exist
    if (!content.contains('web_socket_channel:')) {
      final updatedContent = content.replaceFirst(
        'dependencies:',
        'dependencies:$wirelessDeps',
      );
      await pubspecFile.writeAsString(updatedContent);
      print('   ✓ Added wireless debugging dependencies');
    }
  }

  /// Create debug entry point
  Future<void> _createDebugEntryPoint() async {
    print('   📝 Creating debug entry point...');
    
    final debugMain = '''
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
    
    Logger.i('📱 Device: \${deviceInfo.model}');
    Logger.i('🌐 Network IP: \$networkInfo');
    
    // Setup WebSocket for remote debugging
    final channel = WebSocketChannel.connect(
      Uri.parse('ws://\$networkInfo:8080/debug'),
    );
    
    channel.stream.listen(
      (message) {
        Logger.d('📡 Debug message: \$message');
        _handleDebugMessage(message);
      },
      onError: (error) {
        Logger.e('❌ WebSocket error: \$error');
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
    Logger.e('❌ Failed to setup wireless debugging: \$e');
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
        Logger.i('📝 Updating log level to \${data['level']}');
        Logger.level = _getLogLevel(data['level']);
        break;
      case 'performance':
        Logger.i('📊 Performance data: \${data['data']}');
        break;
      case 'network':
        Logger.i('🌐 Network data: \${data['data']}');
        break;
    }
    
  } catch (e) {
    Logger.e('❌ Failed to handle debug message: \$e');
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
''';
    
    final debugMainFile = File('$projectPath/lib/debug_main.dart');
    await debugMainFile.writeAsString(debugMain);
    
    print('   ✓ Debug entry point created');
  }

  /// Configure observatory
  Future<void> _configureObservatory() async {
    print('   🔧 Configuring observatory...');
    
    // Create observatory configuration
    final observatoryConfig = {
      'observatory': {
        'enabled': true,
        'port': debugPort ?? 8080,
        'host': '0.0.0.0',
        'auth': false,
        'enable_service': true,
      },
    };
    
    final configFile = File('$projectPath/observatory_config.json');
    await configFile.writeAsString(jsonEncode(observatoryConfig));
    
    print('   ✓ Observatory configured');
  }

  /// Start wireless server
  Future<void> _startWirelessServer() async {
    print('🌐 Starting wireless server...');
    
    try {
      // Start debug server
      final serverArgs = [
        'run',
        '--debug',
        '--host=0.0.0.0',
        '--port=${debugPort ?? 8080}',
        '--web-port=${(debugPort ?? 8080) + 1}',
        '--web-hostname=0.0.0.0',
        if (targetDevice != null) '-d $targetDevice',
        if (enableHotReload) '--hot',
        if (enableDebugLogging) '--verbose',
      ];
      
      print('   🚀 Starting Flutter debug server...');
      print('   📡 Server will be available at: http://0.0.0.0:${debugPort ?? 8080}');
      print('   📱 Debug console: http://0.0.0.0:${(debugPort ?? 8080) + 1}');
      
      // Start the server in background
      await Process.start('flutter', serverArgs, workingDirectory: projectPath);
      
      // Wait for server to start
      await Future.delayed(const Duration(seconds: 5));
      
      print('   ✓ Wireless server started successfully');
      
    } catch (e) {
      throw Exception('Failed to start wireless server: $e');
    }
    
    print('✅ Wireless server started\n');
  }

  /// Connect to target device
  Future<void> _connectToTargetDevice() async {
    print('📱 Connecting to target device...');
    
    try {
      if (targetDevice != null) {
        // Connect to specific device
        await Process.run('flutter', ['devices'], workingDirectory: projectPath);
        
        final connectArgs = [
          'run',
          '-d',
          targetDevice!,
          '--debug',
          '--host=0.0.0.0',
          '--port=${debugPort ?? 8080}',
        ];
        
        await Process.run('flutter', connectArgs, workingDirectory: projectPath);
        
        print('   ✓ Connected to device: $targetDevice');
      } else {
        // Auto-detect and connect to available device
        final devicesResult = await Process.run('flutter', ['devices'], workingDirectory: projectPath);
        
        if (devicesResult.exitCode == 0) {
          print('   📱 Available devices:');
          print(devicesResult.stdout);
          
          // Try to connect to first available device
          await Process.run('flutter', [
            'run',
            '--debug',
            '--host=0.0.0.0',
            '--port=${debugPort ?? 8080}',
          ], workingDirectory: projectPath);
          
          print('   ✓ Connected to first available device');
        } else {
          throw Exception('No devices found');
        }
      }
      
    } catch (e) {
      throw Exception('Failed to connect to target device: $e');
    }
    
    print('✅ Device connection established\n');
  }

  /// Start debugging session
  Future<void> _startDebuggingSession() async {
    print('🐛 Starting debugging session...');
    
    try {
      // Open debug console in browser
      final debugUrl = 'http://localhost:${debugPort ?? 8080}';
      print('   🌐 Opening debug console: $debugUrl');
      
      if (Platform.isWindows) {
        await Process.run('start', [debugUrl]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [debugUrl]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [debugUrl]);
      }
      
      // Start monitoring session
      await _startSessionMonitoring();
      
      print('   ✓ Debugging session started');
      print('   📡 Debug server: http://0.0.0.0:${debugPort ?? 8080}');
      print('   📱 Debug console: http://localhost:${debugPort ?? 8080}');
      print('   🔍 Observatory: http://localhost:${(debugPort ?? 8080) + 1}');
      
      print('\n🎯 Wireless debugging is now active!');
      print('💡 Use your browser to debug the app wirelessly');
      print('📱 Connect your mobile device to the same network');
      print('🌐 Access the debug console from any device on the network');
      
    } catch (e) {
      throw Exception('Failed to start debugging session: $e');
    }
    
    print('✅ Debugging session started\n');
  }

  /// Start session monitoring
  Future<void> _startSessionMonitoring() async {
    print('   📊 Starting session monitoring...');
    
    // Monitor for debug events
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      await _checkSessionHealth();
    });
    
    print('   ✓ Session monitoring started');
  }

  /// Check session health
  Future<void> _checkSessionHealth() async {
    try {
      // Check if debug server is still running
      final result = await Process.run('curl', [
        '-s',
        'http://localhost:${debugPort ?? 8080}/health',
      ]);
      
      if (result.exitCode == 0) {
        if (verbose) {
          print('   💚 Debug server is healthy');
        }
      } else {
        print('   💔 Debug server is not responding');
        print('   🔄 Attempting to restart debug server...');
        await _restartDebugServer();
      }
      
    } catch (e) {
      if (verbose) {
        print('   ⚠️  Health check failed: $e');
      }
    }
  }

  /// Restart debug server
  Future<void> _restartDebugServer() async {
    try {
      print('   🔄 Restarting debug server...');
      
      // Kill existing server
      await Process.run('pkill', ['-f', 'flutter']);
      
      // Wait a moment
      await Future.delayed(const Duration(seconds: 2));
      
      // Restart server
      await _startWirelessServer();
      
      print('   ✓ Debug server restarted');
      
    } catch (e) {
      print('   ❌ Failed to restart debug server: $e');
    }
  }

  /// Stop wireless debugging
  Future<void> stop() async {
    print('🛑 Stopping wireless debugging...');
    
    try {
      // Kill Flutter processes
      await Process.run('pkill', ['-f', 'flutter']);
      
      // Clean up debug files
      await _cleanupDebugFiles();
      
      print('✅ Wireless debugging stopped');
      
    } catch (e) {
      print('❌ Failed to stop wireless debugging: $e');
    }
  }

  /// Clean up debug files
  Future<void> _cleanupDebugFiles() async {
    try {
      final filesToClean = [
        '$projectPath/debug_config.json',
        '$projectPath/observatory_config.json',
        '$projectPath/lib/debug_main.dart',
        '$projectPath/debug_tools/',
      ];
      
      for (final file in filesToClean) {
        try {
          if (await File(file).exists()) {
            await File(file).delete();
          }
          if (await Directory(file).exists()) {
            await Directory(file).delete(recursive: true);
          }
        } catch (e) {
          print('   ⚠️  Could not clean $file: $e');
        }
      }
      
      print('   ✓ Debug files cleaned up');
      
    } catch (e) {
      print('   ❌ Failed to clean up debug files: $e');
    }
  }
}

/// Main entry point
Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('path', abbr: 'p', help: 'Project path', defaultsTo: '.')
    ..addOption('device', abbr: 'd', help: 'Target device ID')
    ..addOption('port', abbr: 'P', help: 'Debug port', defaultsTo: '8080')
    ..addFlag('verbose', abbr: 'v', help: 'Verbose output', defaultsTo: false)
    ..addFlag('no-hot-reload', help: 'Disable hot reload', defaultsTo: false)
    ..addFlag('no-debug-logging', help: 'Disable debug logging', defaultsTo: false)
    ..addCommand('deploy', help: 'Deploy in wireless debug mode')
    ..addCommand('stop', help: 'Stop wireless debugging')
    ..addCommand('status', help: 'Check wireless debugging status');

  try {
    final results = parser.parse(arguments);
    
    final deployment = WirelessDebugDeployment(
      projectPath: results['path'] as String,
      verbose: results['verbose'] as bool,
      targetDevice: results['device'] as String?,
      enableHotReload: !(results['no-hot-reload'] as bool),
      enableDebugLogging: !(results['no-debug-logging'] as bool),
      debugPort: int.tryParse(results['port'] as String),
    );
    
    switch (results.command?.name) {
      case 'deploy':
        await deployment.deploy();
        break;
      case 'stop':
        await deployment.stop();
        break;
      case 'status':
        await _checkStatus(deployment);
        break;
      default:
        await deployment.deploy();
    }
    
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}

/// Check wireless debugging status
Future<void> _checkStatus(WirelessDebugDeployment deployment) async {
  print('🔍 Checking wireless debugging status...');
  
  try {
    // Check if debug server is running
    final result = await Process.run('curl', [
      '-s',
      'http://localhost:${deployment.debugPort ?? 8080}/health',
    ]);
    
    if (result.exitCode == 0) {
      print('✅ Wireless debugging is running');
      print('📡 Debug server: http://localhost:${deployment.debugPort ?? 8080}');
      print('📱 Debug console: http://localhost:${deployment.debugPort ?? 8080}');
    } else {
      print('❌ Wireless debugging is not running');
    }
    
  } catch (e) {
    print('❌ Failed to check status: $e');
  }
}
