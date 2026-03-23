import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/workspace_activity_update.dart';

abstract class WorkspaceActivityJournalService {
  Future<List<WorkspaceActivityUpdate>> loadUpdates();

  Future<List<WorkspaceActivityUpdate>> addUpdate({
    required String activityId,
    required String status,
    required String note,
    required String updatedBy,
  });
}

class LocalWorkspaceActivityJournalService
    implements WorkspaceActivityJournalService {
  LocalWorkspaceActivityJournalService();

  static const _updatesKey = 'neutralitical.workspace.activity_updates.v1';

  @override
  Future<List<WorkspaceActivityUpdate>> loadUpdates() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_updatesKey);
    if (encoded == null || encoded.isEmpty) {
      return const <WorkspaceActivityUpdate>[];
    }

    final decoded = jsonDecode(encoded) as List<dynamic>;
    final updates = decoded
        .map(
          (item) =>
              WorkspaceActivityUpdate.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
    return _sorted(updates);
  }

  @override
  Future<List<WorkspaceActivityUpdate>> addUpdate({
    required String activityId,
    required String status,
    required String note,
    required String updatedBy,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await loadUpdates();
    final now = DateTime.now().toUtc();
    final update = WorkspaceActivityUpdate(
      id: '${activityId}_${now.microsecondsSinceEpoch}',
      activityId: activityId,
      status: status.trim(),
      note: note.trim(),
      updatedBy: updatedBy.trim(),
      updatedAt: now,
    );
    final updated = _sorted([update, ...current]);
    await preferences.setString(
      _updatesKey,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
    return updated;
  }

  List<WorkspaceActivityUpdate> _sorted(List<WorkspaceActivityUpdate> updates) {
    final sorted = [...updates];
    sorted.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return sorted;
  }
}
