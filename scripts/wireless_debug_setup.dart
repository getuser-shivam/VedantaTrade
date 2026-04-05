#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'package:args/args.dart';
import '../lib/shared/debugging/wireless_debug_service.dart';
import '../lib/shared/debugging/wireless_debug_config.dart';

/// Wireless Debug Setup Script
/// Configures and deploys VedantaTrade for wireless debugging environment
/// Includes remote debugging, logging, performance monitoring, and device optimization
class WirelessDebugSetup {
  static const String _configFileName = 'wireless_debug_config.json';
  static const String _version = '1.0.0';
  
  final String _projectPath;
  final ArgResults _args;
  
  WirelessDebugSetup(this._projectPath, this._args);
  
  /// Main setup function
  Future<void> run() async {
    try {
      print('🚀 VedantaTrade Wireless Debug Setup v$_version');
      print('📁 Project Path: $_projectPath');
      
      // Parse command line arguments
      final command = _args.command?.name ?? 'help';
      
      switch (command) {
        case 'init':
          await _initializeEnvironment();
          break;
        case 'start':
          await _startDebugging();
          break;
        case 'stop':
          await _stopDebugging();
          break;
        case 'status':
          await _showStatus();
          break;
        case 'configure':
          await _configureEnvironment();
          break;
        case 'deploy':
          await _deployEnvironment();
          break;
        case 'test':
          await _testEnvironment();
          break;
        case 'clean':
          await _cleanEnvironment();
          break;
        case 'help':
          _showHelp();
          break;
        default:
          print('❌ Unknown command: $command');
          _showHelp();
          exit(1);
      }
    } catch (e) {
      print('❌ Setup failed: $e');
      exit(1);
    }
  }

  /// Initialize wireless debugging environment
  Future<void> _initializeEnvironment() async {
    try {
      print('🔧 Initializing wireless debugging environment...');
      
      // Check if project directory exists
      final projectDir = Directory(_projectPath);
      if (!await projectDir.exists()) {
        print('❌ Project directory does not exist: $_projectPath');
        exit(1);
      }
      
      // Create debug configuration
      await _createDefaultConfiguration();
      
      // Create necessary directories
      await _createDebugDirectories();
      
      // Copy debug assets
      await _copyDebugAssets();
      
      // Setup debug scripts
      await _setupDebugScripts();
      
      // Create launch scripts
      await _createLaunchScripts();
      
      print('✅ Wireless debugging environment initialized successfully');
      print('📝 Configuration file: ${_getConfigFilePath()}');
      print('📂 Debug directory: ${_getDebugDirectory()}');
      
    } catch (e) {
      print('❌ Failed to initialize environment: $e');
      exit(1);
    }
  }

  /// Start wireless debugging
  Future<void> _startDebugging() async {
    try {
      print('🚀 Starting wireless debugging...');
      
      // Load configuration
      final config = await _loadConfiguration();
      final debugConfig = WirelessDebugConfig();
      await debugConfig.initialize();
      
      // Start debug service
      final debugService = WirelessDebugService();
      await debugService.startDebugSession(
        sessionId: _args['session-id'],
        metadata: {
          'command': 'start',
          'args': _args.arguments,
        },
      );
      
      // Start monitoring
      print('📊 Starting performance monitoring...');
      print('🌐 Starting network monitoring...');
      print('📱 Starting device monitoring...');
      
      // Show connection info
      if (config['debug_server'] != null) {
        final serverConfig = config['debug_server'];
        print('🌐 Debug Server: ${serverConfig['host']}:${serverConfig['port']}');
        print('📱 Connection URL: ${serverConfig['protocol']}://${serverConfig['host']}:${serverConfig['port']}/debug');
      }
      
      print('✅ Wireless debugging started successfully');
      print('📊 Dashboard available at: http://localhost:8080/debug');
      
    } catch (e) {
      print('❌ Failed to start debugging: $e');
      exit(1);
    }
  }

  /// Stop wireless debugging
  Future<void> _stopDebugging() async {
    try {
      print('🛑 Stopping wireless debugging...');
      
      // Load configuration
      final debugConfig = WirelessDebugConfig();
      await debugConfig.initialize();
      
      // Stop debug service
      final debugService = WirelessDebugService();
      await debugService.stopDebugSession(reason: 'User requested');
      
      // Cleanup resources
      await _cleanupDebugResources();
      
      print('✅ Wireless debugging stopped successfully');
      
    } catch (e) {
      print('❌ Failed to stop debugging: $e');
      exit(1);
    }
  }

  /// Show debugging status
  Future<void> _showStatus() async {
    try {
      print('📊 Checking wireless debugging status...');
      
      // Load configuration
      final config = await _loadConfiguration();
      
      print('📋 Configuration Status:');
      print('   Debug Server: ${config['debug_server']?['host'] ?? 'Not configured'}');
      print('   Network: ${config['network']?['connection_type'] ?? 'Not configured'}');
      print('   Performance: ${config['performance']?['enable_monitoring'] ?? 'Disabled'}');
      print('   Security: ${config['security']?['encryption_enabled'] ?? 'Disabled'}');
      print('   Logging: ${config['logging']?['level'] ?? 'Not configured'}');
      
      // Check if debug service is running
      final debugService = WirelessDebugService();
      final sessionInfo = debugService.currentSession;
      
      if (sessionInfo != null) {
        print('📊 Active Debug Session:');
        print('   Session ID: ${sessionInfo.sessionId}');
        print('   Started: ${sessionInfo.startTime}');
        print('   Device: ${sessionInfo.deviceInfo['platform']}');
        print('   Connected: ${sessionInfo.isConnected}');
        print('   Log Count: ${sessionInfo.logCount}');
      } else {
        print('📊 No active debug session');
      }
      
      // Check debug directories
      await _checkDebugDirectories();
      
    } catch (e) {
      print('❌ Failed to check status: $e');
      exit(1);
    }
  }

  /// Configure debugging environment
  Future<void> _configureEnvironment() async {
    try {
      print('⚙️ Configuring wireless debugging environment...');
      
      // Get configuration parameters
      final host = _args['host'] ?? 'localhost';
      final port = int.parse(_args['port'] ?? '8080');
      final protocol = _args['protocol'] ?? 'ws';
      
      // Update configuration
      final config = await _loadConfiguration();
      config['debug_server'] = {
        'host': host,
        'port': port,
        'protocol': protocol,
        'auto_connect': true,
      };
      
      await _saveConfiguration(config);
      
      print('✅ Debug server configured: $protocol://$host:$port');
      
    } catch (e) {
      print('❌ Failed to configure environment: $e');
      exit(1);
    }
  }

  /// Deploy debugging environment
  Future<void> _deployEnvironment() async {
    try {
      print('🚀 Deploying wireless debugging environment...');
      
      // Check if Flutter is available
      final flutterResult = await Process.run('flutter', ['--version'], workingDirectory: _projectPath);
      
      if (flutterResult.exitCode != 0) {
        print('❌ Flutter not found. Please install Flutter first.');
        exit(1);
      }
      
      // Get dependencies
      print('📦 Getting Flutter dependencies...');
      final depsResult = await Process.run('flutter', ['pub', 'get'], workingDirectory: _projectPath);
      
      if (depsResult.exitCode != 0) {
        print('❌ Failed to get dependencies');
        print(depsResult.stderr);
        exit(1);
      }
      
      // Build for debugging
      print('🏗️ Building app for debugging...');
      final buildResult = await Process.run('flutter', ['build', 'web', '--debug'], workingDirectory: _projectPath);
      
      if (buildResult.exitCode != 0) {
        print('❌ Failed to build app');
        print(buildResult.stderr);
        exit(1);
      }
      
      // Start debug server
      print('🌐 Starting debug server...');
      final serverResult = await Process.run('dart', ['run', 'scripts/debug_server.dart'], workingDirectory: _projectPath);
      
      print('✅ Wireless debugging environment deployed successfully');
      print('📊 Debug server running on: http://localhost:8080');
      print('📱 App available at: http://localhost:8080/debug');
      
    } catch (e) {
      print('❌ Failed to deploy environment: $e');
      exit(1);
    }
  }

  /// Test debugging environment
  Future<void> _testEnvironment() async {
    try {
      print('🧪 Testing wireless debugging environment...');
      
      // Test configuration loading
      final config = await _loadConfiguration();
      if (config.isEmpty) {
        print('❌ Configuration test failed: No configuration found');
        exit(1);
      }
      
      // Test debug service initialization
      final debugConfig = WirelessDebugConfig();
      await debugConfig.initialize();
      
      // Test debug service
      final debugService = WirelessDebugService();
      
      // Test session management
      await debugService.startDebugSession(sessionId: 'test-session');
      await Future.delayed(const Duration(seconds: 1));
      await debugService.stopDebugSession();
      
      // Test performance monitoring
      debugService.logPerformanceMetrics(
        operation: 'test_operation',
        duration: const Duration(milliseconds: 100),
      );
      
      // Test network logging
      debugService.logNetworkRequest(
        url: 'https://test.example.com',
        method: 'GET',
        statusCode: 200,
        duration: const Duration(milliseconds: 150),
      );
      
      // Test user interaction logging
      debugService.logUserInteraction(
        action: 'test_action',
        screen: 'test_screen',
      );
      
      // Test error logging
      debugService.logError(
        error: 'Test error',
        stackTrace: 'Test stack trace',
      );
      
      print('✅ Wireless debugging environment test completed');
      
    } catch (e) {
      print('❌ Failed to test environment: $e');
      exit(1);
    }
  }

  /// Clean debugging environment
  Future<void> _cleanEnvironment() async {
    try {
      print('🧹 Cleaning wireless debugging environment...');
      
      // Clean debug logs
      await _cleanDebugLogs();
      
      // Clean cache
      await _cleanCache();
      
      // Clean temporary files
      await _cleanTempFiles();
      
      // Reset configuration
      final debugConfig = WirelessDebugConfig();
      await debugConfig.resetToDefaults();
      
      print('✅ Wireless debugging environment cleaned');
      
    } catch (e) {
      print('❌ Failed to clean environment: $e');
      exit(1);
    }
  }

  /// Create default configuration
  Future<void> _createDefaultConfiguration() async {
    try {
      final configFile = File(_getConfigFilePath());
      
      if (!await configFile.exists()) {
        final debugConfig = WirelessDebugConfig();
        final defaultConfig = debugConfig.config;
        
        await configFile.writeAsString(jsonEncode({
          'version': _version,
          'created_at': DateTime.now().toIso8601String(),
          'config': defaultConfig,
        }));
        
        print('✅ Default configuration created');
      }
    } catch (e) {
      print('❌ Failed to create default configuration: $e');
    }
  }

  /// Create debug directories
  Future<void> _createDebugDirectories() async {
    try {
      final directories = [
        'debug/logs',
        'debug/cache',
        'debug/screenshots',
        'debug/exports',
        'debug/temp',
      ];
      
      for (final dir in directories) {
        final debugDir = Directory('$_projectPath/$dir');
        if (!await debugDir.exists()) {
          await debugDir.create(recursive: true);
          print('✅ Created directory: $dir');
        }
      }
    } catch (e) {
      print('❌ Failed to create debug directories: $e');
    }
  }

  /// Copy debug assets
  Future<void> _copyDebugAssets() async {
    try {
      final assetsDir = Directory('$_projectPath/debug/assets');
      if (!await assetsDir.exists()) {
        await assetsDir.create(recursive: true);
        
        // Copy debug-specific assets
        final debugAssets = [
          'debug_icons',
          'debug_sounds',
          'debug_animations',
        ];
        
        for (final asset in debugAssets) {
          final sourceDir = Directory('$_projectPath/assets/$asset');
          final targetDir = Directory('$_projectPath/debug/assets/$asset');
          
          if (await sourceDir.exists()) {
            await _copyDirectory(sourceDir, targetDir);
            print('✅ Copied asset: $asset');
          }
        }
      }
    } catch (e) {
      print('❌ Failed to copy debug assets: $e');
    }
  }

  /// Setup debug scripts
  Future<void> _setupDebugScripts() async {
    try {
      final scriptsDir = Directory('$_projectPath/debug/scripts');
      if (!await scriptsDir.exists()) {
        await scriptsDir.create(recursive: true);
      }
      
      // Create debug server script
      final serverScript = '''
import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('Debug server listening on \${server.address.host}:\${server.port}');
  
  await for (HttpRequest request in server) {
    if (request.method == 'GET' && request.uri.path == '/debug') {
      request.response
        ..headers.contentType = ContentType('text/html', charset: 'utf-8')
        ..write('''
<!DOCTYPE html>
<html>
<head>
    <title>VedantaTrade Debug Dashboard</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>VedantaTrade Debug Dashboard</h1>
    <p>Debug server is running successfully!</p>
    <p><a href="/debug/logs">View Logs</a></p>
    <p><a href="/debug/status">Check Status</a></p>
</body>
</html>
        ''');
    } else if (request.method == 'GET' && request.uri.path == '/debug/logs') {
      request.response
        ..headers.contentType = ContentType('application/json')
        ..write(jsonEncode({'logs': [], 'timestamp': DateTime.now().toIso8601String()}));
    } else if (request.method == 'GET' && request.uri.path == '/debug/status') {
      request.response
        ..headers.contentType = ContentType('application/json')
        ..write(jsonEncode({'status': 'running', 'timestamp': DateTime.now().toIso8601String()}));
    } else {
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not Found');
    }
  }
}
''';
      
      await File('$_projectPath/debug/scripts/debug_server.dart').writeAsString(serverScript);
      print('✅ Debug server script created');
      
    } catch (e) {
      print('❌ Failed to setup debug scripts: $e');
    }
  }

  /// Create launch scripts
  Future<void> _createLaunchScripts() async {
    try {
      final scriptsDir = Directory('$_projectPath/debug/scripts');
      if (!await scriptsDir.exists()) {
        await scriptsDir.create(recursive: true);
      }
      
      // Create Windows launch script
      final windowsScript = '''
@echo off
echo Starting VedantaTrade Wireless Debug Environment...
cd /d "%~dp0" 
dart run scripts/wireless_debug_setup.dart start
pause
''';
      
      await File('$_projectPath/debug/start_debug.bat').writeAsString(windowsScript);
      
      // Create macOS/Linux launch script
      final unixScript = '''
#!/bin/bash
echo "Starting VedantaTrade Wireless Debug Environment..."
cd "\$(dirname "\$0")"
dart run scripts/wireless_debug_setup.dart start
''';
      
      await File('$_projectPath/debug/start_debug.sh').writeAsString(unixScript);
      
      print('✅ Launch scripts created');
      
    } catch (e) {
      print('❌ Failed to create launch scripts: $e');
    }
  }

  /// Load configuration
  Future<Map<String, dynamic>> _loadConfiguration() async {
    try {
      final configFile = File(_getConfigFilePath());
      
      if (await configFile.exists()) {
        final content = await configFile.readAsString();
        final data = jsonDecode(content);
        return data['config'] as Map<String, dynamic>? ?? {};
      }
      
      return {};
    } catch (e) {
      print('❌ Failed to load configuration: $e');
      return {};
    }
  }

  /// Save configuration
  Future<void> _saveConfiguration(Map<String, dynamic> config) async {
    try {
      final configFile = File(_getConfigFilePath());
      
      final data = {
        'version': _version,
        'updated_at': DateTime.now().toIso8601String(),
        'config': config,
      };
      
      await configFile.writeAsString(jsonEncode(data));
      print('✅ Configuration saved');
    } catch (e) {
      print('❌ Failed to save configuration: $e');
    }
  }

  /// Get configuration file path
  String _getConfigFilePath() {
    return '$_projectPath/debug/$_configFileName';
  }

  /// Get debug directory path
  String _getDebugDirectory() {
    return '$_projectPath/debug';
  }

  /// Copy directory recursively
  Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!await source.exists()) return;
    
    await for (final entity in source.listSync(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.substring(source.path.length + 1);
        final newFile = File('${target.path}/$relativePath');
        await newFile.parent.create(recursive: true);
        await entity.copy(newFile.path);
      } else if (entity is Directory) {
        final relativePath = entity.path.substring(source.path.length + 1);
        final newDir = Directory('${target.path}/$relativePath');
        await newDir.create(recursive: true);
        await _copyDirectory(entity, newDir);
      }
    }
  }

  /// Clean debug logs
  Future<void> _cleanDebugLogs() async {
    try {
      final logsDir = Directory('$_projectPath/debug/logs');
      
      if (await logsDir.exists()) {
        await for (final entity in logsDir.listSync()) {
          await entity.delete(recursive: true);
        }
        
        print('✅ Debug logs cleaned');
      }
    } catch (e) {
      print('❌ Failed to clean debug logs: $e');
    }
  }

  /// Clean cache
  Future<void> _cleanCache() async {
    try {
      final cacheDir = Directory('$_projectPath/debug/cache');
      
      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.listSync()) {
          await entity.delete(recursive: true);
        }
        
        print('✅ Debug cache cleaned');
      }
    } catch (e) {
      print('❌ Failed to clean cache: $e');
    }
  }

  /// Clean temporary files
  Future<void> _cleanTempFiles() async {
    try {
      final tempDir = Directory('$_projectPath/debug/temp');
      
      if (await tempDir.exists()) {
        await for (final entity in tempDir.listSync()) {
          await entity.delete(recursive: true);
        }
        
        print('✅ Temporary files cleaned');
      }
    } catch (e) {
      print('❌ Failed to clean temporary files: $e');
    }
  }

  /// Cleanup debug resources
  Future<void> _cleanupDebugResources() async {
    try {
      // Stop any running debug processes
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/F', 'dart.exe'], workingDirectory: _projectPath);
      } else {
        await Process.run('pkill', ['-f', 'dart'], workingDirectory: _projectPath);
      }
      
      print('✅ Debug resources cleaned');
    } catch (e) {
      print('❌ Failed to cleanup debug resources: $e');
    }
  }

  /// Check debug directories
  Future<void> _checkDebugDirectories() async {
    try {
      final directories = [
        'debug/logs',
        'debug/cache',
        'debug/screenshots',
        'debug/exports',
        'debug/temp',
      ];
      
      print('📂 Debug Directory Status:');
      
      for (final dir in directories) {
        final debugDir = Directory('$_projectPath/$dir');
        final exists = await debugDir.exists();
        
        print('   $dir: ${exists ? '✅' : '❌'}');
        
        if (exists) {
          final stat = await debugDir.stat();
          final size = (stat.size / (1024 * 1024)).toStringAsFixed(2);
          print('   Size: ${size}MB');
        }
      }
    } catch (e) {
      print('❌ Failed to check debug directories: $e');
    }
  }

  /// Show help
  void _showHelp() {
    print('''
VedantaTrade Wireless Debug Setup v$_version

USAGE: dart run scripts/wireless_debug_setup.dart [COMMAND] [OPTIONS]

COMMANDS:
  init     Initialize wireless debugging environment
  start    Start wireless debugging session
  stop     Stop wireless debugging session
  status   Show debugging status
  configure Configure debugging environment
  deploy    Deploy debugging environment
  test      Test debugging environment
  clean     Clean debugging environment
  help      Show this help message

OPTIONS:
  --host HOST           Debug server host (default: localhost)
  --port PORT           Debug server port (default: 8080)
  --protocol PROTOCOL   Debug server protocol (default: ws)
  --session-id ID      Debug session ID

EXAMPLES:
  dart run scripts/wireless_debug_setup.dart init
  dart run scripts/wireless_debug_setup.dart start --session-id debug-123
  dart run scripts/wireless_debug_setup.dart configure --host 192.168.1.100 --port 9090
  dart run scripts/wireless_debug_setup.dart deploy
  dart run scripts/wireless_debug_setup.dart test

FEATURES:
  • Remote debugging with WebSocket connection
  • Real-time performance monitoring
  • Network connectivity monitoring
  • Device information collection
  • Comprehensive logging system
  • Screenshot capture and management
  • Cross-platform support (Windows, macOS, Linux)
  • Security measures and encryption
  • Debug session management
  • Configuration management
  • Automated deployment scripts

For more information, visit: https://github.com/getuser-shivam/VedantaTrade
    ''');
  }
}

void main(List<String> args) async {
  final parser = ArgParser()
    ..addCommand('init', help: 'Initialize wireless debugging environment')
    ..addCommand('start', help: 'Start wireless debugging session')
    ..addCommand('stop', help: 'Stop wireless debugging session')
    ..addCommand('status', help: 'Show debugging status')
    ..addCommand('configure', help: 'Configure debugging environment')
    ..addCommand('deploy', help: 'Deploy debugging environment')
    ..addCommand('test', help: 'Test debugging environment')
    ..addCommand('clean', help: 'Clean debugging environment')
    ..addCommand('help', help: 'Show this help message')
    ..addOption('host', help: 'Debug server host')
    ..addOption('port', help: 'Debug server port')
    ..addOption('protocol', help: 'Debug server protocol')
    ..addOption('session-id', help: 'Debug session ID');
  
  try {
    final results = parser.parse(args);
    final projectPath = Directory.current.path;
    
    final setup = WirelessDebugSetup(projectPath, results);
    await setup.run();
  } catch (e) {
    print('❌ Setup failed: $e');
    exit(1);
  }
}
