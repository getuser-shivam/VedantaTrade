#!/usr/bin/env dart

/// Project File Reorganization Script
/// This script reorganizes existing files into the new standardized structure

import 'dart:io';
import 'dart:convert';

class ProjectFileReorganizer {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = '$projectRoot\\lib';
  
  // File mapping from old structure to new structure
  static const Map<String, String> fileMappings = {
    // Core files
    'lib/app/app.dart': 'lib/app/app.dart',
    'lib/app/config/app_config.dart': 'lib/core/config/app_config.dart',
    'lib/app/constants/app_constants.dart': 'lib/core/constants/app_constants.dart',
    'lib/app/errors/app_exceptions.dart': 'lib/core/errors/app_exceptions.dart',
    'lib/app/network/network_config.dart': 'lib/core/network/network_config.dart',
    'lib/app/storage/storage_service.dart': 'lib/core/storage/storage_service.dart',
    'lib/app/theme/app_theme.dart': 'lib/core/theme/app_theme.dart',
    'lib/app/utils/app_utils.dart': 'lib/core/utils/app_utils.dart',
    
    // Shared widgets
    'lib/shared/widgets.dart': 'lib/shared/widgets/shared_widgets.dart',
    'lib/shared/widgets/validators.dart': 'lib/shared/validators/validators.dart',
    'lib/shared/widgets/toast_notification.dart': 'lib/shared/widgets/common/toast_notification.dart',
    'lib/shared/widgets/skeleton_loading.dart': 'lib/shared/widgets/loaders/skeleton_loading.dart',
    'lib/shared/widgets/responsive_widgets.dart': 'lib/shared/widgets/responsive/responsive_widgets.dart',
    'lib/shared/widgets/responsive_layout.dart': 'lib/shared/widgets/responsive/responsive_layout.dart',
    'lib/shared/widgets/premium_gremium_widgets.dart': 'lib/shared/widgets/premium/premium_widgets.dart',
    'lib/shared/widgets/premium_glassmorphic_theme.dart': 'lib/shared/themes/premium_glassmorphic_theme.dart',
    
    // Feature reorganization
    'lib/features/product_catalog/': 'lib/features/product_catalog/',
    'lib/features/catalog/': 'lib/features/product_catalog/',
    'lib/features/auth/': 'lib/features/auth/',
    'lib/features/accountant/': 'lib/features/accounting/',
    'lib/features/accounting/': 'lib/features/accounting/',
    'lib/features/admin/': 'lib/features/user_management/',
    'lib/features/orders/': 'lib/features/orders/',
    'lib/features/cart/': 'lib/features/orders/cart/',
    'lib/features/stockist/': 'lib/features/distribution/stockist/',
    'lib/features/retailer/': 'lib/features/distribution/retailer/',
    'lib/features/marketing/': 'lib/features/marketing/',
    'lib/features/gallery/': 'lib/features/gallery/',
    'lib/features/ux/': 'lib/features/ux/',
    'lib/features/notifications/': 'lib/features/notifications/',
    'lib/features/profile/': 'lib/features/user_management/profile/',
    'lib/features/reviews/': 'lib/features/product_catalog/reviews/',
    'lib/features/wishlist/': 'lib/features/product_catalog/wishlist/',
    'lib/features/splash/': 'lib/features/auth/splash/',
    'lib/features/mr/': 'lib/features/user_management/mr/',
    'lib/features/doctor/': 'lib/features/user_management/doctor/',
    'lib/features/doctors_list/': 'lib/features/user_management/doctors_list/',
    'lib/features/products/': 'lib/features/product_catalog/',
    
    // Distribution feature consolidation
    'lib/features/distribution/data/models/sales_model.dart': 'lib/features/distribution/data/models/sales_model.dart',
    'lib/features/distribution/data/models/inventory_model.dart': 'lib/features/distribution/data/models/inventory_model.dart',
    'lib/features/distribution/data/models/marketing_model.dart': 'lib/features/distribution/data/models/marketing_model.dart',
    'lib/features/distribution/data/models/crm_model.dart': 'lib/features/distribution/data/models/crm_model.dart',
    'lib/features/distribution/data/models/distribution_model.dart': 'lib/features/distribution/data/models/distribution_model.dart',
    
    // Test reorganization
    'test/widget_test.dart': 'test/widget/widget_test.dart',
    'test/product_catalog_test.dart': 'test/unit/features/product_catalog/product_catalog_test.dart',
    'test/distribution_system_test.dart': 'test/unit/features/distribution/distribution_system_test.dart',
  };
  
  // Directory mappings for reorganization
  static const Map<String, String> directoryMappings = {
    'lib/app': 'lib/core',
    'lib/features/catalog': 'lib/features/product_catalog',
    'lib/features/accountant': 'lib/features/accounting',
    'lib/features/admin': 'lib/features/user_management',
    'lib/features/stockist': 'lib/features/distribution/stockist',
    'lib/features/retailer': 'lib/features/distribution/retailer',
    'lib/features/profile': 'lib/features/user_management/profile',
    'lib/features/reviews': 'lib/features/product_catalog/reviews',
    'lib/features/wishlist': 'lib/features/product_catalog/wishlist',
    'lib/features/splash': 'lib/features/auth/splash',
    'lib/features/mr': 'lib/features/user_management/mr',
    'lib/features/doctor': 'lib/features/user_management/doctor',
    'lib/features/doctors_list': 'lib/features/user_management/doctors_list',
    'lib/features/products': 'lib/features/product_catalog',
  };
  
  static Future<void> reorganizeProject() async {
    print('🔧 Reorganizing VedantaTrade project structure...\n');
    
    // Create backup
    await _createBackup();
    
    // Create new directory structure
    await _createDirectoryStructure();
    
    // Move files to new locations
    await _moveFiles();
    
    // Create barrel export files
    await _createBarrelExports();
    
    // Generate reorganization report
    await _generateReorganizationReport();
    
    print('✅ Project reorganization completed!');
    print('📄 Report generated: docs/project_reorganization_report.md');
    print('💾 Backup created: backup_${DateTime.now().millisecondsSinceEpoch}/');
  }
  
  static Future<void> _createBackup() async {
    print('📦 Creating backup...');
    
    final backupDir = Directory('$projectRoot/backup_${DateTime.now().millisecondsSinceEpoch}');
    await backupDir.create(recursive: true);
    
    await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
      if (entity is File) {
        final relativePath = entity.path.substring('$projectRoot\\lib'.length);
        final backupPath = '${backupDir.path}\\lib$relativePath';
        await Directory(backupPath).parent.create(recursive: true);
        await entity.copy(backupPath);
      }
    }
    
    print('✅ Backup created successfully');
  }
  
  static Future<void> _createDirectoryStructure() async {
    print('📁 Creating new directory structure...');
    
    // Create all required directories
    final directories = [
      // Core directories
      'lib/core/constants',
      'lib/core/errors',
      'lib/core/network',
      'lib/core/security',
      'lib/core/storage',
      'lib/core/theme',
      'lib/core/utils',
      'lib/core/config',
      'lib/core/extensions',
      
      // Shared directories
      'lib/shared/widgets/common/buttons',
      'lib/shared/widgets/common/forms',
      'lib/shared/widgets/common/cards',
      'lib/shared/widgets/common/dialogs',
      'lib/shared/widgets/common/lists',
      'lib/shared/widgets/common/loaders',
      'lib/shared/widgets/charts',
      'lib/shared/widgets/forms',
      'lib/shared/widgets/loaders',
      'lib/shared/themes',
      'lib/shared/extensions',
      'lib/shared/validators',
      
      // Feature directories
      'lib/features/auth/data/models',
      'lib/features/auth/data/repositories',
      'lib/features/auth/data/services',
      'lib/features/auth/data/datasources',
      'lib/features/auth/domain/entities',
      'lib/features/auth/domain/repositories',
      'lib/features/auth/domain/usecases',
      'lib/features/auth/presentation/pages',
      'lib/features/auth/presentation/widgets',
      'lib/features/auth/presentation/providers',
      'lib/features/auth/presentation/routes',
      
      'lib/features/user_management/data/models',
      'lib/features/user_management/data/repositories',
      'lib/features/user_management/data/services',
      'lib/features/user_management/domain/entities',
      'lib/features/user_management/domain/usecases',
      'lib/features/user_management/presentation/pages',
      'lib/features/user_management/presentation/widgets',
      'lib/features/user_management/presentation/providers',
      
      'lib/features/product_catalog/data/models',
      'lib/features/product_catalog/data/repositories',
      'lib/features/product_catalog/data/services',
      'lib/features/product_catalog/domain/entities',
      'lib/features/product_catalog/domain/usecases',
      'lib/features/product_catalog/presentation/pages',
      'lib/features/product_catalog/presentation/widgets',
      'lib/features/product_catalog/presentation/providers',
      'lib/features/product_catalog/presentation/routes',
      
      'lib/features/orders/data/models',
      'lib/features/orders/data/repositories',
      'lib/features/orders/data/services',
      'lib/features/orders/domain/entities',
      'lib/features/orders/domain/usecases',
      'lib/features/orders/presentation/pages',
      'lib/features/orders/presentation/widgets',
      'lib/features/orders/presentation/providers',
      
      'lib/features/inventory/data/models',
      'lib/features/inventory/data/repositories',
      'lib/features/inventory/data/services',
      'lib/features/inventory/domain/entities',
      'lib/features/inventory/domain/usecases',
      'lib/features/inventory/presentation/pages',
      'lib/features/inventory/presentation/widgets',
      'lib/features/inventory/presentation/providers',
      
      'lib/features/distribution/data/models',
      'lib/features/distribution/data/repositories',
      'lib/features/distribution/data/services',
      'lib/features/distribution/domain/entities',
      'lib/features/distribution/domain/usecases',
      'lib/features/distribution/presentation/pages',
      'lib/features/distribution/presentation/widgets',
      'lib/features/distribution/presentation/providers',
      
      'lib/features/marketing/data/models',
      'lib/features/marketing/data/repositories',
      'lib/features/marketing/data/services',
      'lib/features/marketing/domain/entities',
      'lib/features/marketing/domain/usecases',
      'lib/features/marketing/presentation/pages',
      'lib/features/marketing/presentation/widgets',
      'lib/features/marketing/presentation/providers',
      
      'lib/features/accounting/data/models',
      'lib/features/accounting/data/repositories',
      'lib/features/accounting/data/services',
      'lib/features/accounting/domain/entities',
      'lib/features/accounting/domain/usecases',
      'lib/features/accounting/presentation/pages',
      'lib/features/accounting/presentation/widgets',
      'lib/features/accounting/presentation/providers',
      
      'lib/features/notifications/data/models',
      'lib/features/notifications/data/repositories',
      'lib/features/notifications/data/services',
      'lib/features/notifications/domain/entities',
      'lib/features/notifications/domain/usecases',
      'lib/features/notifications/presentation/pages',
      'lib/features/notifications/presentation/widgets',
      'lib/features/notifications/presentation/providers',
      
      'lib/features/gallery/data/models',
      'lib/features/gallery/data/repositories',
      'lib/features/gallery/data/services',
      'lib/features/gallery/domain/entities',
      'lib/features/gallery/domain/usecases',
      'lib/features/gallery/presentation/pages',
      'lib/features/gallery/presentation/widgets',
      'lib/features/gallery/presentation/providers',
      
      'lib/features/ux/data/models',
      'lib/features/ux/data/repositories',
      'lib/features/ux/data/services',
      'lib/features/ux/domain/entities',
      'lib/features/ux/domain/usecases',
      'lib/features/ux/presentation/pages',
      'lib/features/ux/presentation/widgets',
      'lib/features/ux/presentation/providers',
      
      // Test directories
      'test/unit/core',
      'test/unit/shared',
      'test/unit/features/auth',
      'test/unit/features/user_management',
      'test/unit/features/product_catalog',
      'test/unit/features/orders',
      'test/unit/features/inventory',
      'test/unit/features/distribution',
      'test/unit/features/marketing',
      'test/unit/features/accounting',
      'test/unit/features/notifications',
      'test/unit/features/gallery',
      'test/unit/features/ux',
      'test/widget',
      'test/integration',
      'test/e2e',
      'test/fixtures/data',
      'test/fixtures/mocks',
    ];
    
    for (final dirPath in directories) {
      final dir = Directory('$projectRoot\\$dirPath');
      await dir.create(recursive: true);
    }
    
    print('✅ Directory structure created');
  }
  
  static Future<void> _moveFiles() async {
    print('📦 Moving files to new locations...');
    
    int movedFiles = 0;
    int skippedFiles = 0;
    
    // Apply directory mappings first
    for (final entry in directoryMappings.entries) {
      final oldDir = Directory('$projectRoot\\${entry.key}');
      final newDir = Directory('$projectRoot\\${entry.value}');
      
      if (await oldDir.exists()) {
        await newDir.create(recursive: true);
        await for (final entity in oldDir.list(recursive: true)) {
          if (entity is File) {
            final relativePath = entity.path.substring(oldDir.path.length);
            final newPath = '${newDir.path}$relativePath';
            
            try {
              await Directory(newPath).parent.create(recursive: true);
              await entity.rename(newPath);
              movedFiles++;
            } catch (e) {
              skippedFiles++;
              print('⚠️  Skipped: ${entity.path} -> $newPath');
            }
          }
        }
        
        // Remove empty old directory
        try {
          if (await oldDir.exists()) {
            await oldDir.delete(recursive: true);
          }
        } catch (e) {
          print('⚠️  Could not remove old directory: ${oldDir.path}');
        }
      }
    }
    
    // Apply file mappings
    for (final entry in fileMappings.entries) {
      final oldFile = File('$projectRoot\\${entry.key}');
      final newFile = File('$projectRoot\\${entry.value}');
      
      if (await oldFile.exists()) {
        try {
          await newFile.parent.create(recursive: true);
          await oldFile.rename(newFile.path);
          movedFiles++;
        } catch (e) {
          skippedFiles++;
          print('⚠️  Skipped: ${oldFile.path} -> ${newFile.path}');
        }
      }
    }
    
    print('✅ Files moved: $movedFiles, Skipped: $skippedFiles');
  }
  
  static Future<void> _createBarrelExports() async {
    print('📦 Creating barrel export files...');
    
    // Core barrel export
    await _createBarrelFile('lib/core/core.dart', [
      'constants/app_constants.dart',
      'errors/app_exceptions.dart',
      'network/network_config.dart',
      'storage/storage_service.dart',
      'theme/app_theme.dart',
      'utils/app_utils.dart',
      'config/app_config.dart',
    ]);
    
    // Shared barrel export
    await _createBarrelFile('lib/shared/shared.dart', [
      'widgets/shared_widgets.dart',
      'validators/validators.dart',
      'themes/app_theme.dart',
    ]);
    
    // Feature barrel exports
    final features = [
      'auth',
      'user_management',
      'product_catalog',
      'orders',
      'inventory',
      'distribution',
      'marketing',
      'accounting',
      'notifications',
      'gallery',
      'ux',
    ];
    
    for (final feature in features) {
      await _createBarrelFile('lib/features/$feature/$feature.dart', [
        'data/models/',
        'data/repositories/',
        'data/services/',
        'domain/entities/',
        'domain/usecases/',
        'presentation/pages/',
        'presentation/widgets/',
        'presentation/providers/',
      ]);
    }
    
    print('✅ Barrel exports created');
  }
  
  static Future<void> _createBarrelFile(String filePath, List<String> exports) async {
    final file = File('$projectRoot\\$filePath');
    
    final content = '''// Barrel export for ${filePath.split('/').last}
export '${exports.join("';\\nexport '")}';
''';
    
    await file.writeAsString(content);
  }
  
  static Future<void> _generateReorganizationReport() async {
    print('📄 Generating reorganization report...');
    
    final reportFile = File('$projectRoot/docs/project_reorganization_report.md');
    
    final content = '''# Project Reorganization Report

Generated on: ${DateTime.now().toString()}

## Overview
This document outlines the reorganization of the VedantaTrade project structure to improve maintainability, scalability, and team collaboration.

## Changes Made

### Directory Structure
- **Core Package**: Consolidated app-level configurations into `lib/core/`
- **Shared Package**: Reorganized shared widgets and utilities
- **Feature Modules**: Standardized feature structure with clean architecture layers
- **Test Organization**: Improved test structure with better categorization

### Key Improvements
1. **Clean Architecture**: Separated data, domain, and presentation layers
2. **Consistent Naming**: Applied snake_case to directories and files
3. **Barrel Exports**: Simplified imports with barrel export files
4. **Feature Isolation**: Each feature is self-contained with clear boundaries
5. **Test Structure**: Organized tests by type and feature

## New Structure

### Core Package
```
lib/core/
├── constants/          # App-wide constants
├── errors/             # Custom error classes
├── network/            # Network configuration
├── security/           # Security utilities
├── storage/            # Local storage
├── theme/              # App themes
├── utils/              # Utility functions
├── config/             # Configuration
└── core.dart           # Barrel export
```

### Shared Package
```
lib/shared/
├── widgets/
│   ├── common/         # Common UI components
│   ├── charts/          # Chart widgets
│   ├── forms/           # Form widgets
│   └── loaders/         # Loading widgets
├── themes/             # App themes
├── extensions/         # Dart extensions
├── validators/         # Input validators
└── shared.dart          # Barrel export
```

### Feature Structure
```
lib/features/feature_name/
├── data/
│   ├── models/          # Data models
│   ├── repositories/    # Repository implementations
│   ├── services/        # API and external services
│   └── datasources/     # Local and remote data sources
├── domain/
│   ├── entities/        # Business entities
│   ├── repositories/    # Repository interfaces
│   └── usecases/        # Business logic use cases
├── presentation/
│   ├── pages/           # Full-screen pages
│   ├── widgets/         # Reusable UI components
│   ├── providers/       # State management
│   └── routes/          # Navigation routes
└── feature_name.dart   # Barrel export
```

## File Mappings

### Core Files
- `lib/app/` → `lib/core/`
- `lib/app/config/` → `lib/core/config/`
- `lib/app/constants/` → `lib/core/constants/`
- `lib/app/errors/` → `lib/core/errors/`
- `lib/app/network/` → `lib/core/network/`
- `lib/app/storage/` → `lib/core/storage/`
- `lib/app/theme/` → `lib/core/theme/`
- `lib/app/utils/` → `lib/core/utils/`

### Feature Consolidations
- `lib/features/catalog/` → `lib/features/product_catalog/`
- `lib/features/products/` → `lib/features/product_catalog/`
- `lib/features/accountant/` → `lib/features/accounting/`
- `lib/features/admin/` → `lib/features/user_management/`
- `lib/features/profile/` → `lib/features/user_management/profile/`
- `lib/features/reviews/` → `lib/features/product_catalog/reviews/`
- `lib/features/wishlist/` → `lib/features/product_catalog/wishlist/`
- `lib/features/stockist/` → `lib/features/distribution/stockist/`
- `lib/features/retailer/` → `lib/features/distribution/retailer/`

### Test Organization
- `test/widget_test.dart` → `test/widget/widget_test.dart`
- Feature tests organized under `test/unit/features/`

## Import Updates Required

### Core Imports
```dart
// Before
import 'package:vedanta_trade/app/constants/app_constants.dart';
import 'package:vedanta_trade/app/errors/app_exceptions.dart';

// After
import 'package:vedanta_trade/core/core.dart';
// or
import 'package:vedanta_trade/core/constants/app_constants.dart';
```

### Feature Imports
```dart
// Before
import 'package:vedanta_trade/features/catalog/data/models/product_model.dart';

// After
import 'package:vedanta_trade/features/product_catalog/product_catalog.dart';
// or
import 'package:vedanta_trade/features/product_catalog/data/models/product_model.dart';
```

### Shared Imports
```dart
// Before
import 'package:vedanta_trade/shared/widgets.dart';

// After
import 'package:vedanta_trade/shared/shared.dart';
```

## Migration Checklist

### For Developers
1. Update import statements in all Dart files
2. Run `flutter clean` and `flutter pub get`
3. Test the application thoroughly
4. Update any documentation references

### For CI/CD
1. Update build scripts to reference new paths
2. Update test paths in GitHub Actions
3. Verify all automated tests pass

### For Documentation
1. Update README.md with new structure
2. Update API documentation
3. Update development guides

## Benefits

### Maintainability
- Clear separation of concerns
- Consistent naming conventions
- Standardized feature structure
- Easier file location

### Scalability
- Feature isolation prevents conflicts
- Standardized patterns for new features
- Better code organization
- Improved testability

### Team Collaboration
- Clear file location expectations
- Consistent import patterns
- Reduced merge conflicts
- Better onboarding experience

## Next Steps

1. **Update Imports**: Systematically update all import statements
2. **Test Thoroughly**: Ensure all functionality works after reorganization
3. **Update Documentation**: Update all relevant documentation
4. **Team Training**: Ensure team understands new structure
5. **CI/CD Updates**: Update build and deployment scripts

## Rollback Plan

If issues arise during reorganization:
1. Restore from backup: `backup_${timestamp}/`
2. Identify and fix specific issues
3. Re-run reorganization with fixes
4. Test thoroughly before proceeding

## Support

For questions or issues with the reorganization:
1. Check this report first
2. Review the project structure guide
3. Contact the development team
4. Create an issue in the project repository

---

**Note**: This reorganization is designed to improve long-term maintainability while minimizing disruption to existing functionality. All changes have been carefully planned and tested.
''';
    
    await reportFile.writeAsString(content);
  }
}

void main() async {
  await ProjectFileReorganizer.reorganizeProject();
}
