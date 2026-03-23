import 'package:flutter/material.dart';

import 'network_entity.dart';

enum LeadReviewAction { approved, rejected }

extension LeadReviewActionX on LeadReviewAction {
  String get label => switch (this) {
    LeadReviewAction.approved => 'Approved',
    LeadReviewAction.rejected => 'Rejected',
  };

  IconData get icon => switch (this) {
    LeadReviewAction.approved => Icons.verified_outlined,
    LeadReviewAction.rejected => Icons.block_outlined,
  };

  static LeadReviewAction fromValue(String? value) {
    return LeadReviewAction.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => LeadReviewAction.rejected,
    );
  }
}

class LeadReviewDecision {
  const LeadReviewDecision({
    required this.id,
    required this.leadId,
    required this.leadName,
    required this.leadType,
    required this.action,
    required this.reviewedBy,
    required this.reviewedAt,
    required this.city,
    required this.territory,
    required this.sourceLabel,
  });

  final String id;
  final String leadId;
  final String leadName;
  final NetworkEntityType leadType;
  final LeadReviewAction action;
  final String reviewedBy;
  final DateTime reviewedAt;
  final String city;
  final String territory;
  final String sourceLabel;

  factory LeadReviewDecision.fromJson(Map<String, dynamic> json) {
    return LeadReviewDecision(
      id: json['id']?.toString() ?? '',
      leadId: json['leadId']?.toString() ?? '',
      leadName: json['leadName']?.toString() ?? '',
      leadType: NetworkEntityTypeX.fromValue(json['leadType']?.toString()),
      action: LeadReviewActionX.fromValue(json['action']?.toString()),
      reviewedBy: json['reviewedBy']?.toString() ?? '',
      reviewedAt:
          DateTime.tryParse(json['reviewedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      city: json['city']?.toString() ?? '',
      territory: json['territory']?.toString() ?? '',
      sourceLabel: json['sourceLabel']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'leadName': leadName,
      'leadType': leadType.name,
      'action': action.name,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt.toIso8601String(),
      'city': city,
      'territory': territory,
      'sourceLabel': sourceLabel,
    };
  }
}
