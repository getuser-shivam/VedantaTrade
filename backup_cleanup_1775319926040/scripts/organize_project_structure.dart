#!/usr/bin/env dart

/// Project Structure Organization Script
/// This script organizes the VedantaTrade project structure
/// according to established conventions and best practices.

import 'dart:io';
import 'dart:convert';
import 'dart:math';

class ProjectOrganizer {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = '$projectRoot\\lib';
  
  // Standardized directory structure
  static const Map<String, List<String>> directoryStructure = {
    'core': [
      'constants',
      'errors',
      'network',
      'security',
      'storage',
      'theme',
      'utils',
      'config',
      'extensions',
    ],
    'shared': [
      'widgets/common/buttons',
      'widgets/common/forms',
      'widgets/common/cards',
      'widgets/common/dialogs',
      'widgets/common/lists',
      'widgets/common/loaders',
      'widgets/charts',
      'widgets/forms',
      'widgets/loaders',
      'themes',
      'extensions',
      'validators',
    ],
    'features': [
      'auth/data/models',
      'auth/data/repositories',
      'auth/data/services',
      'auth/data/datasources',
      'auth/domain/entities',
      'auth/domain/repositories',
      'auth/domain/usecases',
      'auth/presentation/pages',
      'auth/presentation/widgets',
      'auth/presentation/providers',
      'auth/presentation/routes',
      'user_management/data/models',
      'user_management/data/repositories',
      'user_management/data/services',
      'user_management/domain/entities',
      'user_management/domain/usecases',
      'user_management/presentation/pages',
      'user_management/presentation/widgets',
      'user_management/presentation/providers',
      'product_catalog/data/models',
      'product_catalog/data/repositories',
      'product_catalog/data/services',
      'product_catalog/domain/entities',
      'product_catalog/domain/usecases',
      'product_catalog/presentation/pages',
      'product_catalog/presentation/widgets',
      'product_catalog/presentation/providers',
      'product_catalog/presentation/routes',
      'orders/data/models',
      'orders/data/repositories',
      'orders/data/services',
      'orders/domain/entities',
      'orders/domain/usecases',
      'orders/presentation/pages',
      'orders/presentation/widgets',
      'orders/presentation/providers',
      'inventory/data/models',
      'inventory/data/repositories',
      'inventory/data/services',
      'inventory/domain/entities',
      'inventory/domain/usecases',
      'inventory/presentation/pages',
      'inventory/presentation/widgets',
      'inventory/presentation/providers',
      'distribution/data/models',
      'distribution/data/repositories',
      'distribution/data/services',
      'distribution/domain/entities',
      'distribution/domain/usecases',
      'distribution/presentation/pages',
      'distribution/presentation/widgets',
      'distribution/presentation/providers',
      'marketing/data/models',
      'marketing/data/repositories',
      'marketing/data/services',
      'marketing/domain/entities',
      'marketing/domain/usecases',
      'marketing/presentation/pages',
      'marketing/presentation/widgets',
      'marketing/presentation/providers',
      'accounting/data/models',
      'accounting/data/repositories',
      'accounting/data/services',
      'accounting/domain/entities',
      'accounting/domain/usecases',
      'accounting/presentation/pages',
      'accounting/presentation/widgets',
      'accounting/presentation/providers',
      'notifications/data/models',
      'notifications/data/repositories',
      'notifications/data/services',
      'notifications/domain/entities',
      'notifications/domain/usecases',
      'notifications/presentation/pages',
      'notifications/presentation/widgets',
      'notifications/presentation/providers',
      'gallery/data/models',
      'gallery/data/repositories',
      'gallery/data/services',
      'gallery/domain/entities',
      'gallery/domain/usecases',
      'gallery/presentation/pages',
      'gallery/presentation/widgets',
      'gallery/presentation/providers',
      'ux/data/models',
      'ux/data/repositories',
      'ux/data/services',
      'ux/domain/entities',
      'ux/domain/usecases',
      'ux/presentation/pages',
      'ux/presentation/widgets',
      'ux/presentation/providers',
    ],
    'data': [
      'models',
      'repositories',
      'services',
      'datasources',
      'mappers',
    ],
    'test': [
      'unit/core',
      'unit/shared',
      'unit/features/auth',
      'unit/features/user_management',
      'unit/features/product_catalog',
      'unit/features/orders',
      'unit/features/inventory',
      'unit/features/distribution',
      'unit/features/marketing',
      'unit/features/accounting',
      'unit/features/notifications',
      'unit/features/gallery',
      'unit/features/ux',
      'widget',
      'integration',
      'e2e',
      'fixtures/data',
      'fixtures/mocks',
    ],
    'assets': [
      'images/icons',
      'images/logos',
      'images/banners',
      'images/products',
      'fonts',
      'animations',
      'data/mock',
      'data/config',
    ],
  };
      'extensions',
      'providers',
      'services',
    ],
    'core/constants': [],
    'core/errors': [],
    'core/network': [],
    'core/security': [],
    'core/storage': [],
    'core/theme': [],
    'core/utils': [],
    'core/config': [],
    'shared/widgets/common': [],
    'shared/widgets/forms': [],
    'shared/widgets/cards': [],
    'shared/widgets/dialogs': [],
    'shared/extensions': [],
    'shared/providers': [],
    'shared/services': [],
  };

  // Files to organize
  static const Map<String, String> filesToOrganize = {
    'lib/core/constants/app_constants.dart': 'core/constants/app_constants.dart',
    'lib/core/constants/theme_constants.dart': 'core/constants/theme_constants.dart',
    'lib/core/utils/validation_utils.dart': 'core/utils/validation_utils.dart',
    'lib/shared/widgets/common/glassmorphic_button.dart': 'shared/widgets/common/glassmorphic_button.dart',
    'lib/shared/widgets/common/glassmorphic_card.dart': 'shared/widgets/common/glassmorphic_card.dart',
    'lib/shared/extensions/string_extensions.dart': 'shared/extensions/string_extensions.dart',
    'lib/shared/extensions/date_extensions.dart': 'shared/extensions/date_extensions.dart',
  };

  Future<void> organizeProject() async {
    print('🔧 Organizing VedantaTrade project structure...');
    
    try {
      // Create directory structure
      await _createDirectoryStructure();
      
      // Move files to correct locations
      await _organizeFiles();
      
      // Create index files
      await _createIndexFiles();
      
      // Update pubspec.yaml if needed
      await _updatePubspec();
      
      print('✅ Project structure organization completed successfully!');
      print('\n📁 Created directories:');
      _printDirectoryStructure();
      
      print('\n📄 Organized files:');
      _printOrganizedFiles();
      
    } catch (e) {
      print('❌ Error organizing project structure: $e');
      exit(1);
    }
  }

  Future<void> _createDirectoryStructure() async {
    print('\n📁 Creating directory structure...');
    
    for (final entry in directoryStructure.entries) {
      final dirPath = '$libPath\\${entry.key}';
      
      // Create main directory
      await Directory(dirPath).create(recursive: true);
      
      // Create subdirectories
      for (final subdir in entry.value) {
        final subPath = '$libPath\\${entry.key}\\$subdir';
        await Directory(subPath).create(recursive: true);
      }
    }
  }

  Future<void> _organizeFiles() async {
    print('\n📄 Organizing files...');
    
    for (final entry in filesToOrganize.entries) {
      final sourcePath = '$projectRoot\\${entry.key}';
      final targetPath = '$projectRoot\\${entry.value}';
      
      if (await File(sourcePath).exists()) {
        // Ensure target directory exists
        final targetDir = Directory(targetPath).parent;
        await targetDir.create(recursive: true);
        
        // Move file
        await File(sourcePath).rename(targetPath);
        print('  ✅ Moved: ${entry.key} → ${entry.value}');
      } else {
        print('  ⚠️  File not found: ${entry.key}');
      }
    }
  }

  Future<void> _createIndexFiles() async {
    print('\n📄 Creating index files...');
    
    // Create core/index.dart
    await _createCoreIndex();
    
    // Create shared/index.dart
    await _createSharedIndex();
    
    // Create feature index files
    await _createFeatureIndexes();
  }

  Future<void> _createCoreIndex() async {
    final indexContent = '''
/// Core utilities and configurations
library core;

// Constants
export 'constants/app_constants.dart';
export 'constants/theme_constants.dart';

// Errors
export 'errors/exceptions.dart';
export 'errors/failures.dart';

// Network
export 'network/api_client.dart';
export 'network/network_info.dart';
export 'network/interceptors.dart';

// Security
export 'security/encryption.dart';
export 'security/biometric.dart';

// Storage
export 'storage/secure_storage.dart';
export 'storage/shared_preferences.dart';

// Theme
export 'theme/app_theme.dart';
export 'theme/colors.dart';
export 'theme/text_styles.dart';

// Utils
export 'utils/date_utils.dart';
export 'utils/currency_utils.dart';
export 'utils/validation_utils.dart';
export 'utils/nepal_localization.dart';

// Config
export 'config/api_config.dart';
export 'config/app_config.dart';
export 'config/environment_config.dart';
''';

    await File('$libPath\\core\\index.dart').writeAsString(indexContent);
    print('  ✅ Created: core/index.dart');
  }

  Future<void> _createSharedIndex() async {
    final indexContent = '''
/// Shared widgets and utilities
library shared;

// Widgets
export 'widgets/common/glassmorphic_button.dart';
export 'widgets/common/glassmorphic_card.dart';
export 'widgets/forms/index.dart';
export 'widgets/cards/index.dart';
export 'widgets/dialogs/index.dart';

// Extensions
export 'extensions/string_extensions.dart';
export 'extensions/date_extensions.dart';
export 'extensions/widget_extensions.dart';

// Providers
export 'providers/theme_provider.dart';
export 'providers/locale_provider.dart';
export 'providers/connectivity_provider.dart';

// Services
export 'services/navigation_service.dart';
export 'services/notification_service.dart';
export 'services/analytics_service.dart';
''';

    await File('$libPath\\shared\\index.dart').writeAsString(indexContent);
    print('  ✅ Created: shared/index.dart');
  }

  Future<void> _createFeatureIndexes() async {
    final featuresDir = Directory('$libPath\\features');
    
    if (await featuresDir.exists()) {
      await for (final feature in featuresDir.listSync()) {
        if (feature is Directory) {
          final featureName = feature.path.split('\\').last;
          await _createFeatureIndex(featureName);
        }
      }
    }
  }

  Future<void> _createFeatureIndex(String featureName) async {
    final featurePath = '$libPath\\features\\$featureName';
    final indexPath = '$featurePath\\index.dart';
    
    // Check if feature follows the standard structure
    final dataDir = Directory('$featurePath\\data');
    final domainDir = Directory('$featurePath\\domain');
    final presentationDir = Directory('$featurePath\\presentation');
    
    if (await dataDir.exists() && await domainDir.exists() && await presentationDir.exists()) {
      final indexContent = '''
/// $featureName feature module
library ${featureName}_feature;

// Data layer
export 'data/datasources/index.dart';
export 'data/models/index.dart';
export 'data/repositories/index.dart';
export 'data/services/index.dart';

// Domain layer
export 'domain/entities/index.dart';
export 'domain/repositories/index.dart';
export 'domain/usecases/index.dart';

// Presentation layer
export 'presentation/pages/index.dart';
export 'presentation/widgets/index.dart';
export 'presentation/providers/index.dart';
export 'presentation/routes/index.dart';
''';
      
      await File(indexPath).writeAsString(indexContent);
      print('  ✅ Created: features/$featureName/index.dart');
    }
  }

  Future<void> _updatePubspec() async {
    print('\n📦 Updating pubspec.yaml...');
    
    final pubspecPath = '$projectRoot\\pubspec.yaml';
    final pubspecFile = File(pubspecPath);
    
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      
      // Check if lints section exists
      if (!content.contains('lints:')) {
        final updatedContent = content.replaceFirst(
          'flutter:',
          '''flutter:
  lints:
    - prefer_const_constructors
    - prefer_const_literals_to_create_immutables
    - prefer_const_declarations
    - avoid_print
    - prefer_single_quotes
    - sort_child_properties_last
    - use_key_in_widget_constructors
    - avoid_unnecessary_containers
    - sized_box_for_whitespace
    - use_build_context_synchronously
    - avoid_web_libraries_in_flutter
''',
        );
        
        await pubspecFile.writeAsString(updatedContent);
        print('  ✅ Updated: pubspec.yaml (added lints)');
      }
    }
  }

  void _printDirectoryStructure() {
    for (final entry in directoryStructure.entries) {
      print('    ${entry.key}/');
      for (final subdir in entry.value) {
        print('      ${subdir}/');
      }
    }
  }

  void _printOrganizedFiles() {
    for (final entry in filesToOrganize.entries) {
      print('    ${entry.key} → ${entry.value}');
    }
  }

  Future<void> generateNamingReport() async {
    print('\n📊 Generating naming convention report...');
    
    final report = <String, dynamic>{};
    final issues = <String>[];
    
    // Check file naming
    await _checkFileNaming(report, issues);
    
    // Check class naming
    await _checkClassNaming(report, issues);
    
    // Check directory naming
    await _checkDirectoryNaming(report, issues);
    
    // Save report
    final reportPath = '$projectRoot\\docs\\naming_convention_report.json';
    await File(reportPath).writeAsString(jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'report': report,
      'issues': issues,
    }));
    
    print('  ✅ Report saved to: docs/naming_convention_report.json');
    print('  📊 Issues found: ${issues.length}');
    
    if (issues.isNotEmpty) {
      print('\n⚠️  Naming convention issues:');
      for (final issue in issues) {
        print('    - $issue');
      }
    }
  }

  Future<void> _checkFileNaming(Map<String, dynamic> report, List<String> issues) async {
    final libDir = Directory(libPath);
    
    await for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final fileName = file.path.split('\\').last;
        
        // Check snake_case naming
        if (!RegExp(r'^[a-z_][a-z0-9_]*\.dart$').hasMatch(fileName)) {
          issues.add('File name should be snake_case: $fileName');
        }
      }
    }
  }

  Future<void> _checkClassNaming(Map<String, dynamic> report, List<String> issues) async {
    final libDir = Directory(libPath);
    
    await for (final file in libDir.listSync(recursive: true)) {
      if (file is File && file.path.endsWith('.dart')) {
        final content = await file.readAsString();
        
        // Find class names
        final classMatches = RegExp(r'class\s+([A-Z][a-zA-Z0-9]*)').allMatches(content);
        
        for (final match in classMatches) {
          final className = match.group(1)!;
          
          // Check PascalCase naming
          if (!RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(className)) {
            issues.add('Class name should be PascalCase: $className');
          }
        }
      }
    }
  }

  Future<void> _checkDirectoryNaming(Map<String, dynamic> report, List<String> issues) async {
    final libDir = Directory(libPath);
    
    await for (final dir in libDir.listSync()) {
      if (dir is Directory) {
        final dirName = dir.path.split('\\').last;
        
        // Check snake_case naming
        if (!RegExp(r'^[a-z_][a-z0-9_]*$').hasMatch(dirName)) {
          issues.add('Directory name should be snake_case: $dirName');
        }
      }
    }
  }

  Future<void> generateStructureDocumentation() async {
    print('\n📚 Generating structure documentation...');
    
    final docContent = '''
# VedantaTrade Project Structure

## Overview
This document describes the organized structure of the VedantaTrade project.

## Directory Structure

### Root Structure
\`\`\`
vedanta_trade/
├── lib/                          # Main application code
│   ├── app/                       # App-level configuration
│   ├── core/                      # Core utilities and configurations
│   ├── features/                   # Feature modules
│   ├── shared/                     # Shared widgets and utilities
│   └── main.dart                 # Application entry point
├── assets/                        # Static assets
├── docs/                         # Documentation
├── scripts/                       # Build and deployment scripts
├── test/                         # Test files
├── tools/                         # Development tools
└── pubspec.yaml                   # Dependencies
\`\`\`

### Core Directory
\`\`\`
core/
├── constants/                     # App constants
│   ├── app_constants.dart
│   └── theme_constants.dart
├── errors/                        # Custom error classes
├── network/                       # Network configuration
├── security/                      # Security utilities
├── storage/                       # Local storage
├── theme/                         # App theme
├── utils/                         # Utility functions
└── config/                        # Configuration files
\`\`\`

### Shared Directory
\`\`\`
shared/
├── widgets/                       # Reusable widgets
│   ├── common/                   # Generic widgets
│   ├── forms/                    # Form widgets
│   ├── cards/                    # Card widgets
│   └── dialogs/                  # Dialog widgets
├── extensions/                    # Dart extensions
├── providers/                     # Shared providers
└── services/                      # Shared services
\`\`\`

### Feature Module Structure
\`\`\`
features/
├── feature_name/                   # Feature directory (snake_case)
│   ├── data/                      # Data layer
│   │   ├── datasources/           # API, database, cache sources
│   │   ├── models/                # Data models and entities
│   │   ├── repositories/          # Repository implementations
│   │   └── services/             # Business logic services
│   ├── domain/                    # Domain layer
│   │   ├── entities/              # Domain entities
│   │   ├── repositories/          # Repository interfaces
│   │   └── usecases/             # Use cases (business logic)
│   └── presentation/              # UI layer
│       ├── pages/                 # Full-screen pages
│       ├── widgets/               # Reusable widgets for this feature
│       ├── providers/              # State management
│       └── routes/                # Navigation routes
\`\`\`

## Naming Conventions

### Files
- **Files**: \`snake_case.dart\` (e.g., \`user_profile_page.dart\`)
- **Classes**: \`PascalCase\` (e.g., \`UserProfilePage\`)
- **Variables**: \`camelCase\` (e.g., \`userName\`)
- **Constants**: \`SCREAMING_SNAKE_CASE\` (e.g., \`API_BASE_URL\`)
- **Private members**: \`_camelCase\` (e.g., \`_privateMethod\`)

### Directories
- **Directories**: \`snake_case\` (e.g., \`user_profile/\`)
- **Feature names**: \`snake_case\` (e.g., \`expense_tracking/\`)

### Widgets
- **StatelessWidget**: \`PascalCase\` + \`Widget\` (e.g., \`UserProfileWidget\`)
- **StatefulWidget**: \`PascalCase\` + \`Widget\` (e.g., \`UserProfileWidget\`)
- **Pages**: \`PascalCase\` + \`Page\` (e.g., \`UserProfilePage\`)
- **Providers**: \`PascalCase\` + \`Provider\` (e.g., \`UserProfileProvider\`)

### Models
- **Models**: \`PascalCase\` + \`Model\` (e.g., \`UserModel\`)
- **Entities**: \`PascalCase\` + \`Entity\` (e.g., \`UserEntity\`)
- **DTOs**: \`PascalCase\` + \`Dto\` (e.g., \`UserDto\`)

## Benefits

1. **Maintainability**: Clear structure makes code easier to navigate
2. **Scalability**: Modular architecture supports growth
3. **Collaboration**: Consistent patterns improve team coordination
4. **Testing**: Organized structure enables focused testing
5. **Documentation**: Clear boundaries simplify documentation

## Usage

### Adding New Features
1. Create feature directory following the standard structure
2. Implement data, domain, and presentation layers
3. Follow naming conventions consistently
4. Add exports to feature index file
5. Update documentation as needed

### Using Shared Components
1. Import from shared/index.dart for widgets
2. Import from core/index.dart for utilities
3. Follow established patterns for consistency

---

*Generated on: ${DateTime.now().toIso8601String()}*
''';

    await File('$projectRoot\\docs\\PROJECT_STRUCTURE.md').writeAsString(docContent);
    print('  ✅ Documentation saved to: docs/PROJECT_STRUCTURE.md');
  }
}

void main(List<String> args) async {
  final organizer = ProjectOrganizer();
  
  if (args.contains('--report')) {
    await organizer.generateNamingReport();
  } else if (args.contains('--docs')) {
    await organizer.generateStructureDocumentation();
  } else {
    await organizer.organizeProject();
  }
}
