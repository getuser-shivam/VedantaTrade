class WorkspaceActivityUpdate {
  const WorkspaceActivityUpdate({
    required this.id,
    required this.activityId,
    required this.status,
    required this.note,
    required this.updatedBy,
    required this.updatedAt,
  });

  final String id;
  final String activityId;
  final String status;
  final String note;
  final String updatedBy;
  final DateTime updatedAt;

  factory WorkspaceActivityUpdate.fromJson(Map<String, dynamic> json) {
    return WorkspaceActivityUpdate(
      id: json['id']?.toString() ?? '',
      activityId: json['activityId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      updatedBy: json['updatedBy']?.toString() ?? '',
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activityId': activityId,
      'status': status,
      'note': note,
      'updatedBy': updatedBy,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
