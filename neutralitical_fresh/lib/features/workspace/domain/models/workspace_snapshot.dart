import 'workspace_module.dart';

class WorkspaceMetric {
  const WorkspaceMetric({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;
}

class WorkspaceTask {
  const WorkspaceTask({
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final String title;
  final String subtitle;
  final String status;
}

class WorkspaceSnapshot {
  const WorkspaceSnapshot({
    required this.headline,
    required this.summary,
    required this.metrics,
    required this.tasks,
    required this.enabledModules,
  });

  final String headline;
  final String summary;
  final List<WorkspaceMetric> metrics;
  final List<WorkspaceTask> tasks;
  final List<WorkspaceModule> enabledModules;
}
