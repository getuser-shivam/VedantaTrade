#!/usr/bin/env dart

/// Project Reorganization Testing Script
/// This script validates the reorganized project structure and ensures everything works correctly

import 'dart:io';
import 'dart:convert';

class ProjectTester {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  
  static Future<void> runAllTests() async {
    print('🧪 Testing Reorganized VedantaTrade Project...\n');
    
    final results = <String, bool>{};
    
    // Test 1: Directory Structure Validation
    results['Directory Structure'] = await _testDirectoryStructure();
    
    // Test 2: File Naming Conventions
    results['File Naming'] = await _testFileNaming();
    
    // Test 3: Import Statements
    results['Import Statements'] = await _testImportStatements();
    
    // Test 4: Barrel Exports
    results['Barrel Exports'] = await _testBarrelExports();
    
    // Test 5: Flutter Dependencies
    results['Flutter Dependencies'] = await _testFlutterDependencies();
    
    // Test 6: Build Process
    results['Build Process'] = await _testBuildProcess();
    
    // Test 7: Test Execution
    results['Test Execution'] = await _testExecution();
    
    // Generate test report
    await _generateTestReport(results);
    
    // Print summary
    _printTestSummary(results);
  }
  
  static Future<bool> _testDirectoryStructure() async {
    print('📁 Testing Directory Structure...');
    
    try {
      final requiredDirectories = [
        'lib/core/constants',
        'lib/core/errors',
        'lib/core/network',
        'lib/core/security',
        'lib/core/storage',
        'lib/core/theme',
        'lib/core/utils',
        'lib/core/config',
        'lib/core/extensions',
        
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
        
        'lib/features/auth/data/models',
        'lib/features/auth/data/repositories',
        'lib/features/auth/data/services',
        'lib/features/auth/domain/entities',
        'lib/features/auth/domain/usecases',
        'lib/features/auth/presentation/pages',
        'lib/features/auth/presentation/widgets',
        'lib/features/auth/presentation/providers',
        
        'lib/features/user_management/data/models',
        'lib/features/user_management/domain/entities',
        'lib/features/user_management/presentation/pages',
        
        'lib/features/product_catalog/data/models',
        'lib/features/product_catalog/domain/entities',
        'lib/features/product_catalog/presentation/pages',
        
        'lib/features/orders/data/models',
        'lib/features/orders/domain/entities',
        'lib/features/orders/presentation/pages',
        
        'lib/features/inventory/data/models',
        'lib/features/inventory/domain/entities',
        'lib/features/inventory/presentation/pages',
        
        'lib/features/distribution/data/models',
        'lib/features/distribution/domain/entities',
        'lib/features/distribution/presentation/pages',
        
        'lib/features/marketing/data/models',
        'lib/features/marketing/domain/entities',
        'lib/features/marketing/presentation/pages',
        
        'lib/features/accounting/data/models',
        'lib/features/accounting/domain/entities',
        'lib/features/accounting/presentation/pages',
        
        'lib/features/notifications/data/models',
        'lib/features/notifications/domain/entities',
        'lib/features/notifications/presentation/pages',
        
        'lib/features/gallery/data/models',
        'lib/features/gallery/domain/entities',
        'lib/features/gallery/presentation/pages',
        
        'lib/features/ux/data/models',
        'lib/features/ux/domain/entities',
        'lib/features/ux/presentation/pages',
        
        'test/unit/core',
        'test/unit/shared',
        'test/unit/features/auth',
        'test/unit/features/user_management',
        'test/unit/features/product_catalog',
        'test/widget',
        'test/integration',
        'test/fixtures/data',
        'test/fixtures/mocks',
      ];
      
      int missingDirs = 0;
      
      for (final dirPath in requiredDirectories) {
        final dir = Directory('$projectRoot\\$dirPath');
        if (!await dir.exists()) {
          print('  ❌ Missing: $dirPath');
          missingDirs++;
        } else {
          print('  ✅ Found: $dirPath');
        }
      }
      
      if (missingDirs == 0) {
        print('✅ Directory structure is valid');
        return true;
      } else {
        print('❌ $missingDirs directories missing');
        return false;
      }
    } catch (e) {
      print('❌ Error testing directory structure: $e');
      return false;
    }
  }
  
  static Future<bool> _testFileNaming() async {
    print('📝 Testing File Naming Conventions...');
    
    try {
      final snakeCasePattern = RegExp(r'^[a-z]+(_[a-z0-9]+)*\.dart$');
      final kebabCasePattern = RegExp(r'^[a-z]+(-[a-z0-9]+)*\.(md|yml|yaml|json)$');
      
      int invalidFiles = 0;
      int totalFiles = 0;
      
      await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          totalFiles++;
          final fileName = entity.path.split(Platform.pathSeparator).last;
          
          if (!snakeCasePattern.hasMatch(fileName)) {
            print('  ❌ Invalid file name: $fileName');
            invalidFiles++;
          }
        }
      }
      
      await for (final entity in Directory('$projectRoot/docs').list(recursive: true)) {
        if (entity is File) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final extension = fileName.split('.').last.toLowerCase();
          
          if (['md', 'yml', 'yaml', 'json'].contains(extension)) {
            totalFiles++;
            if (!kebabCasePattern.hasMatch(fileName)) {
              print('  ❌ Invalid file name: $fileName');
              invalidFiles++;
            }
          }
        }
      }
      
      if (invalidFiles == 0) {
        print('✅ All $totalFiles files follow naming conventions');
        return true;
      } else {
        print('❌ $invalidFiles of $totalFiles files have invalid names');
        return false;
      }
    } catch (e) {
      print('❌ Error testing file naming: $e');
      return false;
    }
  }
  
  static Future<bool> _testImportStatements() async {
    print('📦 Testing Import Statements...');
    
    try {
      int invalidImports = 0;
      int totalImports = 0;
      
      await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final content = await entity.readAsString();
          final lines = content.split('\n');
          
          for (final line in lines) {
            final trimmedLine = line.trim();
            if (trimmedLine.startsWith('import')) {
              totalImports++;
              
              // Check for common import issues
              if (trimmedLine.contains('package:vedanta_trade/app/')) {
                print('  ❌ Legacy import: $trimmedLine (${entity.path})');
                invalidImports++;
              } else if (trimmedLine.contains('package:vedanta_trade/features/catalog/')) {
                print('  ❌ Legacy import: $trimmedLine (${entity.path})');
                invalidImports++;
              } else if (trimmedLine.contains('package:vedanta_trade/features/products/')) {
                print('  ❌ Legacy import: $trimmedLine (${entity.path})');
                invalidImports++;
              }
            }
          }
        }
      }
      
      if (invalidImports == 0) {
        print('✅ All $totalImports imports are valid');
        return true;
      } else {
        print('❌ $invalidImports of $totalImports imports need updating');
        return false;
      }
    } catch (e) {
      print('❌ Error testing import statements: $e');
      return false;
    }
  }
  
  static Future<bool> _testBarrelExports() async {
    print('📦 Testing Barrel Exports...');
    
    try {
      final barrelFiles = [
        'lib/core/core.dart',
        'lib/shared/shared.dart',
        'lib/features/auth/auth.dart',
        'lib/features/user_management/user_management.dart',
        'lib/features/product_catalog/product_catalog.dart',
        'lib/features/orders/orders.dart',
        'lib/features/inventory/inventory.dart',
        'lib/features/distribution/distribution.dart',
        'lib/features/marketing/marketing.dart',
        'lib/features/accounting/accounting.dart',
        'lib/features/notifications/notifications.dart',
        'lib/features/gallery/gallery.dart',
        'lib/features/ux/ux.dart',
      ];
      
      int missingBarrels = 0;
      
      for (final barrelPath in barrelFiles) {
        final barrelFile = File('$projectRoot\\$barrelPath');
        if (!await barrelFile.exists()) {
          print('  ❌ Missing barrel: $barrelPath');
          missingBarrels++;
        } else {
          final content = await barrelFile.readAsString();
          if (!content.contains('export')) {
            print('  ❌ Empty barrel: $barrelPath');
            missingBarrels++;
          } else {
            print('  ✅ Barrel exists: $barrelPath');
          }
        }
      }
      
      if (missingBarrels == 0) {
        print('✅ All barrel exports are present');
        return true;
      } else {
        print('❌ $missingBarrels barrel files missing or empty');
        return false;
      }
    } catch (e) {
      print('❌ Error testing barrel exports: $e');
      return false;
    }
  }
  
  static Future<bool> _testFlutterDependencies() async {
    print('🔧 Testing Flutter Dependencies...');
    
    try {
      final pubspecFile = File('$projectRoot\\pubspec.yaml');
      if (!await pubspecFile.exists()) {
        print('❌ pubspec.yaml not found');
        return false;
      }
      
      final content = await pubspecFile.readAsString();
      
      // Check for essential dependencies
      final requiredDeps = [
        'flutter',
        'provider',
        'http',
        'equatable',
      ];
      
      int missingDeps = 0;
      
      for (final dep in requiredDeps) {
        if (!content.contains(dep)) {
          print('  ❌ Missing dependency: $dep');
          missingDeps++;
        } else {
          print('  ✅ Found dependency: $dep');
        }
      }
      
      if (missingDeps == 0) {
        print('✅ All required dependencies are present');
        return true;
      } else {
        print('❌ $missingDeps dependencies missing');
        return false;
      }
    } catch (e) {
      print('❌ Error testing Flutter dependencies: $e');
      return false;
    }
  }
  
  static Future<bool> _testBuildProcess() async {
    print('🔨 Testing Build Process...');
    
    try {
      // Test flutter clean
      print('  🧹 Running flutter clean...');
      final cleanResult = await Process.run('flutter', ['clean'], 
        workingDirectory: projectRoot);
      
      if (cleanResult.exitCode != 0) {
        print('❌ Flutter clean failed');
        print('Error: ${cleanResult.stderr}');
        return false;
      }
      
      // Test flutter pub get
      print('  📦 Running flutter pub get...');
      final pubGetResult = await Process.run('flutter', ['pub get'], 
        workingDirectory: projectRoot);
      
      if (pubGetResult.exitCode != 0) {
        print('❌ Flutter pub get failed');
        print('Error: ${pubGetResult.stderr}');
        return false;
      }
      
      // Test flutter analyze
      print('  🔍 Running flutter analyze...');
      final analyzeResult = await Process.run('flutter', ['analyze'], 
        workingDirectory: projectRoot);
      
      if (analyzeResult.exitCode != 0) {
        print('❌ Flutter analyze found issues');
        print('Output: ${analyzeResult.stdout}');
        print('Error: ${analyzeResult.stderr}');
        return false;
      }
      
      print('✅ Build process tests passed');
      return true;
    } catch (e) {
      print('❌ Error testing build process: $e');
      return false;
    }
  }
  
  static Future<bool> _testExecution() async {
    print('🧪 Testing Test Execution...');
    
    try {
      // Run unit tests
      print('  🧪 Running unit tests...');
      final unitTestResult = await Process.run('flutter', ['test', 'test/unit/'], 
        workingDirectory: projectRoot);
      
      if (unitTestResult.exitCode != 0) {
        print('❌ Unit tests failed');
        print('Output: ${unitTestResult.stdout}');
        print('Error: ${unitTestResult.stderr}');
        return false;
      }
      
      // Run widget tests
      print('  🎨 Running widget tests...');
      final widgetTestResult = await Process.run('flutter', ['test', 'test/widget/'], 
        workingDirectory: projectRoot);
      
      if (widgetTestResult.exitCode != 0) {
        print('❌ Widget tests failed');
        print('Output: ${widgetTestResult.stdout}');
        print('Error: ${widgetTestResult.stderr}');
        return false;
      }
      
      print('✅ All tests passed');
      return true;
    } catch (e) {
      print('❌ Error running tests: $e');
      return false;
    }
  }
  
  static void _printTestSummary(Map<String, bool> results) {
    print('\n' + '='*50);
    print('📊 TEST SUMMARY');
    print('='*50);
    
    int passed = 0;
    int total = results.length;
    
    for (final entry in results.entries) {
      final status = entry.value ? '✅ PASS' : '❌ FAIL';
      print('$status ${entry.key}');
      if (entry.value) passed++;
    }
    
    print('='*50);
    print('📈 Results: $passed/$total tests passed');
    
    if (passed == total) {
      print('🎉 All tests passed! Project reorganization is successful.');
    } else {
      print('⚠️  Some tests failed. Please review the issues above.');
    }
  }
  
  static Future<void> _generateTestReport(Map<String, bool> results) async {
    final reportFile = File('$projectRoot/docs/project_reorganization_test_report.md');
    
    final content = '''# Project Reorganization Test Report

Generated on: ${DateTime.now().toString()}

## Test Results Summary

| Test Category | Status | Details |
|---------------|--------|---------|
${results.entries.map((entry) => 
  '| ${entry.key} | ${entry.value ? '✅ PASSED' : '❌ FAILED'} | ${entry.value ? 'All checks passed' : 'Issues found'} |'
).join('\n')}

## Test Details

### Directory Structure Test
${results['Directory Structure'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['Directory Structure'] == true ? 'All required directories are present and properly structured.' : 'Some directories are missing or incorrectly structured.'}

### File Naming Test
${results['File Naming'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['File Naming'] == true ? 'All files follow the established naming conventions.' : 'Some files have invalid names that don\'t follow naming conventions.'}

### Import Statements Test
${results['Import Statements'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['Import Statements'] == true ? 'All import statements are updated and valid.' : 'Some import statements still reference old file paths.'}

### Barrel Exports Test
${results['Barrel Exports'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['Barrel Exports'] == true ? 'All barrel export files are present and properly configured.' : 'Some barrel export files are missing or empty.'}

### Flutter Dependencies Test
${results['Flutter Dependencies'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['Flutter Dependencies'] == true ? 'All required Flutter dependencies are present.' : 'Some required dependencies are missing from pubspec.yaml.'}

### Build Process Test
${results['Build Process'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['Build Process'] == true ? 'Flutter clean, pub get, and analyze all passed successfully.' : 'Build process encountered errors.'}

### Test Execution Test
${results['Test Execution'] == true ? '✅ PASSED' : '❌ FAILED'}
${results['Test Execution'] == true ? 'All unit and widget tests pass successfully.' : 'Some tests failed or encountered errors.'}

## Recommendations

### If All Tests Passed ✅
1. Review the new project structure
2. Update team documentation
3. Begin development with new structure
4. Monitor for any issues in production

### If Some Tests Failed ❌
1. Address the failed tests one by one
2. Run the test script again after fixes
3. Ensure all tests pass before proceeding
4. Consider manual verification of complex issues

## Next Steps

1. **Fix Failed Tests**: Address any failing tests
2. **Manual Verification**: Manually test key features
3. **Team Training**: Ensure team understands new structure
4. **Documentation Update**: Update all relevant documentation
5. **CI/CD Update**: Update build scripts if needed

## Rollback Plan

If critical issues arise:
1. Restore from backup created during reorganization
2. Identify specific issues
3. Apply targeted fixes
4. Test thoroughly before redeployment

## Support

For assistance with reorganization issues:
1. Review this test report
2. Check the project structure documentation
3. Contact the development team
4. Create issues for specific problems

---

**Test Environment**: Flutter ${await _getFlutterVersion()}
**Platform**: ${Platform.operatingSystem}
**Test Date**: ${DateTime.now().toString().split('.')[0]}
''';
    
    await reportFile.writeAsString(content);
    print('📄 Test report generated: docs/project_reorganization_test_report.md');
  }
  
  static Future<String> _getFlutterVersion() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      return result.stdout.toString().trim();
    } catch (e) {
      return 'Unknown';
    }
  }
}

void main() async {
  await ProjectTester.runAllTests();
}
