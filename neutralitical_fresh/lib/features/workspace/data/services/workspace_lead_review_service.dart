import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/ingestion_lead.dart';
import '../../domain/models/lead_review_decision.dart';
import '../../domain/models/network_entity.dart';

abstract class WorkspaceLeadReviewService {
  Future<List<LeadReviewDecision>> loadDecisions();

  Future<List<NetworkEntity>> loadPromotedEntities();

  Future<void> reviewLead({
    required IngestionLead lead,
    required LeadReviewAction action,
    required String reviewedBy,
  });
}

class LocalWorkspaceLeadReviewService implements WorkspaceLeadReviewService {
  static const String _decisionStorageKey =
      'neutralitical.workspace.lead_review_decisions.v1';
  static const String _promotedEntityStorageKey =
      'neutralitical.workspace.promoted_entities.v1';

  @override
  Future<List<LeadReviewDecision>> loadDecisions() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_decisionStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <LeadReviewDecision>[];
    }

    final decoded = json.decode(raw) as List<dynamic>;
    final decisions = decoded
        .map((item) => LeadReviewDecision.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    decisions.sort((left, right) => right.reviewedAt.compareTo(left.reviewedAt));
    return decisions;
  }

  @override
  Future<List<NetworkEntity>> loadPromotedEntities() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_promotedEntityStorageKey);
    if (raw == null || raw.trim().isEmpty) {
      return const <NetworkEntity>[];
    }

    final decoded = json.decode(raw) as List<dynamic>;
    return decoded
        .map((item) => NetworkEntity.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> reviewLead({
    required IngestionLead lead,
    required LeadReviewAction action,
    required String reviewedBy,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final decisions = await loadDecisions();
    final promotedEntities = await loadPromotedEntities();

    final decision = LeadReviewDecision(
      id: 'lead_review_${DateTime.now().microsecondsSinceEpoch}',
      leadId: lead.id,
      leadName: lead.name,
      leadType: lead.type,
      action: action,
      reviewedBy: reviewedBy,
      reviewedAt: DateTime.now(),
      city: lead.city,
      territory: lead.territory,
      sourceLabel: lead.sourceLabel,
    );

    final updatedDecisions = [
      decision,
      ...decisions.where((item) => item.leadId != lead.id),
    ]..sort((left, right) => right.reviewedAt.compareTo(left.reviewedAt));

    final updatedPromoted = action == LeadReviewAction.approved
        ? [
            _entityFromLead(lead, reviewedBy),
            ...promotedEntities.where(
              (entity) => entity.id != _promotedEntityIdFor(lead.id),
            ),
          ]
        : promotedEntities
              .where((entity) => entity.id != _promotedEntityIdFor(lead.id))
              .toList(growable: false);

    await preferences.setString(
      _decisionStorageKey,
      json.encode(updatedDecisions.map((item) => item.toJson()).toList()),
    );
    await preferences.setString(
      _promotedEntityStorageKey,
      json.encode(updatedPromoted.map((item) => item.toJson()).toList()),
    );
  }

  NetworkEntity _entityFromLead(IngestionLead lead, String reviewedBy) {
    return NetworkEntity(
      id: _promotedEntityIdFor(lead.id),
      name: lead.name,
      type: lead.type,
      specialty: _specialtyFor(lead.type),
      city: lead.city,
      territory: lead.territory,
      owner: reviewedBy,
      phone: 'Pending verification',
      status: 'Approved from import queue',
      institution: _institutionFor(lead),
      sourceLabel: '${lead.sourceLabel} · reviewed',
      verified: true,
    );
  }

  String _promotedEntityIdFor(String leadId) => 'promoted_$leadId';

  String _specialtyFor(NetworkEntityType type) {
    return switch (type) {
      NetworkEntityType.doctor => 'Imported doctor record',
      NetworkEntityType.stockist => 'Imported trade partner',
      NetworkEntityType.retailer => 'Imported retail account',
      NetworkEntityType.hospital => 'Imported hospital account',
    };
  }

  String _institutionFor(IngestionLead lead) {
    return switch (lead.type) {
      NetworkEntityType.doctor => 'Pending institution verification',
      NetworkEntityType.hospital => lead.name,
      NetworkEntityType.stockist => 'Trade channel review',
      NetworkEntityType.retailer => 'Outlet verification pending',
    };
  }
}
