import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/workspace_activity.dart';

abstract class WorkspaceActivityDraftService {
  Future<List<WorkspaceActivity>> loadDraftActivities();

  Future<List<WorkspaceActivity>> addDraftActivity(WorkspaceActivity activity);
}

class LocalWorkspaceActivityDraftService
    implements WorkspaceActivityDraftService {
  LocalWorkspaceActivityDraftService();

  static const _draftActivitiesKey =
      'neutralitical.workspace.draft_activities.v1';

  @override
  Future<List<WorkspaceActivity>> loadDraftActivities() async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = preferences.getString(_draftActivitiesKey);
    if (encoded == null || encoded.isEmpty) {
      return const <WorkspaceActivity>[];
    }

    final decoded = jsonDecode(encoded) as List<dynamic>;
    return decoded
        .map((item) => WorkspaceActivity.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<WorkspaceActivity>> addDraftActivity(
    WorkspaceActivity activity,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final current = await loadDraftActivities();
    final updated = [activity, ...current];
    await preferences.setString(
      _draftActivitiesKey,
      jsonEncode(updated.map((item) => item.toJson()).toList()),
    );
    return updated;
  }
}
