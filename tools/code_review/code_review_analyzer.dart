import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Code Review Analyzer for VedantaTrade
/// Identifies redundant code, structural issues, and optimization opportunities
void main(List<String> args) async {
  final projectPath = args.isNotEmpty ? args[0] : Directory.current.path;
  final analyzer = CodeReviewAnalyzer(projectPath);
  
  print('🔍 Starting comprehensive code review...');
  final report = await analyzer.analyze();
  report.printSummary();
  
  // Save report to file
  final reportPath = path.join(projectPath, 'code_review_report.json');
  await report.saveToFile(reportPath);
}

class CodeReviewAnalyzer {
  final String projectPath;
  final List<String> _issues = [];
  final List<String> _recommendations = [];
  final Map<String, int> _fileCounts = {};
  final Map<String, List<String>> _duplicateFiles = {};
  
  CodeReviewAnalyzer(this.projectPath);
  
  /// Run comprehensive code review
  Future<CodeReviewReport> analyze() async {
    print('🔍 Starting comprehensive code review...');
    
    // Clear previous results
    _issues.clear();
    _recommendations.clear();
    _fileCounts.clear();
    _duplicateFiles.clear();
    
    // Run all analysis checks
    await _analyzeProjectStructure();
    await _analyzeDuplicateFiles();
    await _analyzeAuthenticationModule();
    await _analyzeImportStatements();
    await _analyzeNamingConventions();
    await _analyzeUnusedFiles();
    await _analyzePerformanceIssues();
    await _analyzeSecurityIssues();
    await _analyzeCodeDuplication();
    
    return _generateReport();
  }
  
  /// Analyze project structure
  Future<void> _analyzeProjectStructure() async {
    print('📁 Analyzing project structure...');
    
    final libPath = path.join(projectPath, 'lib');
    final featuresPath = path.join(libPath, 'features');
    
    if (!await Directory(featuresPath).exists()) {
      _issues.add('Features directory not found');
      return;
    }
    
    // Check for duplicate feature modules
    final featureDirs = await Directory(featuresPath).list().where((entity) => 
      entity is Directory && !entity.path.contains('.')
    ).toList();
    
    final featureNames = <String>{};
    for (final dir in featureDirs) {
      final dirName = path.basename(dir.path);
      if (featureNames.contains(dirName.toLowerCase())) {
        _issues.add('Duplicate feature directory: $dirName');
        _duplicateFiles[dirName] = (_duplicateFiles[dirName] ?? []) + [dir.path];
      }
      featureNames.add(dirName.toLowerCase());
    }
    
    // Check for structural inconsistencies
    await _checkFeatureStructure(featureDirs);
    
    // Check for backup directories
    await _checkBackupDirectories();
  }
  
  /// Check feature structure consistency
  Future<void> _checkFeatureStructure(List<FileSystemEntity> featureDirs) async {
    for (final dir in featureDirs) {
      final dirName = path.basename(dir.path);
      final featurePath = dir.path;
      
      // Check for standard clean architecture structure
      final expectedDirs = ['domain', 'data', 'presentation'];
      final actualDirs = <String>[];
      
      try {
        final subdirs = await Directory(featurePath).list().where((entity) => 
          entity is Directory
        ).toList();
        
        for (final subdir in subdirs) {
          actualDirs.add(path.basename(subdir.path));
        }
      } catch (e) {
        _issues.add('Cannot read feature directory: $dirName');
        continue;
      }
      
      for (final expectedDir in expectedDirs) {
        if (!actualDirs.contains(expectedDir)) {
          _issues.add('Missing $expectedDir directory in feature: $dirName');
        }
      }
      
      // Check for domain structure
      if (actualDirs.contains('domain')) {
        await _checkDomainStructure(path.join(featurePath, 'domain'), dirName);
      }
    }
  }
  
  /// Check domain structure
  Future<void> _checkDomainStructure(String domainPath, String featureName) async {
    try {
      final domainDirs = await Directory(domainPath).list().where((entity) => 
        entity is Directory
      ).toList();
      
      final hasEntities = domainDirs.any((dir) => 
        path.basename(dir.path) == 'entities'
      );
      final hasRepositories = domainDirs.any((dir) => 
        path.basename(dir.path) == 'repositories'
      );
      final hasServices = domainDirs.any((dir) => 
        path.basename(dir.path) == 'services'
      );
      
      if (!hasEntities) {
        _issues.add('Missing entities directory in domain: $featureName');
      }
      if (!hasRepositories) {
        _issues.add('Missing repositories directory in domain: $featureName');
      }
      if (!hasServices) {
        _recommendations.add('Consider adding services directory in domain: $featureName');
      }
    } catch (e) {
      _issues.add('Cannot analyze domain structure for: $featureName');
    }
  }
  
  /// Check for backup directories
  Future<void> _checkBackupDirectories() async {
    final projectDir = Directory(projectPath);
    final entities = await projectDir.list().toList();
    
    for (final entity in entities) {
      if (entity is Directory && 
          (entity.path.contains('backup') || 
           entity.path.contains('cleanup') ||
           entity.path.contains('temp'))) {
        _issues.add('Backup/temporary directory found in project root: ${path.basename(entity.path)}');
        _recommendations.add('Remove backup directories from project root');
      }
    }
  }
  
  /// Analyze duplicate files
  Future<void> _analyzeDuplicateFiles() async {
    print('🔍 Analyzing duplicate files...');
    
    final libPath = path.join(projectPath, 'lib');
    await _findDuplicateFiles(libPath);
  }
  
  /// Find duplicate files recursively
  Future<void> _findDuplicateFiles(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (!await dir.exists()) return;
      
      final entities = await dir.list().toList();
      final fileMap = <String, List<String>>{};
      
      for (final entity in entities) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          if (!fileMap.containsKey(fileName)) {
            fileMap[fileName] = [];
          }
          fileMap[fileName]!.add(entity.path);
        } else if (entity is Directory) {
          await _findDuplicateFiles(entity.path);
        }
      }
      
      // Report duplicates
      for (final entry in fileMap.entries) {
        if (entry.value.length > 1) {
          _issues.add('Duplicate file found: ${entry.key} (${entry.value.length} copies)');
          _duplicateFiles[entry.key] = entry.value;
        }
      }
    } catch (e) {
      _issues.add('Error analyzing directory: $dirPath');
    }
  }
  
  /// Analyze authentication module issues
  Future<void> _analyzeAuthenticationModule() async {
    print('🔐 Analyzing authentication module...');
    
    // Check for duplicate authentication providers
    final authPath = path.join(projectPath, 'lib', 'features');
    final authProviders = <String>[];
    
    try {
      final authDir = Directory(path.join(authPath, 'authentication'));
      if (await authDir.exists()) {
        final providerPath = path.join(authDir.path, 'presentation', 'providers');
        final providerDir = Directory(providerPath);
        
        if (await providerDir.exists()) {
          final providers = await providerDir.list().where((entity) => 
            entity is File && entity.path.endsWith('_provider.dart')
          ).toList();
          
          for (final provider in providers) {
            final fileName = path.basename(provider.path);
            if (fileName.contains('auth_provider.dart') || 
                fileName.contains('authentication_provider.dart')) {
              authProviders.add(provider.path);
            }
          }
        }
      }
    } catch (e) {
      _issues.add('Error analyzing authentication module');
    }
    
    if (authProviders.length > 1) {
      _issues.add('Multiple authentication providers found (${authProviders.length})');
      _recommendations.add('Consolidate authentication providers to avoid conflicts');
    }
    
    // Check for auth vs authentication naming
    final authDir = Directory(path.join(authPath, 'auth'));
    final authenticationDir = Directory(path.join(authPath, 'authentication'));
    
    if (await authDir.exists() && await authenticationDir.exists()) {
      _issues.add('Both auth and authentication directories exist');
      _recommendations.add('Consolidate to single authentication module');
    }
  }
  
  /// Analyze import statements
  Future<void> _analyzeImportStatements() async {
    print('📦 Analyzing import statements...');
    
    final libPath = path.join(projectPath, 'lib');
    await _analyzeImportsInDirectory(libPath);
  }
  
  /// Analyze imports in directory
  Future<void> _analyzeImportsInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _analyzeFileImports(entity.path);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _analyzeImportsInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Analyze imports in a file
  Future<void> _analyzeFileImports(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        if (trimmedLine.startsWith('import ') && trimmedLine.contains('../')) {
          // Check for relative import issues
          if (trimmedLine.contains('../../') || 
              trimmedLine.contains('../../../')) {
            _issues.add('Deep relative import in: ${path.basename(filePath)}');
            _recommendations.add('Use barrel exports or restructure to reduce deep imports');
          }
        }
        
        // Check for unused imports (basic check)
        if (trimmedLine.startsWith('import ') && 
            trimmedLine.contains('vedanta_trade/features/')) {
          final importPath = trimmedLine.split(' ')[1];
          final featureName = importPath.split('/')[3];
          
          if (importPath.contains('auth') && importPath.contains('authentication')) {
            _issues.add('Conflicting import path: $importPath');
          }
        }
      }
    } catch (e) {
      // Skip files that can't be read
    }
  }
  
  /// Analyze naming conventions
  Future<void> _analyzeNamingConventions() async {
    print('📝 Analyzing naming conventions...');
    
    final libPath = path.join(projectPath, 'lib');
    await _checkFileNaming(libPath);
  }
  
  /// Check file naming conventions
  Future<void> _checkFileNaming(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          final fileName = path.basenameWithoutExtension(entity.path);
          
          // Check for camelCase vs snake_case
          if (fileName.contains('_') && !fileName.endsWith('_test') && 
              !fileName.endsWith('_widget')) {
            _recommendations.add('Consider using camelCase for: $fileName.dart');
          }
          
          // Check for consecutive underscores
          if (fileName.contains('__')) {
            _issues.add('Invalid filename: $fileName.dart (consecutive underscores)');
          }
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _checkFileNaming(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Analyze unused files
  Future<void> _analyzeUnusedFiles() async {
    print('🗑️ Analyzing unused files...');
    
    // Check for empty files
    final libPath = path.join(projectPath, 'lib');
    await _findEmptyFiles(libPath);
  }
  
  /// Find empty files
  Future<void> _findEmptyFiles(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.size == 0) {
            _issues.add('Empty file found: ${entity.path}');
            _recommendations.add('Remove empty files or add content');
          }
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _findEmptyFiles(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Analyze performance issues
  Future<void> _analyzePerformanceIssues() async {
    print('⚡ Analyzing performance issues...');
    
    final libPath = path.join(projectPath, 'lib');
    await _checkPerformanceInDirectory(libPath);
  }
  
  /// Check performance issues in directory
  Future<void> _checkPerformanceInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _analyzeFilePerformance(entity.path);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _checkPerformanceInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Analyze file performance
  Future<void> _analyzeFilePerformance(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      
      // Check for large files
      if (lines.length > 500) {
        _recommendations.add('Consider splitting large file: ${path.basename(filePath)} (${lines.length} lines)');
      }
      
      // Check for potential performance issues
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        
        // Check for print statements in production code
        if (line.startsWith('print(') && !filePath.contains('test')) {
          _issues.add('Print statement found in production code: ${path.basename(filePath)}:$i');
        }
        
        // Check for TODO comments
        if (line.startsWith('// TODO:') || line.startsWith('/* TODO:')) {
          _recommendations.add('TODO item found: ${path.basename(filePath)}:$i');
        }
        
        // Check for hardcoded values
        if (line.contains('http://') || line.contains('https://') && 
            !line.contains('example.com')) {
          _issues.add('Hardcoded URL found: ${path.basename(filePath)}:$i');
        }
      }
    } catch (e) {
      // Skip files that can't be read
    }
  }
  
  /// Analyze security issues
  Future<void> _analyzeSecurityIssues() async {
    print('🔒 Analyzing security issues...');
    
    final libPath = path.join(projectPath, 'lib');
    await _checkSecurityInDirectory(libPath);
  }
  
  /// Check security issues in directory
  Future<void> _checkSecurityInDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _analyzeFileSecurity(entity.path);
        } else if (entity is Directory && !entity.path.contains('.')) {
          await _checkSecurityInDirectory(entity.path);
        }
      }
    } catch (e) {
      // Skip directories that can't be read
    }
  }
  
  /// Analyze file security
  Future<void> _analyzeFileSecurity(String filePath) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        
        // Check for hardcoded passwords or API keys
        if (line.contains('password') || line.contains('secret') || 
            line.contains('api_key') || line.contains('token')) {
          if (line.contains('=') && !line.contains('//')) {
            _issues.add('Potential hardcoded secret found: ${path.basename(filePath)}:$i');
          }
        }
        
        // Check for insecure HTTP usage
        if (line.contains('http://') && !line.contains('https://') &&
            !line.contains('localhost') && !line.contains('example')) {
          _issues.add('Insecure HTTP usage: ${path.basename(filePath)}:$i');
        }
      }
    } catch (e) {
      // Skip files that can't be read
    }
  }
  
  /// Analyze code duplication
  Future<void> _analyzeCodeDuplication() async {
    print('🔄 Analyzing code duplication...');
    
    // Check for similar authentication providers
    await _compareAuthenticationProviders();
  }
  
  /// Compare authentication providers for duplication
  Future<void> _compareAuthenticationProviders() async {
    final authProviderPath = path.join(projectPath, 'lib', 'features', 'authentication', 'presentation', 'providers');
    
    try {
      final providerDir = Directory(authProviderPath);
      if (!await providerDir.exists()) return;
      
      final providers = await providerDir.list().where((entity) => 
        entity is File && entity.path.endsWith('_provider.dart')
      ).toList();
      
      if (providers.length >= 2) {
        _issues.add('Multiple authentication providers detected - potential code duplication');
        _recommendations.add('Consolidate authentication providers to single implementation');
        
        // Analyze content similarity
        for (int i = 0; i < providers.length - 1; i++) {
          for (int j = i + 1; j < providers.length; j++) {
            final similarity = await _calculateFileSimilarity(
              providers[i].path, 
              providers[j].path
            );
            
            if (similarity > 0.7) {
              _issues.add('High similarity (${(similarity * 100).toInt()}%) between authentication providers');
            }
          }
        }
      }
    } catch (e) {
      _issues.add('Error comparing authentication providers');
    }
  }
  
  /// Calculate similarity between two files
  Future<double> _calculateFileSimilarity(String filePath1, String filePath2) async {
    try {
      final content1 = await File(filePath1).readAsString();
      final content2 = await File(filePath2).readAsString();
      
      final lines1 = content1.split('\n');
      final lines2 = content2.split('\n');
      
      int commonLines = 0;
      int totalLines = lines1.length + lines2.length;
      
      for (final line1 in lines1) {
        if (lines2.contains(line1)) {
          commonLines++;
        }
      }
      
      return totalLines > 0 ? commonLines / totalLines : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Generate comprehensive report
  CodeReviewReport _generateReport() {
    return CodeReviewReport(
      issues: _issues,
      recommendations: _recommendations,
      duplicateFiles: _duplicateFiles,
      fileCounts: _fileCounts,
      generatedAt: DateTime.now(),
    );
  }
}

/// Code Review Report
class CodeReviewReport {
  final List<String> issues;
  final List<String> recommendations;
  final Map<String, List<String>> duplicateFiles;
  final Map<String, int> fileCounts;
  final DateTime generatedAt;
  
  const CodeReviewReport({
    required this.issues,
    required this.recommendations,
    required this.duplicateFiles,
    required this.fileCounts,
    required this.generatedAt,
  });
  
  /// Print report summary
  void printSummary() {
    print('\n' + '='*60);
    print('📊 CODE REVIEW REPORT');
    print('='*60);
    print('Generated: ${generatedAt.toIso8601String()}');
    print('');
    
    print('🔍 ISSUES FOUND (${issues.length}):');
    if (issues.isEmpty) {
      print('  ✅ No critical issues found!');
    } else {
      for (int i = 0; i < issues.length; i++) {
        print('  ${i + 1}. ${issues[i]}');
      }
    }
    
    print('\n💡 RECOMMENDATIONS (${recommendations.length}):');
    if (recommendations.isEmpty) {
      print('  ✅ No recommendations needed!');
    } else {
      for (int i = 0; i < recommendations.length; i++) {
        print('  ${i + 1}. ${recommendations[i]}');
      }
    }
    
    if (duplicateFiles.isNotEmpty) {
      print('\n📁 DUPLICATE FILES:');
      for (final entry in duplicateFiles.entries) {
        print('  ${entry.key}: ${entry.value.length} copies');
        for (final path in entry.value) {
          print('    - $path');
        }
      }
    }
    
    print('\n' + '='*60);
  }
  
  /// Export report to JSON
  Map<String, dynamic> toJson() {
    return {
      'generatedAt': generatedAt.toIso8601String(),
      'summary': {
        'totalIssues': issues.length,
        'totalRecommendations': recommendations.length,
        'totalDuplicateFiles': duplicateFiles.length,
      },
      'issues': issues,
      'recommendations': recommendations,
      'duplicateFiles': duplicateFiles.map((key, value) => MapEntry(key, value)),
      'fileCounts': fileCounts,
    };
  }
  
  /// Save report to file
  Future<void> saveToFile(String outputPath) async {
    final reportFile = File(outputPath);
    await reportFile.writeAsString(jsonEncode(toJson()));
    print('📄 Report saved to: $outputPath');
  }
}
