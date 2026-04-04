#!/usr/bin/env dart

/// Project Cleanup and Fix Script
/// This script will:
/// 1. Remove duplicate files
/// 2. Fix hardcoded URLs
/// 3. Remove TODO/FIXME comments
/// 4. Remove print statements
/// 5. Organize file structure
/// 6. Fix import issues

import 'dart:io';
import 'dart:convert';

class ProjectCleaner {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = '$projectRoot\\lib';
  
  final List<String> filesToRemove = [];
  final List<String> filesToFix = [];
  final Map<String, String> fileFixes = {};
  
  Future<void> cleanupProject() async {
    print('🧹 Cleaning up VedantaTrade project...');
    
    try {
      // 1. Remove duplicate files
      await _removeDuplicateFiles();
      
      // 2. Fix hardcoded URLs
      await _fixHardcodedUrls();
      
      // 3. Remove TODO/FIXME comments
      await _removeTodoComments();
      
      // 4. Remove print statements
      await _removePrintStatements();
      
      // 5. Organize file structure
      await _organizeFileStructure();
      
      // 6. Generate cleanup report
      await _generateCleanupReport();
      
      print('✅ Project cleanup completed successfully!');
      
    } catch (e) {
      print('❌ Error cleaning project: $e');
      exit(1);
    }
  }

  Future<void> _removeDuplicateFiles() async {
    print('\n🗑️  Removing duplicate files...');
    
    // Define which files to keep (keep the ones in better locations)
    final filesToKeep = {
      'distribution.dart': 'lib/features/distribution/distribution.dart',
      'marketing_provider.dart': 'lib/features/distribution/presentation/providers/marketing_provider.dart',
      'inventory_management_screen.dart': 'lib/features/distribution/presentation/screens/inventory_management_screen.dart',
      'app_gallery_screen.dart': 'lib/features/gallery/presentation/screens/app_gallery_screen.dart',
      'gallery_screen.dart': 'lib/features/gallery/presentation/screens/gallery_screen.dart',
      'gallery_provider.dart': 'lib/features/gallery/presentation/providers/gallery_provider.dart',
      'gallery_carousel.dart': 'lib/features/gallery/presentation/widgets/gallery_carousel.dart',
      'order_provider.dart': 'lib/features/orders/presentation/providers/order_provider.dart',
      'checkout_screen.dart': 'lib/features/orders/presentation/screens/checkout_screen.dart',
      'profile_screen.dart': 'lib/features/profile/presentation/screens/profile_screen.dart',
      'order_management_screen.dart': 'lib/features/orders/presentation/screens/order_management_screen.dart',
      'stockist_dashboard.dart': 'lib/features/stockist/presentation/screens/stockist_dashboard.dart',
      'enhanced_navigation.dart': 'lib/shared/widgets/common/enhanced_navigation_widget.dart',
      'micro_interactions.dart': 'lib/shared/widgets/common/micro_interactions.dart',
      'custom_button.dart': 'lib/shared/widgets/common/glassmorphic_button.dart',
    };
    
    final libDir = Directory(libPath);
    final fileMap = <String, List<String>>{};
    
    // Group files by name
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final fileName = file.path.split('\\').last;
        
        if (!fileMap.containsKey(fileName)) {
          fileMap[fileName] = [];
        }
        fileMap[fileName]!.add(file.path);
      }
    }
    
    // Remove duplicates, keeping the preferred one
    for (final entry in fileMap.entries) {
      if (entry.value.length > 1) {
        final fileName = entry.key;
        final duplicates = entry.value;
        
        if (filesToKeep.containsKey(fileName)) {
          final keepPath = filesToKeep[fileName]!;
          
          for (final duplicate in duplicates) {
            if (duplicate != keepPath) {
              try {
                await File(duplicate).delete();
                print('    ✅ Removed duplicate: $duplicate');
                filesToRemove.add(duplicate);
              } catch (e) {
                print('    ❌ Failed to remove: $duplicate - $e');
              }
            }
          }
        }
      }
    }
  }

  Future<void> _fixHardcodedUrls() async {
    print('\n🔧 Fixing hardcoded URLs...');
    
    final libDir = Directory(libPath);
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        var modifiedContent = content;
        bool modified = false;
        
        // Replace hardcoded URLs with constants
        if (content.contains('https://api.vedantatrade.com.np')) {
          modifiedContent = modifiedContent.replaceAll(
            'https://api.vedantatrade.com.np',
            'AppConstants.apiBaseUrl',
          );
          modified = true;
        }
        
        if (content.contains('http://localhost')) {
          modifiedContent = modifiedContent.replaceAll(
            RegExp(r'http://localhost:\d+'),
            'AppConstants.localApiUrl',
          );
          modified = true;
        }
        
        if (modified) {
          // Add import if not present
          if (!modifiedContent.contains('import \'package:vedanta_trade/')) {
            final firstImportIndex = modifiedContent.indexOf('import ');
            if (firstImportIndex != -1) {
              modifiedContent = modifiedContent.replaceFirst(
                'import ',
                "import 'package:vedanta_trade/core/constants/app_constants.dart';\nimport ",
              );
            }
          }
          
          await file.writeAsString(modifiedContent);
          print('    ✅ Fixed hardcoded URLs in: ${file.path}');
          filesToFix.add(file.path);
          fileFixes[file.path] = 'Fixed hardcoded URLs';
        }
      }
    }
  }

  Future<void> _removeTodoComments() async {
    print('\n📝 Removing TODO/FIXME comments...');
    
    final libDir = Directory(libPath);
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        var modifiedContent = content;
        bool modified = false;
        
        // Remove TODO and FIXME comments
        modifiedContent = modifiedContent.replaceAll(RegExp(r'// TODO:.*'), '');
        modifiedContent = modifiedContent.replaceAll(RegExp(r'// FIXME:.*'), '');
        modifiedContent = modifiedContent.replaceAll(RegExp(r'// TODO.*'), '');
        modifiedContent = modifiedContent.replaceAll(RegExp(r'// FIXME.*'), '');
        modifiedContent = modifiedContent.replaceAll(RegExp(r'/\* TODO:.*?\*/'), '');
        modifiedContent = modifiedContent.replaceAll(RegExp(r'/\* FIXME:.*?\*/'), '');
        
        // Clean up extra empty lines
        modifiedContent = modifiedContent.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
        
        if (modifiedContent != content) {
          await file.writeAsString(modifiedContent);
          print('    ✅ Removed TODO/FIXME comments from: ${file.path}');
          filesToFix.add(file.path);
          fileFixes[file.path] = 'Removed TODO/FIXME comments';
        }
      }
    }
  }

  Future<void> _removePrintStatements() async {
    print('\n🖨️  Removing print statements...');
    
    final libDir = Directory(libPath);
    
    for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        var modifiedContent = content;
        bool modified = false;
        
        // Remove print statements (except in main.dart)
        if (!file.path.contains('main.dart')) {
          modifiedContent = modifiedContent.replaceAll(RegExp(r'print\(.*\);'), '');
          modifiedContent = modifiedContent.replaceAll(RegExp(r'debugPrint\(.*\);'), '');
        }
        
        // Clean up extra empty lines
        modifiedContent = modifiedContent.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
        
        if (modifiedContent != content) {
          await file.writeAsString(modifiedContent);
          print('    ✅ Removed print statements from: ${file.path}');
          filesToFix.add(file.path);
          fileFixes[file.path] = 'Removed print statements';
        }
      }
    }
  }

  Future<void> _organizeFileStructure() async {
    print('\n📁 Organizing file structure...');
    
    // Create missing directories
    final directoriesToCreate = [
      'lib/core/network',
      'lib/core/security',
      'lib/core/storage',
      'lib/shared/services',
      'lib/shared/providers',
      'lib/features/auth/data/models',
      'lib/features/auth/data/services',
      'lib/features/auth/data/repositories',
      'lib/features/auth/domain/entities',
      'lib/features/auth/domain/repositories',
      'lib/features/auth/domain/usecases',
      'lib/features/auth/presentation/pages',
      'lib/features/auth/presentation/widgets',
      'lib/features/auth/presentation/providers',
      'lib/features/auth/presentation/routes',
    ];
    
    for (final dirPath in directoriesToCreate) {
      final dir = Directory('$projectRoot\\$dirPath');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        print('    ✅ Created directory: $dirPath');
      }
    }
    
    // Move files to proper locations
    await _moveFilesToProperLocations();
  }

  Future<void> _moveFilesToProperLocations() async {
    final fileMoves = {
      // Move auth files to proper structure
      'lib/features/auth/data/models/auth_user_model.dart': 'lib/features/auth/data/models/auth_user_model.dart',
      'lib/features/auth/data/services/auth_service.dart': 'lib/features/auth/data/services/auth_service.dart',
      'lib/features/auth/presentation/providers/auth_provider.dart': 'lib/features/auth/presentation/providers/auth_provider.dart',
      'lib/features/auth/presentation/screens/login_screen.dart': 'lib/features/auth/presentation/pages/login_screen.dart',
      'lib/features/auth/presentation/screens/register_screen.dart': 'lib/features/auth/presentation/pages/register_screen.dart',
      
      // Move distribution files
      'lib/features/distribution/data/models/distribution_models.dart': 'lib/features/distribution/data/models/distribution_models.dart',
      'lib/features/distribution/data/services/distribution_service.dart': 'lib/features/distribution/data/services/distribution_service.dart',
      'lib/features/distribution/presentation/providers/distribution_provider.dart': 'lib/features/distribution/presentation/providers/distribution_provider.dart',
      
      // Move shared files
      'lib/core/api_config.dart': 'lib/core/network/api_config.dart',
      'lib/core/services/api_service.dart': 'lib/core/network/api_service.dart',
      'lib/shared/ui/components/': 'lib/shared/widgets/',
    };
    
    for (final entry in fileMoves.entries) {
      final sourcePath = entry.key;
      final targetPath = entry.value;
      
      final sourceFile = File('$projectRoot\\$sourcePath');
      if (await sourceFile.exists()) {
        final targetFile = File('$projectRoot\\$targetPath');
        final targetDir = targetFile.parent;
        
        // Create target directory if it doesn't exist
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
        }
        
        try {
          await sourceFile.rename(targetFile.path);
          print('    ✅ Moved: $sourcePath -> $targetPath');
        } catch (e) {
          print('    ❌ Failed to move: $sourcePath - $e');
        }
      }
    }
  }

  Future<void> _generateCleanupReport() async {
    print('\n📊 Generating cleanup report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': {
        'filesRemoved': filesToRemove.length,
        'filesFixed': filesToFix.length,
        'totalChanges': filesToRemove.length + filesToFix.length,
      },
      'filesRemoved': filesToRemove,
      'filesFixed': filesToFix,
      'fileFixes': fileFixes,
    };
    
    final reportPath = '$projectRoot\\docs\\project_cleanup_report.json';
    await File(reportPath).writeAsString(jsonEncode(report));
    
    print('  📄 Report saved to: docs/project_cleanup_report.json');
    
    // Print summary
    print('\n📊 Cleanup Summary:');
    print('  Files removed: ${filesToRemove.length}');
    print('  Files fixed: ${filesToFix.length}');
    print('  Total changes: ${filesToRemove.length + filesToFix.length}');
  }
}

void main() async {
  final cleaner = ProjectCleaner();
  await cleaner.cleanupProject();
}
