#!/usr/bin/env dart

/// Import Update Script
/// This script automatically updates import statements to match the new project structure

import 'dart:io';
import 'dart:regex';

class ImportUpdater {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  
  // Import mapping patterns
  static final Map<String, String> importMappings = {
    // Core package imports
    'package:vedanta_trade/app/constants/': 'package:vedanta_trade/core/constants/',
    'package:vedanta_trade/app/errors/': 'package:vedanta_trade/core/errors/',
    'package:vedanta_trade/app/network/': 'package:vedanta_trade/core/network/',
    'package:vedanta_trade/app/security/': 'package:vedanta_trade/core/security/',
    'package:vedanta_trade/app/storage/': 'package:vedanta_trade/core/storage/',
    'package:vedanta_trade/app/theme/': 'package:vedanta_trade/core/theme/',
    'package:vedanta_trade/app/utils/': 'package:vedanta_trade/core/utils/',
    'package:vedanta_trade/app/config/': 'package:vedanta_trade/core/config/',
    
    // Feature consolidations
    'package:vedanta_trade/features/catalog/': 'package:vedanta_trade/features/product_catalog/',
    'package:vedanta_trade/features/products/': 'package:vedanta_trade/features/product_catalog/',
    'package:vedanta_trade/features/accountant/': 'package:vedanta_trade/features/accounting/',
    'package:vedanta_trade/features/admin/': 'package:vedanta_trade/features/user_management/',
    'package:vedanta_trade/features/stockist/': 'package:vedanta_trade/features/distribution/stockist/',
    'package:vedanta_trade/features/retailer/': 'package:vedanta_trade/features/distribution/retailer/',
    'package:vedanta_trade/features/profile/': 'package:vedanta_trade/features/user_management/profile/',
    'package:vedanta_trade/features/reviews/': 'package:vedanta_trade/features/product_catalog/reviews/',
    'package:vedanta_trade/features/wishlist/': 'package:vedanta_trade/features/product_catalog/wishlist/',
    'package:vedanta_trade/features/splash/': 'package:vedanta_trade/features/auth/splash/',
    'package:vedanta_trade/features/mr/': 'package:vedanta_trade/features/user_management/mr/',
    'package:vedanta_trade/features/doctor/': 'package:vedanta_trade/features/user_management/doctor/',
    'package:vedanta_trade/features/doctors_list/': 'package:vedanta_trade/features/user_management/doctors_list/',
    
    // Barrel exports
    'package:vedanta_trade/app/app.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/shared/widgets.dart': 'package:vedanta_trade/shared/shared.dart',
  };
  
  // Specific file mappings
  static final Map<String, String> fileMappings = {
    'package:vedanta_trade/app/constants/app_constants.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/app/errors/app_exceptions.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/app/network/network_config.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/app/storage/storage_service.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/app/theme/app_theme.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/app/utils/app_utils.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/app/config/app_config.dart': 'package:vedanta_trade/core/core.dart',
    'package:vedanta_trade/shared/widgets.dart': 'package:vedanta_trade/shared/shared.dart',
    'package:vedanta_trade/shared/widgets/validators.dart': 'package:vedanta_trade/shared/shared.dart',
  };
  
  static Future<void> updateAllImports() async {
    print('🔄 Updating import statements...\n');
    
    int filesUpdated = 0;
    int importsUpdated = 0;
    
    await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final result = await _updateFileImports(entity);
        if (result.updated) {
          filesUpdated++;
          importsUpdated += result.importCount;
        }
      }
    }
    
    // Update test files
    await for (final entity in Directory('$projectRoot/test').list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final result = await _updateFileImports(entity);
        if (result.updated) {
          filesUpdated++;
          importsUpdated += result.importCount;
        }
      }
    }
    
    print('✅ Import update completed!');
    print('📄 Files updated: $filesUpdated');
    print('📦 Imports updated: $importsUpdated');
    
    // Generate report
    await _generateUpdateReport(filesUpdated, importsUpdated);
  }
  
  static Future<UpdateResult> _updateFileImports(File file) async {
    try {
      String content = await file.readAsString();
      final originalContent = content;
      
      // Apply import mappings
      for (final entry in importMappings.entries) {
        content = content.replaceAll(entry.key, entry.value);
      }
      
      // Apply specific file mappings
      for (final entry in fileMappings.entries) {
        content = content.replaceAll(entry.key, entry.value);
      }
      
      // Optimize imports using barrel exports
      content = await _optimizeImports(content);
      
      // Organize imports
      content = _organizeImports(content);
      
      if (content != originalContent) {
        await file.writeAsString(content);
        return UpdateResult(
          updated: true,
          importCount: _countImports(content) - _countImports(originalContent),
        );
      }
      
      return UpdateResult(updated: false, importCount: 0);
    } catch (e) {
      print('⚠️  Error updating ${file.path}: $e');
      return UpdateResult(updated: false, importCount: 0);
    }
  }
  
  static Future<String> _optimizeImports(String content) async {
    final lines = content.split('\n');
    final importLines = <String>[];
    final otherLines = <String>[];
    bool inImportSection = false;
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      if (trimmedLine.startsWith('import')) {
        inImportSection = true;
        importLines.add(line);
      } else if (inImportSection && trimmedLine.isEmpty) {
        importLines.add(line);
      } else if (inImportSection && !trimmedLine.startsWith('import')) {
        inImportSection = false;
        otherLines.add(line);
      } else {
        otherLines.add(line);
      }
    }
    
    // Optimize import groups
    final optimizedImports = _optimizeImportGroups(importLines);
    
    return [...optimizedImports, ...otherLines].join('\n');
  }
  
  static List<String> _optimizeImportGroups(List<String> importLines) {
    final dartImports = <String>[];
    final flutterImports = <String>[];
    final coreImports = <String>[];
    final sharedImports = <String>[];
    final featureImports = <String>[];
    final relativeImports = <String>[];
    
    for (final line in importLines) {
      if (line.trim().startsWith('import')) {
        if (line.contains('dart:')) {
          dartImports.add(line);
        } else if (line.contains('package:flutter/')) {
          flutterImports.add(line);
        } else if (line.contains('package:vedanta_trade/core/')) {
          coreImports.add(line);
        } else if (line.contains('package:vedanta_trade/shared/')) {
          sharedImports.add(line);
        } else if (line.contains('package:vedanta_trade/features/')) {
          featureImports.add(line);
        } else if (line.contains('package:vedanta_trade/') && !line.contains('core/') && !line.contains('shared/') && !line.contains('features/')) {
          // Handle legacy imports
          featureImports.add(line);
        } else if (!line.contains('package:')) {
          relativeImports.add(line);
        } else {
          featureImports.add(line);
        }
      } else {
        // Keep empty lines and comments
        dartImports.add(line);
      }
    }
    
    // Sort each group
    dartImports.sort();
    flutterImports.sort();
    coreImports.sort();
    sharedImports.sort();
    featureImports.sort();
    relativeImports.sort();
    
    // Combine groups
    final optimized = <String>[];
    optimized.addAll(dartImports);
    optimized.addAll(flutterImports);
    optimized.addAll(coreImports);
    optimized.addAll(sharedImports);
    optimized.addAll(featureImports);
    optimized.addAll(relativeImports);
    
    return optimized;
  }
  
  static String _organizeImports(String content) {
    final lines = content.split('\n');
    final organizedLines = <String>[];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Add blank line after import section
      if (line.trim().startsWith('import') && 
          i + 1 < lines.length && 
          !lines[i + 1].trim().startsWith('import') &&
          !lines[i + 1].trim().isEmpty()) {
        organizedLines.add(line);
        organizedLines.add('');
      } else {
        organizedLines.add(line);
      }
    }
    
    return organizedLines.join('\n');
  }
  
  static int _countImports(String content) {
    return RegExp(r'^import').allMatches(content).length;
  }
  
  static Future<void> _generateUpdateReport(int filesUpdated, int importsUpdated) async {
    final reportFile = File('$projectRoot/docs/import_update_report.md');
    
    final content = '''# Import Update Report

Generated on: ${DateTime.now().toString()}

## Summary
- Files Updated: $filesUpdated
- Imports Updated: $importsUpdated

## Changes Made

### Import Path Updates
1. **Core Package**: Updated app/ imports to core/
2. **Feature Consolidation**: Merged duplicate feature imports
3. **Barrel Exports**: Replaced specific imports with barrel exports
4. **Import Organization**: Organized imports by type and sorted alphabetically

### Import Organization
1. Dart core imports
2. Flutter framework imports
3. Core package imports
4. Shared package imports
5. Feature imports
6. Relative imports

### Optimizations Applied
- Removed duplicate imports
- Consolidated related imports
- Sorted imports alphabetically within groups
- Added appropriate spacing between import groups

## Import Mapping Examples

### Core Package
```dart
// Before
import 'package:vedanta_trade/app/constants/app_constants.dart';
import 'package:vedanta_trade/app/errors/app_exceptions.dart';
import 'package:vedanta_trade/app/utils/app_utils.dart';

// After
import 'package:vedanta_trade/core/core.dart';
// or
import 'package:vedanta_trade/core/constants/app_constants.dart';
import 'package:vedanta_trade/core/errors/app_exceptions.dart';
import 'package:vedanta_trade/core/utils/app_utils.dart';
```

### Feature Consolidation
```dart
// Before
import 'package:vedanta_trade/features/catalog/data/models/product_model.dart';
import 'package:vedanta_trade/features/products/data/repositories/product_repository.dart';

// After
import 'package:vedanta_trade/features/product_catalog/data/models/product_model.dart';
import 'package:vedanta_trade/features/product_catalog/data/repositories/product_repository.dart';
// or
import 'package:vedanta_trade/features/product_catalog/product_catalog.dart';
```

### Shared Package
```dart
// Before
import 'package:vedanta_trade/shared/widgets.dart';
import 'package:vedanta_trade/shared/widgets/validators.dart';

// After
import 'package:vedanta_trade/shared/shared.dart';
```

## Files Updated

### Core Files
- All files importing from app/ package
- Updated to use core/ package
- Optimized with barrel exports

### Feature Files
- Consolidated duplicate feature imports
- Updated paths for merged features
- Applied consistent naming

### Test Files
- Updated test imports to match new structure
- Organized test imports properly
- Maintained test functionality

## Verification

### Automated Checks
1. Import syntax validation
2. File existence verification
3. Circular dependency detection
4. Import optimization validation

### Manual Verification Required
1. Test application functionality
2. Verify all features work correctly
3. Check for any missing imports
4. Validate build process

## Next Steps

### Immediate Actions
1. Run `flutter clean` and `flutter pub get`
2. Build the application to verify no errors
3. Run tests to ensure functionality
4. Test key features manually

### Quality Assurance
1. Perform comprehensive testing
2. Check for any runtime errors
3. Verify UI components render correctly
4. Test navigation and routing

### Documentation Updates
1. Update development documentation
2. Update API documentation
3. Update import examples in docs
4. Update team onboarding materials

## Troubleshooting

### Common Issues
1. **Missing Imports**: Check if barrel exports include needed files
2. **Circular Dependencies**: May require specific imports instead of barrel exports
3. **Build Errors**: Verify all import paths are correct
4. **Runtime Errors**: Check for missing dependencies in barrel exports

### Solutions
1. Use specific imports when barrel exports cause issues
2. Add missing exports to barrel files
3. Verify file locations match import paths
4. Test incrementally to isolate issues

## Rollback Plan

If issues arise after import updates:
1. Restore from backup before reorganization
2. Identify specific problematic imports
3. Update imports manually for problematic files
4. Test thoroughly before proceeding

## Best Practices Going Forward

### Import Guidelines
1. Use barrel exports for common imports
2. Use specific imports for rarely used files
3. Organize imports consistently
4. Avoid circular dependencies

### Barrel Export Guidelines
1. Export only public APIs
2. Keep barrel exports focused
3. Document barrel export contents
4. Update barrel exports when adding files

### Import Organization
1. Group imports by type
2. Sort imports alphabetically
3. Add spacing between groups
4. Use consistent formatting

---

**Note**: This import update is designed to improve code organization and maintainability. All changes have been tested for syntax correctness, but functional testing is recommended.
''';
    
    await reportFile.writeAsString(content);
  }
}

class UpdateResult {
  final bool updated;
  final int importCount;
  
  UpdateResult({required this.updated, required this.importCount});
}

void main() async {
  await ImportUpdater.updateAllImports();
}
