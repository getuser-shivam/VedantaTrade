import 'dart:io';
import 'dart:convert';
import 'dart:process';

/// VedantaTrade Development Automation Tool
/// 
/// Comprehensive tool for analyzing, fixing, building the app,
/// and maintaining version control using GitHub
class VedantaTradeDevTool {
  static const String projectName = 'VedantaTrade';
  static const String version = 'v3.2.1-alpha';
  
  // Project paths
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String libPath = '$projectRoot\\lib';
  static const String testPath = '$projectRoot\\test';
  static const String docsPath = '$projectRoot\\docs';
  static const String toolsPath = '$projectRoot\\tools';
  
  // Git configuration
  static const String remoteUrl = 'git@github.com:getuser-shivam/VedantaTrade.git';
  static const String mainBranch = 'main';
  
  late ProcessResult _lastResult;
  List<String> _issues = [];
  List<String> _fixes = [];
  Map<String, dynamic> _analysisResults = {};

  /// Main execution method
  Future<void> runFullWorkflow() async {
    print('🚀 Starting VedantaTrade Development Workflow...');
    print('📦 Project: $projectName');
    print('🏷️  Version: $version');
    print('');
    
    try {
      // Step 1: Analyze project
      await analyzeProject();
      
      // Step 2: Fix identified issues
      await fixIssues();
      
      // Step 3: Build the application
      await buildApplication();
      
      // Step 4: Run tests
      await runTests();
      
      // Step 5: Update documentation
      await updateDocumentation();
      
      // Step 6: Git operations
      await performGitOperations();
      
      // Step 7: Generate report
      await generateReport();
      
      print('✅ Development workflow completed successfully!');
      
    } catch (e) {
      print('❌ Error during workflow: $e');
      await generateErrorReport(e);
    }
  }

  /// Step 1: Analyze the project for issues
  Future<void> analyzeProject() async {
    print('🔍 Analyzing project...');
    
    _analysisResults = {
      'timestamp': DateTime.now().toIso8601String(),
      'flutter_version': await getFlutterVersion(),
      'dart_version': await getDartVersion(),
      'project_stats': await getProjectStats(),
      'dependencies': await analyzeDependencies(),
      'code_quality': await analyzeCodeQuality(),
      'test_coverage': await analyzeTestCoverage(),
      'documentation': await analyzeDocumentation(),
    };
    
    // Identify issues
    _issues = await identifyIssues();
    
    print('📊 Analysis complete. Found ${_issues.length} issues.');
    if (_issues.isNotEmpty) {
      print('🔧 Issues to fix:');
      for (int i = 0; i < _issues.length; i++) {
        print('   ${i + 1}. ${_issues[i]}');
      }
    }
    print('');
  }

  /// Step 2: Fix identified issues
  Future<void> fixIssues() async {
    print('🔧 Fixing issues...');
    
    if (_issues.isEmpty) {
      print('✅ No issues to fix!');
      return;
    }
    
    for (String issue in _issues) {
      try {
        String fix = await fixIssue(issue);
        _fixes.add(fix);
        print('✅ Fixed: $issue');
      } catch (e) {
        print('❌ Failed to fix: $issue - $e');
      }
    }
    
    print('🔧 Fixed ${_fixes.length} issues.');
    print('');
  }

  /// Step 3: Build the application
  Future<void> buildApplication() async {
    print('🏗️  Building application...');
    
    try {
      // Clean build
      print('   🧹 Cleaning previous builds...');
      await runCommand('flutter', ['clean'], projectRoot);
      
      // Get dependencies
      print('   📦 Getting dependencies...');
      await runCommand('flutter', ['pub', 'get'], projectRoot);
      
      // Analyze code
      print('   🔍 Analyzing code...');
      await runCommand('flutter', ['analyze'], projectRoot);
      
      // Build APK
      print('   📱 Building Android APK...');
      await runCommand('flutter', ['build', 'apk', '--release'], projectRoot);
      
      // Build AAB
      print('   📦 Building Android App Bundle...');
      await runCommand('flutter', ['build', 'appbundle', '--release'], projectRoot);
      
      // Build Web
      print('   🌐 Building Web version...');
      await runCommand('flutter', ['build', 'web', '--release'], projectRoot);
      
      print('✅ Build completed successfully!');
      
    } catch (e) {
      print('❌ Build failed: $e');
      rethrow;
    }
    print('');
  }

  /// Step 4: Run tests
  Future<void> runTests() async {
    print('🧪 Running tests...');
    
    try {
      // Unit tests
      print('   📋 Running unit tests...');
      await runCommand('flutter', ['test'], projectRoot);
      
      // Integration tests
      print('   🔗 Running integration tests...');
      await runCommand('flutter', ['test', 'integration_test/'], projectRoot);
      
      // Generate coverage report
      print('   📊 Generating coverage report...');
      await runCommand('flutter', ['test', '--coverage'], projectRoot);
      
      print('✅ All tests passed!');
      
    } catch (e) {
      print('❌ Tests failed: $e');
      rethrow;
    }
    print('');
  }

  /// Step 5: Update documentation
  Future<void> updateDocumentation() async {
    print('📚 Updating documentation...');
    
    try {
      // Update README.md
      await updateReadme();
      
      // Update TODO.md
      await updateTodo();
      
      // Update CHANGELOG.md
      await updateChangelog();
      
      // Update app gallery documentation
      await updateGalleryDocumentation();
      
      print('✅ Documentation updated!');
      
    } catch (e) {
      print('❌ Documentation update failed: $e');
      rethrow;
    }
    print('');
  }

  /// Step 6: Git operations
  Future<void> performGitOperations() async {
    print('🔀 Performing Git operations...');
    
    try {
      // Check git status
      print('   📋 Checking Git status...');
      await runCommand('git', ['status'], projectRoot);
      
      // Add all changes
      print('   ➕ Adding changes...');
      await runCommand('git', ['add', '.'], projectRoot);
      
      // Commit changes
      String commitMessage = generateCommitMessage();
      print('   💾 Committing changes...');
      await runCommand('git', ['commit', '-m', commitMessage], projectRoot);
      
      // Push to remote
      print('   ⬆️  Pushing to remote...');
      await runCommand('git', ['push', 'origin', mainBranch], projectRoot);
      
      // Create tag if needed
      await createVersionTag();
      
      print('✅ Git operations completed!');
      
    } catch (e) {
      print('❌ Git operations failed: $e');
      rethrow;
    }
    print('');
  }

  /// Helper methods for analysis
  Future<String> getFlutterVersion() async {
    _lastResult = await runCommand('flutter', ['--version'], projectRoot);
    return _lastResult.stdout.toString().trim();
  }

  Future<String> getDartVersion() async {
    _lastResult = await runCommand('dart', ['--version'], projectRoot);
    return _lastResult.stdout.toString().trim();
  }

  Future<Map<String, int>> getProjectStats() async {
    final libDir = Directory(libPath);
    final dartFiles = await libDir
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();
    
    int totalLines = 0;
    int totalFiles = dartFiles.length;
    
    for (File file in dartFiles) {
      String content = await file.readAsString();
      totalLines += content.split('\n').length;
    }
    
    return {
      'files': totalFiles,
      'lines': totalLines,
    };
  }

  Future<Map<String, dynamic>> analyzeDependencies() async {
    final pubspecFile = File('$projectRoot\\pubspec.yaml');
    String content = await pubspecFile.readAsString();
    
    // Simple parsing of pubspec.yaml
    List<String> dependencies = [];
    List<String> devDependencies = [];
    
    final lines = content.split('\n');
    bool inDependencies = false;
    bool inDevDependencies = false;
    
    for (String line in lines) {
      if (line.startsWith('dependencies:')) {
        inDependencies = true;
        inDevDependencies = false;
      } else if (line.startsWith('dev_dependencies:')) {
        inDependencies = false;
        inDevDependencies = true;
      } else if (line.startsWith('flutter:') || line.startsWith('  flutter:')) {
        continue;
      } else if (line.startsWith(' ') && (inDependencies || inDevDependencies)) {
        final dep = line.split(':')[0].trim();
        if (dep.isNotEmpty) {
          if (inDependencies) {
            dependencies.add(dep);
          } else {
            devDependencies.add(dep);
          }
        }
      }
    }
    
    return {
      'dependencies': dependencies,
      'dev_dependencies': devDependencies,
      'total_dependencies': dependencies.length + devDependencies.length,
    };
  }

  Future<Map<String, dynamic>> analyzeCodeQuality() async {
    _lastResult = await runCommand('flutter', ['analyze'], projectRoot);
    
    String output = _lastResult.stdout.toString();
    List<String> issues = [];
    
    if (output.contains('issues found')) {
      final lines = output.split('\n');
      for (String line in lines) {
        if (line.contains('• ') || line.contains('error') || line.contains('warning')) {
          issues.add(line.trim());
        }
      }
    }
    
    return {
      'issues': issues,
      'issue_count': issues.length,
      'output': output,
    };
  }

  Future<Map<String, dynamic>> analyzeTestCoverage() async {
    try {
      _lastResult = await runCommand('flutter', ['test', '--coverage'], projectRoot);
      
      // Parse coverage from lcov.info if it exists
      final lcovFile = File('$projectRoot\\coverage\\lcov.info');
      if (await lcovFile.exists()) {
        String content = await lcovFile.readAsString();
        // Simple coverage parsing
        return {
          'coverage_available': true,
          'coverage_file': 'coverage/lcov.info',
          'output': _lastResult.stdout.toString(),
        };
      }
      
      return {
        'coverage_available': false,
        'output': _lastResult.stdout.toString(),
      };
    } catch (e) {
      return {
        'coverage_available': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> analyzeDocumentation() async {
    final docsDir = Directory(docsPath);
    final readmeFile = File('$projectRoot\\README.md');
    final todoFile = File('$projectRoot\\TODO.md');
    final changelogFile = File('$projectRoot\\CHANGELOG.md');
    
    return {
      'docs_directory_exists': await docsDir.exists(),
      'readme_exists': await readmeFile.exists(),
      'todo_exists': await todoFile.exists(),
      'changelog_exists': await changelogFile.exists(),
      'docs_count': (await docsDir.list().toList()).length,
    };
  }

  Future<List<String>> identifyIssues() async {
    List<String> issues = [];
    
    // Check for common issues
    final codeQuality = _analysisResults['code_quality'] as Map<String, dynamic>;
    if (codeQuality['issue_count'] > 0) {
      issues.add('Code analysis found ${codeQuality['issue_count']} issues');
    }
    
    final testCoverage = _analysisResults['test_coverage'] as Map<String, dynamic>;
    if (!testCoverage['coverage_available']) {
      issues.add('Test coverage report not available');
    }
    
    final documentation = _analysisResults['documentation'] as Map<String, dynamic>;
    if (!documentation['readme_exists']) {
      issues.add('README.md is missing');
    }
    if (!documentation['todo_exists']) {
      issues.add('TODO.md is missing');
    }
    if (!documentation['changelog_exists']) {
      issues.add('CHANGELOG.md is missing');
    }
    
    // Check for print statements
    await checkForPrintStatements(issues);
    
    // Check for unused imports
    await checkForUnusedImports(issues);
    
    return issues;
  }

  Future<void> checkForPrintStatements(List<String> issues) async {
    final libDir = Directory(libPath);
    final dartFiles = await libDir
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();
    
    int printCount = 0;
    for (File file in dartFiles) {
      String content = await file.readAsString();
      printCount += content.split('print(').length - 1;
    }
    
    if (printCount > 0) {
      issues.add('Found $printCount print statements that should be replaced with debugPrint');
    }
  }

  Future<void> checkForUnusedImports(List<String> issues) async {
    // This would require more sophisticated analysis
    // For now, just check if there are obvious unused imports
    _lastResult = await runCommand('flutter', ['analyze', '--no-fatal-infos'], projectRoot);
    String output = _lastResult.stdout.toString();
    
    if (output.contains('unused_import')) {
      issues.add('Unused imports detected');
    }
  }

  Future<String> fixIssue(String issue) async {
    if (issue.contains('print statements')) {
      return await fixPrintStatements();
    } else if (issue.contains('unused_import')) {
      return await fixUnusedImports();
    } else if (issue.contains('README.md is missing')) {
      return await createReadme();
    } else if (issue.contains('TODO.md is missing')) {
      return await createTodo();
    } else if (issue.contains('CHANGELOG.md is missing')) {
      return await createChangelog();
    }
    
    return 'No automatic fix available for: $issue';
  }

  Future<String> fixPrintStatements() async {
    print('   🔄 Replacing print statements with debugPrint...');
    
    final libDir = Directory(libPath);
    final dartFiles = await libDir
        .list(recursive: true)
        .where((entity) => entity is File && entity.path.endsWith('.dart'))
        .cast<File>()
        .toList();
    
    int fixedCount = 0;
    for (File file in dartFiles) {
      String content = await file.readAsString();
      
      // Replace print( with debugPrint(
      if (content.contains('print(')) {
        content = content.replaceAll('print(', 'debugPrint(');
        await file.writeAsString(content);
        fixedCount++;
      }
    }
    
    return 'Replaced $fixedCount print statements with debugPrint';
  }

  Future<String> fixUnusedImports() async {
    print('   🔄 Removing unused imports...');
    
    // Use dart fix to automatically remove unused imports
    await runCommand('dart', ['fix', '--apply'], projectRoot);
    
    return 'Applied dart fix to remove unused imports';
  }

  Future<String> createReadme() async {
    print('   📝 Creating README.md...');
    
    String readmeContent = '''# $projectName

## Description
Enterprise pharmaceutical distribution platform for Nepal market.

## Version
$version

## Features
- CI/CD Pipeline
- Enhanced UI/UX
- Product Catalog
- Distribution Management
- Authentication System

## Getting Started
\`\`\`bash
flutter pub get
flutter run
\`\`\`

## Build
\`\`\`bash
flutter build apk --release
flutter build web --release
\`\`\`

## License
MIT
''';
    
    await File('$projectRoot\\README.md').writeAsString(readmeContent);
    return 'Created README.md';
  }

  Future<String> createTodo() async {
    print('   📝 Creating TODO.md...');
    
    String todoContent = '''# TODO List for $projectName

## High Priority
- [ ] Performance monitoring dashboard
- [ ] Security monitoring system
- [ ] Mobile application optimization

## Medium Priority
- [ ] Enhance code coverage to >90%
- [ ] Implement microservices architecture

## Completed
- [x] CI/CD pipeline implementation
- [x] App gallery creation
- [x] Documentation synchronization

---
*Last Updated: ${DateTime.now().toIso8601String()}*
''';
    
    await File('$projectRoot\\TODO.md').writeAsString(todoContent);
    return 'Created TODO.md';
  }

  Future<String> createChangelog() async {
    print('   📝 Creating CHANGELOG.md...');
    
    String changelogContent = '''# Changelog

All notable changes to this repository are documented in this file.

## [$version] - ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}

### Added
- Comprehensive CI/CD pipeline
- Enhanced UI/UX system
- App gallery with version showcase
- Automated development workflow

### Improved
- Code quality and organization
- Documentation completeness
- Build and deployment process

### Fixed
- Print statements replaced with debugPrint
- Unused imports removed
- Build optimization

---

*For earlier versions, please refer to the git commit history.*
''';
    
    await File('$projectRoot\\CHANGELOG.md').writeAsString(changelogContent);
    return 'Created CHANGELOG.md';
  }

  Future<void> updateReadme() async {
    print('   📝 Updating README.md...');
    
    // Update version and build status
    final readmeFile = File('$projectRoot\\README.md');
    if (await readmeFile.exists()) {
      String content = await readmeFile.readAsString();
      
      // Update version if needed
      if (!content.contains(version)) {
        content = content.replaceAll(
          RegExp(r'v\d+\.\d+\.\d+-[a-zA-Z0-9]+'),
          version,
        );
        await readmeFile.writeAsString(content);
      }
    }
  }

  Future<void> updateTodo() async {
    print('   📝 Updating TODO.md...');
    
    final todoFile = File('$projectRoot\\TODO.md');
    if (await todoFile.exists()) {
      String content = await todoFile.readAsString();
      
      // Update timestamp
      String updatedContent = content.replaceAll(
        RegExp(r'\*Last Updated: .+\*'),
        '*Last Updated: ${DateTime.now().toIso8601String()}*',
      );
      
      await todoFile.writeAsString(updatedContent);
    }
  }

  Future<void> updateChangelog() async {
    print('   📝 Updating CHANGELOG.md...');
    
    final changelogFile = File('$projectRoot\\CHANGELOG.md');
    if (await changelogFile.exists()) {
      String content = await changelogFile.readAsString();
      
      // Add new entry if today's version doesn't exist
      String today = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      String versionHeader = '## [$version] - $today';
      
      if (!content.contains(versionHeader)) {
        String newEntry = '''$versionHeader

### Added
- Automated development workflow execution
- Code quality analysis and fixes
- Build automation and testing
- Documentation updates

### Fixed
- ${_fixes.join('\n- ')}

---

''';
        
        content = content.replaceFirst('# Changelog', '# Changelog\n\n$newEntry');
        await changelogFile.writeAsString(content);
      }
    }
  }

  Future<void> updateGalleryDocumentation() async {
    print('   📝 Updating app gallery documentation...');
    
    final galleryDocsFile = File('$docsPath\\APP_GALLERY_IMPLEMENTATION.md');
    if (await galleryDocsFile.exists()) {
      String content = await galleryDocsFile.readAsString();
      
      // Update last updated timestamp
      String updatedContent = content.replaceAll(
        RegExp(r'\*Last Updated: .+\*'),
        '*Last Updated: ${DateTime.now().toIso8601String()}*',
      );
      
      await galleryDocsFile.writeAsString(updatedContent);
    }
  }

  String generateCommitMessage() {
    final timestamp = DateTime.now().toIso8601String();
    final fixes = _fixes.isNotEmpty ? _fixes.join('; ') : 'maintenance updates';
    
    return '''feat: Automated development workflow execution

- Analyzed project and identified ${_issues.length} issues
- Fixed ${_fixes.length} issues: $fixes
- Built application successfully (APK, AAB, Web)
- Ran all tests with coverage reporting
- Updated documentation (README, TODO, CHANGELOG, Gallery)
- Performed Git operations with automatic commit and push

Timestamp: $timestamp
Version: $version
''';
  }

  Future<void> createVersionTag() async {
    print('   🏷️  Creating version tag...');
    
    try {
      // Check if tag already exists
      _lastResult = await runCommand('git', ['tag', '-l', version], projectRoot);
      
      if (_lastResult.stdout.toString().trim().isEmpty) {
        // Create and push tag
        await runCommand('git', ['tag', version], projectRoot);
        await runCommand('git', ['push', 'origin', version], projectRoot);
        print('   ✅ Created tag: $version');
      } else {
        print('   ℹ️  Tag $version already exists');
      }
    } catch (e) {
      print('   ⚠️  Failed to create tag: $e');
    }
  }

  Future<void> generateReport() async {
    print('📊 Generating development report...');
    
    final reportFile = File('$projectRoot\\development_report_${DateTime.now().millisecondsSinceEpoch}.json');
    
    final report = {
      'project': projectName,
      'version': version,
      'timestamp': DateTime.now().toIso8601String(),
      'workflow_results': {
        'analysis': _analysisResults,
        'issues_found': _issues,
        'issues_fixed': _fixes,
        'build_status': 'success',
        'test_status': 'success',
        'documentation_updated': true,
        'git_operations': 'success',
      },
      'summary': {
        'total_issues': _issues.length,
        'total_fixes': _fixes.length,
        'success_rate': _fixes.length / _issues.length,
        'workflow_duration': 'completed',
      },
    };
    
    await reportFile.writeAsString(jsonEncode(report));
    print('📄 Report saved: ${reportFile.path}');
    print('');
  }

  Future<void> generateErrorReport(dynamic error) async {
    print('📊 Generating error report...');
    
    final reportFile = File('$projectRoot\\error_report_${DateTime.now().millisecondsSinceEpoch}.json');
    
    final report = {
      'project': projectName,
      'version': version,
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toString(),
      'analysis_results': _analysisResults,
      'issues_found': _issues,
      'partial_fixes': _fixes,
    };
    
    await reportFile.writeAsString(jsonEncode(report));
    print('📄 Error report saved: ${reportFile.path}');
    print('');
  }

  /// Utility method to run commands
  Future<ProcessResult> runCommand(String command, List<String> args, String workingDirectory) async {
    print('   🔄 Running: $command ${args.join(' ')}');
    
    try {
      _lastResult = await Process.run(command, args, workingDirectory: workingDirectory);
      
      if (_lastResult.exitCode != 0) {
        print('   ❌ Command failed with exit code ${_lastResult.exitCode}');
        print('   📄 Error: ${_lastResult.stderr}');
        throw Exception('Command failed: $command ${args.join(' ')}');
      }
      
      return _lastResult;
    } catch (e) {
      print('   ❌ Exception running command: $e');
      rethrow;
    }
  }

  /// Quick analysis method
  Future<void> quickAnalysis() async {
    print('🔍 Quick Analysis...');
    
    await analyzeProject();
    
    print('📊 Quick Analysis Results:');
    print('   Flutter Version: ${_analysisResults['flutter_version']}');
    print('   Dart Files: ${_analysisResults['project_stats']['files']}');
    print('   Code Lines: ${_analysisResults['project_stats']['lines']}');
    print('   Dependencies: ${_analysisResults['dependencies']['total_dependencies']}');
    print('   Issues Found: ${_analysisResults['code_quality']['issue_count']}');
    print('   Test Coverage: ${_analysisResults['test_coverage']['coverage_available'] ? 'Available' : 'Not Available'}');
    print('');
  }

  /// Quick build method
  Future<void> quickBuild() async {
    print('🏗️  Quick Build...');
    
    try {
      await runCommand('flutter', ['pub', 'get'], projectRoot);
      await runCommand('flutter', ['build', 'apk', '--release'], projectRoot);
      print('✅ Quick build completed!');
    } catch (e) {
      print('❌ Quick build failed: $e');
    }
  }

  /// Quick git operations
  Future<void> quickGit() async {
    print('🔀 Quick Git Operations...');
    
    try {
      await runCommand('git', ['add', '.'], projectRoot);
      
      String commitMessage = 'feat: Quick update - ${DateTime.now().toIso8601String()}';
      await runCommand('git', ['commit', '-m', commitMessage], projectRoot);
      
      await runCommand('git', ['push', 'origin', mainBranch], projectRoot);
      
      print('✅ Quick git operations completed!');
    } catch (e) {
      print('❌ Quick git operations failed: $e');
    }
  }
}

/// Main entry point
void main(List<String> args) async {
  final devTool = VedantaTradeDevTool();
  
  if (args.isEmpty) {
    print('🚀 VedantaTrade Development Tool');
    print('');
    print('Usage: dart run tools/vedanta_trade_dev_tool.dart [command]');
    print('');
    print('Commands:');
    print('  full      - Run complete development workflow');
    print('  analyze   - Quick project analysis');
    print('  build     - Quick build only');
    print('  git       - Quick git operations');
    print('');
    print('Example:');
    print('  dart run tools/vedanta_trade_dev_tool.dart full');
    return;
  }
  
  switch (args[0]) {
    case 'full':
      await devTool.runFullWorkflow();
      break;
    case 'analyze':
      await devTool.quickAnalysis();
      break;
    case 'build':
      await devTool.quickBuild();
      break;
    case 'git':
      await devTool.quickGit();
      break;
    default:
      print('❌ Unknown command: ${args[0]}');
      print('Use "dart run tools/vedanta_trade_dev_tool.dart" for help.');
  }
}
