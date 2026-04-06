import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Git History Analyzer for VedantaTrade
/// Analyzes commit history to identify milestones, track changes, and understand project evolution
class GitHistoryAnalyzer {
  final String projectPath;
  final List<GitCommit> _commits = [];
  final Map<String, dynamic> _statistics = {};
  
  GitHistoryAnalyzer(this.projectPath);
  
  /// Analyze git history
  Future<GitAnalysisReport> analyze() async {
    print('🔍 Analyzing Git history...');
    
    // Get commit history
    await _getCommitHistory();
    
    // Analyze commits
    await _analyzeCommits();
    
    // Generate report
    final report = _generateReport();
    
    return report;
  }
  
  /// Get commit history from git
  Future<void> _getCommitHistory() async {
    try {
      final result = await Process.run('git', [
        'log',
        '--oneline',
        '--graph',
        '--all',
        '--decorate',
        '--abbrev-commit',
        '--pretty=format:%H|%s|%f|%ad|%an|%ae',
      ], workingDirectory: projectPath);
      
      if (result.exitCode == 0) {
        final lines = result.stdout.split('\n');
        
        for (final line in lines) {
          if (line.trim().isEmpty) continue;
          
          // Parse commit format more robustly
          final parts = line.split('|');
          if (parts.length >= 5) {
            // Try to extract date from different positions
            String dateStr = '';
            DateTime? commitDate;
            
            // Check different positions for date
            for (int i = 2; i < parts.length - 2; i++) {
              if (parts[i].length >= 8) {
                dateStr = parts[i];
                break;
              }
            }
            
            // Try to parse date
            if (dateStr.isNotEmpty) {
              try {
                // Handle different date formats
                if (dateStr.contains(' ')) {
                  // Format like "Fri Mar 27 16:22:08 2026"
                  final dateParts = dateStr.split(' ');
                  if (dateParts.length >= 5) {
                    final monthStr = dateParts[1];
                    final dayStr = dateParts[2];
                    final timeStr = dateParts[3];
                    final yearStr = dateParts[4];
                    
                    final monthMap = {
                      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
                      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
                    };
                    
                    final month = monthMap[monthStr] ?? 1;
                    final day = int.tryParse(dayStr) ?? 1;
                    final year = int.tryParse(yearStr) ?? 2026;
                    
                    if (month > 0 && day > 0 && year > 0) {
                      commitDate = DateTime(year, month, day);
                    }
                  }
                } else {
                  // Try standard ISO format
                  commitDate = DateTime.tryParse(dateStr);
                }
                
                if (commitDate != null) {
                  final commit = GitCommit(
                    hash: parts[0],
                    message: parts[1],
                    date: commitDate!,
                    author: parts[parts.length - 2],
                    authorEmail: parts[parts.length - 1],
                  );
                  _commits.add(commit);
                }
              } catch (e) {
                // Skip invalid date formats
                print('Warning: Skipping invalid date format: $dateStr');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error getting git history: $e');
    }
  }
  
  /// Analyze commits for patterns and insights
  Future<void> _analyzeCommits() async {
    print('📊 Analyzing commit patterns...');
    
    // Initialize statistics
    _statistics['totalCommits'] = _commits.length;
    _statistics['totalAuthors'] = <String>{};
    _statistics['commitFrequency'] = <String, int>{};
    _statistics['featureCommits'] = 0;
    _statistics['bugFixCommits'] = 0;
    _statistics['refactorCommits'] = 0;
    _statistics['docsCommits'] = 0;
    _statistics['ciCommits'] = 0;
    _statistics['testCommits'] = 0;
    _statistics['hotfixCommits'] = 0;
    _statistics['majorUpdates'] = 0;
    _statistics['minorUpdates'] = 0;
    _statistics['patchUpdates'] = 0;
    
    // Analyze each commit
    for (final commit in _commits) {
      // Track authors
      _statistics['totalAuthors'].add(commit.author);
      
      // Track commit frequency by day
      final dayKey = commit.date.toIso8601String().substring(0, 10);
      _statistics['commitFrequency'][dayKey] = 
          (_statistics['commitFrequency'][dayKey] ?? 0) + 1;
      
      // Categorize commits
      final message = commit.message.toLowerCase();
      
      if (message.contains('feat:') || message.contains('feature')) {
        _statistics['featureCommits']++;
      } else if (message.contains('fix:') || message.contains('bug') || message.contains('error')) {
        _statistics['bugFixCommits']++;
      } else if (message.contains('refactor') || message.contains('restructure') || message.contains('cleanup')) {
        _statistics['refactorCommits']++;
      } else if (message.contains('docs') || message.contains('readme') || message.contains('changelog')) {
        _statistics['docsCommits']++;
      } else if (message.contains('ci') || message.contains('cd') || message.contains('pipeline')) {
        _statistics['ciCommits']++;
      } else if (message.contains('test')) {
        _statistics['testCommits']++;
      } else if (message.contains('hotfix') || message.contains('urgent')) {
        _statistics['hotfixCommits']++;
      }
      
      // Categorize by version
      if (message.contains('v1.') || message.contains('major')) {
        _statistics['majorUpdates']++;
      } else if (message.contains('v1.') || message.contains('minor')) {
        _statistics['minorUpdates']++;
      } else if (message.contains('v1.') || message.contains('patch')) {
        _statistics['patchUpdates']++;
      }
    }
    
    // Calculate additional statistics
    _statistics['uniqueAuthors'] = (_statistics['totalAuthors'] as Set<String>).length;
    _statistics['avgCommitsPerDay'] = _statistics['commitFrequency'].isNotEmpty
        ? (_statistics['commitFrequency'].values.reduce((a, b) => a + b) / _statistics['commitFrequency'].length)
        : 0.0;
    
    // Find most active day
    if (_statistics['commitFrequency'].isNotEmpty) {
      final mostActiveDay = _statistics['commitFrequency'].entries
          .reduce((a, b) => a.value > b.value ? a : b);
      _statistics['mostActiveDay'] = mostActiveDay.key;
      _statistics['mostActiveDayCommits'] = mostActiveDay.value;
    }
    
    // Find first and last commit dates
    if (_commits.isNotEmpty) {
      _statistics['firstCommitDate'] = _commits.last.date;
      _statistics['lastCommitDate'] = _commits.first.date;
      _statistics['projectDuration'] = _commits.first.date.difference(_commits.last.date).inDays;
    }
  }
  
  /// Generate analysis report
  GitAnalysisReport _generateReport() {
    print('📋 Generating Git analysis report...');
    
    return GitAnalysisReport(
      totalCommits: _statistics['totalCommits'] ?? 0,
      uniqueAuthors: _statistics['uniqueAuthors'] ?? 0,
      projectDuration: _statistics['projectDuration'] ?? 0,
      firstCommitDate: _statistics['firstCommitDate'],
      lastCommitDate: _statistics['lastCommitDate'],
      avgCommitsPerDay: _statistics['avgCommitsPerDay'] ?? 0.0,
      mostActiveDay: _statistics['mostActiveDay'],
      mostActiveDayCommits: _statistics['mostActiveDayCommits'] ?? 0,
      featureCommits: _statistics['featureCommits'] ?? 0,
      bugFixCommits: _statistics['bugFixCommits'] ?? 0,
      refactorCommits: _statistics['refactorCommits'] ?? 0,
      docsCommits: _statistics['docsCommits'] ?? 0,
      ciCommits: _statistics['ciCommits'] ?? 0,
      testCommits: _statistics['testCommits'] ?? 0,
      hotfixCommits: _statistics['hotfixCommits'] ?? 0,
      majorUpdates: _statistics['majorUpdates'] ?? 0,
      minorUpdates: _statistics['minorUpdates'] ?? 0,
      patchUpdates: _statistics['patchUpdates'] ?? 0,
      commits: _commits,
      keyMilestones: _identifyKeyMilestones(),
      evolutionPhases: _identifyEvolutionPhases(),
      generatedAt: DateTime.now(),
    );
  }
  
  /// Identify key milestones in project history
  List<ProjectMilestone> _identifyKeyMilestones() {
    final milestones = <ProjectMilestone>[];
    
    // Look for major feature completions
    for (final commit in _commits) {
      final message = commit.message.toLowerCase();
      
      if (message.contains('initial commit') || message.contains('setup')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.initial,
          title: 'Project Initialization',
          date: commit.date,
          commit: commit,
          description: 'Initial project setup and basic structure',
        ));
      } else if (message.contains('authentication') && message.contains('complete')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.feature,
          title: 'Authentication System Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete user authentication system implementation',
        ));
      } else if (message.contains('product catalog') && message.contains('complete')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.feature,
          title: 'Product Catalog Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete product catalog with filtering and search',
        ));
      } else if (message.contains('stock monitoring') && message.contains('complete')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.feature,
          title: 'Stock Monitoring Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete real-time stock level monitoring with alerts',
        ));
      } else if (message.contains('checkout') && message.contains('complete')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.feature,
          title: 'Checkout System Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete checkout and payment flow for retailers',
        ));
      } else if (message.contains('expense reconciliation') && message.contains('complete')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.feature,
          title: 'Expense Reconciliation Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete MR expense reconciliation with multi-photo receipt approval',
        ));
      } else if (message.contains('vat') || message.contains('tax return')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.feature,
          title: 'VAT/Tax Returns Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete exportable PDF VAT/Tax returns with IRDN compliance',
        ));
      } else if (message.contains('ci/cd') && message.contains('complete')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.infrastructure,
          title: 'CI/CD Pipeline Complete',
          date: commit.date,
          commit: commit,
          description: 'Complete comprehensive CI/CD pipeline with automated testing',
        ));
      } else if (message.contains('production') || message.contains('deploy')) {
        milestones.add(ProjectMilestone(
          type: MilestoneType.deployment,
          title: 'Production Deployment',
          date: commit.date,
          commit: commit,
          description: 'Deploy application to production environment',
        ));
      }
    }
    
    // Sort milestones by date
    milestones.sort((a, b) => a.date.compareTo(b.date));
    
    return milestones;
  }
  
  /// Identify evolution phases of the project
  List<EvolutionPhase> _identifyEvolutionPhases() {
    final phases = <EvolutionPhase>[];
    
    // Group commits into phases based on time and content
    if (_commits.isEmpty) return phases;
    
    final startDate = _commits.last.date;
    final endDate = _commits.first.date;
    final totalDuration = endDate.difference(startDate).inDays;
    
    // Phase 1: Initial Development (first 30 days)
    final initialPhaseCommits = _commits.where((c) => 
      c.date.isAfter(startDate) && c.date.isBefore(startDate.add(const Duration(days: 30)))
    ).toList();
    
    if (initialPhaseCommits.isNotEmpty) {
      phases.add(EvolutionPhase(
        name: 'Initial Development',
        startDate: startDate,
        endDate: initialPhaseCommits.first.date,
        description: 'Project setup and basic feature implementation',
        keyActivities: _extractKeyActivities(initialPhaseCommits),
        commitCount: initialPhaseCommits.length,
      ));
    }
    
    // Phase 2: Feature Development (30-90 days)
    final featurePhaseCommits = _commits.where((c) => 
      c.date.isAfter(startDate.add(const Duration(days: 30))) && 
      c.date.isBefore(startDate.add(const Duration(days: 90)))
    ).toList();
    
    if (featurePhaseCommits.isNotEmpty) {
      phases.add(EvolutionPhase(
        name: 'Feature Development',
        startDate: startDate.add(const Duration(days: 30)),
        endDate: featurePhaseCommits.first.date,
        description: 'Major feature implementation and enhancement',
        keyActivities: _extractKeyActivities(featurePhaseCommits),
        commitCount: featurePhaseCommits.length,
      ));
    }
    
    // Phase 3: Optimization & Cleanup (90+ days)
    final optimizationPhaseCommits = _commits.where((c) => 
      c.date.isAfter(startDate.add(const Duration(days: 90)))
    ).toList();
    
    if (optimizationPhaseCommits.isNotEmpty) {
      phases.add(EvolutionPhase(
        name: 'Optimization & Cleanup',
        startDate: startDate.add(const Duration(days: 90)),
        endDate: optimizationPhaseCommits.first.date,
        description: 'Code optimization, cleanup, and performance improvements',
        keyActivities: _extractKeyActivities(optimizationPhaseCommits),
        commitCount: optimizationPhaseCommits.length,
      ));
    }
    
    return phases;
  }
  
  /// Extract key activities from commits
  List<String> _extractKeyActivities(List<GitCommit> commits) {
    final activities = <String>{};
    
    for (final commit in commits) {
      final message = commit.message.toLowerCase();
      
      if (message.contains('authentication')) activities.add('Authentication System');
      if (message.contains('product catalog')) activities.add('Product Catalog');
      if (message.contains('stock monitoring')) activities.add('Stock Monitoring');
      if (message.contains('checkout')) activities.add('Checkout System');
      if (message.contains('expense reconciliation')) activities.add('Expense Reconciliation');
      if (message.contains('vat') || message.contains('tax')) activities.add('VAT/Tax Returns');
      if (message.contains('ci') || message.contains('cd')) activities.add('CI/CD Pipeline');
      if (message.contains('deploy')) activities.add('Deployment');
      if (message.contains('ui') || message.contains('ux')) activities.add('UI/UX Enhancement');
      if (message.contains('refactor') || message.contains('cleanup')) activities.add('Code Optimization');
      if (message.contains('test')) activities.add('Testing');
      if (message.contains('docs')) activities.add('Documentation');
    }
    
    return activities.toList();
  }
  
  /// Save report to file
  Future<void> saveReport(GitAnalysisReport report) async {
    try {
      final reportPath = path.join(projectPath, 'git_analysis_report.json');
      final file = File(reportPath);
      await file.writeAsString(jsonEncode(report.toJson()));
      print('📄 Git analysis report saved to: $reportPath');
    } catch (e) {
      print('Error saving report: $e');
    }
  }
}

/// Git Commit representation
class GitCommit {
  final String hash;
  final String message;
  final DateTime date;
  final String author;
  final String authorEmail;
  
  const GitCommit({
    required this.hash,
    required this.message,
    required this.date,
    required this.author,
    required this.authorEmail,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'message': message,
      'date': date.toIso8601String(),
      'author': author,
      'authorEmail': authorEmail,
    };
  }
}

/// Git Analysis Report
class GitAnalysisReport {
  final int totalCommits;
  final int uniqueAuthors;
  final int projectDuration;
  final DateTime? firstCommitDate;
  final DateTime? lastCommitDate;
  final double avgCommitsPerDay;
  final String? mostActiveDay;
  final int mostActiveDayCommits;
  final int featureCommits;
  final int bugFixCommits;
  final int refactorCommits;
  final int docsCommits;
  final int ciCommits;
  final int testCommits;
  final int hotfixCommits;
  final int majorUpdates;
  final int minorUpdates;
  final int patchUpdates;
  final List<GitCommit> commits;
  final List<ProjectMilestone> keyMilestones;
  final List<EvolutionPhase> evolutionPhases;
  final DateTime generatedAt;
  
  const GitAnalysisReport({
    required this.totalCommits,
    required this.uniqueAuthors,
    required this.projectDuration,
    this.firstCommitDate,
    this.lastCommitDate,
    required this.avgCommitsPerDay,
    this.mostActiveDay,
    required this.mostActiveDayCommits,
    required this.featureCommits,
    required this.bugFixCommits,
    required this.refactorCommits,
    required this.docsCommits,
    required this.ciCommits,
    required this.testCommits,
    required this.hotfixCommits,
    required this.majorUpdates,
    required this.minorUpdates,
    required this.patchUpdates,
    required this.commits,
    required this.keyMilestones,
    required this.evolutionPhases,
    required this.generatedAt,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'summary': {
        'totalCommits': totalCommits,
        'uniqueAuthors': uniqueAuthors,
        'projectDuration': projectDuration,
        'firstCommitDate': firstCommitDate?.toIso8601String(),
        'lastCommitDate': lastCommitDate?.toIso8601String(),
        'avgCommitsPerDay': avgCommitsPerDay,
        'mostActiveDay': mostActiveDay,
        'mostActiveDayCommits': mostActiveDayCommits,
      },
      'commitBreakdown': {
        'featureCommits': featureCommits,
        'bugFixCommits': bugFixCommits,
        'refactorCommits': refactorCommits,
        'docsCommits': docsCommits,
        'ciCommits': ciCommits,
        'testCommits': testCommits,
        'hotfixCommits': hotfixCommits,
      },
      'versionBreakdown': {
        'majorUpdates': majorUpdates,
        'minorUpdates': minorUpdates,
        'patchUpdates': patchUpdates,
      },
      'milestones': keyMilestones.map((m) => m.toJson()).toList(),
      'evolutionPhases': evolutionPhases.map((p) => p.toJson()).toList(),
      'commits': commits.map((c) => c.toJson()).toList(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
  
  void printSummary() {
    print('\n' + '='*60);
    print('📊 GIT HISTORY ANALYSIS REPORT');
    print('='*60);
    print('Generated: ${generatedAt.toIso8601String()}');
    print('');
    
    print('📈 PROJECT SUMMARY:');
    print('  Total Commits: $totalCommits');
    print('  Unique Authors: $uniqueAuthors');
    print('  Project Duration: $projectDuration days');
    print('  First Commit: ${firstCommitDate?.toIso8601String() ?? 'N/A'}');
    print('  Last Commit: ${lastCommitDate?.toIso8601String() ?? 'N/A'}');
    print('  Avg Commits/Day: ${avgCommitsPerDay.toStringAsFixed(2)}');
    if (mostActiveDay != null) {
      print('  Most Active Day: $mostActiveDay ($mostActiveDayCommits commits)');
    }
    
    print('\n📊 COMMIT BREAKDOWN:');
    print('  Features: $featureCommits');
    print('  Bug Fixes: $bugFixCommits');
    print('  Refactoring: $refactorCommits');
    print('  Documentation: $docsCommits');
    print('  CI/CD: $ciCommits');
    print('  Testing: $testCommits');
    print('  Hotfixes: $hotfixCommits');
    
    print('\n📈 VERSION BREAKDOWN:');
    print('  Major Updates: $majorUpdates');
    print('  Minor Updates: $minorUpdates');
    print('  Patch Updates: $patchUpdates');
    
    print('\n🎯 KEY MILESTONES:');
    for (final milestone in keyMilestones) {
      print('  ${milestone.date.toIso8601String()}: ${milestone.title}');
      print('    ${milestone.description}');
    }
    
    print('\n📈 EVOLUTION PHASES:');
    for (final phase in evolutionPhases) {
      print('  ${phase.name}: ${phase.startDate.toIso8601String()} - ${phase.endDate.toIso8601String()}');
      print('    ${phase.description}');
      print('    Key Activities: ${phase.keyActivities.join(', ')}');
      print('    Commits: ${phase.commitCount}');
    }
    
    print('\n' + '='*60);
  }
}

/// Project Milestone
class ProjectMilestone {
  final MilestoneType type;
  final String title;
  final DateTime date;
  final GitCommit commit;
  final String description;
  
  const ProjectMilestone({
    required this.type,
    required this.title,
    required this.date,
    required this.commit,
    required this.description,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'date': date.toIso8601String(),
      'commit': commit.toJson(),
      'description': description,
    };
  }
}

/// Milestone Type
enum MilestoneType {
  initial,
  feature,
  infrastructure,
  deployment,
  release,
}

/// Evolution Phase
class EvolutionPhase {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final List<String> keyActivities;
  final int commitCount;
  
  const EvolutionPhase({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.keyActivities,
    required this.commitCount,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'keyActivities': keyActivities,
      'commitCount': commitCount,
    };
  }
}

/// Main function to run Git history analysis
void main(List<String> args) async {
  final projectPath = args.isNotEmpty ? args[0] : Directory.current.path;
  final analyzer = GitHistoryAnalyzer(projectPath);
  
  print('🔍 Starting Git history analysis...');
  final report = await analyzer.analyze();
  
  // Print summary
  report.printSummary();
  
  // Save detailed report
  await analyzer.saveReport(report);
  
  print('✅ Git history analysis completed!');
}
