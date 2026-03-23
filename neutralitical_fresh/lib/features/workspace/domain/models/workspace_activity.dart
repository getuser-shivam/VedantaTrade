import 'package:flutter/material.dart';

import '../../../auth/domain/models/business_role.dart';
import 'workspace_module.dart';

enum WorkspaceActivityType {
  visit,
  order,
  collection,
  inventory,
  audit,
  expense,
  procurement,
  sample,
}

extension WorkspaceActivityTypeX on WorkspaceActivityType {
  String get label => switch (this) {
    WorkspaceActivityType.visit => 'Visit',
    WorkspaceActivityType.order => 'Order',
    WorkspaceActivityType.collection => 'Collection',
    WorkspaceActivityType.inventory => 'Inventory',
    WorkspaceActivityType.audit => 'Audit',
    WorkspaceActivityType.expense => 'Expense',
    WorkspaceActivityType.procurement => 'Procurement',
    WorkspaceActivityType.sample => 'Sample',
  };

  IconData get icon => switch (this) {
    WorkspaceActivityType.visit => Icons.route_outlined,
    WorkspaceActivityType.order => Icons.shopping_bag_outlined,
    WorkspaceActivityType.collection => Icons.payments_outlined,
    WorkspaceActivityType.inventory => Icons.inventory_2_outlined,
    WorkspaceActivityType.audit => Icons.fact_check_outlined,
    WorkspaceActivityType.expense => Icons.receipt_long_outlined,
    WorkspaceActivityType.procurement => Icons.local_shipping_outlined,
    WorkspaceActivityType.sample => Icons.medication_outlined,
  };

  static WorkspaceActivityType fromValue(String? value) {
    return WorkspaceActivityType.values.firstWhere(
      (candidate) => candidate.name == value,
      orElse: () => WorkspaceActivityType.visit,
    );
  }
}

class WorkspaceActivity {
  const WorkspaceActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.module,
    required this.roles,
    required this.status,
    required this.dateLabel,
    required this.owner,
    required this.territory,
    required this.tags,
    this.details = const <String, String>{},
    this.amount,
  });

  final String id;
  final String title;
  final String subtitle;
  final WorkspaceActivityType type;
  final WorkspaceModule module;
  final List<BusinessRole> roles;
  final String status;
  final String dateLabel;
  final String owner;
  final String territory;
  final List<String> tags;
  final Map<String, String> details;
  final String? amount;

  factory WorkspaceActivity.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List<dynamic>? ?? const <dynamic>[])
        .map((value) => BusinessRoleX.fromValue(value?.toString()))
        .toList(growable: false);

    return WorkspaceActivity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      type: WorkspaceActivityTypeX.fromValue(json['type']?.toString()),
      module: WorkspaceModule.values.firstWhere(
        (candidate) => candidate.name == json['module']?.toString(),
        orElse: () => WorkspaceModule.overview,
      ),
      roles: roles,
      status: json['status']?.toString() ?? '',
      dateLabel: json['dateLabel']?.toString() ?? '',
      owner: json['owner']?.toString() ?? '',
      territory: json['territory']?.toString() ?? '',
      tags: (json['tags'] as List<dynamic>? ?? const <dynamic>[])
          .map((value) => value.toString())
          .toList(growable: false),
      details: (json['details'] as Map<String, dynamic>? ?? const {})
          .map(
            (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
          ),
      amount: json['amount']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'type': type.name,
      'module': module.name,
      'roles': roles.map((role) => role.name).toList(),
      'status': status,
      'dateLabel': dateLabel,
      'owner': owner,
      'territory': territory,
      'tags': tags,
      'details': details,
      'amount': amount,
    };
  }
}
