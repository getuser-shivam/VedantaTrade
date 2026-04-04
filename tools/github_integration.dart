import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:args/args.dart';
import 'package:path/path.dart' as path;

/// GitHub integration for version control and repository management
class GitHubIntegration {
  final String repositoryUrl;
  final String token;
  final String projectPath;
  final bool verbose;
  
  GitHubIntegration({
    required this.repositoryUrl,
    required this.token,
    required this.projectPath,
    this.verbose = false,
  });

  /// Initialize GitHub integration
  Future<void> initialize() async {
    print('🔗 Initializing GitHub Integration...');
    
    try {
      // Validate repository connection
      await _validateRepository();
      
      // Setup local repository
      await _setupLocalRepository();
      
      // Configure Git hooks
      await _configureGitHooks();
      
      print('✅ GitHub integration initialized successfully');
      
    } catch (e) {
      print('❌ Failed to initialize GitHub integration: $e');
      throw Exception('GitHub integration failed: $e');
    }
  }

  /// Validate repository connection
  Future<void> _validateRepository() async {
    print('   🔍 Validating repository connection...');
    
    final uri = Uri.parse(repositoryUrl);
    final response = await http.get(
      Uri.parse('https://api.github.com/repos${uri.path}'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('   ✓ Repository: ${data['name']}');
      print('   ✓ Description: ${data['description']}');
      print('   ✓ Stars: ${data['stargazers_count']}');
      print('   ✓ Forks: ${data['forks_count']}');
    } else {
      throw Exception('Repository validation failed: ${response.statusCode}');
    }
  }

  /// Setup local repository
  Future<void> _setupLocalRepository() async {
    print('   🏗️ Setting up local repository...');
    
    // Check if already a git repository
    final gitDir = Directory(path.join(projectPath, '.git'));
    
    if (!gitDir.existsSyncSync()) {
      print('   ⚠️  Not a git repository, initializing...');
      await _runCommand('git init', projectPath);
    }
    
    // Setup remote origin
    await _runCommand('git remote add origin $repositoryUrl', projectPath);
    
    // Setup main branch if not exists
    await _setupMainBranch();
    
    print('   ✓ Local repository setup completed');
  }

  /// Setup main branch
  Future<void> _setupMainBranch() async {
    try {
      await _runCommand('git checkout main', projectPath);
      await _runCommand('git pull origin main', projectPath);
    } catch (e) {
      // Create main branch if it doesn't exist
      await _runCommand('git checkout -b main', projectPath);
      await _runCommand('git push -u origin main', projectPath);
    }
  }

  /// Configure Git hooks
  Future<void> _configureGitHooks() async {
    print('   🔧 Configuring Git hooks...');
    
    final hooksDir = Directory(path.join(projectPath, '.git', 'hooks'));
    await hooksDir.create(recursive: true);
    
    // Pre-commit hook for code quality
    final preCommitHook = '''
#!/bin/sh
# VedantaTrade Pre-commit Hook
echo "🔍 Running pre-commit checks..."

# Run Flutter analyze
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Flutter analyze failed"
    exit 1
fi

# Run tests
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Pre-commit checks passed"
exit 0
''';
    
    final preCommitFile = File(path.join(hooksDir.path, 'pre-commit'));
    await preCommitFile.writeAsString(preCommitHook);
    await _runCommand('chmod +x .git/hooks/pre-commit', projectPath);
    
    // Pre-push hook for build validation
    final prePushHook = '''
#!/bin/sh
# VedantaTrade Pre-push Hook
echo "🚀 Running pre-push validation..."

# Build application
flutter build web --web-renderer canvaskit
if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo "✅ Pre-push validation passed"
exit 0
''';
    
    final prePushFile = File(path.join(hooksDir.path, 'pre-push'));
    await prePushFile.writeAsString(prePushHook);
    await _runCommand('chmod +x .git/hooks/pre-push', projectPath);
    
    print('   ✓ Git hooks configured');
  }

  /// Commit changes with automatic todo update
  Future<void> commitChanges(String message, {bool updateTodo = true}) async {
    print('📝 Committing changes: $message');
    
    try {
      // Stage all changes
      await _runCommand('git add .', projectPath);
      
      // Update todo if requested
      if (updateTodo) {
        await _updateTodoFromCommit(message);
      }
      
      // Create commit
      final commitMessage = _generateCommitMessage(message);
      await _runCommand('git commit -m "$commitMessage"', projectPath);
      
      print('   ✓ Changes committed successfully');
      
    } catch (e) {
      print('   ❌ Failed to commit changes: $e');
      throw Exception('Commit failed: $e');
    }
  }

  /// Update todo from commit message
  Future<void> _updateTodoFromCommit(String message) async {
    final todoFile = File(path.join(projectPath, 'TODO.md'));
    
    if (!todoFile.existsSyncSync()) return;
    
    final content = await todoFile.readAsString();
    final lines = content.split('\n');
    
    // Extract todo items from commit message
    final todoItems = _extractTodoItems(message);
    
    if (todoItems.isNotEmpty) {
      // Add new todo items to TODO.md
      final updatedContent = _addTodoItems(content, todoItems);
      await todoFile.writeAsString(updatedContent);
      
      print('   ✓ Updated TODO.md with ${todoItems.length} items');
    }
  }

  /// Extract todo items from commit message
  List<String> _extractTodoItems(String message) {
    final todoItems = <String>[];
    final todoPattern = RegExp(r'TODO:\s*(.+)', caseSensitive: false);
    
    for (final match in todoPattern.allMatches(message)) {
      final item = match.group(1)?.trim();
      if (item != null) {
        todoItems.add(item);
      }
    }
    
    return todoItems;
  }

  /// Add todo items to TODO.md
  String _addTodoItems(String content, List<String> items) {
    final lines = content.split('\n');
    var insertIndex = lines.length;
    
    // Find the best place to insert new todo items
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].contains('## 🎯 Current Focus')) {
        insertIndex = i + 1;
        break;
      }
    }
    
    // Insert new todo items
    final newItems = items.map((item) => '- [ ] $item').join('\n');
    lines.insert(insertIndex, newItems);
    
    return lines.join('\n');
  }

  /// Generate commit message
  String _generateCommitMessage(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final branch = _getCurrentBranch();
    
    return '''$message

Timestamp: $timestamp
Branch: $branch
Type: Automated Commit
''';
  }

  /// Get current git branch
  Future<String> _getCurrentBranch() async {
    try {
      final result = await _runCommand('git rev-parse --abbrev-ref HEAD', projectPath);
      return result.stdout.trim();
    } catch (e) {
      return 'main';
    }
  }

  /// Push changes to remote repository
  Future<void> pushChanges({String branch = 'main'}) async {
    print('🚀 Pushing changes to $branch branch...');
    
    try {
      // Pull latest changes first
      await _runCommand('git pull origin $branch', projectPath);
      
      // Push changes
      await _runCommand('git push origin $branch', projectPath);
      
      print('   ✓ Changes pushed successfully');
      
    } catch (e) {
      print('   ❌ Failed to push changes: $e');
      throw Exception('Push failed: $e');
    }
  }

  /// Create new release
  Future<void> createRelease(String version, String description) async {
    print('🏷️ Creating release v$version...');
    
    try {
      // Create tag
      await _runCommand('git tag v$version', projectPath);
      
      // Push tag
      await _runCommand('git push origin v$version', projectPath);
      
      // Create GitHub release
      await _createGitHubRelease(version, description);
      
      print('   ✓ Release v$version created successfully');
      
    } catch (e) {
      print('   ❌ Failed to create release: $e');
      throw Exception('Release creation failed: $e');
    }
  }

  /// Create GitHub release
  Future<void> _createGitHubRelease(String version, String description) async {
    final uri = Uri.parse(repositoryUrl);
    final repoPath = uri.path;
    
    final releaseData = {
      'tag_name': 'v$version',
      'target_commitish': 'main',
      'name': 'VedantaTrade v$version',
      'body': description,
      'draft': false,
      'prerelease': false,
    };
    
    final response = await http.post(
      Uri.parse('https://api.github.com/repos$repoPath/releases'),
      headers: {
        'Authorization': 'token $token',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(releaseData),
    );
    
    if (response.statusCode != 201) {
      throw Exception('GitHub release creation failed: ${response.statusCode}');
    }
  }

  /// Generate changelog from commits
  Future<void> generateChangelog() async {
    print('📋 Generating changelog...');
    
    try {
      final commits = await _getCommitsSinceLastRelease();
      final changelog = _formatChangelog(commits);
      
      final changelogFile = File(path.join(projectPath, 'CHANGELOG.md'));
      await changelogFile.writeAsString(changelog);
      
      print('   ✓ Changelog generated successfully');
      
    } catch (e) {
      print('   ❌ Failed to generate changelog: $e');
      throw Exception('Changelog generation failed: $e');
    }
  }

  /// Get commits since last release
  Future<List<Map<String, dynamic>>> _getCommitsSinceLastRelease() async {
    try {
      // Get last release tag
      final lastTag = await _runCommand('git describe --tags --abbrev=0', projectPath);
      
      // Get commits since last tag
      final result = await _runCommand(
        'git log ${lastTag.stdout.trim()}..HEAD --oneline --format=\'{"hash": "%H", "message": "%s", "author": "%an", "date": "%ad"}\'',
        projectPath,
      );
      
      final commits = <Map<String, dynamic>>[];
      for (final line in result.stdout.split('\n')) {
        if (line.trim().isNotEmpty) {
          try {
            final commit = jsonDecode(line);
            commits.add(commit);
          } catch (e) {
            // Skip invalid lines
          }
        }
      }
      
      return commits;
      
    } catch (e) {
      // Fallback to recent commits
      return await _getRecentCommits();
    }
  }

  /// Get recent commits (fallback)
  Future<List<Map<String, dynamic>>> _getRecentCommits() async {
    final result = await _runCommand(
      'git log --oneline --format=\'{"hash": "%H", "message": "%s", "author": "%an", "date": "%ad"}\' -10',
      projectPath,
    );
    
    final commits = <Map<String, dynamic>>[];
    for (final line in result.stdout.split('\n')) {
      if (line.trim().isNotEmpty) {
        try {
          final commit = jsonDecode(line);
          commits.add(commit);
        } catch (e) {
          // Skip invalid lines
        }
      }
    }
    
    return commits;
  }

  /// Format changelog
  String _formatChangelog(List<Map<String, dynamic>> commits) {
    final changelog = StringBuffer();
    
    changelog.writeln('# Changelog');
    changelog.writeln();
    changelog.writeln('All notable changes to this repository are documented in this file.');
    changelog.writeln();
    
    final groupedCommits = _groupCommitsByDate(commits);
    
    for (final date in groupedCommits.keys) {
      final dateStr = date.toString().split(' ')[0];
      changelog.writeln('## [$dateStr]');
      changelog.writeln();
      
      for (final commit in groupedCommits[date]!) {
        final message = commit['message'] as String;
        final author = commit['author'] as String;
        
        changelog.writeln('### ${message.split('\n')[0]}');
        changelog.writeln('* $message');
        changelog.writeln();
      }
    }
    
    return changelog.toString();
  }

  /// Group commits by date
  Map<DateTime, List<Map<String, dynamic>>> _groupCommitsByDate(List<Map<String, dynamic>> commits) {
    final grouped = <DateTime, List<Map<String, dynamic>>>{};
    
    for (final commit in commits) {
      final dateStr = commit['date'] as String;
      final date = DateTime.parse(dateStr);
      final dateKey = DateTime(date.year, date.month, date.day);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      
      grouped[dateKey]!.add(commit);
    }
    
    return grouped;
  }

  /// Sync with remote repository
  Future<void> syncWithRemote() async {
    print('🔄 Syncing with remote repository...');
    
    try {
      // Fetch latest changes
      await _runCommand('git fetch origin', projectPath);
      
      // Check for conflicts
      await _checkForConflicts();
      
      // Pull changes
      await _runCommand('git pull origin main', projectPath);
      
      print('   ✓ Sync completed successfully');
      
    } catch (e) {
      print('   ❌ Failed to sync: $e');
      throw Exception('Sync failed: $e');
    }
  }

  /// Check for merge conflicts
  Future<void> _checkForConflicts() async {
    try {
      final result = await _runCommand('git status --porcelain', projectPath);
      
      if (result.stdout.contains('UU')) {
        print('   ⚠️  Merge conflicts detected!');
        print('   Please resolve conflicts before continuing');
      }
    } catch (e) {
      print('   ⚠️  Could not check for conflicts');
    }
  }

  /// Run command and capture output
  Future<ProcessResult> _runCommand(String command, String workingDirectory) async {
    final result = await Process.run(
      command,
      [],
      workingDirectory: workingDirectory,
      runInShell: true,
    );
    
    if (verbose) {
      print('   Running: $command');
      if (result.stdout.isNotEmpty) {
        print('   Output: ${result.stdout}');
      }
      if (result.stderr.isNotEmpty) {
        print('   Error: ${result.stderr}');
      }
    }
    
    return result;
  }

  /// Get repository statistics
  Future<Map<String, dynamic>> getRepositoryStats() async {
    print('📊 Getting repository statistics...');
    
    try {
      final uri = Uri.parse(repositoryUrl);
      final repoPath = uri.path;
      
      // Get basic repo info
      final repoResponse = await http.get(
        Uri.parse('https://api.github.com/repos$repoPath'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      // Get contributors
      final contributorsResponse = await http.get(
        Uri.parse('https://api.github.com/repos$repoPath/contributors'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      // Get commit activity
      final commitsResponse = await http.get(
        Uri.parse('https://api.github.com/repos$repoPath/commits'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      final repoData = jsonDecode(repoResponse.body);
      final contributorsData = jsonDecode(contributorsResponse.body);
      final commitsData = jsonDecode(commitsResponse.body);
      
      final stats = {
        'name': repoData['name'],
        'description': repoData['description'],
        'stars': repoData['stargazers_count'],
        'forks': repoData['forks_count'],
        'open_issues': repoData['open_issues_count'],
        'contributors': contributorsData.length,
        'total_commits': commitsData.length,
        'last_commit': commitsData.isNotEmpty ? commitsData[0]['commit']['author']['date'] : null,
        'languages': await _getRepositoryLanguages(repoPath),
      };
      
      print('   ✓ Repository statistics retrieved');
      return stats;
      
    } catch (e) {
      print('   ❌ Failed to get repository statistics: $e');
      throw Exception('Failed to get repository statistics: $e');
    }
  }

  /// Get repository languages
  Future<Map<String, int>> _getRepositoryLanguages(String repoPath) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos$repoPath/languages'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      
      if (response.statusCode == 200) {
        final languages = jsonDecode(response.body);
        return Map<String, int>.from(languages);
      }
      
      return {};
    } catch (e) {
      return {};
    }
  }

  /// Create automated todo management
  Future<void> createAutomatedTodoManagement() async {
    print('📝 Setting up automated todo management...');
    
    try {
      // Create todo management script
      final todoScript = '''
#!/bin/bash
# VedantaTrade Todo Management Script

echo "📝 Managing TODO items..."

# Add new todo item
add_todo() {
    echo "Enter todo item:"
    read -r item
    echo "- [ ] \$item" >> TODO.md
    echo "✅ Todo item added"
}

# Mark todo as complete
complete_todo() {
    echo "Enter todo number to complete:"
    read -r number
    sed -i "s/- \\[ \\] \$number/- [x]/" TODO.md
    echo "✅ Todo item marked as complete"
}

# Show current todos
show_todos() {
    echo "📋 Current TODO items:"
    cat TODO.md
}

# Menu
echo "Choose an option:"
echo "1) Add new todo"
echo "2) Complete todo"
echo "3) Show todos"
echo "4) Exit"

read -r choice

case \$choice in
    1) add_todo ;;
    2) complete_todo ;;
    3) show_todos ;;
    4) exit 0 ;;
    *) echo "Invalid option" ;;
esac
''';
      
      final scriptFile = File(path.join(projectPath, 'tools', 'manage_todo.sh'));
      await scriptFile.writeAsString(todoScript);
      await _runCommand('chmod +x tools/manage_todo.sh', projectPath);
      
      print('   ✓ Automated todo management setup completed');
      
    } catch (e) {
      print('   ❌ Failed to setup todo management: $e');
      throw Exception('Todo management setup failed: $e');
    }
  }

  /// Main entry point for GitHub integration
  static void main(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption('repo', abbr: 'r', help: 'Repository URL', defaultsTo: '')
      ..addOption('token', abbr: 't', help: 'GitHub token', defaultsTo: '')
      ..addOption('path', abbr: 'p', help: 'Project path', defaultsTo: '.')
      ..addOption('verbose', abbr: 'v', help: 'Verbose output', defaultsTo: false)
      ..addCommand('commit', help: 'Commit changes')
      ..addCommand('push', help: 'Push changes')
      ..addCommand('release', help: 'Create release')
      ..addCommand('changelog', help: 'Generate changelog')
      ..addCommand('sync', help: 'Sync with remote')
      ..addCommand('stats', help: 'Get repository statistics')
      ..addCommand('setup-todo', help: 'Setup todo management');

    try {
      final results = parser.parse(arguments);
      
      final integration = GitHubIntegration(
        repositoryUrl: results['repo'] as String,
        token: results['token'] as String,
        projectPath: results['path'] as String,
        verbose: results['verbose'] as bool,
      );
      
      // Handle commands
      switch (results.command) {
        case 'commit':
          await integration.commitChanges(
            results.rest.isNotEmpty ? results.rest.first : 'Automated commit',
          );
          break;
        case 'push':
          await integration.pushChanges();
          break;
        case 'release':
          await integration.createRelease(
            results.rest.isNotEmpty ? results.rest.first : '1.0.0',
            results.rest.length > 1 ? results.rest[1] : 'Automated release',
          );
          break;
        case 'changelog':
          await integration.generateChangelog();
          break;
        case 'sync':
          await integration.syncWithRemote();
          break;
        case 'stats':
          final stats = await integration.getRepositoryStats();
          print('📊 Repository Statistics:');
          print('   Name: ${stats['name']}');
          print('   Stars: ${stats['stars']}');
          print('   Forks: ${stats['forks']}');
          print('   Contributors: ${stats['contributors']}');
          print('   Total Commits: ${stats['total_commits']}');
          break;
        case 'setup-todo':
          await integration.createAutomatedTodoManagement();
          break;
        default:
          await integration.initialize();
          break;
      }
      
    } catch (e) {
      print('❌ Error: $e');
      exit(1);
    }
  }
}
