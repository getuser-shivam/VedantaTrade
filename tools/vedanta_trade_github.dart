import 'dart:io';
import 'dart:convert';

/// VedantaTrade GitHub Integration Tool
/// 
/// Advanced GitHub integration for version control, releases, and repository management
class VedantaTradeGitHubIntegration {
  static const String projectName = 'VedantaTrade';
  static const String version = 'v3.2.1-alpha';
  static const String projectRoot = 'i:\\Path\\Projects\\VedantaTrade';
  static const String remoteUrl = 'git@github.com:getuser-shivam/VedantaTrade.git';
  static const String mainBranch = 'main';
  
  // GitHub API configuration
  final String? _githubToken = Platform.environment['GITHUB_TOKEN'];
  final String _owner = 'getuser-shivam';
  final String _repo = 'VedantaTrade';
  
  // Repository state
  Map<String, dynamic> _repoState = {};
  List<Map<String, dynamic>> _commitHistory = [];
  List<Map<String, dynamic>> _releaseHistory = [];
  
  /// Initialize GitHub integration
  Future<void> initialize() async {
    print('🔗 Initializing GitHub integration...');
    
    try {
      // Check git configuration
      await checkGitConfiguration();
      
      // Fetch repository information
      await fetchRepositoryInfo();
      
      // Get commit history
      await getCommitHistory();
      
      // Get release history
      await getReleaseHistory();
      
      print('✅ GitHub integration initialized');
    } catch (e) {
      print('❌ Failed to initialize GitHub integration: $e');
      rethrow;
    }
  }
  
  /// Check git configuration
  Future<void> checkGitConfiguration() async {
    print('🔧 Checking git configuration...');
    
    // Check remote URL
    final remoteResult = await runCommand('git', ['remote', 'get-url', 'origin'], projectRoot);
    String currentRemote = remoteResult.stdout.toString().trim();
    
    if (currentRemote != remoteUrl) {
      print('⚠️  Remote URL mismatch. Current: $currentRemote, Expected: $remoteUrl');
    }
    
    // Check current branch
    final branchResult = await runCommand('git', ['branch', '--show-current'], projectRoot);
    String currentBranch = branchResult.stdout.toString().trim();
    
    if (currentBranch != mainBranch) {
      print('⚠️  Not on main branch. Current: $currentBranch, Expected: $mainBranch');
    }
    
    // Check for uncommitted changes
    final statusResult = await runCommand('git', ['status', '--porcelain'], projectRoot);
    bool hasChanges = statusResult.stdout.toString().trim().isNotEmpty;
    
    if (hasChanges) {
      print('⚠️  Uncommitted changes detected');
    }
    
    _repoState = {
      'remote_url': currentRemote,
      'current_branch': currentBranch,
      'has_changes': hasChanges,
      'git_configured': true,
    };
  }
  
  /// Fetch repository information
  Future<void> fetchRepositoryInfo() async {
    print('📊 Fetching repository information...');
    
    try {
      // Get latest commit
      final logResult = await runCommand('git', ['log', '-1', '--format=%H|%s|%an|%ad'], projectRoot);
      String logOutput = logResult.stdout.toString().trim();
      
      if (logOutput.isNotEmpty) {
        final parts = logOutput.split('|');
        _repoState['latest_commit'] = {
          'hash': parts[0],
          'message': parts[1],
          'author': parts[2],
          'date': parts[3],
        };
      }
      
      // Get total commits
      final countResult = await runCommand('git', ['rev-list', '--count', 'HEAD'], projectRoot);
      int totalCommits = int.parse(countResult.stdout.toString().trim());
      _repoState['total_commits'] = totalCommits;
      
      // Get branches
      final branchResult = await runCommand('git', ['branch', '-a'], projectRoot);
      List<String> branches = branchResult.stdout.toString()
          .split('\n')
          .map((b) => b.trim().replaceAll('* ', '').replaceAll('remotes/origin/', ''))
          .where((b) => b.isNotEmpty)
          .toList();
      _repoState['branches'] = branches;
      
      print('   📝 Total commits: $totalCommits');
      print('   🌿 Branches: ${branches.length}');
      
    } catch (e) {
      print('❌ Failed to fetch repository info: $e');
    }
  }
  
  /// Get commit history
  Future<void> getCommitHistory() async {
    print('📜 Getting commit history...');
    
    try {
      final logResult = await runCommand('git', ['log', '--oneline', '-20'], projectRoot);
      String logOutput = logResult.stdout.toString().trim();
      
      _commitHistory = logOutput.split('\n').map((line) {
        final parts = line.split(' ', 2);
        return {
          'hash': parts[0],
          'message': parts.length > 1 ? parts[1] : '',
          'timestamp': DateTime.now().toIso8601String(), // Would need proper parsing
        };
      }).toList();
      
      print('   📜 Retrieved ${_commitHistory.length} commits');
      
    } catch (e) {
      print('❌ Failed to get commit history: $e');
    }
  }
  
  /// Get release history
  Future<void> getReleaseHistory() async {
    print('🏷️  Getting release history...');
    
    try {
      final tagResult = await runCommand('git', ['tag', '-l', 'v*'], projectRoot);
      String tagOutput = tagResult.stdout.toString().trim();
      
      if (tagOutput.isNotEmpty) {
        _releaseHistory = tagOutput.split('\n').map((tag) {
          return {
            'tag': tag.trim(),
            'name': tag.trim(),
            'timestamp': DateTime.now().toIso8601String(), // Would need proper parsing
          };
        }).toList();
        
        // Sort by version (simple sort)
        _releaseHistory.sort((a, b) => b['tag'].compareTo(a['tag']));
        
        print('   🏷️  Retrieved ${_releaseHistory.length} releases');
      } else {
        print('   ℹ️  No releases found');
      }
      
    } catch (e) {
      print('❌ Failed to get release history: $e');
    }
  }
  
  /// Create new release
  Future<Map<String, dynamic>> createRelease({
    required String tagName,
    required String releaseName,
    required String description,
    bool isPrerelease = false,
    String targetBranch = mainBranch,
  }) async {
    print('🚀 Creating release: $tagName');
    
    try {
      // Ensure we're on the target branch
      await runCommand('git', ['checkout', targetBranch], projectRoot);
      
      // Pull latest changes
      await runCommand('git', ['pull', 'origin', targetBranch], projectRoot);
      
      // Create tag
      await runCommand('git', ['tag', '-a', tagName, '-m', releaseName], projectRoot);
      
      // Push tag
      await runCommand('git', ['push', 'origin', tagName], projectRoot);
      
      // Create release data
      /* Map<String, dynamic> releaseData = {
        'tag_name': tagName,
        'name': releaseName,
        'body': description,
        'target_commitish': targetBranch,
        'prerelease': isPrerelease,
        'draft': false,
      }; */
      
      // Save release info locally
      final releaseInfo = {
        'tag': tagName,
        'name': releaseName,
        'description': description,
        'prerelease': isPrerelease,
        'target_branch': targetBranch,
        'created_at': DateTime.now().toIso8601String(),
        'assets': [],
      };
      
      _releaseHistory.insert(0, releaseInfo);
      
      print('✅ Release created: $tagName');
      return releaseInfo;
      
    } catch (e) {
      print('❌ Failed to create release: $e');
      rethrow;
    }
  }
  
  /// Commit changes with proper formatting
  Future<String> commitChanges({
    required String message,
    List<String> files = const ['.'],
    bool createTag = false,
    String? tagVersion,
  }) async {
    print('💾 Committing changes...');
    
    try {
      // Stage files
      for (String file in files) {
        await runCommand('git', ['add', file], projectRoot);
      }
      
      // Commit
      await runCommand('git', ['commit', '-m', message], projectRoot);
      
      // Get commit hash
      final hashResult = await runCommand('git', ['rev-parse', 'HEAD'], projectRoot);
      String commitHash = hashResult.stdout.toString().trim();
      
      // Push
      await runCommand('git', ['push', 'origin', mainBranch], projectRoot);
      
      // Create tag if requested
      if (createTag && tagVersion != null) {
        await runCommand('git', ['tag', tagVersion], projectRoot);
        await runCommand('git', ['push', 'origin', tagVersion], projectRoot);
      }
      
      print('✅ Changes committed: $commitHash');
      return commitHash;
      
    } catch (e) {
      print('❌ Failed to commit changes: $e');
      rethrow;
    }
  }
  
  /// Create feature branch
  Future<String> createFeatureBranch({
    required String featureName,
    String baseBranch = mainBranch,
  }) async {
    print('🌿 Creating feature branch: $featureName');
    
    try {
      // Ensure we're on base branch
      await runCommand('git', ['checkout', baseBranch], projectRoot);
      
      // Pull latest changes
      await runCommand('git', ['pull', 'origin', baseBranch], projectRoot);
      
      // Create and checkout new branch
      String branchName = 'feature/$featureName';
      await runCommand('git', ['checkout', '-b', branchName], projectRoot);
      
      // Push new branch
      await runCommand('git', ['push', '-u', 'origin', branchName], projectRoot);
      
      print('✅ Feature branch created: $branchName');
      return branchName;
      
    } catch (e) {
      print('❌ Failed to create feature branch: $e');
      rethrow;
    }
  }
  
  /// Merge feature branch
  Future<void> mergeFeatureBranch({
    required String featureBranch,
    bool deleteAfterMerge = true,
  }) async {
    print('🔀 Merging feature branch: $featureBranch');
    
    try {
      // Checkout main branch
      await runCommand('git', ['checkout', mainBranch], projectRoot);
      
      // Pull latest changes
      await runCommand('git', ['pull', 'origin', mainBranch], projectRoot);
      
      // Merge feature branch
      await runCommand('git', ['merge', featureBranch], projectRoot);
      
      // Push merged changes
      await runCommand('git', ['push', 'origin', mainBranch], projectRoot);
      
      // Delete feature branch if requested
      if (deleteAfterMerge) {
        await runCommand('git', ['branch', '-d', featureBranch], projectRoot);
        await runCommand('git', ['push', 'origin', '--delete', featureBranch], projectRoot);
      }
      
      print('✅ Feature branch merged: $featureBranch');
      
    } catch (e) {
      print('❌ Failed to merge feature branch: $e');
      rethrow;
    }
  }
  
  /// Generate comprehensive report
  Map<String, dynamic> generateReport() {
    return {
      'project': projectName,
      'version': version,
      'timestamp': DateTime.now().toIso8601String(),
      'repository_state': _repoState,
      'commit_history': _commitHistory.take(10).toList(),
      'release_history': _releaseHistory,
      'statistics': {
        'total_commits': _repoState['total_commits'] ?? 0,
        'total_releases': _releaseHistory.length,
        'current_branch': _repoState['current_branch'] ?? 'unknown',
        'has_uncommitted_changes': _repoState['has_changes'] ?? false,
      },
      'recommendations': _generateRecommendations(),
    };
  }
  
  /// Generate recommendations
  List<String> _generateRecommendations() {
    List<String> recommendations = [];
    
    if (_repoState['has_changes'] == true) {
      recommendations.add('Commit uncommitted changes');
    }
    
    if (_repoState['current_branch'] != mainBranch) {
      recommendations.add('Switch to main branch');
    }
    
    if (_releaseHistory.isEmpty) {
      recommendations.add('Create initial release');
    }
    
    if (_commitHistory.isNotEmpty) {
      String lastCommit = _commitHistory.first['message'] ?? '';
      if (lastCommit.contains('fix:') || lastCommit.contains('hotfix:')) {
        recommendations.add('Consider creating patch release');
      }
    }
    
    return recommendations;
  }
  
  /// Save report to file
  Future<void> saveReport() async {
    final report = generateReport();
    final reportFile = File('$projectRoot\\github_report_${DateTime.now().millisecondsSinceEpoch}.json');
    
    await reportFile.writeAsString(jsonEncode(report));
    print('📄 GitHub report saved: ${reportFile.path}');
  }
  
  /// Sync with remote
  Future<void> syncWithRemote() async {
    print('🔄 Syncing with remote...');
    
    try {
      // Fetch latest changes
      await runCommand('git', ['fetch', 'origin'], projectRoot);
      
      // Pull latest changes for main branch
      await runCommand('git', ['checkout', mainBranch], projectRoot);
      await runCommand('git', ['pull', 'origin', mainBranch], projectRoot);
      
      print('✅ Synced with remote');
      
    } catch (e) {
      print('❌ Failed to sync with remote: $e');
      rethrow;
    }
  }
  
  /// Create backup
  Future<void> createBackup() async {
    print('💾 Creating backup...');
    
    try {
      String backupName = 'backup_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create backup branch
      await runCommand('git', ['branch', backupName], projectRoot);
      
      // Push backup branch
      await runCommand('git', ['push', 'origin', backupName], projectRoot);
      
      print('✅ Backup created: $backupName');
      
    } catch (e) {
      print('❌ Failed to create backup: $e');
      rethrow;
    }
  }
  
  /// Run command
  Future<ProcessResult> runCommand(String command, List<String> args, String workingDirectory) async {
    print('   🔄 Running: $command ${args.join(' ')}');
    
    try {
      final result = await Process.run(command, args, workingDirectory: workingDirectory);
      
      if (result.exitCode != 0) {
        print('   ❌ Command failed with exit code ${result.exitCode}');
        print('   📄 Error: ${result.stderr}');
        throw Exception('Command failed: $command ${args.join(' ')}');
      }
      
      return result;
    } catch (e) {
      print('   ❌ Exception running command: $e');
      rethrow;
    }
  }
  
  /// Get repository statistics
  Map<String, dynamic> getRepositoryStatistics() {
    return {
      'total_commits': _repoState['total_commits'] ?? 0,
      'total_releases': _releaseHistory.length,
      'branches': _repoState['branches']?.length ?? 0,
      'current_branch': _repoState['current_branch'] ?? 'unknown',
      'latest_commit': _repoState['latest_commit'],
      'has_uncommitted_changes': _repoState['has_changes'] ?? false,
      'git_configured': _repoState['git_configured'] ?? false,
    };
  }
  
  /// Analyze commit patterns
  Map<String, dynamic> analyzeCommitPatterns() {
    if (_commitHistory.isEmpty) {
      return {'error': 'No commit history available'};
    }
    
    Map<String, int> commitTypes = {};
    // List<String> authors = []; // Not used currently
    
    for (Map<String, dynamic> commit in _commitHistory) {
      String message = commit['message'] ?? '';
      
      // Extract commit type (conventional commits)
      if (message.contains(':')) {
        String type = message.split(':')[0];
        commitTypes[type] = (commitTypes[type] ?? 0) + 1;
      }
    }
    
    return {
      'commit_types': commitTypes,
      'total_commits_analyzed': _commitHistory.length,
      'most_common_type': commitTypes.isNotEmpty 
          ? commitTypes.keys.reduce((a, b) => commitTypes[a]! > commitTypes[b]! ? a : b)
          : null,
    };
  }
  
  /// Generate release notes
  Future<String> generateReleaseNotes(String fromTag, String toTag) async {
    print('📝 Generating release notes...');
    
    try {
      // Get commits between tags
      final logResult = await runCommand(
        'git', 
        ['log', '$fromTag..$toTag', '--oneline'], 
        projectRoot
      );
      
      String logOutput = logResult.stdout.toString().trim();
      
      if (logOutput.isEmpty) {
        return 'No changes found between $fromTag and $toTag';
      }
      
      List<String> commits = logOutput.split('\n');
      Map<String, List<String>> categorizedCommits = {
        'feat': [],
        'fix': [],
        'docs': [],
        'style': [],
        'refactor': [],
        'test': [],
        'chore': [],
        'other': [],
      };
      
      for (String commit in commits) {
        if (commit.isEmpty) continue;
        
        String message = commit.substring(commit.indexOf(' ') + 1);
        String category = 'other';
        
        for (String cat in categorizedCommits.keys) {
          if (message.startsWith('$cat:')) {
            category = cat;
            break;
          }
        }
        
        categorizedCommits[category]!.add(message);
      }
      
      // Generate release notes
      StringBuffer releaseNotes = StringBuffer();
      releaseNotes.writeln('## Release Notes');
      releaseNotes.writeln();
      
      for (String category in ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'other']) {
        List<String> categoryCommits = categorizedCommits[category]!;
        if (categoryCommits.isNotEmpty) {
          String title = _getCategoryTitle(category);
          releaseNotes.writeln('### $title');
          releaseNotes.writeln();
          
          for (String commit in categoryCommits) {
            releaseNotes.writeln('- ${commit.substring(category.length + 2)}');
          }
          releaseNotes.writeln();
        }
      }
      
      return releaseNotes.toString();
      
    } catch (e) {
      print('❌ Failed to generate release notes: $e');
      return 'Failed to generate release notes: $e';
    }
  }
  
  /// Get category title
  String _getCategoryTitle(String category) {
    switch (category) {
      case 'feat': return '🚀 Features';
      case 'fix': return '🐛 Bug Fixes';
      case 'docs': return '📚 Documentation';
      case 'style': return '💄 Style';
      case 'refactor': return '♻️  Refactoring';
      case 'test': return '🧪 Testing';
      case 'chore': return '🔧 Maintenance';
      default: return '📦 Other';
    }
  }
}

/// Main entry point
void main(List<String> args) async {
  final github = VedantaTradeGitHubIntegration();
  
  if (args.isEmpty) {
    print('🔗 VedantaTrade GitHub Integration');
    print('');
    print('Usage: dart run tools/vedanta_trade_github.dart [command]');
    print('');
    print('Commands:');
    print('  init        - Initialize GitHub integration');
    print('  sync        - Sync with remote repository');
    print('  commit      - Commit changes');
    print('  release     - Create new release');
    print('  branch      - Create feature branch');
    print('  merge       - Merge feature branch');
    print('  backup      - Create backup');
    print('  report      - Generate repository report');
    print('  notes       - Generate release notes');
    print('');
    print('Examples:');
    print('  dart run tools/vedanta_trade_github.dart init');
    print('  dart run tools/vedanta_trade_github.dart commit "feat: Add new feature"');
    print('  dart run tools/vedanta_trade_github.dart release v3.2.2 "New Release"');
    return;
  }
  
  switch (args[0]) {
    case 'init':
      await github.initialize();
      break;
    case 'sync':
      await github.syncWithRemote();
      break;
    case 'commit':
      if (args.length < 2) {
        print('❌ Commit message required');
        return;
      }
      await github.commitChanges(message: args[1]);
      break;
    case 'release':
      if (args.length < 3) {
        print('❌ Tag name and release name required');
        return;
      }
      await github.createRelease(
        tagName: args[1],
        releaseName: args[2],
        description: 'Automated release creation',
      );
      break;
    case 'branch':
      if (args.length < 2) {
        print('❌ Feature name required');
        return;
      }
      await github.createFeatureBranch(featureName: args[1]);
      break;
    case 'merge':
      if (args.length < 2) {
        print('❌ Feature branch name required');
        return;
      }
      await github.mergeFeatureBranch(featureBranch: args[1]);
      break;
    case 'backup':
      await github.createBackup();
      break;
    case 'report':
      await github.saveReport();
      break;
    case 'notes':
      if (args.length < 3) {
        print('❌ From tag and to tag required');
        return;
      }
      String notes = await github.generateReleaseNotes(args[1], args[2]);
      print(notes);
      break;
    default:
      print('❌ Unknown command: ${args[0]}');
      print('Use "dart run tools/vedanta_trade_github.dart" for help.');
  }
}
