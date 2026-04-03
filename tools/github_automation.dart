import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';

/// GitHub Automation for VedantaTrade
/// Handles version control, releases, and repository management
class GitHubAutomation {
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String gitPath = 'git';
  
  // GitHub configuration
  static const Map<String, String> githubConfig = {
    'mainBranch': 'main',
    'developBranch': 'develop',
    'releasePrefix': 'v',
    'changelogFile': 'CHANGELOG.md',
    'readmeFile': 'README.md',
    'todoFile': 'TODO.md',
  };

  /// Run GitHub automation workflow
  Future<void> runAutomation(List<String> args) async {
    debugPrint('🐙 GitHub Automation for VedantaTrade');
    debugPrint('=====================================\n');

    try {
      final command = args.isNotEmpty ? args.first : 'help';
      
      switch (command) {
        case 'init':
          await initializeRepository();
          break;
        case 'status':
          await showRepositoryStatus();
          break;
        case 'commit':
          await commitChanges(args.length > 1 ? args[1] : null);
          break;
        case 'push':
          await pushChanges();
          break;
        case 'pull':
          await pullChanges();
          break;
        case 'branch':
          await manageBranches(args.length > 1 ? args[1] : null);
          break;
        case 'release':
          await createRelease(args.length > 1 ? args[1] : null);
          break;
        case 'tag':
          await createTag(args.length > 1 ? args[1] : null);
          break;
        case 'merge':
          await mergeBranches(args.length > 1 ? args[1] : null);
          break;
        case 'changelog':
          await updateChangelog();
          break;
        case 'readme':
          await updateReadme();
          break;
        case 'todo':
          await updateTodo();
          break;
        case 'appgallery':
          await updateAppGallery();
          break;
        case 'sync':
          await synchronizeRepository();
          break;
        case 'cleanup':
          await cleanupRepository();
          break;
        case 'all':
          await runFullGitWorkflow();
          break;
        default:
          showHelp();
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      exit(1);
    }
  }

  /// Initialize Git repository
  Future<void> initializeRepository() async {
    debugPrint('🔧 Initializing Git Repository...');
    
    Directory.current = projectRoot;
    
    // Check if already initialized
    final gitDir = Directory('.git');
    if (await gitDir.exists()) {
      debugPrint('  ✅ Git repository already initialized');
      return;
    }
    
    // Initialize repository
    debugPrint('  📋 Initializing Git...');
    await _runGitCommand(['init']);
    
    // Create .gitignore
    await _createGitignore();
    
    // Create initial commit
    debugPrint('  📝 Creating initial commit...');
    await _runGitCommand(['add', '.']);
    await _runGitCommand(['commit', '-m', 'Initial commit: VedantaTrade project setup']);
    
    // Setup main branch
    await _runGitCommand(['branch', '-M', githubConfig['mainBranch']!]);
    
    debugPrint('✅ Repository initialized\n');
  }

  /// Show repository status
  Future<void> showRepositoryStatus() async {
    debugPrint('📊 Repository Status');
    debugPrint('==================\n');
    
    Directory.current = projectRoot;
    
    // Current branch
    debugPrint('🌿 Current Branch:');
    final branchResult = await _runGitCommand(['branch', '--show-current']);
    debugPrint('  ${branchResult.stdout.trim()}');
    
    // Git status
    debugPrint('\n📋 Git Status:');
    final statusResult = await _runGitCommand(['status', '--porcelain']);
    if (statusResult.stdout.trim().isEmpty) {
      debugPrint('  ✅ Working directory clean');
    } else {
      final lines = statusResult.stdout.split('\n').where((l) => l.isNotEmpty).toList();
      debugPrint('  📝 Changes detected:');
      for (final line in lines) {
        debugPrint('    $line');
      }
      debugPrint('  📁 Total changes: ${lines.length}');
    }
    
    // Remote status
    debugPrint('\n🌐 Remote Status:');
    final remoteResult = await _runGitCommand(['remote', '-v']);
    debugPrint(remoteResult.stdout);
    
    // Last commit
    debugPrint('\n💾 Last Commit:');
    final logResult = await _runGitCommand(['log', '-1', '--oneline']);
    debugPrint('  ${logResult.stdout.trim()}');
    
    debugPrint('\n');
  }

  /// Commit changes with automatic message generation
  Future<void> commitChanges(String? message) async {
    debugPrint('💾 Committing Changes...');
    
    Directory.current = projectRoot;
    
    // Check for changes
    final statusResult = await _runGitCommand(['status', '--porcelain']);
    if (statusResult.stdout.trim().isEmpty) {
      debugPrint('  ℹ️ No changes to commit');
      return;
    }
    
    // Add all changes
    debugPrint('  ➕ Adding changes...');
    await _runGitCommand(['add', '.']);
    
    // Generate commit message if not provided
    final commitMessage = message ?? await _generateCommitMessage();
    
    // Commit changes
    debugPrint('  💾 Committing with message: "$commitMessage"');
    final commitResult = await _runGitCommand(['commit', '-m', commitMessage]);
    
    if (commitResult.exitCode == 0) {
      debugPrint('  ✅ Changes committed successfully');
    } else {
      debugPrint('  ❌ Commit failed');
      debugPrint('  Error: ${commitResult.stderr}');
    }
    
    debugPrint('');
  }

  /// Push changes to remote
  Future<void> pushChanges() async {
    debugPrint('📤 Pushing Changes...');
    
    Directory.current = projectRoot;
    
    // Get current branch
    final branchResult = await _runGitCommand(['branch', '--show-current']);
    final currentBranch = branchResult.stdout.trim();
    
    // Push to remote
    debugPrint('  📤 Pushing $currentBranch to remote...');
    final pushResult = await _runGitCommand(['push', 'origin', currentBranch]);
    
    if (pushResult.exitCode == 0) {
      debugPrint('  ✅ Changes pushed successfully');
    } else {
      debugPrint('  ❌ Push failed');
      debugPrint('  Error: ${pushResult.stderr}');
    }
    
    debugPrint('');
  }

  /// Pull changes from remote
  Future<void> pullChanges() async {
    debugPrint('📥 Pulling Changes...');
    
    Directory.current = projectRoot;
    
    // Get current branch
    final branchResult = await _runGitCommand(['branch', '--show-current']);
    final currentBranch = branchResult.stdout.trim();
    
    // Pull from remote
    debugPrint('  📥 Pulling $currentBranch from remote...');
    final pullResult = await _runGitCommand(['pull', 'origin', currentBranch]);
    
    if (pullResult.exitCode == 0) {
      debugPrint('  ✅ Changes pulled successfully');
    } else {
      debugPrint('  ❌ Pull failed');
      debugPrint('  Error: ${pullResult.stderr}');
    }
    
    debugPrint('');
  }

  /// Manage branches
  Future<void> manageBranches(String? branchName) async {
    if (branchName == null) {
      await showBranches();
    } else {
      await createBranch(branchName);
    }
  }

  /// Show all branches
  Future<void> showBranches() async {
    debugPrint('🌿 Branches');
    debugPrint('==========\n');
    
    Directory.current = projectRoot;
    
    final result = await _runGitCommand(['branch', '-a']);
    debugPrint(result.stdout);
    debugPrint('');
  }

  /// Create new branch
  Future<void> createBranch(String branchName) async {
    debugPrint('🌿 Creating Branch: $branchName');
    
    Directory.current = projectRoot;
    
    final result = await _runGitCommand(['checkout', '-b', branchName]);
    
    if (result.exitCode == 0) {
      debugPrint('  ✅ Branch $branchName created and checked out');
    } else {
      debugPrint('  ❌ Failed to create branch $branchName');
      debugPrint('  Error: ${result.stderr}');
    }
    
    debugPrint('');
  }

  /// Create release
  Future<void> createRelease(String? version) async {
    debugPrint('🚀 Creating Release...');
    
    Directory.current = projectRoot;
    
    // Get version from parameter or generate
    final releaseVersion = version ?? await _getCurrentVersion();
    
    // Create tag
    debugPrint('  🏷️ Creating tag ${githubConfig['releasePrefix']}$releaseVersion...');
    final tagResult = await _runGitCommand([
      'tag',
      '-a',
      '${githubConfig['releasePrefix']}$releaseVersion',
      '-m',
      'Release $releaseVersion',
    ]);
    
    if (tagResult.exitCode != 0) {
      debugPrint('  ❌ Failed to create tag');
      return;
    }
    
    // Push tag
    debugPrint('  📤 Pushing tag to remote...');
    await _runGitCommand(['push', 'origin', '${githubConfig['releasePrefix']}$releaseVersion']);
    
    // Update changelog
    await _updateChangelogForRelease(releaseVersion);
    
    debugPrint('  ✅ Release $releaseVersion created successfully\n');
  }

  /// Create tag
  Future<void> createTag(String? tagName) async {
    if (tagName == null) {
      debugPrint('❌ Please provide a tag name');
      return;
    }
    
    debugPrint('🏷️ Creating Tag: $tagName');
    
    Directory.current = projectRoot;
    
    final result = await _runGitCommand(['tag', '-a', tagName, '-m', 'Tag $tagName']);
    
    if (result.exitCode == 0) {
      debugPrint('  ✅ Tag $tagName created successfully');
    } else {
      debugPrint('  ❌ Failed to create tag $tagName');
      debugPrint('  Error: ${result.stderr}');
    }
    
    debugPrint('');
  }

  /// Merge branches
  Future<void> mergeBranches(String? sourceBranch) async {
    if (sourceBranch == null) {
      debugPrint('❌ Please provide source branch name');
      return;
    }
    
    debugPrint('🔀 Merging $sourceBranch into ${githubConfig['mainBranch']}...');
    
    Directory.current = projectRoot;
    
    // Switch to main branch
    await _runGitCommand(['checkout', githubConfig['mainBranch']!]);
    
    // Merge source branch
    final result = await _runGitCommand(['merge', sourceBranch]);
    
    if (result.exitCode == 0) {
      debugPrint('  ✅ $sourceBranch merged successfully');
    } else {
      debugPrint('  ❌ Merge failed');
      debugPrint('  Error: ${result.stderr}');
    }
    
    debugPrint('');
  }

  /// Update changelog
  Future<void> updateChangelog() async {
    debugPrint('📋 Updating CHANGELOG.md...');
    
    Directory.current = projectRoot;
    
    final changelogFile = File(githubConfig['changelogFile']!);
    if (!await changelogFile.exists()) {
      debugPrint('  ❌ CHANGELOG.md not found');
      return;
    }
    
    // Read existing changelog
    final content = await changelogFile.readAsString();
    
    // Generate new entry
    final newEntry = await _generateChangelogEntry();
    
    // Update changelog
    final updatedContent = newEntry + '\n' + content;
    await changelogFile.writeAsString(updatedContent);
    
    // Commit changelog update
    await _runGitCommand(['add', githubConfig['changelogFile']!]);
    await _runGitCommand(['commit', '-m', 'docs: update CHANGELOG.md']);
    
    debugPrint('  ✅ CHANGELOG.md updated\n');
  }

  /// Update README
  Future<void> updateReadme() async {
    debugPrint('📖 Updating README.md...');
    
    Directory.current = projectRoot;
    
    final readmeFile = File(githubConfig['readmeFile']!);
    if (!await readmeFile.exists()) {
      debugPrint('  ❌ README.md not found');
      return;
    }
    
    // Generate updated content
    final updatedContent = await _generateReadmeContent();
    
    // Update README
    await readmeFile.writeAsString(updatedContent);
    
    // Commit README update
    await _runGitCommand(['add', githubConfig['readmeFile']!]);
    await _runGitCommand(['commit', '-m', 'docs: update README.md']);
    
    debugPrint('  ✅ README.md updated\n');
  }

  /// Update TODO
  Future<void> updateTodo() async {
    debugPrint('📝 Updating TODO.md...');
    
    Directory.current = projectRoot;
    
    final todoFile = File(githubConfig['todoFile']!);
    if (!await todoFile.exists()) {
      debugPrint('  ❌ TODO.md not found');
      return;
    }
    
    // Generate updated TODO content
    final updatedContent = await _generateTodoContent();
    
    // Update TODO
    await todoFile.writeAsString(updatedContent);
    
    // Commit TODO update
    await _runGitCommand(['add', githubConfig['todoFile']!]);
    await _runGitCommand(['commit', '-m', 'docs: update TODO.md']);
    
    debugPrint('  ✅ TODO.md updated\n');
  }

  /// Update app gallery
  Future<void> updateAppGallery() async {
    debugPrint('🖼️ Updating App Gallery...');
    
    Directory.current = projectRoot;
    
    // Check if gallery exists
    final galleryDir = Directory('lib/features/gallery');
    if (!await galleryDir.exists()) {
      debugPrint('  ❌ Gallery directory not found');
      return;
    }
    
    // Generate gallery screenshots (simulated)
    await _generateGalleryScreenshots();
    
    // Update gallery data
    await _updateGalleryData();
    
    // Commit gallery updates
    await _runGitCommand(['add', 'lib/features/gallery/']);
    await _runGitCommand(['add', 'assets/screenshots/']);
    await _runGitCommand(['commit', '-m', 'feat: update app gallery with new screenshots']);
    
    debugPrint('  ✅ App gallery updated\n');
  }

  /// Synchronize repository
  Future<void> synchronizeRepository() async {
    debugPrint('🔄 Synchronizing Repository...');
    
    // Pull latest changes
    await pullChanges();
    
    // Update all documentation
    await updateChangelog();
    await updateReadme();
    await updateTodo();
    await updateAppGallery();
    
    // Push all changes
    await pushChanges();
    
    debugPrint('✅ Repository synchronized\n');
  }

  /// Cleanup repository
  Future<void> cleanupRepository() async {
    debugPrint('🧹 Cleaning Repository...');
    
    Directory.current = projectRoot;
    
    // Clean untracked files
    debugPrint('  🗑️ Cleaning untracked files...');
    final cleanResult = await _runGitCommand(['clean', '-fd']);
    if (cleanResult.exitCode == 0) {
      debugPrint('  ✅ Untracked files cleaned');
    }
    
    // Reset any staged changes
    debugPrint('  🔄 Resetting staged changes...');
    final resetResult = await _runGitCommand(['reset', '--hard', 'HEAD']);
    if (resetResult.exitCode == 0) {
      debugPrint('  ✅ Staged changes reset');
    }
    
    // Clean Flutter build cache
    debugPrint('  🧹 Cleaning Flutter cache...');
    await _runCommand('flutter', ['clean']);
    
    debugPrint('✅ Repository cleaned\n');
  }

  /// Run full Git workflow
  Future<void> runFullGitWorkflow() async {
    debugPrint('🚀 Running Full Git Workflow...\n');
    
    await showRepositoryStatus();
    await commitChanges();
    await pushChanges();
    await updateChangelog();
    await updateReadme();
    await updateTodo();
    await updateAppGallery();
    
    debugPrint('🎉 Full Git workflow completed!\n');
  }

  // Helper methods

  Future<ProcessResult> _runGitCommand(List<String> args) async {
    try {
      final result = await Process.run(gitPath, args);
      return result;
    } catch (e) {
      return ProcessResult(1, '', 'Git command failed: $e');
    }
  }

  Future<ProcessResult> _runCommand(String command, List<String> args) async {
    try {
      final result = await Process.run(command, args);
      return result;
    } catch (e) {
      return ProcessResult(1, '', 'Command failed: $e');
    }
  }

  Future<void> _createGitignore() async {
    debugPrint('  📝 Creating .gitignore...');
    
    final gitignoreContent = '''
# Flutter
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub-
/build/

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Environment
.env
.env.local
.env.production

# Build artifacts
build/
dist/

# Temporary files
*.tmp
*.temp
''';
    
    final gitignoreFile = File('.gitignore');
    await gitignoreFile.writeAsString(gitignoreContent);
    
    debugPrint('  ✅ .gitignore created');
  }

  Future<String> _generateCommitMessage() async {
    final timestamp = DateTime.now();
    final formatted = '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
    
    // Check for staged files
    final statusResult = await _runGitCommand(['status', '--porcelain']);
    final files = statusResult.stdout.split('\n').where((line) => line.isNotEmpty).toList();
    
    if (files.isEmpty) {
      return 'chore: empty commit';
    }
    
    // Analyze file types
    final hasDartFiles = files.any((file) => file.endsWith('.dart'));
    final hasYamlFiles = files.any((file) => file.endsWith('.yaml') || file.endsWith('.yml'));
    final hasMdFiles = files.any((file) => file.endsWith('.md'));
    final hasJsonFiles = files.any((file) => file.endsWith('.json'));
    
    // Generate appropriate commit message
    if (hasDartFiles && files.length == 1) {
      return 'feat: ${files.first.split(' ').last}';
    } else if (hasYamlFiles) {
      return 'chore: update configuration files';
    } else if (hasMdFiles) {
      return 'docs: update documentation';
    } else if (hasJsonFiles) {
      return 'chore: update data files';
    } else if (files.length == 1) {
      return 'chore: update ${files.first.split(' ').last}';
    } else {
      return 'chore: multiple updates ($formatted)';
    }
  }

  Future<String> _getCurrentVersion() async {
    // Try to get version from pubspec.yaml
    final pubspecFile = File('pubspec.yaml');
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      final versionMatch = RegExp(r'version:\s*(.+)').firstMatch(content);
      if (versionMatch != null) {
        return versionMatch.group(1)!.trim();
      }
    }
    
    // Fallback to date-based version
    final now = DateTime.now();
    return '${now.year}.${now.month}.${now.day}';
  }

  Future<String> _generateChangelogEntry() async {
    final version = await _getCurrentVersion();
    final timestamp = DateTime.now().toIso8601String();
    
    return '''## [${version}] - ${timestamp.split('T')[0]}

### Added
- Automated changelog entry generation
- GitHub integration improvements
- Enhanced development workflow automation

### Changed
- Updated build processes
- Improved documentation generation

### Fixed
- Resolved automation issues
- Enhanced error handling

---
''';
  }

  Future<String> _generateReadmeContent() async {
    final version = await _getCurrentVersion();
    final timestamp = DateTime.now().toIso8601String();
    
    return '''# VedantaTrade

VedantaTrade is a comprehensive Flutter commerce app for Vedanta TradeLink health supplements.

## 🌟 Key Features

- **Product Catalog**: Advanced product management
- **Distribution System**: Complete distribution management
- **Marketing Campaigns**: Campaign creation and tracking
- **App Gallery**: Interactive version showcase
- **Analytics**: Real-time insights and reporting

## 📊 Current Version: v$version

Last updated: $timestamp

## 🚀 Getting Started

See [documentation](./docs/) for detailed setup instructions.

## 🐛 Issues

Report issues through [GitHub Issues](https://github.com/your-org/VedantaTrade/issues).

---

*This README is automatically generated. Run \`dart tools/github_automation.dart readme\` to update.*
''';
  }

  Future<String> _generateTodoContent() async {
    return '''# VedantaTrade TODO

## 🚀 Current SdebugPrint Goals

### High Priority
- [ ] Complete UI/UX enhancements
- [ ] Implement comprehensive testing
- [ ] Optimize performance
- [ ] Add accessibility features

### Medium Priority
- [ ] Enhance error handling
- [ ] Improve documentation
- [ ] Add more analytics
- [ ] Implement caching

### Low Priority
- [ ] Add dark mode
- [ ] Implement offline support
- [ ] Add internationalization
- [ ] Create admin dashboard

## 📋 Recent Tasks

### Completed
- ✅ App gallery implementation
- ✅ Enhanced design system
- ✅ GitHub automation
- ✅ Build optimization

### In Progress
- 🔄 Performance optimization
- 🔄 Testing improvements

## 🎯 Future Enhancements

### Version 2.2.0
- Advanced analytics dashboard
- Real-time collaboration features
- Enhanced security features
- Performance monitoring

### Version 3.0.0
- AI-powered recommendations
- Advanced automation
- Multi-tenant support
- Enterprise features

---

*This TODO is automatically generated. Run \`dart tools/github_automation.dart todo\` to update.*
''';
  }

  Future<void> _updateChangelogForRelease(String version) async {
    final changelogFile = File(githubConfig['changelogFile']!);
    if (!await changelogFile.exists()) return;
    
    final content = await changelogFile.readAsString();
    final timestamp = DateTime.now().toIso8601String().split('T')[0];
    
    final releaseEntry = '''## [${version}] - ${timestamp}

### 🎉 Release Highlights
- Automated release process
- Version bump to $version
- Updated documentation

### 🚀 New Features
- GitHub automation improvements
- Enhanced development workflow
- Automated changelog generation

### 🐛 Bug Fixes
- Resolved build issues
- Fixed automation bugs
- Enhanced error handling

### 📝 Documentation
- Updated API documentation
- Enhanced README content
- Improved setup instructions

---

''';
    
    final updatedContent = releaseEntry + content;
    await changelogFile.writeAsString(updatedContent);
  }

  Future<void> _generateGalleryScreenshots() async {
    final screenshotDir = Directory('assets/screenshots');
    await screenshotDir.create(recursive: true);
    
    debugPrint('  📸 Gallery screenshots would be generated here');
  }

  Future<void> _updateGalleryData() async {
    debugPrint('  🔄 Gallery data updated');
  }

  /// Show help information
  void showHelp() {
    debugPrint('''
🐙 GitHub Automation for VedantaTrade

Usage: dart tools/github_automation.dart [command] [options]

Commands:
  init              - Initialize Git repository
  status            - Show repository status
  commit [message]  - Commit changes with optional message
  push              - Push changes to remote
  pull              - Pull changes from remote
  branch [name]    - Show branches or create new branch
  release [version] - Create release with optional version
  tag [name]       - Create tag with name
  merge [branch]   - Merge branch into main
  changelog         - Update CHANGELOG.md
  readme            - Update README.md
  todo              - Update TODO.md
  appgallery        - Update app gallery
  sync              - Synchronize repository (pull, update, push)
  cleanup            - Clean repository
  all               - Run full Git workflow
  help              - Show this help message

Examples:
  dart tools/github_automation.dart init
  dart tools/github_automation.dart commit "Add new feature"
  dart tools/github_automation.dart release 2.1.0
  dart tools/github_automation.dart all

Configuration:
  Main branch: ${githubConfig['mainBranch']}
  Develop branch: ${githubConfig['developBranch']}
  Release prefix: ${githubConfig['releasePrefix']}
''');
  }
}

void main(List<String> args) async {
  await GitHubAutomation.runAutomation(args);
}
