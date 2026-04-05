import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Build Analyzer for VedantaTrade
/// Analyzes codebase, identifies issues, and generates reports
class BuildAnalyzer {
  static const String _projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const List<String> _dartExtensions = ['.dart'];
  static const List<String> _ignorePatterns = [
    '.git',
    'build',
    '.dart_tool',
    'node_modules',
    '.vscode',
    'android',
    'ios',
    'web',
  ];

  /// Run complete codebase analysis
  static Future<AnalysisReport> analyzeCodebase() async {
    print('🔍 Starting codebase analysis...');
    
    final report = AnalysisReport();
    
    // Analyze Dart files
    await _analyzeDartFiles(report);
    
    // Analyze dependencies
    await _analyzeDependencies(report);
    
    // Analyze project structure
    await _analyzeProjectStructure(report);
    
    // Check for common issues
    await _checkCommonIssues(report);
    
    // Generate report
    await _generateReport(report);
    
    print('✅ Codebase analysis complete!');
    return report;
  }

  /// Analyze all Dart files in the project
  static Future<void> _analyzeDartFiles(AnalysisReport report) async {
    print('📝 Analyzing Dart files...');
    
    final dartFiles = await _findDartFiles(_projectRoot);
    report.totalDartFiles = dartFiles.length;
    
    for (final file in dartFiles) {
      await _analyzeDartFile(file, report);
    }
    
    print('📊 Analyzed ${dartFiles.length} Dart files');
  }

  /// Find all Dart files recursively
  static Future<List<File>> _findDartFiles(String directory) async {
    final files = <File>[];
    final dir = Directory(directory);
    
    if (!await dir.exists()) return files;
    
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && 
          _dartExtensions.contains(path.extension(entity.path)) &&
          !_shouldIgnore(entity.path)) {
        files.add(entity);
      }
    }
    
    return files;
  }

  /// Check if path should be ignored
  static bool _shouldIgnore(String filePath) {
    final normalizedPath = path.normalize(filePath);
    for (final pattern in _ignorePatterns) {
      if (normalizedPath.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Analyze individual Dart file
  static Future<void> _analyzeDartFile(File file, AnalysisReport report) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');
      
      // Check file size
      if (content.length > 10000) {
        report.largeFiles.add(file.path);
      }
      
      // Check for common issues
      await _checkFileIssues(file, lines, report);
      
      // Count imports
      final imports = _extractImports(content);
      report.totalImports += imports.length;
      
      // Count lines of code
      final linesOfCode = _countLinesOfCode(lines);
      report.totalLinesOfCode += linesOfCode;
      
    } catch (e) {
      report.errors.add('Failed to analyze ${file.path}: $e');
    }
  }

  /// Check for common file issues
  static Future<void> _checkFileIssues(File file, List<String> lines, AnalysisReport report) async {
    final content = lines.join('\n');
    
    // Check for TODO comments
    if (content.contains('TODO:') || content.contains('TODO:')) {
      report.todos.add(file.path);
    }
    
    // Check for FIXME comments
    if (content.contains('FIXME:') || content.contains('FIXME:')) {
      report.fixmes.add(file.path);
    }
    
    // Check for long lines
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].length > 120) {
        report.longLines.add('${file.path}:${i + 1}');
      }
    }
    
    // Check for missing documentation
    if (!content.contains('///') && !content.contains('/**')) {
      report.undocumentedFiles.add(file.path);
    }
    
    // Check for hardcoded strings
    if (content.contains('http://') || content.contains('https://')) {
      report.hardcodedUrls.add(file.path);
    }
  }

  /// Extract imports from file content
  static List<String> _extractImports(String content) {
    final imports = <String>[];
    final lines = content.split('\n');
    
    for (final line in lines) {
      if (line.trim().startsWith("import '") || 
          line.trim().startsWith('import "') ||
          line.trim().startsWith("import 'package:")) {
        imports.add(line.trim());
      }
    }
    
    return imports;
  }

  /// Count actual lines of code (excluding comments and empty lines)
  static int _countLinesOfCode(List<String> lines) {
    int count = 0;
    bool inMultilineComment = false;
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // Skip empty lines
      if (trimmed.isEmpty) continue;
      
      // Handle multiline comments
      if (trimmed.startsWith('/*')) {
        inMultilineComment = true;
        continue;
      }
      if (trimmed.endsWith('*/')) {
        inMultilineComment = false;
        continue;
      }
      if (inMultilineComment) continue;
      
      // Skip single line comments
      if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;
      
      count++;
    }
    
    return count;
  }

  /// Analyze project dependencies
  static Future<void> _analyzeDependencies(AnalysisReport report) async {
    print('📦 Analyzing dependencies...');
    
    final pubspecFile = File(path.join(_projectRoot, 'pubspec.yaml'));
    if (!await pubspecFile.exists()) {
      report.errors.add('pubspec.yaml not found');
      return;
    }
    
    try {
      final content = await pubspecFile.readAsString();
      // Simple dependency counting (would use yaml parser in real implementation)
      final dependencies = content.split('\n').where((line) => 
          line.trim().startsWith('  ') && line.contains(':')).length;
      
      report.totalDependencies = dependencies;
    } catch (e) {
      report.errors.add('Failed to parse pubspec.yaml: $e');
    }
  }

  /// Analyze project structure
  static Future<void> _analyzeProjectStructure(AnalysisReport report) async {
    print('🏗️ Analyzing project structure...');
    
    // Check for required directories
    final requiredDirs = [
      'lib',
      'test',
      'docs',
      'tools',
    ];
    
    for (final dir in requiredDirs) {
      final dirPath = path.join(_projectRoot, dir);
      if (!await Directory(dirPath).exists()) {
        report.missingDirectories.add(dir);
      }
    }
    
    // Check for required files
    final requiredFiles = [
      'README.md',
      'pubspec.yaml',
      'analysis_options.yaml',
    ];
    
    for (final file in requiredFiles) {
      final filePath = path.join(_projectRoot, file);
      if (!await File(filePath).exists()) {
        report.missingFiles.add(file);
      }
    }
  }

  /// Check for common project issues
  static Future<void> _checkCommonIssues(AnalysisReport report) async {
    print('🔧 Checking for common issues...');
    
    // Check for .gitignore
    final gitignoreFile = File(path.join(_projectRoot, '.gitignore'));
    if (!await gitignoreFile.exists()) {
      report.missingFiles.add('.gitignore');
    }
    
    // Check for analysis_options.yaml
    final analysisFile = File(path.join(_projectRoot, 'analysis_options.yaml'));
    if (!await analysisFile.exists()) {
      report.missingFiles.add('analysis_options.yaml');
    }
    
    // Check for test directory
    final testDir = Directory(path.join(_projectRoot, 'test'));
    if (!await testDir.exists()) {
      report.missingDirectories.add('test');
    } else {
      // Count test files
      final testFiles = await _findDartFiles(testDir.path);
      report.totalTestFiles = testFiles.length;
    }
  }

  /// Generate analysis report
  static Future<void> _generateReport(AnalysisReport report) async {
    print('📊 Generating analysis report...');
    
    final reportDir = Directory(path.join(_projectRoot, 'build', 'reports'));
    if (!await reportDir.exists()) {
      await reportDir.create(recursive: true);
    }
    
    // Generate JSON report
    final jsonReport = File(path.join(reportDir.path, 'analysis_report.json'));
    await jsonReport.writeAsString(
      JsonEncoder.withIndent('  ').convert(report.toJson())
    );
    
    // Generate Markdown report
    final mdReport = File(path.join(reportDir.path, 'analysis_report.md'));
    await mdReport.writeAsString(_generateMarkdownReport(report));
    
    print('📄 Reports generated in ${reportDir.path}');
  }

  /// Generate Markdown report
  static String _generateMarkdownReport(AnalysisReport report) {
    final buffer = StringBuffer();
    
    buffer.writeln('# VedantaTrade Code Analysis Report');
    buffer.writeln();
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    
    // Summary
    buffer.writeln('## 📊 Summary');
    buffer.writeln();
    buffer.writeln('- **Total Dart Files**: ${report.totalDartFiles}');
    buffer.writeln('- **Total Lines of Code**: ${report.totalLinesOfCode}');
    buffer.writeln('- **Total Imports**: ${report.totalImports}');
    buffer.writeln('- **Total Dependencies**: ${report.totalDependencies}');
    buffer.writeln('- **Total Test Files**: ${report.totalTestFiles}');
    buffer.writeln();
    
    // Issues
    if (report.hasIssues()) {
      buffer.writeln('## 🚨 Issues Found');
      buffer.writeln();
      
      if (report.todos.isNotEmpty) {
        buffer.writeln('### TODO Comments');
        for (final todo in report.todos) {
          buffer.writeln('- $todo');
        }
        buffer.writeln();
      }
      
      if (report.fixmes.isNotEmpty) {
        buffer.writeln('### FIXME Comments');
        for (final fixme in report.fixmes) {
          buffer.writeln('- $fixme');
        }
        buffer.writeln();
      }
      
      if (report.errors.isNotEmpty) {
        buffer.writeln('### Errors');
        for (final error in report.errors) {
          buffer.writeln('- $error');
        }
        buffer.writeln();
      }
      
      if (report.missingFiles.isNotEmpty) {
        buffer.writeln('### Missing Files');
        for (final file in report.missingFiles) {
          buffer.writeln('- $file');
        }
        buffer.writeln();
      }
      
      if (report.missingDirectories.isNotEmpty) {
        buffer.writeln('### Missing Directories');
        for (final dir in report.missingDirectories) {
          buffer.writeln('- $dir');
        }
        buffer.writeln();
      }
    } else {
      buffer.writeln('## ✅ No Issues Found');
      buffer.writeln();
    }
    
    // Recommendations
    buffer.writeln('## 💡 Recommendations');
    buffer.writeln();
    
    if (report.todos.isNotEmpty) {
      buffer.writeln('- Address TODO comments before release');
    }
    
    if (report.largeFiles.isNotEmpty) {
      buffer.writeln('- Consider breaking down large files into smaller components');
    }
    
    if (report.undocumentedFiles.isNotEmpty) {
      buffer.writeln('- Add documentation to public APIs and classes');
    }
    
    if (report.totalTestFiles < report.totalDartFiles ~/ 2) {
      buffer.writeln('- Increase test coverage (current: ${((report.totalTestFiles / report.totalDartFiles) * 100).toStringAsFixed(1)}%)');
    }
    
    return buffer.toString();
  }
}

/// Analysis Report Data Model
class AnalysisReport {
  int totalDartFiles = 0;
  int totalLinesOfCode = 0;
  int totalImports = 0;
  int totalDependencies = 0;
  int totalTestFiles = 0;
  
  List<String> todos = [];
  List<String> fixmes = [];
  List<String> errors = [];
  List<String> largeFiles = [];
  List<String> undocumentedFiles = [];
  List<String> hardcodedUrls = [];
  List<String> longLines = [];
  List<String> missingFiles = [];
  List<String> missingDirectories = [];
  
  bool hasIssues() {
    return todos.isNotEmpty ||
           fixmes.isNotEmpty ||
           errors.isNotEmpty ||
           largeFiles.isNotEmpty ||
           undocumentedFiles.isNotEmpty ||
           hardcodedUrls.isNotEmpty ||
           longLines.isNotEmpty ||
           missingFiles.isNotEmpty ||
           missingDirectories.isNotEmpty;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'totalDartFiles': totalDartFiles,
        'totalLinesOfCode': totalLinesOfCode,
        'totalImports': totalImports,
        'totalDependencies': totalDependencies,
        'totalTestFiles': totalTestFiles,
        'hasIssues': hasIssues(),
      },
      'issues': {
        'todos': todos,
        'fixmes': fixmes,
        'errors': errors,
        'largeFiles': largeFiles,
        'undocumentedFiles': undocumentedFiles,
        'hardcodedUrls': hardcodedUrls,
        'longLines': longLines,
        'missingFiles': missingFiles,
        'missingDirectories': missingDirectories,
      },
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }
}

/// Main entry point for build analysis
void main() async {
  await BuildAnalyzer.analyzeCodebase();
}
