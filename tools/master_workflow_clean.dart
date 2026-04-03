import 'dart:io';
import 'package:process_run/process_run.dart';

/// Development workflow automation for VedantaTrade project
class MasterWorkflow {
  static String get projectRoot => Directory.current.path;

  /// Check development environment
  static Future<void> checkEnvironment() async {
    print('🔍 Checking development environment...');
    
    // Check Flutter installation
    try {
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode == 0) {
        print('  ✅ Flutter ${flutterResult.stdout.trim()}');
      } else {
        print('  ❌ Flutter not found');
        return;
      }
    } catch (e) {
      print('  ❌ Error checking Flutter: $e');
      return;
    }
    
    // Check Node.js (for backend)
    try {
      final nodeResult = await Process.run('node', ['--version']);
      if (nodeResult.exitCode == 0) {
        print('  ✅ Node.js ${nodeResult.stdout.trim()}');
      } else {
        print('  ⚠️  Node.js not found (needed for backend)');
      }
    } catch (e) {
      print('  ⚠️  Error checking Node.js: $e');
    }
    
    print('');
  }

  /// Show project status
  static Future<void> showProjectStatus() async {
    print('📊 VedantaTrade Project Status');
    print('=' * 40);
    
    // Check if we're in the right directory
    if (!File('pubspec.yaml').existsSync()) {
      print('❌ Not in Flutter project directory');
      return;
    }
    
    print('✅ Flutter project detected');
    print('📁 Project root: $projectRoot');
    
    // Check backend directory
    final backendDir = Directory('$projectRoot/backend');
    if (backendDir.existsSync()) {
      print('✅ Backend directory found');
    } else {
      print('⚠️  Backend directory not found');
    }
    
    print('');
  }

  /// Show help information
  static void showHelp() {
    print('🚀 VedantaTrade Development Workflow');
    print('=' * 40);
    print('');
    print('Available commands:');
    print('  check     - Check development environment');
    print('  status    - Show project status');
    print('  setup     - Setup development environment');
    print('  analyze    - Run code analysis');
    print('  test      - Run tests');
    print('  build     - Build for production');
    print('  clean     - Clean build artifacts');
    print('  help      - Show this help message');
    print('');
    print('Examples:');
    print('  dart tools/master_workflow.dart check');
    print('  dart tools/master_workflow.dart setup');
    print('  dart tools/master_workflow.dart analyze');
    print('');
  }

  /// Setup development environment
  static Future<void> setupEnvironment() async {
    print('🔧 Setting up development environment...');
    
    await checkEnvironment();
    
    // Get Flutter dependencies
    print('📦 Getting Flutter dependencies...');
    final flutterResult = await Process.run('flutter', ['pub', 'get']);
    if (flutterResult.exitCode == 0) {
      print('✅ Flutter dependencies installed');
    } else {
      print('❌ Failed to install Flutter dependencies');
      print(flutterResult.stderr);
    }
    
    print('');
  }

  /// Run code analysis
  static Future<void> runCodeAnalysis() async {
    print('🔬 Running code analysis...');
    
    final result = await Process.run('flutter', ['analyze']);
    if (result.exitCode == 0) {
      print('✅ Code analysis passed');
    } else {
      print('⚠️  Code analysis found issues:');
      print(result.stdout);
    }
    
    print('');
  }

  /// Run tests
  static Future<void> runTests() async {
    print('🧪 Running tests...');
    
    final result = await Process.run('flutter', ['test']);
    if (result.exitCode == 0) {
      print('✅ All tests passed');
    } else {
      print('❌ Some tests failed');
      print(result.stderr);
    }
    
    print('');
  }

  /// Build for production
  static Future<void> buildProduction() async {
    print('🏗️  Building for production...');
    
    // Build APK
    print('Building Android APK...');
    final apkResult = await Process.run('flutter', ['build', 'apk', '--release']);
    if (apkResult.exitCode == 0) {
      print('✅ APK built successfully');
    } else {
      print('❌ APK build failed');
    }
    
    // Build App Bundle
    print('Building Android App Bundle...');
    final aabResult = await Process.run('flutter', ['build', 'appbundle', '--release']);
    if (aabResult.exitCode == 0) {
      print('✅ App Bundle built successfully');
    } else {
      print('❌ App Bundle build failed');
    }
    
    print('');
  }

  /// Clean build artifacts
  static Future<void> cleanBuilds() async {
    print('🧹 Cleaning build artifacts...');
    
    final result = await Process.run('flutter', ['clean']);
    if (result.exitCode == 0) {
      print('✅ Build artifacts cleaned');
    } else {
      print('❌ Failed to clean build artifacts');
    }
    
    print('');
  }

  /// Main entry point
  static Future<void> main(List<String> arguments) async {
    if (arguments.isEmpty) {
      showHelp();
      return;
    }
    
    final command = arguments.first;
    
    switch (command.toLowerCase()) {
      case 'check':
        await checkEnvironment();
        break;
      case 'status':
        await showProjectStatus();
        break;
      case 'setup':
        await setupEnvironment();
        break;
      case 'analyze':
        await runCodeAnalysis();
        break;
      case 'test':
        await runTests();
        break;
      case 'build':
        await buildProduction();
        break;
      case 'clean':
        await cleanBuilds();
        break;
      case 'help':
        showHelp();
        break;
      default:
        print('❌ Unknown command: $command');
        print('Run "help" for available commands');
        print('');
    }
  }
}
