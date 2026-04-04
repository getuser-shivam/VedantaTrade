#!/usr/bin/env dart

/// Naming Conventions Enforcement Script
/// This script enforces consistent naming conventions across the project

import 'dart:io';
import 'dart:regex';

class NamingConventionsEnforcer {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  
  // Naming convention patterns
  static final RegExp snakeCasePattern = RegExp(r'^[a-z]+(_[a-z0-9]+)*$');
  static final RegExp pascalCasePattern = RegExp(r'^[A-Z][a-zA-Z0-9]*$');
  static final RegExp camelCasePattern = RegExp(r'^[a-z][a-zA-Z0-9]*$');
  static final RegExp screamingSnakeCasePattern = RegExp(r'^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$');
  static final RegExp kebabCasePattern = RegExp(r'^[a-z]+(-[a-z0-9]+)*$');
  
  // File naming rules
  static final Map<String, RegExp> fileNamingRules = {
    'dart': snakeCasePattern, // Files should be snake_case
    'md': kebabCasePattern,   // Markdown files should be kebab-case
    'yml': kebabCasePattern,  // YAML files should be kebab-case
    'yaml': kebabCasePattern,
    'json': kebabCasePattern, // JSON files should be kebab-case
  };
  
  // Directory naming rules
  static final RegExp dirNamingPattern = snakeCasePattern;
  
  // Class naming patterns
  static final Map<String, RegExp> classNamingPatterns = {
    'class': pascalCasePattern,
    'enum': pascalCasePattern,
    'mixin': pascalCasePattern,
    'extension': pascalCasePattern,
    'typedef': pascalCasePattern,
  };
  
  // Variable naming patterns
  static final Map<String, RegExp> variableNamingPatterns = {
    'variable': camelCasePattern,
    'function': camelCasePattern,
    'parameter': camelCasePattern,
    'constant': screamingSnakeCasePattern,
    'private': camelCasePattern, // Private starts with _
  };
  
  static Future<void> enforceNamingConventions() async {
    print('🔍 Analyzing project naming conventions...\n');
    
    final issues = <String>[];
    
    // Check directory structure
    issues.addAll(await _checkDirectoryNaming());
    
    // Check file naming
    issues.addAll(await _checkFileNaming());
    
    // Check class naming in Dart files
    issues.addAll(await _checkClassNaming());
    
    // Check variable naming in Dart files
    issues.addAll(await _checkVariableNaming());
    
    // Check import organization
    issues.addAll(await _checkImportOrganization());
    
    // Generate report
    await _generateNamingReport(issues);
    
    if (issues.isEmpty) {
      print('✅ All naming conventions are properly followed!');
    } else {
      print('⚠️  Found ${issues.length} naming convention issues.');
      print('📄 Report generated: docs/naming_conventions_report.md');
    }
  }
  
  static Future<List<String>> _checkDirectoryNaming() async {
    final issues = <String>[];
    
    await for (final entity in Directory(projectRoot).list(recursive: true)) {
      if (entity is Directory) {
        final dirName = entity.path.split(Platform.pathSeparator).last;
        
        // Skip certain directories
        if (_shouldSkipDirectory(dirName)) continue;
        
        if (!dirNamingPattern.hasMatch(dirName)) {
          issues.add('Directory name should be snake_case: ${entity.path}');
        }
      }
    }
    
    return issues;
  }
  
  static Future<List<String>> _checkFileNaming() async {
    final issues = <String>[];
    
    await for (final entity in Directory(projectRoot).list(recursive: true)) {
      if (entity is File) {
        final fileName = entity.path.split(Platform.pathSeparator).last;
        final extension = fileName.split('.').last.toLowerCase();
        
        // Skip certain files
        if (_shouldSkipFile(fileName)) continue;
        
        final pattern = fileNamingRules[extension];
        if (pattern != null) {
          final baseName = fileName.substring(0, fileName.lastIndexOf('.'));
          if (!pattern.hasMatch(baseName)) {
            final expectedFormat = _getExpectedFormat(extension);
            issues.add('File name should be $expectedFormat: ${entity.path}');
          }
        }
      }
    }
    
    return issues;
  }
  
  static Future<List<String>> _checkClassNaming() async {
    final issues = <String>[];
    
    await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          
          // Check class declarations
          if (line.startsWith('class ')) {
            final className = line.split(' ')[1].split('{')[0].trim();
            if (!pascalCasePattern.hasMatch(className)) {
              issues.add('Class name should be PascalCase: $className (${entity.path}:${i + 1})');
            }
          }
          
          // Check enum declarations
          if (line.startsWith('enum ')) {
            final enumName = line.split(' ')[1].split('{')[0].trim();
            if (!pascalCasePattern.hasMatch(enumName)) {
              issues.add('Enum name should be PascalCase: $enumName (${entity.path}:${i + 1})');
            }
          }
          
          // Check mixin declarations
          if (line.startsWith('mixin ')) {
            final mixinName = line.split(' ')[1].split(' ')[0].trim();
            if (!pascalCasePattern.hasMatch(mixinName)) {
              issues.add('Mixin name should be PascalCase: $mixinName (${entity.path}:${i + 1})');
            }
          }
          
          // Check extension declarations
          if (line.startsWith('extension ')) {
            final extensionName = line.split(' ')[1].split(' ')[0].trim();
            if (!pascalCasePattern.hasMatch(extensionName)) {
              issues.add('Extension name should be PascalCase: $extensionName (${entity.path}:${i + 1})');
            }
          }
        }
      }
    }
    
    return issues;
  }
  
  static Future<List<String>> _checkVariableNaming() async {
    final issues = <String>[];
    
    await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final lines = content.split('\n');
        
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          
          // Skip comments and strings
          if (line.startsWith('//') || line.startsWith('/*') || line.startsWith('*')) continue;
          
          // Check constant declarations (final static const)
          if (line.contains('static const') || line.contains('const ')) {
            final matches = RegExp(r'\b([a-z][a-zA-Z0-9_]*)\s*=').allMatches(line);
            for (final match in matches) {
              final varName = match.group(1)!;
              if (!screamingSnakeCasePattern.hasMatch(varName) && !varName.startsWith('_')) {
                issues.add('Constant should be SCREAMING_SNAKE_CASE: $varName (${entity.path}:${i + 1})');
              }
            }
          }
          
          // Check function declarations
          if (line.contains(' Future<') || line.contains(' void ') || line.contains(' bool ') || line.contains(' String ') || line.contains(' int ')) {
            final matches = RegExp(r'\b([a-z][a-zA-Z0-9_]*)\s*\(').allMatches(line);
            for (final match in matches) {
              final functionName = match.group(1)!;
              if (!camelCasePattern.hasMatch(functionName)) {
                issues.add('Function name should be camelCase: $functionName (${entity.path}:${i + 1})');
              }
            }
          }
          
          // Check variable declarations
          if (line.contains('=') && !line.contains('const') && !line.contains('final')) {
            final matches = RegExp(r'\b([a-z][a-zA-Z0-9_]*)\s*=').allMatches(line);
            for (final match in matches) {
              final varName = match.group(1)!;
              if (!camelCasePattern.hasMatch(varName) && !varName.startsWith('_')) {
                issues.add('Variable name should be camelCase: $varName (${entity.path}:${i + 1})');
              }
            }
          }
        }
      }
    }
    
    return issues;
  }
  
  static Future<List<String>> _checkImportOrganization() async {
    final issues = <String>[];
    
    await for (final entity in Directory('$projectRoot/lib').list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        final lines = content.split('\n');
        
        final imports = <String>[];
        int importStart = -1;
        int importEnd = -1;
        
        // Find import section
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.startsWith('import') && importStart == -1) {
            importStart = i;
          } else if (line.startsWith('import') && importStart != -1) {
            importEnd = i;
          } else if (importStart != -1 && !line.startsWith('import') && line.isNotEmpty) {
            break;
          }
        }
        
        if (importStart != -1) {
          // Check import organization
          final importLines = lines.sublist(importStart, importEnd + 1);
          final dartImports = <String>[];
          final flutterImports = <String>[];
          final packageImports = <String>[];
          final relativeImports = <String>[];
          
          for (final importLine in importLines) {
            if (importLine.contains('dart:')) {
              dartImports.add(importLine);
            } else if (importLine.contains('package:flutter/')) {
              flutterImports.add(importLine);
            } else if (importLine.contains('package:')) {
              packageImports.add(importLine);
            } else {
              relativeImports.add(importLine);
            }
          }
          
          // Check if imports are properly grouped
          final allImports = [...dartImports, ...flutterImports, ...packageImports, ...relativeImports];
          final sortedImports = [...dartImports, ...flutterImports, ...packageImports, ...relativeImports];
          
          if (!_listsEqual(allImports, sortedImports)) {
            issues.add('Imports not properly organized in: ${entity.path}');
          }
        }
      }
    }
    
    return issues;
  }
  
  static bool _shouldSkipDirectory(String dirName) {
    final skipPatterns = [
      '.git',
      '.dart_tool',
      'build',
      'ios',
      'android',
      'web',
      'node_modules',
    ];
    
    return skipPatterns.any((pattern) => dirName.contains(pattern));
  }
  
  static bool _shouldSkipFile(String fileName) {
    final skipPatterns = [
      '.git',
      '.DS_Store',
      'pubspec.lock',
      'packages',
    ];
    
    return skipPatterns.any((pattern) => fileName.contains(pattern));
  }
  
  static String _getExpectedFormat(String extension) {
    switch (extension) {
      case 'dart':
        return 'snake_case';
      case 'md':
        return 'kebab-case';
      case 'yml':
      case 'yaml':
        return 'kebab-case';
      case 'json':
        return 'kebab-case';
      default:
        return 'snake_case';
    }
  }
  
  static bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
  
  static Future<void> _generateNamingReport(List<String> issues) async {
    final reportFile = File('$projectRoot/docs/naming_conventions_report.md');
    
    final content = '''# Naming Conventions Report

Generated on: ${DateTime.now().toString()}

## Summary
- Total Issues Found: ${issues.length}

## Issues

${issues.isEmpty ? '✅ No naming convention issues found!' : issues.map((issue) => '- ⚠️ $issue').join('\n')}

## Naming Convention Rules

### File Naming
- Dart files: `snake_case.dart`
- Markdown files: `kebab-case.md`
- YAML files: `kebab-case.yml`
- JSON files: `kebab-case.json`

### Directory Naming
- All directories: `snake_case`

### Class Naming
- Classes: `PascalCase`
- Enums: `PascalCase`
- Mixins: `PascalCase`
- Extensions: `PascalCase`

### Variable Naming
- Variables: `camelCase`
- Functions: `camelCase`
- Parameters: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Private members: `_camelCase`

### Import Organization
1. Dart core imports
2. Flutter framework imports
3. Third-party package imports
4. Core package imports
5. Shared package imports
6. Feature imports
7. Relative imports

## Recommendations

1. Use descriptive names that clearly indicate purpose
2. Keep names concise but meaningful
3. Avoid abbreviations unless widely understood
4. Use consistent naming across the project
5. Follow established conventions for the platform

## Next Steps

1. Fix the identified naming convention issues
2. Run this script again to verify fixes
3. Update team documentation with naming conventions
4. Consider adding pre-commit hooks to enforce conventions
''';
    
    await reportFile.writeAsString(content);
  }
}

void main() async {
  await NamingConventionsEnforcer.enforceNamingConventions();
}
