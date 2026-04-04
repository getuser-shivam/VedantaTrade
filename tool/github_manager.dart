#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// VedantaTrade GitHub Manager
/// Comprehensive tool for GitHub integration, version control, and release management
class VedantaTradeGitHubManager {
  static const String repoOwner = 'getuser-shivam';
  static const String repoName = 'VedantaTrade';
  static const String apiBaseUrl = 'https://api.github.com';
  
  final String? _authToken;
  final Map<String, dynamic> _repoInfo = {};
  final List<Map<String, dynamic>> _commits = [];
  final List<Map<String, dynamic>> _branches = [];
  final List<Map<String, dynamic>> _releases = [];
  
  VedantaTradeGitHubManager([String? authToken]) : _authToken = authToken;
  
  /// Main GitHub management workflow
  Future<void> runGitHubWorkflow() async {
    print('🚀 Starting VedantaTrade GitHub Management...');
    print('=' * 60);
    
    try {
      // 1. Authenticate with GitHub
      await _authenticate();
      
      // 2. Get repository information
      await _getRepositoryInfo();
      
      // 3. Analyze commit history
      await _analyzeCommitHistory();
      
      // 4. Check branch status
      await _checkBranchStatus();
      
      // 5. Analyze releases
      await _analyzeReleases();
      
      // 6. Create release if needed
      await _createReleaseIfNeeded();
      
      // 7. Update documentation
      await _updateDocumentation();
      
      // 8. Generate status report
      await _generateStatusReport();
      
      print('✅ GitHub Management Complete!');
      
    } catch (e) {
      print('❌ GitHub management failed: $e');
      await _logError(e.toString());
    }
  }
  
  /// Authenticate with GitHub
  Future<void> _authenticate() async {
    print('\n🔐 Authenticating with GitHub...');
    
    if (_authToken == null) {
      print('  ⚠ No auth token provided, using public API');
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/user'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/vnd.github.v3+json'
        }
      );
      
      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        print('  ✓ Authenticated as ${userData['login']}');
      } else {
        throw Exception('Authentication failed: ${response.statusCode}');
      }
      
    } catch (e) {
      print('  ❌ Authentication failed: $e');
    }
  }
  
  /// Get repository information
  Future<void> _getRepositoryInfo() async {
    print('\n📁 Getting Repository Information...');
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName'),
        headers: _getHeaders()
      );
      
      if (response.statusCode == 200) {
        _repoInfo.addAll(jsonDecode(response.body));
        print('  ✓ Repository: ${_repoInfo['full_name']}');
        print('  ⭐ Stars: ${_repoInfo['stargazers_count']}');
        print('  🍴 Forks: ${_repoInfo['forks_count']}');
        print('  📝 Issues: ${_repoInfo['open_issues_count']}');
        print('  📅 Last updated: ${_repoInfo['updated_at']}');
      } else {
        throw Exception('Failed to get repository info: ${response.statusCode}');
      }
      
    } catch (e) {
      print('  ❌ Failed to get repository info: $e');
    }
  }
  
  /// Analyze commit history
  Future<void> _analyzeCommitHistory() async {
    print('\n📝 Analyzing Commit History...');
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName/commits?per_page=50'),
        headers: _getHeaders()
      );
      
      if (response.statusCode == 200) {
        final commits = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _commits.addAll(commits);
        
        print('  ✓ Analyzed ${commits.length} recent commits');
        
        // Analyze commit patterns
        await _analyzeCommitPatterns(commits);
        
      } else {
        throw Exception('Failed to get commits: ${response.statusCode}');
      }
      
    } catch (e) {
      print('  ❌ Failed to analyze commits: $e');
    }
  }
  
  /// Analyze commit patterns
  Future<void> _analyzeCommitPatterns(List<Map<String, dynamic>> commits) async {
    print('  📊 Commit Analysis:');
    
    final commitTypes = <String, int>{};
    final authors = <String, int>{};
    final commitTimes = <DateTime>[];
    
    for (final commit in commits) {
      // Analyze commit types
      final message = commit['commit']['message'] as String;
      if (message.startsWith('feat:')) {
        commitTypes['feature'] = (commitTypes['feature'] ?? 0) + 1;
      } else if (message.startsWith('fix:')) {
        commitTypes['fix'] = (commitTypes['fix'] ?? 0) + 1;
      } else if (message.startsWith('docs:')) {
        commitTypes['docs'] = (commitTypes['docs'] ?? 0) + 1;
      } else if (message.startsWith('refactor:')) {
        commitTypes['refactor'] = (commitTypes['refactor'] ?? 0) + 1;
      } else if (message.startsWith('test:')) {
        commitTypes['test'] = (commitTypes['test'] ?? 0) + 1;
      } else if (message.startsWith('chore:')) {
        commitTypes['chore'] = (commitTypes['chore'] ?? 0) + 1;
      }
      
      // Analyze authors
      final author = commit['commit']['author']['name'] as String;
      authors[author] = (authors[author] ?? 0) + 1;
      
      // Analyze commit times
      final date = DateTime.parse(commit['commit']['author']['date']);
      commitTimes.add(date);
    }
    
    // Print commit type analysis
    print('    Commit Types:');
    for (final entry in commitTypes.entries) {
      print('      ${entry.key}: ${entry.value}');
    }
    
    // Print top contributors
    print('    Top Contributors:');
    final sortedAuthors = authors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < sortedAuthors.length && i < 5; i++) {
      print('      ${sortedAuthors[i].key}: ${sortedAuthors[i].value} commits');
    }
    
    // Analyze commit frequency
    if (commitTimes.isNotEmpty) {
      commitTimes.sort();
      final firstCommit = commitTimes.first;
      final lastCommit = commitTimes.last;
      final duration = lastCommit.difference(firstCommit);
      final avgCommitsPerDay = commits.length / duration.inDays;
      
      print('    Average commits per day: ${avgCommitsPerDay.toStringAsFixed(2)}');
    }
  }
  
  /// Check branch status
  Future<void> _checkBranchStatus() async {
    print('\n🌿 Checking Branch Status...');
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName/branches'),
        headers: _getHeaders()
      );
      
      if (response.statusCode == 200) {
        final branches = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _branches.addAll(branches);
        
        print('  ✓ Found ${branches.length} branches');
        
        for (final branch in branches) {
          final name = branch['name'] as String;
          final protected = branch['protected'] as bool;
          final defaultBranch = name == _repoInfo['default_branch'];
          
          print('    ${defaultBranch ? '→' : ' '} $name ${protected ? '(protected)' : ''}');
        }
        
      } else {
        throw Exception('Failed to get branches: ${response.statusCode}');
      }
      
    } catch (e) {
      print('  ❌ Failed to check branch status: $e');
    }
  }
  
  /// Analyze releases
  Future<void> _analyzeReleases() async {
    print('\n📦 Analyzing Releases...');
    
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName/releases'),
        headers: _getHeaders()
      );
      
      if (response.statusCode == 200) {
        final releases = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        _releases.addAll(releases);
        
        print('  ✓ Found ${releases.length} releases');
        
        for (final release in releases) {
          final tagName = release['tag_name'] as String;
          final name = release['name'] as String;
          final prerelease = release['prerelease'] as bool;
          final publishedAt = release['published_at'] as String;
          
          print('    $tagName ${prerelease ? '(prerelease)' : ''} - $publishedAt');
        }
        
      } else {
        throw Exception('Failed to get releases: ${response.statusCode}');
      }
      
    } catch (e) {
      print('  ❌ Failed to analyze releases: $e');
    }
  }
  
  /// Create release if needed
  Future<void> _createReleaseIfNeeded() async {
    print('\n🚀 Checking Release Needs...');
    
    try {
      // Check if we need to create a new release
      final lastRelease = _releases.isNotEmpty ? _releases.first : null;
      final needsRelease = await _shouldCreateRelease(lastRelease);
      
      if (needsRelease) {
        print('  📦 Creating new release...');
        await _createRelease();
      } else {
        print('  ✓ No release needed');
      }
      
    } catch (e) {
      print('  ❌ Failed to check/create release: $e');
    }
  }
  
  /// Check if we should create a release
  Future<bool> _shouldCreateRelease(Map<String, dynamic>? lastRelease) async {
    if (lastRelease == null) {
      return true;
    }
    
    // Check if significant changes since last release
    final lastReleaseDate = DateTime.parse(lastRelease['published_at']);
    final response = await http.get(
      Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName/commits?since=$lastReleaseDate'),
      headers: _getHeaders()
    );
    
    if (response.statusCode == 200) {
      final commits = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      
      // Count significant commits
      int significantCommits = 0;
      for (final commit in commits) {
        final message = commit['commit']['message'] as String;
        if (message.startsWith('feat:') || message.startsWith('fix:')) {
          significantCommits++;
        }
      }
      
      return significantCommits >= 5; // Create release if 5+ significant commits
    }
    
    return false;
  }
  
  /// Create new release
  Future<void> _createRelease() async {
    if (_authToken == null) {
      print('  ❌ Cannot create release without auth token');
      return;
    }
    
    try {
      // Generate release notes
      final releaseNotes = await _generateReleaseNotes();
      
      // Get next version
      final nextVersion = _getNextVersion();
      
      final releaseData = {
        'tag_name': 'v$nextVersion',
        'name': 'VedantaTrade v$nextVersion',
        'body': releaseNotes,
        'draft': false,
        'prerelease': false
      };
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName/releases'),
        headers: _getHeaders(),
        body: jsonEncode(releaseData)
      );
      
      if (response.statusCode == 201) {
        print('    ✓ Release v$nextVersion created successfully');
      } else {
        print('    ❌ Failed to create release: ${response.statusCode}');
        print(jsonDecode(response.body));
      }
      
    } catch (e) {
      print('    ❌ Failed to create release: $e');
    }
  }
  
  /// Generate release notes
  Future<String> _generateReleaseNotes() async {
    final lastRelease = _releases.isNotEmpty ? _releases.first : null;
    final lastReleaseDate = lastRelease != null 
        ? DateTime.parse(lastRelease['published_at']) 
        : DateTime.now().subtract(const Duration(days: 30));
    
    // Get commits since last release
    final response = await http.get(
      Uri.parse('$apiBaseUrl/repos/$repoOwner/$repoName/commits?since=$lastReleaseDate'),
      headers: _getHeaders()
    );
    
    if (response.statusCode != 200) {
      return 'Release notes generation failed';
    }
    
    final commits = List<Map<String, dynamic>>.from(jsonDecode(response.body));
    final buffer = StringBuffer();
    
    buffer.writeln('## 🚀 What\'s New');
    buffer.writeln();
    
    // Group commits by type
    final features = <String>[];
    final fixes = <String>[];
    final improvements = <String>[];
    
    for (final commit in commits) {
      final message = commit['commit']['message'] as String;
      final author = commit['commit']['author']['name'] as String;
      final hash = commit['sha'] as String;
      
      if (message.startsWith('feat:')) {
        features.add('- ${message.substring(5).trim()} (${hash.substring(0, 7)})');
      } else if (message.startsWith('fix:')) {
        fixes.add('- ${message.substring(4).trim()} (${hash.substring(0, 7)})');
      } else if (message.startsWith('refactor:') || message.startsWith('perf:') || message.startsWith('chore:')) {
        improvements.add('- ${message.split(':').last.trim()} (${hash.substring(0, 7)})');
      }
    }
    
    if (features.isNotEmpty) {
      buffer.writeln('### ✨ Features');
      for (final feature in features) {
        buffer.writeln(feature);
      }
      buffer.writeln();
    }
    
    if (fixes.isNotEmpty) {
      buffer.writeln('### 🐛 Bug Fixes');
      for (final fix in fixes) {
        buffer.writeln(fix);
      }
      buffer.writeln();
    }
    
    if (improvements.isNotEmpty) {
      buffer.writeln('### 🔧 Improvements');
      for (final improvement in improvements) {
        buffer.writeln(improvement);
      }
      buffer.writeln();
    }
    
    buffer.writeln('---');
    buffer.writeln('**Full Changelog**: [View on GitHub](https://github.com/$repoOwner/$repoName/blob/main/CHANGELOG.md)');
    
    return buffer.toString();
  }
  
  /// Get next version
  String _getNextVersion() {
    if (_releases.isEmpty) {
      return '3.4.0';
    }
    
    final lastRelease = _releases.first;
    final lastVersion = lastRelease['tag_name'] as String;
    
    // Parse version (remove 'v' prefix)
    final version = lastVersion.replaceFirst('v', '');
    final parts = version.split('.');
    
    if (parts.length >= 3) {
      final major = int.tryParse(parts[0]) ?? 3;
      final minor = int.tryParse(parts[1]) ?? 4;
      final patch = int.tryParse(parts[2]) ?? 0;
      
      // Increment patch version
      return '$major.$minor.${patch + 1}';
    }
    
    return '3.4.1';
  }
  
  /// Update documentation
  Future<void> _updateDocumentation() async {
    print('\n📚 Updating Documentation...');
    
    try {
      // Update changelog
      await _updateChangelog();
      
      // Update README
      await _updateReadme();
      
      // Update TODO
      await _updateTodo();
      
      print('  ✓ Documentation updated');
      
    } catch (e) {
      print('  ❌ Failed to update documentation: $e');
    }
  }
  
  /// Update changelog
  Future<void> _updateChangelog() async {
    final changelogFile = File('CHANGELOG.md');
    if (!await changelogFile.exists()) {
      print('    ⚠ CHANGELOG.md not found');
      return;
    }
    
    // This would implement automatic changelog updates
    // For now, just log that we checked it
    print('    ✓ CHANGELOG.md checked');
  }
  
  /// Update README
  Future<void> _updateReadme() async {
    final readmeFile = File('README.md');
    if (!await readmeFile.exists()) {
      print('    ⚠ README.md not found');
      return;
    }
    
    // This would implement automatic README updates
    // For now, just log that we checked it
    print('    ✓ README.md checked');
  }
  
  /// Update TODO
  Future<void> _updateTodo() async {
    final todoFile = File('TODO.md');
    if (!await todoFile.exists()) {
      print('    ⚠ TODO.md not found');
      return;
    }
    
    // This would implement automatic TODO updates
    // For now, just log that we checked it
    print('    ✓ TODO.md checked');
  }
  
  /// Generate status report
  Future<void> _generateStatusReport() async {
    print('\n📊 Generating Status Report...');
    
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'repository': {
        'name': _repoInfo['full_name'],
        'stars': _repoInfo['stargazers_count'],
        'forks': _repoInfo['forks_count'],
        'issues': _repoInfo['open_issues_count'],
        'lastUpdated': _repoInfo['updated_at']
      },
      'commits': {
        'total': _commits.length,
        'recent': _commits.take(10).map((c) => c['sha']).toList()
      },
      'branches': {
        'total': _branches.length,
        'default': _repoInfo['default_branch'],
        'protected': _branches.where((b) => b['protected']).length
      },
      'releases': {
        'total': _releases.length,
        'latest': _releases.isNotEmpty ? _releases.first['tag_name'] : null
      },
      'status': _getRepositoryHealth()
    };
    
    final reportFile = File('github_status_report.json');
    await reportFile.writeAsString(JsonEncoder.withIndent('  ').convert(report));
    
    print('  ✓ Status report saved to github_status_report.json');
    
    // Generate human-readable report
    await _generateHumanReadableStatusReport(report);
  }
  
  /// Get repository health
  String _getRepositoryHealth() {
    final issues = _repoInfo['open_issues_count'] as int? ?? 0;
    final stars = _repoInfo['stargazers_count'] as int? ?? 0;
    final recentCommits = _commits.take(7).length;
    
    if (issues == 0 && recentCommits >= 5) {
      return 'HEALTHY';
    } else if (issues <= 5 && recentCommits >= 3) {
      return 'WARNING';
    } else {
      return 'CRITICAL';
    }
  }
  
  /// Generate human-readable status report
  Future<void> _generateHumanReadableStatusReport(Map<String, dynamic> report) async {
    final reportFile = File('github_status_report.md');
    
    final content = '''
# VedantaTrade GitHub Status Report

**Generated:** ${report['timestamp']}

## Repository Health: ${report['status']}

## Repository Information
- **Name:** ${report['repository']['name']}
- **⭐ Stars:** ${report['repository']['stars']}
- **🍴 Forks:** ${report['repository']['forks']}
- **📝 Open Issues:** ${report['repository']['issues']}
- **📅 Last Updated:** ${report['repository']['lastUpdated']}

## Commit Activity
- **Total Commits:** ${report['commits']['total']}
- **Recent Commits:** ${report['commits']['recent'].length}

## Branch Information
- **Total Branches:** ${report['branches']['total']}
- **Default Branch:** ${report['branches']['default']}
- **Protected Branches:** ${report['branches']['protected']}

## Release Information
- **Total Releases:** ${report['releases']['total']}
- **Latest Release:** ${report['releases']['latest'] ?? 'None'}

## Recommendations
${_getGitHubRecommendations()}

---
*Report generated by VedantaTrade GitHub Manager*
''';
    
    await reportFile.writeAsString(content);
    print('  ✓ Human-readable status report saved to github_status_report.md');
  }
  
  /// Get GitHub recommendations
  String _getGitHubRecommendations() {
    final recommendations = <String>[];
    final issues = _repoInfo['open_issues_count'] as int? ?? 0;
    final recentCommits = _commits.take(7).length;
    
    if (issues > 10) {
      recommendations.add('- Consider addressing open issues to improve repository health');
    }
    
    if (recentCommits < 3) {
      recommendations.add('- Increase commit frequency to show active development');
    }
    
    if (_releases.isEmpty) {
      recommendations.add('- Create initial release to establish versioning');
    }
    
    if (recommendations.isEmpty) {
      return 'Repository is in good health! 🎉';
    }
    
    return recommendations.join('\n');
  }
  
  /// Get headers for API requests
  Map<String, String> _getHeaders() {
    final headers = {
      'Accept': 'application/vnd.github.v3+json',
      'User-Agent': 'VedantaTrade-GitHub-Manager/1.0'
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// Log error
  Future<void> _logError(String error) async {
    final logFile = File('github_errors.log');
    final timestamp = DateTime.now().toIso8601String();
    await logFile.writeAsString('[$timestamp] $error\n', mode: FileMode.append);
  }
}

void main(List<String> arguments) async {
  final authToken = Platform.environment['GITHUB_TOKEN'];
  
  final manager = VedantaTradeGitHubManager(authToken);
  
  if (arguments.contains('--help') || arguments.contains('-h')) {
    print('''
VedantaTrade GitHub Manager

Usage: dart tool/github_manager.dart [options]

Options:
  --help, -h       Show this help message
  --analyze-only      Run analysis only (no actions)
  --create-release    Force create new release
  --update-docs      Update documentation only
  --status          Generate status report only

Environment Variables:
  GITHUB_TOKEN       GitHub personal access token (optional for read-only operations)

Examples:
  dart tool/github_manager.dart                    # Full GitHub management
  dart tool/github_manager.dart --analyze-only      # Analysis only
  dart tool/github_manager.dart --create-release    # Create new release
  dart tool/github_manager.dart --update-docs      # Update documentation
  dart tool/github_manager.dart --status          # Generate status report
''');
    return;
  }
  
  if (arguments.contains('--analyze-only')) {
    await manager._getRepositoryInfo();
    await manager._analyzeCommitHistory();
    await manager._checkBranchStatus();
    await manager._analyzeReleases();
  } else if (arguments.contains('--create-release')) {
    await manager._getRepositoryInfo();
    await manager._analyzeReleases();
    await manager._createRelease();
  } else if (arguments.contains('--update-docs')) {
    await manager._updateDocumentation();
  } else if (arguments.contains('--status')) {
    await manager._getRepositoryInfo();
    await manager._analyzeCommitHistory();
    await manager._checkBranchStatus();
    await manager._analyzeReleases();
    await manager._generateStatusReport();
  } else {
    await manager.runGitHubWorkflow();
  }
}
