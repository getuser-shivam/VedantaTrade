import 'package:flutter/material.dart';

enum WorkspaceModule {
  overview,
  network,
  fieldForce,
  finance,
  catalog,
  imports,
  reports,
}

extension WorkspaceModuleX on WorkspaceModule {
  String get label => switch (this) {
    WorkspaceModule.overview => 'Overview',
    WorkspaceModule.network => 'Network',
    WorkspaceModule.fieldForce => 'Field Force',
    WorkspaceModule.finance => 'Finance',
    WorkspaceModule.catalog => 'Catalog',
    WorkspaceModule.imports => 'Imports',
    WorkspaceModule.reports => 'Reports',
  };

  IconData get icon => switch (this) {
    WorkspaceModule.overview => Icons.space_dashboard_outlined,
    WorkspaceModule.network => Icons.hub_outlined,
    WorkspaceModule.fieldForce => Icons.route_outlined,
    WorkspaceModule.finance => Icons.account_balance_wallet_outlined,
    WorkspaceModule.catalog => Icons.inventory_2_outlined,
    WorkspaceModule.imports => Icons.cloud_download_outlined,
    WorkspaceModule.reports => Icons.bar_chart_outlined,
  };
}
