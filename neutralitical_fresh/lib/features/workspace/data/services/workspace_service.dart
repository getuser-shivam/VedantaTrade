import 'dart:convert';

import 'package:flutter/services.dart';

import '../../../auth/domain/models/business_role.dart';
import '../../domain/models/ingestion_lead.dart';
import '../../domain/models/network_entity.dart';
import '../../domain/models/workspace_activity.dart';
import '../../domain/models/workspace_module.dart';
import '../../domain/models/workspace_snapshot.dart';

abstract class WorkspaceService {
  Future<List<NetworkEntity>> loadNetworkDirectory();

  Future<List<IngestionLead>> loadIngestionQueue();

  Future<List<WorkspaceActivity>> loadActivities();

  WorkspaceSnapshot buildSnapshot(BusinessRole role);
}

class AssetWorkspaceService implements WorkspaceService {
  const AssetWorkspaceService({
    this.networkAssetPath = 'assets/data/network_directory.json',
    this.ingestionAssetPath = 'assets/data/ingestion_queue.json',
    this.activitiesAssetPath = 'assets/data/workspace_activities.json',
  });

  final String networkAssetPath;
  final String ingestionAssetPath;
  final String activitiesAssetPath;

  @override
  Future<List<NetworkEntity>> loadNetworkDirectory() async {
    final jsonString = await rootBundle.loadString(networkAssetPath);
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => NetworkEntity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<IngestionLead>> loadIngestionQueue() async {
    final jsonString = await rootBundle.loadString(ingestionAssetPath);
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => IngestionLead.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkspaceActivity>> loadActivities() async {
    final jsonString = await rootBundle.loadString(activitiesAssetPath);
    final decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map((item) => WorkspaceActivity.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  WorkspaceSnapshot buildSnapshot(BusinessRole role) {
    return switch (role) {
      BusinessRole.admin => const WorkspaceSnapshot(
        headline: 'Control commercial, medical, and compliance operations',
        summary:
            'Watch field coverage, trade health, institutional progress, and data quality from one executive view.',
        metrics: [
          WorkspaceMetric(
            label: 'Active users',
            value: '48',
            detail: 'Across MR, finance, doctor, and trade roles',
          ),
          WorkspaceMetric(
            label: 'Pending approvals',
            value: '11',
            detail: 'Imports, expenses, schemes, and audit exceptions',
          ),
          WorkspaceMetric(
            label: 'Collection risk',
            value: 'Rs 12.4L',
            detail: 'Aged outstanding exposure across trade partners',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Review sourced lead imports',
            subtitle: '4 directory records need compliance and dedupe approval',
            status: 'Today',
          ),
          WorkspaceTask(
            title: 'Approve institution pricing update',
            subtitle: 'Aarogya City Hospital formulary revision is ready',
            status: 'Priority',
          ),
          WorkspaceTask(
            title: 'Close MR route gaps',
            subtitle: 'West team missed 3 planned doctor calls yesterday',
            status: 'Action',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.network,
          WorkspaceModule.fieldForce,
          WorkspaceModule.finance,
          WorkspaceModule.catalog,
          WorkspaceModule.imports,
          WorkspaceModule.reports,
        ],
      ),
      BusinessRole.medicalRepresentative => const WorkspaceSnapshot(
        headline: 'Execute your doctor route and retail follow-up',
        summary:
            'Track planned calls, capture DCR notes, sample movement, retailer orders, and next follow-ups.',
        metrics: [
          WorkspaceMetric(
            label: 'Planned calls',
            value: '9',
            detail: '6 doctors, 1 hospital, 2 retailers on today’s route',
          ),
          WorkspaceMetric(
            label: 'Samples issued',
            value: '38',
            detail: 'MYOBOOST, UTIVA-BV PLUS, ZEO PLUS',
          ),
          WorkspaceMetric(
            label: 'Secondary orders',
            value: 'Rs 84K',
            detail: 'Captured from retailers and stockist follow-ups',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Complete Dr. Meera Adhikari follow-up',
            subtitle: 'Discuss MYOBOOST compliance feedback and reorder intent',
            status: '11:30 AM',
          ),
          WorkspaceTask(
            title: 'Upload DCR with geo check-ins',
            subtitle: 'Morning round is waiting for submission',
            status: 'Pending',
          ),
          WorkspaceTask(
            title: 'Collect Janaki Medicos order',
            subtitle: 'Retailer requested UTIVA-BV PLUS reorder confirmation',
            status: 'Before 6 PM',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.network,
          WorkspaceModule.fieldForce,
          WorkspaceModule.catalog,
          WorkspaceModule.reports,
        ],
      ),
      BusinessRole.accountant => const WorkspaceSnapshot(
        headline: 'Keep collections, vouchers, and books clean',
        summary:
            'Monitor receivables, stockist settlements, expenses, and bank-ready accounting work.',
        metrics: [
          WorkspaceMetric(
            label: 'Receivables due',
            value: 'Rs 7.8L',
            detail: 'Across 14 stockist and retail accounts',
          ),
          WorkspaceMetric(
            label: 'Vouchers pending',
            value: '19',
            detail: 'MR expenses, freight, and scheme adjustments',
          ),
          WorkspaceMetric(
            label: 'Collections today',
            value: 'Rs 2.1L',
            detail: 'Cleared against 7 open invoices',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Post Omkar Distributors collection',
            subtitle: 'Bank reference received, waiting voucher confirmation',
            status: 'Today',
          ),
          WorkspaceTask(
            title: 'Reconcile MR expense claims',
            subtitle: 'East team claim batch is awaiting ledger mapping',
            status: 'Queue',
          ),
          WorkspaceTask(
            title: 'Review credit notes',
            subtitle: '3 retailer returns impacted month-end revenue',
            status: 'Month-end',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.finance,
          WorkspaceModule.network,
          WorkspaceModule.imports,
          WorkspaceModule.reports,
        ],
      ),
      BusinessRole.auditor => const WorkspaceSnapshot(
        headline: 'Audit trail, policy control, and exception review',
        summary:
            'Inspect transaction integrity, promotional controls, imported data quality, and field compliance.',
        metrics: [
          WorkspaceMetric(
            label: 'Open exceptions',
            value: '6',
            detail: 'Pricing overrides, claims, and master-data mismatches',
          ),
          WorkspaceMetric(
            label: 'Trail coverage',
            value: '99.2%',
            detail: 'Digitally attributable user actions this cycle',
          ),
          WorkspaceMetric(
            label: 'Risk flags',
            value: '3',
            detail: 'Duplicates and unsupported external source records',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Audit external lead pipeline',
            subtitle:
                'Validate source URLs and review approvals before publish',
            status: 'Critical',
          ),
          WorkspaceTask(
            title: 'Check scheme override logs',
            subtitle: 'Two retailer schemes exceeded threshold approval',
            status: 'Review',
          ),
          WorkspaceTask(
            title: 'Verify collection edits',
            subtitle: 'Manual bank adjustments need supporting evidence',
            status: 'Today',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.finance,
          WorkspaceModule.imports,
          WorkspaceModule.reports,
          WorkspaceModule.network,
        ],
      ),
      BusinessRole.doctor => const WorkspaceSnapshot(
        headline: 'Review visits, samples, and product support',
        summary:
            'See engagement history, sample support, product references, and institutional coordination.',
        metrics: [
          WorkspaceMetric(
            label: 'Recent visits',
            value: '4',
            detail: 'Last 30 days from assigned medical team',
          ),
          WorkspaceMetric(
            label: 'Samples received',
            value: '12',
            detail: 'Across MYOBOOST, ZEO PLUS, and UTIVA-BV PLUS',
          ),
          WorkspaceMetric(
            label: 'Open requests',
            value: '2',
            detail: 'Patient leaflets and hospital formulary note follow-up',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Review MYOBOOST detail aid',
            subtitle: 'Latest fertility-support positioning from MR team',
            status: 'New',
          ),
          WorkspaceTask(
            title: 'Confirm sample replenishment',
            subtitle: 'UTIVA-BV PLUS request is awaiting approval',
            status: 'Pending',
          ),
          WorkspaceTask(
            title: 'Institutional follow-up',
            subtitle: 'Aarogya City Hospital formulary note attached',
            status: 'This week',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.catalog,
          WorkspaceModule.network,
          WorkspaceModule.reports,
        ],
      ),
      BusinessRole.stockist => const WorkspaceSnapshot(
        headline: 'Manage inventory, primary orders, and trade fulfillment',
        summary:
            'Track stock cover, order dispatch, claims, and payment follow-up with the company team.',
        metrics: [
          WorkspaceMetric(
            label: 'Open primary orders',
            value: '5',
            detail: 'Awaiting dispatch or invoicing',
          ),
          WorkspaceMetric(
            label: 'Low stock SKUs',
            value: '3',
            detail: 'MYOBOOST, OFFER-XT, ZEOCAL-500',
          ),
          WorkspaceMetric(
            label: 'Outstanding',
            value: 'Rs 3.4L',
            detail: 'Due across active company invoices',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Confirm MYOBOOST replenishment',
            subtitle: 'Current stock cover below 10 days',
            status: 'Urgent',
          ),
          WorkspaceTask(
            title: 'Upload secondary sale batch',
            subtitle: 'Retail movement for Central Trade is pending',
            status: 'Today',
          ),
          WorkspaceTask(
            title: 'Review expiry claim',
            subtitle: 'Two packs flagged for commercial settlement',
            status: 'Review',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.finance,
          WorkspaceModule.catalog,
          WorkspaceModule.network,
          WorkspaceModule.reports,
        ],
      ),
      BusinessRole.retailer => const WorkspaceSnapshot(
        headline: 'Track supply, schemes, and outlet-level orders',
        summary:
            'See stocked products, pending supply, company schemes, and account health from the retail view.',
        metrics: [
          WorkspaceMetric(
            label: 'Pending orders',
            value: '2',
            detail: 'Awaiting stockist dispatch confirmation',
          ),
          WorkspaceMetric(
            label: 'Live schemes',
            value: '4',
            detail: 'Retail incentives active this cycle',
          ),
          WorkspaceMetric(
            label: 'Outstanding',
            value: 'Rs 58K',
            detail: 'Open payable across recent invoices',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Confirm UTIVA-BV PLUS replenishment',
            subtitle: 'Outlet demand increased this week',
            status: 'Today',
          ),
          WorkspaceTask(
            title: 'Review scheme claim pack',
            subtitle: 'Upload invoice support before claim cut-off',
            status: 'This week',
          ),
          WorkspaceTask(
            title: 'Check near-expiry stock',
            subtitle: 'One product batch requires return decision',
            status: 'Action',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.catalog,
          WorkspaceModule.finance,
          WorkspaceModule.network,
        ],
      ),
      BusinessRole.hospital => const WorkspaceSnapshot(
        headline: 'Coordinate institutional demand and clinical engagement',
        summary:
            'Monitor procurement, doctor engagement, product references, and institutional supply status.',
        metrics: [
          WorkspaceMetric(
            label: 'Active departments',
            value: '6',
            detail: 'Mapped to current hospital engagement plans',
          ),
          WorkspaceMetric(
            label: 'Open procurement lines',
            value: '7',
            detail: 'Across women care, bone health, and supplements',
          ),
          WorkspaceMetric(
            label: 'Doctor touchpoints',
            value: '14',
            detail: 'Recent calls across associated consultants',
          ),
        ],
        tasks: [
          WorkspaceTask(
            title: 'Approve formulary review packet',
            subtitle: 'Clinical notes ready for committee circulation',
            status: 'Pending',
          ),
          WorkspaceTask(
            title: 'Align institutional order batch',
            subtitle: 'Central stores waiting on final quantities',
            status: 'Today',
          ),
          WorkspaceTask(
            title: 'Review consultant meeting summary',
            subtitle: 'MR notes attached for the latest visit round',
            status: 'New',
          ),
        ],
        enabledModules: [
          WorkspaceModule.overview,
          WorkspaceModule.network,
          WorkspaceModule.catalog,
          WorkspaceModule.finance,
          WorkspaceModule.reports,
        ],
      ),
    };
  }
}
