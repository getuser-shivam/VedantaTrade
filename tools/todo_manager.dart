import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:http/http.dart' as http;

/// TODO management system
class TODOManager {
  final String projectPath;
  final bool verbose;
  
  TODOManager(this.projectPath, {this.verbose = false});

  /// Load TODO items from file
  Future<List<TODOItem>> loadTODOs() async {
    final todos = <TODOItem>[];
    
    try {
      final todoFile = File('$projectPath/TODO.md');
      if (!await todoFile.exists()) {
        return todos;
      }
      
      final content = await todoFile.readAsString();
      final lines = content.split('\n');
      
      TODOItem? currentSection;
      
      for (final line in lines) {
        if (line.startsWith('## ')) {
          if (currentSection != null) {
            todos.add(currentSection);
          }
          currentSection = TODOItem(
            title: line.replaceFirst('## ', ''),
            type: TODOType.section,
            children: [],
          );
        } else if (line.startsWith('- [x]')) {
          final task = line.replaceFirst('- [x] ', '');
          if (currentSection != null) {
            currentSection.children!.add(TODOItem(
              title: task,
              type: TODOType.completed,
              children: [],
            ));
          }
        } else if (line.startsWith('- [ ]')) {
          final task = line.replaceFirst('- [ ] ', '');
          if (currentSection != null) {
            currentSection.children!.add(TODOItem(
              title: task,
              type: TODOType.pending,
              children: [],
            ));
          }
        }
      }
      
      if (currentSection != null) {
        todos.add(currentSection);
      }
      
    } catch (e) {
      if (verbose) print('❌ Failed to load TODOs: $e');
    }
    
    return todos;
  }

  /// Save TODO items to file
  Future<void> saveTODOs(List<TODOItem> todos) async {
    try {
      final content = StringBuffer();
      
      for (final todo in todos) {
        content.writeln('## ${todo.title}');
        content.writeln();
        
        for (final child in todo.children ?? []) {
          final checkbox = child.type == TODOType.completed ? 'x' : ' ';
          content.writeln('- [$checkbox] ${child.title}');
        }
        
        content.writeln();
      }
      
      final todoFile = File('$projectPath/TODO.md');
      await todoFile.writeAsString(content.toString());
      
    } catch (e) {
      if (verbose) print('❌ Failed to save TODOs: $e');
    }
  }

  /// Add new TODO item
  Future<void> addTODO({
    required String section,
    required String task,
    TODOType type = TODOType.pending,
    int priority = 1,
  }) async {
    final todos = await loadTODOs();
    
    // Find or create section
    TODOItem? targetSection;
    for (final todo in todos) {
      if (todo.title.toLowerCase().contains(section.toLowerCase())) {
        targetSection = todo;
        break;
      }
    }
    
    if (targetSection == null) {
      targetSection = TODOItem(
        title: section,
        type: TODOType.section,
        children: [],
      );
      todos.insert(0, targetSection);
    }
    
    // Add task
    targetSection.children!.add(TODOItem(
      title: task,
      type: type,
      priority: priority,
      children: [],
    ));
    
    await saveTODOs(todos);
    
    if (verbose) print('✅ Added TODO: $task');
  }

  /// Complete TODO item
  Future<void> completeTODO({
    required String section,
    required String task,
  }) async {
    final todos = await loadTODOs();
    
    for (final todo in todos) {
      if (todo.title.toLowerCase().contains(section.toLowerCase())) {
        for (final child in todo.children ?? []) {
          if (child.title.toLowerCase().contains(task.toLowerCase())) {
            child.type = TODOType.completed;
            child.completedAt = DateTime.now();
          }
        }
      }
    }
    
    await saveTODOs(todos);
    
    if (verbose) print('✅ Completed TODO: $task');
  }

  /// Get TODO statistics
  Future<TODOStats> getTODOStats() async {
    final todos = await loadTODOs();
    final stats = TODOStats();
    
    for (final todo in todos) {
      for (final child in todo.children ?? []) {
        stats.total++;
        
        if (child.type == TODOType.completed) {
          stats.completed++;
        } else if (child.type == TODOType.pending) {
          stats.pending++;
        }
        
        // Priority statistics
        switch (child.priority) {
          case 1:
            stats.highPriority++;
            break;
          case 2:
            stats.mediumPriority++;
            break;
          case 3:
            stats.lowPriority++;
            break;
        }
      }
    }
    
    stats.completionRate = stats.total > 0 
        ? (stats.completed / stats.total * 100).round()
        : 0;
    
    return stats;
  }

  /// Get overdue TODOs
  Future<List<TODOItem>> getOverdueTODOs() async {
    final todos = await loadTODOs();
    final overdue = <TODOItem>[];
    final now = DateTime.now();
    
    for (final todo in todos) {
      for (final child in todo.children ?? []) {
        if (child.type == TODOType.pending && 
            child.dueDate != null && 
            child.dueDate!.isBefore(now)) {
          overdue.add(child);
        }
      }
    }
    
    return overdue;
  }

  /// Generate TODO report
  Future<String> generateReport() async {
    final todos = await loadTODOs();
    final stats = await getTODOStats();
    final overdue = await getOverdueTODOs();
    
    final report = StringBuffer();
    
    report.writeln('# TODO Report');
    report.writeln('Generated: ${DateTime.now().toIso8601String()}');
    report.writeln();
    
    // Statistics
    report.writeln('## 📊 Statistics');
    report.writeln('- Total Tasks: ${stats.total}');
    report.writeln('- Completed: ${stats.completed}');
    report.writeln('- Pending: ${stats.pending}');
    report.writeln('- Completion Rate: ${stats.completionRate}%');
    report.writeln('- High Priority: ${stats.highPriority}');
    report.writeln('- Medium Priority: ${stats.mediumPriority}');
    report.writeln('- Low Priority: ${stats.lowPriority}');
    report.writeln('- Overdue: ${overdue.length}');
    report.writeln();
    
    // Overdue tasks
    if (overdue.isNotEmpty) {
      report.writeln('## ⚠️ Overdue Tasks');
      for (final task in overdue) {
        report.writeln('- ${task.title} (Due: ${task.dueDate})');
      }
      report.writeln();
    }
    
    // Detailed breakdown
    report.writeln('## 📋 Detailed Breakdown');
    for (final todo in todos) {
      report.writeln('### ${todo.title}');
      
      for (final child in todo.children ?? []) {
        final status = child.type == TODOType.completed ? '✅' : '⏳';
        final priority = _getPriorityEmoji(child.priority);
        report.writeln('$status $priority ${child.title}');
        
        if (child.dueDate != null) {
          report.writeln('  Due: ${child.dueDate}');
        }
      }
      report.writeln();
    }
    
    return report.toString();
  }

  /// Archive completed TODOs
  Future<void> archiveCompleted() async {
    final todos = await loadTODOs();
    final completed = <TODOItem>[];
    final remaining = <TODOItem>[];
    
    for (final todo in todos) {
      final sectionChildren = <TODOItem>[];
      final completedChildren = <TODOItem>[];
      
      for (final child in todo.children ?? []) {
        if (child.type == TODOType.completed) {
          completedChildren.add(child);
        } else {
          sectionChildren.add(child);
        }
      }
      
      if (completedChildren.isNotEmpty) {
        completed.add(TODOItem(
          title: '${todo.title} (Archived)',
          type: TODOType.section,
          children: completedChildren,
        ));
      }
      
      if (sectionChildren.isNotEmpty) {
        remaining.add(TODOItem(
          title: todo.title,
          type: TODOType.section,
          children: sectionChildren,
        ));
      }
    }
    
    // Save remaining TODOs
    await saveTODOs(remaining);
    
    // Save archived TODOs
    final archiveFile = File('$projectPath/TODO_ARCHIVE.md');
    final archiveContent = StringBuffer();
    
    archiveContent.writeln('# Archived TODOs');
    archiveContent.writeln('Archived: ${DateTime.now().toIso8601String()}');
    archiveContent.writeln();
    
    for (final todo in completed) {
      archiveContent.writeln('## ${todo.title}');
      archiveContent.writeln();
      
      for (final child in todo.children ?? []) {
        archiveContent.writeln('- [x] ${child.title}');
        if (child.completedAt != null) {
          archiveContent.writeln('  Completed: ${child.completedAt}');
        }
      }
      archiveContent.writeln();
    }
    
    await archiveFile.writeAsString(archiveContent.toString());
    
    if (verbose) print('📦 Archived ${completed.length} completed TODOs');
  }

  /// Set due date for TODO item
  Future<void> setDueDate({
    required String section,
    required String task,
    required DateTime dueDate,
  }) async {
    final todos = await loadTODOs();
    
    for (final todo in todos) {
      if (todo.title.toLowerCase().contains(section.toLowerCase())) {
        for (final child in todo.children ?? []) {
          if (child.title.toLowerCase().contains(task.toLowerCase())) {
            child.dueDate = dueDate;
          }
        }
      }
    }
    
    await saveTODOs(todos);
    
    if (verbose) print('📅 Set due date for: $task');
  }

  /// Update TODO priority
  Future<void> updatePriority({
    required String section,
    required String task,
    required int priority,
  }) async {
    final todos = await loadTODOs();
    
    for (final todo in todos) {
      if (todo.title.toLowerCase().contains(section.toLowerCase())) {
        for (final child in todo.children ?? []) {
          if (child.title.toLowerCase().contains(task.toLowerCase())) {
            child.priority = priority;
          }
        }
      }
    }
    
    await saveTODOs(todos);
    
    if (verbose) print('🎯 Updated priority for: $task');
  }

  String _getPriorityEmoji(int priority) {
    switch (priority) {
      case 1:
        return '🔴';
      case 2:
        return '🟡';
      case 3:
        return '🟢';
      default:
        return '⚪';
    }
  }
}

/// TODO item model
class TODOItem {
  String title;
  TODOType type;
  int priority;
  DateTime? dueDate;
  DateTime? completedAt;
  List<TODOItem>? children;
  
  TODOItem({
    required this.title,
    required this.type,
    this.priority = 2,
    this.dueDate,
    this.completedAt,
    this.children,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.toString(),
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'children': children?.map((c) => c.toJson()).toList(),
    };
  }
  
  factory TODOItem.fromJson(Map<String, dynamic> json) {
    return TODOItem(
      title: json['title'],
      type: TODOType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TODOType.pending,
      ),
      priority: json['priority'] ?? 2,
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      children: json['children']?.map((c) => TODOItem.fromJson(c)).toList(),
    );
  }
}

/// TODO type enum
enum TODOType {
  section,
  pending,
  completed,
  inProgress,
}

/// TODO statistics model
class TODOStats {
  int total = 0;
  int completed = 0;
  int pending = 0;
  int highPriority = 0;
  int mediumPriority = 0;
  int lowPriority = 0;
  int completionRate = 0;
}
