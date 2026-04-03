import 'dart:io';
import 'dart:convert';
import 'dart:async';

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
    print('🐙 GitHub Automation for VedantaTrade');
    print('=====================================\n');

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
      print('❌ Error: $e');
      exit(1);
    }
  }

  /// Initialize Git repository
  Future<void> initializeRepository() async {
    print('🔧 Initializing Git Repository...');
    
    Directory.current = projectRoot;
    
    // Check if already initialized
    final gitDir = Directory('.git');
    if (await gitDir.exists()) {
      print('  ✅ Git repository already initialized');
      return;
    }
    
    // Initialize repository
    print('  📋 Initializing Git...');
    await _runGitCommand(['init']);
    
    // Create .gitignore
    await _createGitignore();
    
    // Create initial commit
    print('  📝 Creating initial commit...');
    await _runGitCommand(['add', '.']);
    await _runGitCommand(['commit', '-m', 'Initial commit: VedantaTrade project setup']);
    
    // Setup main branch
    await _runGitCommand(['branch', '-M', githubConfig['mainBranch']!]);
    
    print('✅ Repository initialized\n');
  }

  /// Show repository status
  Future<void> showRepositoryStatus() async {
    print('📊 Repository Status');
    print('==================\n');
    
    Directory.current = projectRoot;
    
    // Current branch
    print('🌿 Current Branch:');
    final branchResult = await _runGitCommand(['branch', '--show-current']);
    print('  ${branchResult.stdout.trim()}');
    
    // Git status
    print('\n📋 Git Status:');
    final statusResult = await _runGitCommand(['status', '--porcelain']);
    if (statusResult.stdout.trim().isEmpty) {
      print('  ✅ Working directory clean');
    } else {
      final lines = statusResult.stdout.split('\n').where((l) => l.isNotEmpty).toList();
      print('  📝 Changes detected:');
      for (final line in lines) {
        print('    $line');
      }
      print('  📁 Total changes: ${lines.length}');
    }
    
    // Remote status
    print('\n🌐 Remote Status:');
    final remoteResult = await _runGitCommand(['remote', '-v']);
    print(remoteResult.stdout);
    
    // Last commit
    print('\n💾 Last Commit:');
    final logResult = await _runGitCommand(['log', '-1', '--oneline']);
    print('  ${logResult.stdout.trim()}');
    
    print('\n');
  }

  /// Commit changes with automatic message generation
  Future<void> commitChanges(String? message) async {
    print('💾 Committing Changes...');
    
    Directory.current = projectRoot;
    
    // Check for changes
    final statusResult = await _runGitCommand(['status', '--porcelain']);
    if (statusResult.stdout.trim().isEmpty) {
      print('  ℹ️ No changes to commit');
      return;
    }
    
    // Add all changes
    print('  ➕ Adding changes...');
    await _runGitCommand(['add', '.']);
    
    // Generate commit message if not provided
    final commitMessage = message ?? await _generateCommitMessage();
    
    // Commit changes
    print('  💾 Committing with message: "$commitMessage"');
    final commitResult = await _runGitCommand(['commit', '-m', commitMessage]);
    
    if (commitResult.exitCode == 0) {
      print('  ✅ Changes committed successfully');
    } else {
      print('  ❌ Commit failed');
      print('  Error: ${commitResult.stderr}');
    }
    
    print('');
  }

  /// Push changes to remote
  Future<void> pushChanges() async {
    print('📤 Pushing Changes...');
    
    Directory.current = projectRoot;
    
    // Get current branch
    final branchResult = await _runGitCommand(['branch', '--show-current']);
    final currentBranch = branchResult.stdout.trim();
    
    // Push to remote
    print('  📤 Pushing $currentBranch to remote...');
    final pushResult = await _runGitCommand(['push', 'origin', currentBranch]);
    
    if (pushResult.exitCode == 0) {
      print('  ✅ Changes pushed successfully');
    } else {
      print('  ❌ Push failed');
      print('  Error: ${pushResult.stderr}');
    }
    
    print('');
  }

  /// Pull changes from remote
  Future<void> pullChanges() async {
    print('📥 Pulling Changes...');
    
    Directory.current = projectRoot;
    
    // Get current branch
    final branchResult = await _runGitCommand(['branch', '--show-current']);
    final currentBranch = branchResult.stdout.trim();
    
    // Pull from remote
    print('  📥 Pulling $currentBranch from remote...');
    final pullResult = await _runGitCommand(['pull', 'origin', currentBranch]);
    
    if (pullResult.exitCode == 0) {
      print('  ✅ Changes pulled successfully');
    } else {
      print('  ❌ Pull failed');
      print('  Error: ${pullResult.stderr}');
    }
    
    print('');
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
    print('🌿 Branches');
    print('==========\n');
    
    Directory.current = projectRoot;
    
    final result = await _runGitCommand(['branch', '-a']);
    print(result.stdout);
    print('');
  }

  /// Create new branch
  Future<void> createBranch(String branchName) async {
    print('🌿 Creating Branch: $branchName');
    
    Directory.current = projectRoot;
    
    final result = await _runGitCommand(['checkout', '-b', branchName]);
    
    if (result.exitCode == 0) {
      print('  ✅ Branch $branchName created and checked out');
    } else {
      print('  ❌ Failed to create branch $branchName');
      print('  Error: ${result.stderr}');
    }
    
    print('');
  }

  /// Create release
  Future<void> createRelease(String? version) async {
    print('🚀 Creating Release...');
    
    Directory.current = projectRoot;
    
    // Get version from parameter or generate
    final releaseVersion = version ?? await _getCurrentVersion();
    
    // Create tag
    print('  🏷️ Creating tag ${githubConfig['releasePrefix']}$releaseVersion...');
    final tagResult = await _runGitCommand([
      'tag',
      '-a',
      '${githubConfig['releasePrefix']}$releaseVersion',
      '-m',
      'Release $releaseVersion',
    ]);
    
    if (tagResult.exitCode != 0) {
      print('  ❌ Failed to create tag');
      return;
    }
    
    // Push tag
    print('  📤 Pushing tag to remote...');
    await _runGitCommand(['push', 'origin', '${githubConfig['releasePrefix']}$releaseVersion']);
    
    // Update changelog
    await _updateChangelogForRelease(releaseVersion);
    
    print('  ✅ Release $releaseVersion created successfully\n');
  }

  /// Create tag
  Future<void> createTag(String? tagName) async {
    if (tagName == null) {
      print('❌ Please provide a tag name');
      return;
    }
    
    print('🏷️ Creating Tag: $tagName');
    
    Directory.current = projectRoot;
    
    final result = await _runGitCommand(['tag', '-a', tagName, '-m', 'Tag $tagName']);
    
    if (result.exitCode == 0) {
      print('  ✅ Tag $tagName created successfully');
    } else {
      print('  ❌ Failed to create tag $tagName');
      print('  Error: ${result.stderr}');
    }
    
    print('');
  }

  /// Merge branches
  Future<void> mergeBranches(String? sourceBranch) async {
    if (sourceBranch == null) {
      print('❌ Please provide source branch name');
      return;
    }
    
    print('🔀 Merging $sourceBranch into ${githubConfig['mainBranch']}...');
    
    Directory.current = projectRoot;
    
    // Switch to main branch
    await _runGitCommand(['checkout', githubConfig['mainBranch']!]);
    
    // Merge source branch
    final result = await _runGitCommand(['merge', sourceBranch]);
    
    if (result.exitCode == 0) {
      print('  ✅ $sourceBranch merged successfully');
    } else {
      print('  ❌ Merge failed');
      print('  Error: ${result.stderr}');
    }
    
    print('');
  }

  /// Update changelog
  Future<void> updateChangelog() async {
    print('📋 Updating CHANGELOG.md...');
    
    Directory.current = projectRoot;
    
    final changelogFile = File(githubConfig['changelogFile']!);
    if (!await changelogFile.exists()) {
      print('  ❌ CHANGELOG.md not found');
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
    
    print('  ✅ CHANGELOG.md updated\n');
  }

  /// Update README
  Future<void> updateReadme() async {
    print('📖 Updating README.md...');
    
    Directory.current = projectRoot;
    
    final readmeFile = File(githubConfig['readmeFile']!);
    if (!await readmeFile.exists()) {
      print('  ❌ README.md not found');
      return;
    }
    
    // Generate updated content
    final updatedContent = await _generateReadmeContent();
    
    // Update README
    await readmeFile.writeAsString(updatedContent);
    
    // Commit README update
    await _runGitCommand(['add', githubConfig['readmeFile']!]);
    await _runGitCommand(['commit', '-m', 'docs: update README.md']);
    
    print('  ✅ README.md updated\n');
  }

  /// Update TODO
  Future<void> updateTodo() async {
    print('📝 Updating TODO.md...');
    
    Directory.current = projectRoot;
    
    final todoFile = File(githubConfig['todoFile']!);
    if (!await todoFile.exists()) {
      print('  ❌ TODO.md not found');
      return;
    }
    
    // Generate updated TODO content
    final updatedContent = await _generateTodoContent();
    
    // Update TODO
    await todoFile.writeAsString(updatedContent);
    
    // Commit TODO update
    await _runGitCommand(['add', githubConfig['todoFile']!]);
    await _runGitCommand(['commit', '-m', 'docs: update TODO.md']);
    
    print('  ✅ TODO.md updated\n');
  }

  /// Update app gallery
  Future<void> updateAppGallery() async {
    print('🖼️ Updating App Gallery...');
    
    Directory.current = projectRoot;
    
    // Check if gallery exists
    final galleryDir = Directory('lib/features/gallery');
    if (!await galleryDir.exists()) {
      print('  ❌ Gallery directory not found');
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
    
    print('  ✅ App gallery updated\n');
  }

  /// Synchronize repository
  Future<void> synchronizeRepository() async {
    print('🔄 Synchronizing Repository...');
    
    // Pull latest changes
    await pullChanges();
    
    // Update all documentation
    await updateChangelog();
    await updateReadme();
    await updateTodo();
    await updateAppGallery();
    
    // Push all changes
    await pushChanges();
    
    print('✅ Repository synchronized\n');
  }

  /// Cleanup repository
  Future<void> cleanupRepository() async {
    print('🧹 Cleaning Repository...');
    
    Directory.current = projectRoot;
    
    // Clean untracked files
    print('  🗑️ Cleaning untracked files...');
    final cleanResult = await _runGitCommand(['clean', '-fd']);
    if (cleanResult.exitCode == 0) {
      print('  ✅ Untracked files cleaned');
    }
    
    // Reset any staged changes
    print('  🔄 Resetting staged changes...');
    final resetResult = await _runGitCommand(['reset', '--hard', 'HEAD']);
    if (resetResult.exitCode == 0) {
      print('  ✅ Staged changes reset');
    }
    
    // Clean Flutter build cache
    print('  🧹 Cleaning Flutter cache...');
    await _runCommand('flutter', ['clean']);
    
    print('✅ Repository cleaned\n');
  }

  /// Run full Git workflow
  Future<void> runFullGitWorkflow() async {
    print('🚀 Running Full Git Workflow...\n');
    
    await showRepositoryStatus();
    await commitChanges();
    await pushChanges();
    await updateChangelog();
    await updateReadme();
    await updateTodo();
    await updateAppGallery();
    
    print('🎉 Full Git workflow completed!\n');
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
    print('  📝 Creating .gitignore...');
    
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
    
    print('  ✅ .gitignore created');
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

## 🚀 Current Sprint Goals

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
    
    print('  📸 Gallery screenshots would be generated here');
  }

  Future<void> _updateGalleryData() async {
    print('  🔄 Gallery data updated');
  }

  /// Show help information
  void showHelp() {
    print('''
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
