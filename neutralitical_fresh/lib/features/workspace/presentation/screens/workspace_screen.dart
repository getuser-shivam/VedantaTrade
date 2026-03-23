import 'package:flutter/material.dart';

import '../../../../app/neutralitical_brand.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../../auth/domain/models/business_role.dart';
import '../../../catalog/data/services/product_catalog_service.dart';
import '../../../catalog/data/services/product_media_library_service.dart';
import '../../../catalog/domain/models/product.dart';
import '../../../catalog/presentation/screens/product_catalog_screen.dart';
import '../../data/services/workspace_activity_draft_service.dart';
import '../../data/services/workspace_activity_journal_service.dart';
import '../../data/services/workspace_lead_review_service.dart';
import '../../data/services/workspace_service.dart';
import '../../domain/models/ingestion_lead.dart';
import '../../domain/models/lead_review_decision.dart';
import '../../domain/models/network_entity.dart';
import '../../domain/models/workspace_activity.dart';
import '../../domain/models/workspace_activity_update.dart';
import '../../domain/models/workspace_module.dart';
import '../../domain/models/workspace_snapshot.dart';

class WorkspaceScreen extends StatefulWidget {
  const WorkspaceScreen({
    super.key,
    required this.currentUser,
    required this.workspaceService,
    required this.activityJournalService,
    required this.activityDraftService,
    required this.leadReviewService,
    required this.productCatalogService,
    required this.productMediaLibraryService,
    required this.onSignOut,
  });

  final AuthUser currentUser;
  final WorkspaceService workspaceService;
  final WorkspaceActivityJournalService activityJournalService;
  final WorkspaceActivityDraftService activityDraftService;
  final WorkspaceLeadReviewService leadReviewService;
  final ProductCatalogService productCatalogService;
  final ProductMediaLibraryService productMediaLibraryService;
  final Future<void> Function() onSignOut;

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  WorkspaceSnapshot? _snapshot;
  List<NetworkEntity> _networkDirectory = const <NetworkEntity>[];
  List<IngestionLead> _ingestionQueue = const <IngestionLead>[];
  List<WorkspaceActivity> _activities = const <WorkspaceActivity>[];
  List<WorkspaceActivity> _draftActivities = const <WorkspaceActivity>[];
  List<WorkspaceActivityUpdate> _activityUpdates =
      const <WorkspaceActivityUpdate>[];
  List<NetworkEntity> _promotedEntities = const <NetworkEntity>[];
  List<LeadReviewDecision> _leadReviewDecisions = const <LeadReviewDecision>[];
  List<Product> _catalogProducts = const <Product>[];
  int _selectedModuleIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkspace();
  }

  List<WorkspaceModule> get _modules {
    return _snapshot?.enabledModules ??
        const <WorkspaceModule>[WorkspaceModule.overview];
  }

  WorkspaceModule get _selectedModule {
    final modules = _modules;
    final maxIndex = modules.length - 1;
    final safeIndex = _selectedModuleIndex > maxIndex
        ? maxIndex
        : _selectedModuleIndex;
    return modules[safeIndex];
  }

  List<NetworkEntity> get _visibleNetwork {
    return [
      ..._promotedEntities,
      ..._networkDirectory,
    ].where((entity) => _isVisibleForRole(entity.type)).toList(growable: false);
  }

  List<IngestionLead> get _visibleLeads {
    final reviewedLeadIds = _leadReviewDecisions
        .map((decision) => decision.leadId)
        .toSet();
    return _ingestionQueue
        .where(
          (lead) =>
              _isVisibleForRole(lead.type) &&
              !reviewedLeadIds.contains(lead.id),
        )
        .toList(growable: false);
  }

  List<LeadReviewDecision> get _recentLeadReviews {
    return _leadReviewDecisions
        .where((decision) => _isVisibleForRole(decision.leadType))
        .toList(growable: false);
  }

  List<WorkspaceActivity> get _visibleActivities {
    return [..._draftActivities, ..._activities]
        .where(
          (activity) =>
              activity.roles.isEmpty ||
              activity.roles.contains(widget.currentUser.role),
        )
        .toList(growable: false);
  }

  List<_ResolvedActivity> get _resolvedActivities {
    final updatesByActivity = <String, List<WorkspaceActivityUpdate>>{};
    for (final update in _activityUpdates) {
      updatesByActivity.putIfAbsent(update.activityId, () => []).add(update);
    }

    return _visibleActivities
        .map(
          (activity) => _ResolvedActivity(
            activity: activity,
            updates: updatesByActivity[activity.id] ?? const [],
          ),
        )
        .toList(growable: false);
  }

  List<WorkspaceModule> get _creatableModules {
    final filtered = _modules
        .where(
          (module) =>
              module != WorkspaceModule.overview &&
              module != WorkspaceModule.catalog,
        )
        .toList(growable: false);
    return filtered.isEmpty ? _modules : filtered;
  }

  bool _isVisibleForRole(NetworkEntityType type) {
    return switch (widget.currentUser.role) {
      BusinessRole.doctor =>
        type == NetworkEntityType.doctor || type == NetworkEntityType.hospital,
      BusinessRole.hospital =>
        type == NetworkEntityType.hospital || type == NetworkEntityType.doctor,
      BusinessRole.stockist =>
        type == NetworkEntityType.stockist ||
            type == NetworkEntityType.retailer,
      BusinessRole.retailer =>
        type == NetworkEntityType.retailer ||
            type == NetworkEntityType.stockist,
      _ => true,
    };
  }

  void _showMessage(String message) {
    if (!mounted || message.trim().isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadWorkspace() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final directory = await widget.workspaceService.loadNetworkDirectory();
      final queue = await widget.workspaceService.loadIngestionQueue();
      final activities = await widget.workspaceService.loadActivities();
      final draftActivities = await widget.activityDraftService
          .loadDraftActivities();
      final activityUpdates = await widget.activityJournalService.loadUpdates();
      final promotedEntities = await widget.leadReviewService
          .loadPromotedEntities();
      final leadReviewDecisions = await widget.leadReviewService
          .loadDecisions();
      final catalogProducts = await widget.productCatalogService
          .loadRegisteredProducts();
      final snapshot = widget.workspaceService.buildSnapshot(
        widget.currentUser.role,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        _networkDirectory = directory;
        _ingestionQueue = queue;
        _activities = activities;
        _draftActivities = draftActivities;
        _activityUpdates = activityUpdates;
        _promotedEntities = promotedEntities;
        _leadReviewDecisions = leadReviewDecisions;
        _catalogProducts = catalogProducts;
        _isLoading = false;
        if (_selectedModuleIndex >= snapshot.enabledModules.length) {
          _selectedModuleIndex = 0;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'The workspace could not load right now. Pull to retry.';
      });
    }
  }

  Future<void> _reviewLead(IngestionLead lead, LeadReviewAction action) async {
    await widget.leadReviewService.reviewLead(
      lead: lead,
      action: action,
      reviewedBy: widget.currentUser.fullName,
    );

    final promotedEntities = await widget.leadReviewService
        .loadPromotedEntities();
    final leadReviewDecisions = await widget.leadReviewService.loadDecisions();
    if (!mounted) {
      return;
    }

    setState(() {
      _promotedEntities = promotedEntities;
      _leadReviewDecisions = leadReviewDecisions;
    });

    _showMessage(
      action == LeadReviewAction.approved
          ? '${lead.name} was approved into the network directory.'
          : '${lead.name} was rejected from the import queue.',
    );
  }

  void _selectModule(WorkspaceModule module) {
    final index = _modules.indexOf(module);
    if (index == -1 || index == _selectedModuleIndex) {
      return;
    }

    setState(() {
      _selectedModuleIndex = index;
    });
  }

  Future<void> _openCatalog() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProductCatalogScreen(
          productCatalogService: widget.productCatalogService,
          productMediaLibraryService: widget.productMediaLibraryService,
          currentUserName: widget.currentUser.firstName,
          currentUserEmail: widget.currentUser.email,
          onSignOut: () async {
            Navigator.of(context).pop();
            await widget.onSignOut();
          },
        ),
      ),
    );
  }

  Future<void> _openActivityDetail(_ResolvedActivity record) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ActivityDetailSheet(
          record: record,
          currentUserName: widget.currentUser.fullName,
          onSaveUpdate: (status, note) async {
            final updates = await widget.activityJournalService.addUpdate(
              activityId: record.activity.id,
              status: status,
              note: note,
              updatedBy: widget.currentUser.fullName,
            );
            if (!mounted) {
              return;
            }

            setState(() {
              _activityUpdates = updates;
            });
            _showMessage('Activity updated for ${record.activity.title}.');
          },
        );
      },
    );
  }

  List<_ResolvedActivity> _relatedActivitiesForEntity(NetworkEntity entity) {
    final name = entity.name.toLowerCase();
    final territory = entity.territory.toLowerCase();
    return _resolvedActivities
        .where((record) {
          final activity = record.activity;
          final haystack = [
            activity.title,
            activity.subtitle,
            activity.territory,
            activity.owner,
            ...activity.tags,
          ].join(' ').toLowerCase();
          return haystack.contains(name) ||
              activity.territory.toLowerCase() == territory;
        })
        .take(4)
        .toList(growable: false);
  }

  Future<void> _openEntityDetail(NetworkEntity entity) async {
    final action = await showModalBottomSheet<_EntityQuickAction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _EntityDetailSheet(
          entity: entity,
          quickActions: _quickActionsForEntity(entity, _modules),
          relatedActivities: _relatedActivitiesForEntity(entity),
        );
      },
    );

    if (action == null || !mounted) {
      return;
    }

    switch (action.workflowKind) {
      case _EntityWorkflowKind.visit:
        await _openVisitWorkflow(entity, action);
        return;
      case _EntityWorkflowKind.commercial:
        await _openCommercialWorkflow(entity, action);
        return;
      case _EntityWorkflowKind.generic:
        await _openCreateActivity(
          heading: action.label,
          description: action.helper,
          initialModule: action.module,
          initialType: action.type,
          initialStatus: action.defaultStatus,
          initialTitle: action.buildTitle(entity),
          initialSummary: action.buildSummary(entity),
          initialTerritory: entity.territory,
          initialAmount: action.suggestsAmount ? 'Rs ' : null,
          initialTags: '${entity.name}, ${entity.type.label}, ${entity.city}',
        );
        return;
    }
  }

  Future<void> _saveDraftActivity(WorkspaceActivity activity) async {
    final draftActivities = await widget.activityDraftService.addDraftActivity(
      activity,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _draftActivities = draftActivities;
    });
    _showMessage('Logged a new ${activity.type.label.toLowerCase()} activity.');
  }

  Future<void> _openVisitWorkflow(
    NetworkEntity entity,
    _EntityQuickAction action,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _VisitWorkflowSheet(
          entity: entity,
          action: action,
          currentUser: widget.currentUser,
          availableProducts: _catalogProducts,
          onCreate: _saveDraftActivity,
        );
      },
    );
  }

  Future<void> _openCommercialWorkflow(
    NetworkEntity entity,
    _EntityQuickAction action,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CommercialWorkflowSheet(
          entity: entity,
          action: action,
          currentUser: widget.currentUser,
          availableProducts: _catalogProducts,
          onCreate: _saveDraftActivity,
        );
      },
    );
  }

  Future<void> _openCreateActivity({
    String? heading,
    String? description,
    WorkspaceModule? initialModule,
    WorkspaceActivityType? initialType,
    String? initialStatus,
    String? initialTitle,
    String? initialSummary,
    String? initialTerritory,
    String? initialAmount,
    String? initialTags,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _CreateActivitySheet(
          currentUser: widget.currentUser,
          defaultModule: _creatableModules.contains(_selectedModule)
              ? _selectedModule
              : _creatableModules.first,
          availableModules: _creatableModules,
          heading: heading,
          description: description,
          initialModule: initialModule,
          initialType: initialType,
          initialStatus: initialStatus,
          initialTitle: initialTitle,
          initialSummary: initialSummary,
          initialTerritory: initialTerritory,
          initialAmount: initialAmount,
          initialTags: initialTags,
          onCreate: _saveDraftActivity,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _WorkspaceLoadingView();
    }

    if (_errorMessage != null || _snapshot == null) {
      return _WorkspaceStatusView(
        icon: Icons.cloud_off_outlined,
        title: 'Workspace unavailable',
        message: _errorMessage ?? 'The workspace could not be prepared.',
        actionLabel: 'Retry',
        onActionPressed: _loadWorkspace,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1080;
        return Scaffold(
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: NeutraliticalBrand.shellGradient,
            ),
            child: SafeArea(
              child: isWide ? _buildWideLayout() : _buildNarrowLayout(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 292,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 0, 20),
            child: _WorkspaceRail(
              role: widget.currentUser.role,
              modules: _modules,
              selectedModule: _selectedModule,
              onSelected: _selectModule,
              onRefresh: _loadWorkspace,
              onOpenCatalog: _modules.contains(WorkspaceModule.catalog)
                  ? _openCatalog
                  : null,
            ),
          ),
        ),
        Expanded(child: _buildScrollableContent(showModuleStrip: false)),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return _buildScrollableContent(showModuleStrip: true);
  }

  Widget _buildScrollableContent({required bool showModuleStrip}) {
    return RefreshIndicator(
      onRefresh: _loadWorkspace,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          _WorkspaceHero(
            currentUser: widget.currentUser,
            snapshot: _snapshot!,
            directoryCount: _visibleNetwork.length,
            queueCount: _visibleLeads.length,
            activityCount: _visibleActivities.length,
            onSignOut: widget.onSignOut,
            onLogActivity: _openCreateActivity,
            onOpenCatalog: _modules.contains(WorkspaceModule.catalog)
                ? _openCatalog
                : null,
            onReviewImports: _modules.contains(WorkspaceModule.imports)
                ? () => _selectModule(WorkspaceModule.imports)
                : null,
          ),
          if (showModuleStrip) ...[
            const SizedBox(height: 18),
            _ModuleStrip(
              modules: _modules,
              selectedModule: _selectedModule,
              onSelected: _selectModule,
            ),
          ],
          const SizedBox(height: 22),
          _ModuleView(
            role: widget.currentUser.role,
            snapshot: _snapshot!,
            selectedModule: _selectedModule,
            visibleNetwork: _visibleNetwork,
            visibleLeads: _visibleLeads,
            recentLeadReviews: _recentLeadReviews,
            resolvedActivities: _resolvedActivities,
            onOpenActivity: _openActivityDetail,
            onOpenEntity: _openEntityDetail,
            onReviewLead: _reviewLead,
            onOpenCatalog: _modules.contains(WorkspaceModule.catalog)
                ? _openCatalog
                : null,
            onReviewImports: _modules.contains(WorkspaceModule.imports)
                ? () => _selectModule(WorkspaceModule.imports)
                : null,
          ),
        ],
      ),
    );
  }
}

class _WorkspaceLoadingView extends StatelessWidget {
  const _WorkspaceLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: NeutraliticalBrand.shellGradient,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  NeutraliticalBrand.markAsset,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Preparing the control tower...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: NeutraliticalBrand.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceStatusView extends StatelessWidget {
  const _WorkspaceStatusView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: NeutraliticalBrand.shellGradient,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: NeutraliticalBrand.sand),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 52, color: NeutraliticalBrand.forest),
                    const SizedBox(height: 18),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: NeutraliticalBrand.ink,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF63615B),
                        height: 1.45,
                      ),
                    ),
                    if (actionLabel != null && onActionPressed != null) ...[
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: onActionPressed,
                        child: Text(actionLabel!),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkspaceHero extends StatelessWidget {
  const _WorkspaceHero({
    required this.currentUser,
    required this.snapshot,
    required this.directoryCount,
    required this.queueCount,
    required this.activityCount,
    required this.onSignOut,
    required this.onLogActivity,
    this.onOpenCatalog,
    this.onReviewImports,
  });

  final AuthUser currentUser;
  final WorkspaceSnapshot snapshot;
  final int directoryCount;
  final int queueCount;
  final int activityCount;
  final Future<void> Function() onSignOut;
  final Future<void> Function() onLogActivity;
  final Future<void> Function()? onOpenCatalog;
  final VoidCallback? onReviewImports;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: NeutraliticalBrand.heroGradient,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  NeutraliticalBrand.markAsset,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${currentUser.role.label} workspace',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.headline,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.02,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: onSignOut,
                tooltip: 'Sign out',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            snapshot.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE8DDD0),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStat(label: 'Visible records', value: '$directoryCount'),
              _HeroStat(label: 'Lead queue', value: '$queueCount'),
              _HeroStat(label: 'Live flows', value: '$activityCount'),
              _HeroStat(
                label: 'Modules',
                value: '${snapshot.enabledModules.length}',
              ),
              _HeroStat(label: 'Role', value: currentUser.role.shortLabel),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (onOpenCatalog != null)
                FilledButton.icon(
                  onPressed: onOpenCatalog,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Open Product Catalog'),
                ),
              FilledButton.tonalIcon(
                onPressed: onLogActivity,
                icon: const Icon(Icons.add_task_outlined),
                label: const Text('Log Activity'),
              ),
              if (onReviewImports != null)
                FilledButton.tonalIcon(
                  onPressed: onReviewImports,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text('Review Import Queue'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkspaceRail extends StatelessWidget {
  const _WorkspaceRail({
    required this.role,
    required this.modules,
    required this.selectedModule,
    required this.onSelected,
    required this.onRefresh,
    this.onOpenCatalog,
  });

  final BusinessRole role;
  final List<WorkspaceModule> modules;
  final WorkspaceModule selectedModule;
  final ValueChanged<WorkspaceModule> onSelected;
  final Future<void> Function() onRefresh;
  final Future<void> Function()? onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: NeutraliticalBrand.sand),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role.label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: NeutraliticalBrand.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Control tower modules',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF66635E)),
            ),
            const SizedBox(height: 18),
            ...modules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ModuleButton(
                  module: module,
                  selected: module == selectedModule,
                  onTap: () => onSelected(module),
                ),
              ),
            ),
            const Spacer(),
            if (onOpenCatalog != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton.icon(
                  onPressed: onOpenCatalog,
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('Catalog'),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleStrip extends StatelessWidget {
  const _ModuleStrip({
    required this.modules,
    required this.selectedModule,
    required this.onSelected,
  });

  final List<WorkspaceModule> modules;
  final WorkspaceModule selectedModule;
  final ValueChanged<WorkspaceModule> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: modules.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final module = modules[index];
          final selected = module == selectedModule;
          return FilterChip(
            selected: selected,
            showCheckmark: false,
            label: Text(module.label),
            avatar: Icon(
              module.icon,
              size: 18,
              color: selected ? Colors.white : NeutraliticalBrand.forest,
            ),
            onSelected: (_) => onSelected(module),
            selectedColor: NeutraliticalBrand.forest,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: selected
                  ? NeutraliticalBrand.forest
                  : NeutraliticalBrand.sand,
            ),
            labelStyle: TextStyle(
              color: selected ? Colors.white : NeutraliticalBrand.ink,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }
}

class _ModuleView extends StatelessWidget {
  const _ModuleView({
    required this.role,
    required this.snapshot,
    required this.selectedModule,
    required this.visibleNetwork,
    required this.visibleLeads,
    required this.recentLeadReviews,
    required this.resolvedActivities,
    required this.onOpenActivity,
    required this.onOpenEntity,
    this.onReviewLead,
    this.onOpenCatalog,
    this.onReviewImports,
  });

  final BusinessRole role;
  final WorkspaceSnapshot snapshot;
  final WorkspaceModule selectedModule;
  final List<NetworkEntity> visibleNetwork;
  final List<IngestionLead> visibleLeads;
  final List<LeadReviewDecision> recentLeadReviews;
  final List<_ResolvedActivity> resolvedActivities;
  final ValueChanged<_ResolvedActivity> onOpenActivity;
  final ValueChanged<NetworkEntity> onOpenEntity;
  final Future<void> Function(IngestionLead lead, LeadReviewAction action)?
  onReviewLead;
  final Future<void> Function()? onOpenCatalog;
  final VoidCallback? onReviewImports;

  @override
  Widget build(BuildContext context) {
    final moduleActivities = resolvedActivities
        .where((record) => record.activity.module == selectedModule)
        .toList(growable: false);

    return switch (selectedModule) {
      WorkspaceModule.overview => _ModuleSection(
        title: 'Today at a glance',
        subtitle:
            'A shared role-based summary of priorities, performance, and safe data intake.',
        children: [
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: snapshot.metrics
                .map((metric) => _MetricCard(metric: metric))
                .toList(),
          ),
          const SizedBox(height: 22),
          ...snapshot.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TaskCard(task: task),
            ),
          ),
          if (resolvedActivities.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...resolvedActivities
                .take(4)
                .map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityCard(
                      record: record,
                      onTap: () => onOpenActivity(record),
                    ),
                  ),
                ),
          ],
          if (onOpenCatalog != null) ...[
            const SizedBox(height: 12),
            _InfoCard(
              title: 'Product catalog is ready',
              body:
                  'Open the full registered product catalog to browse, inspect media, and upload official product images or videos.',
              actionLabel: 'Open Product Catalog',
              onActionPressed: onOpenCatalog,
            ),
          ],
        ],
      ),
      WorkspaceModule.network => _ModuleSection(
        title: '${role.label} network',
        subtitle:
            'Verified records stay separate from sourced leads so your team can work from trusted master data.',
        children: [
          if (moduleActivities.isNotEmpty) ...[
            ...moduleActivities.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(
                  record: record,
                  onTap: () => onOpenActivity(record),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (visibleNetwork.isEmpty)
            const _EmptyCard(
              title: 'No network records are visible yet.',
              body:
                  'Once master data is mapped to this role, it will appear here.',
            )
          else
            ...visibleNetwork
                .take(8)
                .map(
                  (entity) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EntityCard(
                      entity: entity,
                      onTap: () => onOpenEntity(entity),
                    ),
                  ),
                ),
          if (visibleLeads.isNotEmpty)
            _InfoCard(
              title: 'Sourced records are still in review',
              body:
                  '${visibleLeads.length} leads are waiting in the controlled import queue rather than being auto-published into master data.',
              actionLabel: onReviewImports == null ? null : 'Review Queue',
              onActionPressed: onReviewImports == null
                  ? null
                  : () async => onReviewImports!(),
            ),
          if (recentLeadReviews.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...recentLeadReviews
                .take(2)
                .map(
                  (decision) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LeadReviewCard(decision: decision),
                  ),
                ),
          ],
        ],
      ),
      WorkspaceModule.fieldForce => _ModuleSection(
        title: 'Field-force execution',
        subtitle:
            'This module covers route planning, doctor calls, DCR follow-up, and downstream trade movement.',
        children: [
          if (moduleActivities.isNotEmpty) ...[
            ...moduleActivities.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(
                  record: record,
                  onTap: () => onOpenActivity(record),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: snapshot.tasks
                .map(
                  (task) => _SummaryCard(
                    title: task.title,
                    value: task.status,
                    detail: task.subtitle,
                    icon: Icons.route_outlined,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          if (visibleNetwork.isEmpty)
            const _EmptyCard(
              title: 'No route records are visible yet.',
              body:
                  'Doctor, hospital, and outlet records will appear here as the network is mapped.',
            )
          else
            ...visibleNetwork
                .take(4)
                .map(
                  (entity) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _VisitCard(
                      entity: entity,
                      onTap: () => onOpenEntity(entity),
                    ),
                  ),
                ),
        ],
      ),
      WorkspaceModule.finance => _ModuleSection(
        title: 'Commercial and finance operations',
        subtitle:
            'Collections, vouchers, claims, and outstanding exposure stay visible from the same workspace.',
        children: [
          if (moduleActivities.isNotEmpty) ...[
            ...moduleActivities.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(
                  record: record,
                  onTap: () => onOpenActivity(record),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: snapshot.metrics
                .map(
                  (metric) => _SummaryCard(
                    title: metric.label,
                    value: metric.value,
                    detail: metric.detail,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 22),
          ...snapshot.tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TaskCard(task: task),
            ),
          ),
        ],
      ),
      WorkspaceModule.catalog => _ModuleSection(
        title: 'Product workspace',
        subtitle:
            'Registered products, curated references, generated fallbacks, and direct uploads are already connected.',
        children: [
          _InfoCard(
            title: 'Catalog module',
            body:
                'Use the full product catalog to inspect product data, curated media, and upload official production images or videos.',
            actionLabel: onOpenCatalog == null ? null : 'Open Product Catalog',
            onActionPressed: onOpenCatalog,
          ),
        ],
      ),
      WorkspaceModule.imports => _ModuleSection(
        title: 'Safe data intake',
        subtitle:
            'Imported or externally sourced doctors, stockists, retailers, and hospitals should always stay in a review queue first.',
        children: [
          if (moduleActivities.isNotEmpty) ...[
            ...moduleActivities.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(
                  record: record,
                  onTap: () => onOpenActivity(record),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          const _InfoCard(
            title: 'No blind auto-scraping',
            body:
                'This app keeps source attribution and approval in the loop. External records should be reviewed, deduplicated, and validated before they become master data.',
          ),
          const SizedBox(height: 16),
          if (visibleLeads.isEmpty)
            const _EmptyCard(
              title: 'No sourced leads are waiting in the queue.',
              body:
                  'Import batches will appear here once they are staged for review.',
            )
          else
            ...visibleLeads.map(
              (lead) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LeadCard(
                  lead: lead,
                  onApprove: onReviewLead == null
                      ? null
                      : () => onReviewLead!(lead, LeadReviewAction.approved),
                  onReject: onReviewLead == null
                      ? null
                      : () => onReviewLead!(lead, LeadReviewAction.rejected),
                ),
              ),
            ),
          if (recentLeadReviews.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Recent review decisions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: NeutraliticalBrand.ink,
              ),
            ),
            const SizedBox(height: 12),
            ...recentLeadReviews
                .take(4)
                .map(
                  (decision) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _LeadReviewCard(decision: decision),
                  ),
                ),
          ],
        ],
      ),
      WorkspaceModule.reports => _ModuleSection(
        title: 'Role-based reporting',
        subtitle:
            'This is the start of a reporting layer for productivity, risk, commercial health, and coverage.',
        children: [
          if (moduleActivities.isNotEmpty) ...[
            ...moduleActivities.map(
              (record) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActivityCard(
                  record: record,
                  onTap: () => onOpenActivity(record),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _SummaryCard(
                title: 'Network coverage',
                value: '${visibleNetwork.length}',
                detail:
                    'Visible ecosystem records for this role across verified master data.',
                icon: Icons.hub_outlined,
              ),
              _SummaryCard(
                title: 'Lead review queue',
                value: '${visibleLeads.length}',
                detail:
                    'Records still waiting for review before promotion into master data.',
                icon: Icons.cloud_download_outlined,
              ),
              ...snapshot.metrics.map(
                (metric) => _SummaryCard(
                  title: metric.label,
                  value: metric.value,
                  detail: metric.detail,
                  icon: Icons.bar_chart_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    };
  }
}

class _ModuleSection extends StatelessWidget {
  const _ModuleSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: NeutraliticalBrand.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF63615B),
            height: 1.48,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _ModuleButton extends StatelessWidget {
  const _ModuleButton({
    required this.module,
    required this.selected,
    required this.onTap,
  });

  final WorkspaceModule module;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? NeutraliticalBrand.forest : const Color(0xFFF8F4EB),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(
                module.icon,
                size: 20,
                color: selected ? Colors.white : NeutraliticalBrand.forest,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.label,
                  style: TextStyle(
                    color: selected ? Colors.white : NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final WorkspaceMetric metric;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: _PanelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              metric.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: NeutraliticalBrand.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              metric.value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: NeutraliticalBrand.forest,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              metric.detail,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF67645F),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
  });

  final String title;
  final String value;
  final String detail;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      child: _PanelCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: NeutraliticalBrand.forest),
            const SizedBox(height: 14),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: NeutraliticalBrand.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: NeutraliticalBrand.forest,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              detail,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF66625D),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final WorkspaceTask task;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.task_alt_rounded, color: NeutraliticalBrand.forest),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: NeutraliticalBrand.ink,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusPill(label: task.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  task.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF66625D),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.record, this.onTap});

  final _ResolvedActivity record;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final activity = record.activity;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: _PanelCard(
          backgroundColor: const Color(0xFFF7F2E9),
          borderColor: const Color(0xFFE6DBC8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(activity.type.icon, color: NeutraliticalBrand.forest),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: NeutraliticalBrand.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusPill(label: record.currentStatus),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                record.currentSummary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5E574F),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DetailPill(label: activity.type.label),
                  _DetailPill(label: activity.dateLabel),
                  _DetailPill(label: activity.owner),
                  _DetailPill(label: activity.territory),
                  if (activity.amount != null &&
                      activity.amount!.trim().isNotEmpty)
                    _DetailPill(label: activity.amount!),
                  if (record.updateCount > 0)
                    _DetailPill(label: '${record.updateCount} updates'),
                  ...activity.tags
                      .take(2)
                      .map((tag) => _DetailPill(label: tag)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityDetailSheet extends StatefulWidget {
  const _ActivityDetailSheet({
    required this.record,
    required this.currentUserName,
    required this.onSaveUpdate,
  });

  final _ResolvedActivity record;
  final String currentUserName;
  final Future<void> Function(String status, String note) onSaveUpdate;

  @override
  State<_ActivityDetailSheet> createState() => _ActivityDetailSheetState();
}

class _ActivityDetailSheetState extends State<_ActivityDetailSheet> {
  late final TextEditingController _noteController;
  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.record.currentStatus;
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
    });
    await widget.onSaveUpdate(_selectedStatus, _noteController.text);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.record.activity;
    final theme = Theme.of(context);
    final statuses = _statusOptionsFor(
      activity.type,
      widget.record.currentStatus,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.56,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1C7B6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: NeutraliticalBrand.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(label: widget.record.currentStatus),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                activity.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5E574F),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DetailPill(label: activity.type.label),
                  _DetailPill(label: activity.owner),
                  _DetailPill(label: activity.territory),
                  _DetailPill(label: activity.dateLabel),
                  if (activity.amount != null &&
                      activity.amount!.trim().isNotEmpty)
                    _DetailPill(label: activity.amount!),
                ],
              ),
              if (activity.details.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Captured details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...activity.details.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActivityDetailFactCard(
                      label: entry.key,
                      value: entry.value,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Update status',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: statuses
                    .map(
                      (status) => ChoiceChip(
                        label: Text(status),
                        selected: status == _selectedStatus,
                        onSelected: (_) {
                          setState(() {
                            _selectedStatus = status;
                          });
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Text(
                'Note',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Log outcome, doctor discussion, order note, collection evidence, or next action.',
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Saved by ${widget.currentUserName}. This is local device history until backend sync is added.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6A665F),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Recent updates',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.record.updates.isEmpty)
                const _EmptyCard(
                  title: 'No updates have been logged yet.',
                  body:
                      'The first saved update will appear here as a local activity timeline entry.',
                )
              else
                ...widget.record.updates.map(
                  (update) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ActivityUpdateCard(update: update),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Update'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityDetailFactCard extends StatelessWidget {
  const _ActivityDetailFactCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      backgroundColor: const Color(0xFFF7F2E9),
      borderColor: const Color(0xFFE6DBC8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF67615A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: NeutraliticalBrand.ink,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityUpdateCard extends StatelessWidget {
  const _ActivityUpdateCard({required this.update});

  final WorkspaceActivityUpdate update;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusPill(label: update.status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${update.updatedBy} • ${_formatUpdateTime(update.updatedAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF68635D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (update.note.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              update.note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF5E574F),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CreateActivitySheet extends StatefulWidget {
  const _CreateActivitySheet({
    required this.currentUser,
    required this.defaultModule,
    required this.availableModules,
    required this.onCreate,
    this.heading,
    this.description,
    this.initialModule,
    this.initialType,
    this.initialStatus,
    this.initialTitle,
    this.initialSummary,
    this.initialTerritory,
    this.initialAmount,
    this.initialTags,
  });

  final AuthUser currentUser;
  final WorkspaceModule defaultModule;
  final List<WorkspaceModule> availableModules;
  final Future<void> Function(WorkspaceActivity activity) onCreate;
  final String? heading;
  final String? description;
  final WorkspaceModule? initialModule;
  final WorkspaceActivityType? initialType;
  final String? initialStatus;
  final String? initialTitle;
  final String? initialSummary;
  final String? initialTerritory;
  final String? initialAmount;
  final String? initialTags;

  @override
  State<_CreateActivitySheet> createState() => _CreateActivitySheetState();
}

class _CreateActivitySheetState extends State<_CreateActivitySheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _territoryController;
  late final TextEditingController _amountController;
  late final TextEditingController _tagsController;

  late WorkspaceModule _selectedModule;
  late WorkspaceActivityType _selectedType;
  late String _selectedStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _summaryController = TextEditingController(
      text: widget.initialSummary ?? '',
    );
    _territoryController = TextEditingController(
      text: widget.initialTerritory ?? '',
    );
    _amountController = TextEditingController(text: widget.initialAmount ?? '');
    _tagsController = TextEditingController(text: widget.initialTags ?? '');
    _selectedModule =
        widget.initialModule != null &&
            widget.availableModules.contains(widget.initialModule)
        ? widget.initialModule!
        : widget.defaultModule;
    final availableTypes = _activityTypesForModule(_selectedModule);
    _selectedType =
        widget.initialType != null &&
            availableTypes.contains(widget.initialType)
        ? widget.initialType!
        : availableTypes.first;
    final statuses = _statusOptionsFor(
      _selectedType,
      widget.initialStatus ?? '',
    );
    _selectedStatus =
        widget.initialStatus != null && statuses.contains(widget.initialStatus)
        ? widget.initialStatus!
        : statuses.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _territoryController.dispose();
    _amountController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleModuleChanged(WorkspaceModule? module) {
    if (module == null) {
      return;
    }
    setState(() {
      _selectedModule = module;
      _selectedType = _activityTypesForModule(module).first;
      _selectedStatus = _statusOptionsFor(_selectedType, '').first;
    });
  }

  void _handleTypeChanged(WorkspaceActivityType? type) {
    if (type == null) {
      return;
    }
    setState(() {
      _selectedType = type;
      _selectedStatus = _statusOptionsFor(_selectedType, '').first;
    });
  }

  Future<void> _handleSave() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final activity = WorkspaceActivity(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      title: _titleController.text.trim(),
      subtitle: _summaryController.text.trim(),
      type: _selectedType,
      module: _selectedModule,
      roles: [widget.currentUser.role],
      status: _selectedStatus,
      dateLabel: 'Just now',
      owner: widget.currentUser.fullName,
      territory: _territoryController.text.trim().isEmpty
          ? widget.currentUser.role.label
          : _territoryController.text.trim(),
      tags: _buildTags(_tagsController.text, _selectedType, _selectedModule),
      amount: _amountController.text.trim().isEmpty
          ? null
          : _amountController.text.trim(),
    );

    await widget.onCreate(activity);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableTypes = _activityTypesForModule(_selectedModule);
    final statusOptions = _statusOptionsFor(_selectedType, _selectedStatus);

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.56,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1C7B6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.heading ?? 'Log activity',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: NeutraliticalBrand.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.description ??
                      'Create a local workflow item for this role. It will appear in the workspace immediately and persist on this device.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5E574F),
                    height: 1.48,
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<WorkspaceModule>(
                  initialValue: _selectedModule,
                  decoration: const InputDecoration(labelText: 'Module'),
                  items: widget.availableModules
                      .map(
                        (module) => DropdownMenuItem(
                          value: module,
                          child: Text(module.label),
                        ),
                      )
                      .toList(),
                  onChanged: _handleModuleChanged,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<WorkspaceActivityType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(labelText: 'Activity type'),
                  items: availableTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: _handleTypeChanged,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status == null) {
                      return;
                    }
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if ((value ?? '').trim().length < 3) {
                      return 'Enter a clear title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _summaryController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Summary'),
                  validator: (value) {
                    if ((value ?? '').trim().length < 6) {
                      return 'Add a short summary.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _territoryController,
                  decoration: const InputDecoration(labelText: 'Territory'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount (optional)',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Create Activity'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VisitWorkflowSheet extends StatefulWidget {
  const _VisitWorkflowSheet({
    required this.entity,
    required this.action,
    required this.currentUser,
    required this.availableProducts,
    required this.onCreate,
  });

  final NetworkEntity entity;
  final _EntityQuickAction action;
  final AuthUser currentUser;
  final List<Product> availableProducts;
  final Future<void> Function(WorkspaceActivity activity) onCreate;

  @override
  State<_VisitWorkflowSheet> createState() => _VisitWorkflowSheetState();
}

class _VisitWorkflowSheetState extends State<_VisitWorkflowSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _timingController;
  late final TextEditingController _scheduledFollowUpController;
  late final TextEditingController _objectiveController;
  late final TextEditingController _productFocusController;
  late final TextEditingController _nextStepController;
  late final TextEditingController _sampleQuantityController;
  final Set<String> _selectedProducts = <String>{};
  final List<_EvidenceDraft> _evidenceDrafts = <_EvidenceDraft>[];
  late String _selectedStatus;
  bool _isSaving = false;

  bool get _showSampleQuantity =>
      widget.action.type == WorkspaceActivityType.sample;

  @override
  void initState() {
    super.initState();
    _timingController = TextEditingController(
      text: _defaultWorkflowTimingLabel(),
    );
    _scheduledFollowUpController = TextEditingController();
    _objectiveController = TextEditingController(
      text: _defaultVisitObjective(widget.action, widget.entity),
    );
    _productFocusController = TextEditingController();
    _nextStepController = TextEditingController();
    _sampleQuantityController = TextEditingController();
    _selectedStatus = widget.action.defaultStatus;
    _evidenceDrafts.add(_EvidenceDraft());
  }

  @override
  void dispose() {
    _timingController.dispose();
    _scheduledFollowUpController.dispose();
    _objectiveController.dispose();
    _productFocusController.dispose();
    _nextStepController.dispose();
    _sampleQuantityController.dispose();
    for (final draft in _evidenceDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _addEvidenceDraft() {
    setState(() {
      _evidenceDrafts.add(_EvidenceDraft());
    });
  }

  void _removeEvidenceDraft(_EvidenceDraft draft) {
    if (_evidenceDrafts.length == 1) {
      draft.clear();
      setState(() {});
      return;
    }

    draft.dispose();
    setState(() {
      _evidenceDrafts.remove(draft);
    });
  }

  Future<void> _handleSave() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final productFocus = _productFocusController.text.trim();
    final nextStep = _nextStepController.text.trim();
    final sampleQuantity = _sampleQuantityController.text.trim();
    final timing = _timingController.text.trim();
    final scheduledFollowUp = _scheduledFollowUpController.text.trim();
    final selectedProductsLabel = _selectedProductsLabel(_selectedProducts);
    final evidenceSummary = _evidenceSummary(_evidenceDrafts);

    final summaryParts = <String>[
      _objectiveController.text.trim(),
      if (timing.isNotEmpty) 'Timing: $timing.',
      if (selectedProductsLabel.isNotEmpty)
        'Selected products: $selectedProductsLabel.',
      if (productFocus.isNotEmpty) 'Products discussed: $productFocus.',
      if (_showSampleQuantity && sampleQuantity.isNotEmpty)
        'Sample quantity: $sampleQuantity.',
      if (evidenceSummary.isNotEmpty) 'Evidence: $evidenceSummary.',
      if (scheduledFollowUp.isNotEmpty)
        'Next scheduled follow-up: $scheduledFollowUp.',
      if (nextStep.isNotEmpty) 'Next step: $nextStep.',
    ];

    final activity = WorkspaceActivity(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      title: widget.action.buildTitle(widget.entity),
      subtitle: summaryParts.join(' '),
      type: widget.action.type,
      module: widget.action.module,
      roles: [widget.currentUser.role],
      status: _selectedStatus,
      dateLabel: 'Just now',
      owner: widget.currentUser.fullName,
      territory: widget.entity.territory,
      tags: _buildTags(
        [
          widget.entity.name,
          widget.entity.type.label,
          widget.entity.city,
          if (selectedProductsLabel.isNotEmpty) selectedProductsLabel,
          if (productFocus.isNotEmpty) productFocus,
          if (_showSampleQuantity && sampleQuantity.isNotEmpty)
            'Sample $sampleQuantity',
        ].join(', '),
        widget.action.type,
        widget.action.module,
      ),
      details: _compactDetails(<String, String>{
        'Account': widget.entity.name,
        'Profile type': widget.entity.type.label,
        'Institution': widget.entity.institution,
        'Visit date / time': timing,
        'Selected products': selectedProductsLabel,
        _visitObjectiveLabel(widget.action): _objectiveController.text.trim(),
        _visitProductLabel(widget.action): productFocus,
        if (_showSampleQuantity) 'Sample quantity': sampleQuantity,
        'Evidence / attachments': evidenceSummary,
        'Next scheduled follow-up': scheduledFollowUp,
        'Next step': nextStep,
      }),
    );

    await widget.onCreate(activity);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusOptions = _statusOptionsFor(
      widget.action.type,
      widget.action.defaultStatus,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.58,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1C7B6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.action.label,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: NeutraliticalBrand.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.action.helper,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5E574F),
                    height: 1.48,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _DetailPill(label: widget.entity.name),
                    _DetailPill(label: widget.entity.type.label),
                    _DetailPill(label: widget.entity.territory),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _timingController,
                  decoration: const InputDecoration(
                    labelText: 'Visit date / time',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Add when this interaction happened.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _objectiveController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: _visitObjectiveLabel(widget.action),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length < 8) {
                      return 'Add a meaningful visit objective.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _productFocusController,
                  decoration: InputDecoration(
                    labelText: _visitProductLabel(widget.action),
                  ),
                ),
                if (widget.availableProducts.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _WorkflowProductSection(
                    title: 'Select products',
                    subtitle:
                        'Mark the products discussed or sampled during this interaction.',
                    products: widget.availableProducts,
                    selectedNames: _selectedProducts,
                    onToggle: (productName) {
                      setState(() {
                        if (_selectedProducts.contains(productName)) {
                          _selectedProducts.remove(productName);
                        } else {
                          _selectedProducts.add(productName);
                        }
                      });
                    },
                  ),
                ],
                if (_showSampleQuantity) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _sampleQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Sample quantity (optional)',
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _EvidenceSection(
                  drafts: _evidenceDrafts,
                  onAdd: _addEvidenceDraft,
                  onRemove: _removeEvidenceDraft,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _scheduledFollowUpController,
                  decoration: const InputDecoration(
                    labelText: 'Next scheduled follow-up (optional)',
                    helperText:
                        'Use a specific date or slot, for example 25/03/2026 11:30 AM.',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nextStepController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Next step / commitment',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_visitSaveLabel(widget.action)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommercialWorkflowSheet extends StatefulWidget {
  const _CommercialWorkflowSheet({
    required this.entity,
    required this.action,
    required this.currentUser,
    required this.availableProducts,
    required this.onCreate,
  });

  final NetworkEntity entity;
  final _EntityQuickAction action;
  final AuthUser currentUser;
  final List<Product> availableProducts;
  final Future<void> Function(WorkspaceActivity activity) onCreate;

  @override
  State<_CommercialWorkflowSheet> createState() =>
      _CommercialWorkflowSheetState();
}

class _CommercialWorkflowSheetState extends State<_CommercialWorkflowSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _timingController;
  late final TextEditingController _scheduledReviewController;
  late final TextEditingController _focusController;
  late final TextEditingController _amountController;
  late final TextEditingController _referenceController;
  late final TextEditingController _nextStepController;
  final Set<String> _selectedProducts = <String>{};
  final List<_CommercialLineItemDraft> _lineItemDrafts =
      <_CommercialLineItemDraft>[];
  final List<_EvidenceDraft> _evidenceDrafts = <_EvidenceDraft>[];
  late String _selectedStatus;
  late String _selectedPaymentMode;
  late String _selectedSettlementType;
  late String _selectedPaymentTerms;
  bool _isSaving = false;

  bool get _showsLineItems =>
      widget.action.type == WorkspaceActivityType.order ||
      widget.action.type == WorkspaceActivityType.procurement;

  bool get _showsCollectionControls =>
      widget.action.type == WorkspaceActivityType.collection;

  bool get _showsPaymentTerms => _showsLineItems;

  double get _estimatedLineTotal =>
      _estimateLineItemsTotal(_lineItemDrafts, widget.availableProducts);

  int get _capturedLineCount => _capturedLineItemsCount(_lineItemDrafts);

  @override
  void initState() {
    super.initState();
    _timingController = TextEditingController(
      text: _defaultWorkflowTimingLabel(),
    );
    _scheduledReviewController = TextEditingController();
    _focusController = TextEditingController();
    _amountController = TextEditingController(text: 'Rs ');
    _referenceController = TextEditingController();
    _nextStepController = TextEditingController();
    _selectedStatus = widget.action.defaultStatus;
    _selectedPaymentMode = _collectionPaymentModes.first;
    _selectedSettlementType = _collectionSettlementTypes.first;
    _selectedPaymentTerms = _commercialPaymentTerms.first;
    if (_showsLineItems) {
      _lineItemDrafts.add(_CommercialLineItemDraft());
    }
    _evidenceDrafts.add(_EvidenceDraft());
  }

  @override
  void dispose() {
    _timingController.dispose();
    _scheduledReviewController.dispose();
    _focusController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _nextStepController.dispose();
    for (final draft in _lineItemDrafts) {
      draft.dispose();
    }
    for (final draft in _evidenceDrafts) {
      draft.dispose();
    }
    super.dispose();
  }

  void _addLineItemDraft() {
    final draft = _CommercialLineItemDraft();
    final usedProducts = _lineItemDrafts
        .map((item) => (item.productName ?? '').trim())
        .where((name) => name.isNotEmpty)
        .toSet();
    for (final product in widget.availableProducts) {
      if (!usedProducts.contains(product.name)) {
        draft.productName = product.name;
        break;
      }
    }
    if (draft.productName == null && widget.availableProducts.isNotEmpty) {
      draft.productName = widget.availableProducts.first.name;
    }
    final suggestedProduct = _findProductByName(
      widget.availableProducts,
      draft.productName,
    );
    if (suggestedProduct != null) {
      draft.unitRateController.text = suggestedProduct.price.toStringAsFixed(2);
    }
    setState(() {
      _lineItemDrafts.add(draft);
    });
  }

  void _removeLineItemDraft(_CommercialLineItemDraft draft) {
    if (_lineItemDrafts.length == 1) {
      draft.clear();
      setState(() {});
      return;
    }

    draft.dispose();
    setState(() {
      _lineItemDrafts.remove(draft);
    });
  }

  void _addEvidenceDraft() {
    setState(() {
      _evidenceDrafts.add(_EvidenceDraft());
    });
  }

  void _removeEvidenceDraft(_EvidenceDraft draft) {
    if (_evidenceDrafts.length == 1) {
      draft.clear();
      setState(() {});
      return;
    }

    draft.dispose();
    setState(() {
      _evidenceDrafts.remove(draft);
    });
  }

  void _handleLineItemsChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _applyEstimatedTotal() {
    final estimate = _estimatedLineTotal;
    if (estimate <= 0) {
      return;
    }
    setState(() {
      _amountController.text = _currencyLabel(estimate);
    });
  }

  Future<void> _handleSave() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final focus = _focusController.text.trim();
    final amount = _amountController.text.trim();
    final reference = _referenceController.text.trim();
    final nextStep = _nextStepController.text.trim();
    final timing = _timingController.text.trim();
    final scheduledReview = _scheduledReviewController.text.trim();
    final paymentMode = _showsCollectionControls ? _selectedPaymentMode : '';
    final settlementType = _showsCollectionControls
        ? _selectedSettlementType
        : '';
    final paymentTerms = _showsPaymentTerms ? _selectedPaymentTerms : '';
    final selectedProductsLabel = _selectedProductsLabel(_selectedProducts);
    final lineItemsSummary = _lineItemsSummary(
      _lineItemDrafts,
      widget.availableProducts,
    );
    final estimatedLineTotal = _estimatedLineTotal;
    final evidenceSummary = _evidenceSummary(_evidenceDrafts);
    final resolvedAmount = _resolveCommercialAmount(
      typedAmount: amount,
      estimatedAmount: estimatedLineTotal,
    );
    final summaryParts = <String>[
      widget.action.buildSummary(widget.entity),
      if (timing.isNotEmpty) 'Timing: $timing.',
      if (selectedProductsLabel.isNotEmpty)
        'Selected products: $selectedProductsLabel.',
      if (lineItemsSummary.isNotEmpty) 'Line items: $lineItemsSummary.',
      if (_showsLineItems && estimatedLineTotal > 0)
        'Estimated total: ${_currencyLabel(estimatedLineTotal)}.',
      if (paymentTerms.isNotEmpty) 'Payment terms: $paymentTerms.',
      '${_commercialFocusLabel(widget.action.type)}: $focus.',
      'Value: $resolvedAmount.',
      if (paymentMode.isNotEmpty) 'Payment mode: $paymentMode.',
      if (settlementType.isNotEmpty) 'Settlement: $settlementType.',
      if (reference.isNotEmpty)
        '${_commercialReferenceLabel(widget.action.type)}: $reference.',
      if (evidenceSummary.isNotEmpty) 'Evidence: $evidenceSummary.',
      if (scheduledReview.isNotEmpty) 'Next review: $scheduledReview.',
      if (nextStep.isNotEmpty) 'Next action: $nextStep.',
    ];

    final activity = WorkspaceActivity(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      title: widget.action.buildTitle(widget.entity),
      subtitle: summaryParts.join(' '),
      type: widget.action.type,
      module: widget.action.module,
      roles: [widget.currentUser.role],
      status: _selectedStatus,
      dateLabel: 'Just now',
      owner: widget.currentUser.fullName,
      territory: widget.entity.territory,
      tags: _buildTags(
        [
          widget.entity.name,
          widget.entity.type.label,
          widget.entity.city,
          if (selectedProductsLabel.isNotEmpty) selectedProductsLabel,
          focus,
          if (reference.isNotEmpty) reference,
        ].join(', '),
        widget.action.type,
        widget.action.module,
      ),
      details: _compactDetails(<String, String>{
        'Account': widget.entity.name,
        'Profile type': widget.entity.type.label,
        'Institution': widget.entity.institution,
        'Action date / time': timing,
        'Selected products': selectedProductsLabel,
        'Line items': lineItemsSummary,
        if (_showsLineItems && estimatedLineTotal > 0)
          'Estimated total': _currencyLabel(estimatedLineTotal),
        if (_showsLineItems && _capturedLineCount > 0)
          'SKU count': _capturedLineCount.toString(),
        if (paymentTerms.isNotEmpty) 'Payment terms': paymentTerms,
        _commercialFocusLabel(widget.action.type): focus,
        'Amount / value': resolvedAmount,
        if (paymentMode.isNotEmpty) 'Payment mode': paymentMode,
        if (settlementType.isNotEmpty) 'Settlement type': settlementType,
        _commercialReferenceLabel(widget.action.type): reference,
        'Evidence / attachments': evidenceSummary,
        'Next review / due': scheduledReview,
        'Next action': nextStep,
      }),
      amount: resolvedAmount,
    );

    await widget.onCreate(activity);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusOptions = _statusOptionsFor(
      widget.action.type,
      widget.action.defaultStatus,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.84,
      minChildSize: 0.58,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1C7B6),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.action.label,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: NeutraliticalBrand.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.action.helper,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF5E574F),
                    height: 1.48,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _DetailPill(label: widget.entity.name),
                    _DetailPill(label: widget.entity.type.label),
                    _DetailPill(label: widget.entity.territory),
                  ],
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: statusOptions
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _timingController,
                  decoration: const InputDecoration(
                    labelText: 'Action date / time',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Add when this workflow is relevant.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _focusController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: _commercialFocusLabel(widget.action.type),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().length < 4) {
                      return 'Add the commercial focus for this workflow.';
                    }
                    return null;
                  },
                ),
                if (widget.availableProducts.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _WorkflowProductSection(
                    title: 'Linked products',
                    subtitle:
                        'Attach the products or brands involved in this order, collection, or procurement line.',
                    products: widget.availableProducts,
                    selectedNames: _selectedProducts,
                    onToggle: (productName) {
                      setState(() {
                        if (_selectedProducts.contains(productName)) {
                          _selectedProducts.remove(productName);
                        } else {
                          _selectedProducts.add(productName);
                        }
                      });
                    },
                  ),
                ],
                if (_showsLineItems) ...[
                  const SizedBox(height: 18),
                  _CommercialLineItemSection(
                    drafts: _lineItemDrafts,
                    products: widget.availableProducts,
                    onChanged: _handleLineItemsChanged,
                    onAdd: _addLineItemDraft,
                    onRemove: _removeLineItemDraft,
                  ),
                  if (_estimatedLineTotal > 0) ...[
                    const SizedBox(height: 14),
                    _LineItemEstimateCard(
                      lineCount: _capturedLineCount,
                      totalLabel: _currencyLabel(_estimatedLineTotal),
                      onUseEstimate: _applyEstimatedTotal,
                    ),
                  ],
                ],
                if (_showsCollectionControls) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('commercial_payment_mode'),
                    initialValue: _selectedPaymentMode,
                    decoration: const InputDecoration(
                      labelText: 'Payment mode',
                    ),
                    items: _collectionPaymentModes
                        .map(
                          (mode) =>
                              DropdownMenuItem(value: mode, child: Text(mode)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedPaymentMode = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('commercial_settlement_type'),
                    initialValue: _selectedSettlementType,
                    decoration: const InputDecoration(
                      labelText: 'Settlement type',
                    ),
                    items: _collectionSettlementTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedSettlementType = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount / value',
                    helperText: _showsLineItems && _estimatedLineTotal > 0
                        ? 'Estimated from SKU lines: ${_currencyLabel(_estimatedLineTotal)}'
                        : null,
                  ),
                  validator: (value) {
                    final trimmed = (value ?? '').trim();
                    if ((trimmed.isEmpty || trimmed == 'Rs') &&
                        !(_showsLineItems && _estimatedLineTotal > 0)) {
                      return 'Enter an amount or value.';
                    }
                    return null;
                  },
                ),
                if (_showsPaymentTerms) ...[
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    key: const ValueKey('commercial_payment_terms'),
                    initialValue: _selectedPaymentTerms,
                    decoration: const InputDecoration(
                      labelText: 'Payment terms',
                    ),
                    items: _commercialPaymentTerms
                        .map(
                          (term) =>
                              DropdownMenuItem(value: term, child: Text(term)),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() {
                        _selectedPaymentTerms = value;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 14),
                TextFormField(
                  controller: _referenceController,
                  decoration: InputDecoration(
                    labelText: _commercialReferenceLabel(widget.action.type),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _scheduledReviewController,
                  decoration: const InputDecoration(
                    labelText: 'Next review / due date (optional)',
                    helperText:
                        'Capture the next follow-up commitment or finance due date.',
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nextStepController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Next action / dependency',
                  ),
                ),
                const SizedBox(height: 18),
                _EvidenceSection(
                  drafts: _evidenceDrafts,
                  onAdd: _addEvidenceDraft,
                  onRemove: _removeEvidenceDraft,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSaving ? null : _handleSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_commercialSaveLabel(widget.action.type)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WorkflowProductSection extends StatelessWidget {
  const _WorkflowProductSection({
    required this.title,
    required this.subtitle,
    required this.products,
    required this.selectedNames,
    required this.onToggle,
  });

  final String title;
  final String subtitle;
  final List<Product> products;
  final Set<String> selectedNames;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: NeutraliticalBrand.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF67615A),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: products
              .map(
                (product) => FilterChip(
                  label: Text(product.name),
                  selected: selectedNames.contains(product.name),
                  onSelected: (_) => onToggle(product.name),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _CommercialLineItemSection extends StatelessWidget {
  const _CommercialLineItemSection({
    required this.drafts,
    required this.products,
    required this.onChanged,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_CommercialLineItemDraft> drafts;
  final List<Product> products;
  final VoidCallback onChanged;
  final VoidCallback onAdd;
  final ValueChanged<_CommercialLineItemDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Line items',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: NeutraliticalBrand.ink,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add SKU'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Capture multiple products with quantities for order or procurement actions.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF67615A),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        ...drafts.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CommercialLineItemCard(
              index: entry.key,
              draft: entry.value,
              products: products,
              canRemove: drafts.length > 1,
              onChanged: onChanged,
              onRemove: () => onRemove(entry.value),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommercialLineItemCard extends StatefulWidget {
  const _CommercialLineItemCard({
    required this.index,
    required this.draft,
    required this.products,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final _CommercialLineItemDraft draft;
  final List<Product> products;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  State<_CommercialLineItemCard> createState() =>
      _CommercialLineItemCardState();
}

class _CommercialLineItemCardState extends State<_CommercialLineItemCard> {
  @override
  Widget build(BuildContext context) {
    final selectedProduct = _findProductByName(
      widget.products,
      widget.draft.productName,
    );
    final estimatedLineValue = _estimateLineItemValue(
      widget.draft,
      widget.products,
    );

    return _PanelCard(
      backgroundColor: const Color(0xFFF7F2E9),
      borderColor: const Color(0xFFE6DBC8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'SKU line',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (widget.canRemove)
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove line item',
                ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            key: ValueKey('commercial_line_product_${widget.index}'),
            initialValue: widget.draft.productName,
            decoration: const InputDecoration(labelText: 'Product'),
            items: widget.products
                .map(
                  (product) => DropdownMenuItem(
                    value: product.name,
                    child: Text(product.name),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              setState(() {
                widget.draft.productName = value;
                final selectedProduct = _findProductByName(
                  widget.products,
                  value,
                );
                if (selectedProduct != null) {
                  widget.draft.unitRateController.text = selectedProduct.price
                      .toStringAsFixed(2);
                }
              });
              widget.onChanged();
            },
            validator: (value) {
              if ((value ?? '').trim().isEmpty) {
                return 'Select a product.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('commercial_line_quantity_${widget.index}'),
            controller: widget.draft.quantityController,
            decoration: InputDecoration(
              labelText: 'Quantity / packs',
              helperText: selectedProduct == null
                  ? 'Start with a number, for example 24 packs.'
                  : 'Start with a number. Unit rate ${selectedProduct.priceLabel}.',
            ),
            onChanged: (_) {
              setState(() {});
              widget.onChanged();
            },
            validator: (value) {
              final trimmed = (value ?? '').trim();
              if (trimmed.isEmpty) {
                return 'Add a quantity.';
              }
              if (_parseLeadingNumber(trimmed) == null) {
                return 'Start quantity with a number.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('commercial_line_rate_${widget.index}'),
            controller: widget.draft.unitRateController,
            decoration: const InputDecoration(
              labelText: 'Unit rate (Rs)',
              helperText:
                  'Override the unit value if this invoice line differs.',
            ),
            onChanged: (_) {
              setState(() {});
              widget.onChanged();
            },
            validator: (value) {
              final trimmed = (value ?? '').trim();
              if (trimmed.isEmpty) {
                return 'Add the unit rate.';
              }
              if (_parseCurrencyNumber(trimmed) == null) {
                return 'Enter a valid unit rate.';
              }
              return null;
            },
          ),
          if (selectedProduct != null || estimatedLineValue > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (selectedProduct != null)
                  _DetailPill(label: 'Unit rate ${selectedProduct.priceLabel}'),
                if (_resolvedLineUnitRate(widget.draft, widget.products) > 0)
                  _DetailPill(
                    label:
                        'Entered ${_currencyLabel(_resolvedLineUnitRate(widget.draft, widget.products))}',
                  ),
                if (estimatedLineValue > 0)
                  _DetailPill(
                    label: 'Estimated ${_currencyLabel(estimatedLineValue)}',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('commercial_line_note_${widget.index}'),
            controller: widget.draft.noteController,
            decoration: const InputDecoration(
              labelText: 'Line note (optional)',
            ),
            onChanged: (_) => widget.onChanged(),
          ),
        ],
      ),
    );
  }
}

class _LineItemEstimateCard extends StatelessWidget {
  const _LineItemEstimateCard({
    required this.lineCount,
    required this.totalLabel,
    required this.onUseEstimate,
  });

  final int lineCount;
  final String totalLabel;
  final VoidCallback onUseEstimate;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      backgroundColor: const Color(0xFFF1E8D7),
      borderColor: const Color(0xFFE2D3BA),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated order value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalLabel across $lineCount SKU lines',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5E574F),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.tonal(
            onPressed: onUseEstimate,
            child: const Text('Use estimate'),
          ),
        ],
      ),
    );
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({
    required this.drafts,
    required this.onAdd,
    required this.onRemove,
  });

  final List<_EvidenceDraft> drafts;
  final VoidCallback onAdd;
  final ValueChanged<_EvidenceDraft> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Evidence / attachments',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: NeutraliticalBrand.ink,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add slot'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Track proof items or attachment references until full file sync is added.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF67615A),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        ...drafts.map(
          (draft) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _EvidenceDraftCard(
              draft: draft,
              canRemove: drafts.length > 1,
              onRemove: () => onRemove(draft),
            ),
          ),
        ),
      ],
    );
  }
}

class _EvidenceDraftCard extends StatelessWidget {
  const _EvidenceDraftCard({
    required this.draft,
    required this.canRemove,
    required this.onRemove,
  });

  final _EvidenceDraft draft;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      backgroundColor: const Color(0xFFF7F2E9),
      borderColor: const Color(0xFFE6DBC8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Evidence slot',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remove evidence slot',
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: draft.labelController,
            decoration: const InputDecoration(labelText: 'Evidence label'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: draft.referenceController,
            decoration: const InputDecoration(labelText: 'Reference / note'),
          ),
        ],
      ),
    );
  }
}

class _EntityDetailSheet extends StatelessWidget {
  const _EntityDetailSheet({
    required this.entity,
    required this.quickActions,
    required this.relatedActivities,
  });

  final NetworkEntity entity;
  final List<_EntityQuickAction> quickActions;
  final List<_ResolvedActivity> relatedActivities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.52,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F6F0),
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1C7B6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entity.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: NeutraliticalBrand.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusPill(label: entity.verified ? 'Verified' : 'Review'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${entity.type.label} • ${entity.city} • ${entity.territory}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF5E574F),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DetailPill(label: entity.specialty),
                  _DetailPill(label: entity.institution),
                  _DetailPill(label: entity.owner),
                  _DetailPill(label: entity.phone),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Quick actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: NeutraliticalBrand.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start a prefilled workflow directly from this profile.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF67615A),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 14),
              if (quickActions.isEmpty)
                const _EmptyCard(
                  title: 'No quick actions are available.',
                  body:
                      'This role can still review the profile, but it cannot create linked workflow items yet.',
                )
              else
                ...quickActions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _QuickActionLaunchCard(
                      action: action,
                      onTap: () => Navigator.of(context).pop(action),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Text(
                'Recent workflow',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: NeutraliticalBrand.ink,
                ),
              ),
              const SizedBox(height: 12),
              if (relatedActivities.isEmpty)
                const _EmptyCard(
                  title: 'No linked workflow is visible yet.',
                  body:
                      'Once activities are created for this account or territory, they will appear here for context.',
                )
              else
                ...relatedActivities.map(
                  (record) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _EntityRelatedActivityCard(record: record),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ResolvedActivity {
  const _ResolvedActivity({required this.activity, required this.updates});

  final WorkspaceActivity activity;
  final List<WorkspaceActivityUpdate> updates;

  String get currentStatus {
    return updates.isEmpty ? activity.status : updates.first.status;
  }

  String get currentSummary {
    if (updates.isNotEmpty && updates.first.note.trim().isNotEmpty) {
      return updates.first.note;
    }
    return activity.subtitle;
  }

  int get updateCount => updates.length;
}

class _CommercialLineItemDraft {
  _CommercialLineItemDraft()
    : quantityController = TextEditingController(),
      unitRateController = TextEditingController(),
      noteController = TextEditingController();

  String? productName;
  final TextEditingController quantityController;
  final TextEditingController unitRateController;
  final TextEditingController noteController;

  void clear() {
    productName = null;
    quantityController.clear();
    unitRateController.clear();
    noteController.clear();
  }

  void dispose() {
    quantityController.dispose();
    unitRateController.dispose();
    noteController.dispose();
  }
}

class _EvidenceDraft {
  _EvidenceDraft()
    : labelController = TextEditingController(),
      referenceController = TextEditingController();

  final TextEditingController labelController;
  final TextEditingController referenceController;

  void clear() {
    labelController.clear();
    referenceController.clear();
  }

  void dispose() {
    labelController.dispose();
    referenceController.dispose();
  }
}

enum _EntityWorkflowKind { generic, visit, commercial }

class _EntityQuickAction {
  const _EntityQuickAction({
    required this.label,
    required this.helper,
    required this.icon,
    required this.workflowKind,
    required this.module,
    required this.type,
    required this.defaultStatus,
    required this.buildTitle,
    required this.buildSummary,
    this.suggestsAmount = false,
  });

  final String label;
  final String helper;
  final IconData icon;
  final _EntityWorkflowKind workflowKind;
  final WorkspaceModule module;
  final WorkspaceActivityType type;
  final String defaultStatus;
  final String Function(NetworkEntity entity) buildTitle;
  final String Function(NetworkEntity entity) buildSummary;
  final bool suggestsAmount;
}

List<_EntityQuickAction> _quickActionsForEntity(
  NetworkEntity entity,
  List<WorkspaceModule> availableModules,
) {
  final actions = <_EntityQuickAction>[];

  if (availableModules.contains(WorkspaceModule.network)) {
    actions.add(
      _EntityQuickAction(
        label: 'Log Follow-up',
        helper:
            'Capture the next conversation, relationship update, or account note tied to this profile.',
        icon: Icons.playlist_add_check_circle_outlined,
        workflowKind: _EntityWorkflowKind.visit,
        module: WorkspaceModule.network,
        type: WorkspaceActivityType.visit,
        defaultStatus: 'Follow-up',
        buildTitle: (entity) => 'Follow-up: ${entity.name}',
        buildSummary: (entity) =>
            'Capture the latest follow-up note, commitment, or relationship update for ${entity.name}.',
      ),
    );
  }

  if (availableModules.contains(WorkspaceModule.fieldForce)) {
    switch (entity.type) {
      case NetworkEntityType.doctor:
        actions.addAll([
          _EntityQuickAction(
            label: 'Log Doctor Visit',
            helper:
                'Prefill a DCR-style visit note for this doctor profile and continue it as a field-force activity.',
            icon: Icons.medical_information_outlined,
            workflowKind: _EntityWorkflowKind.visit,
            module: WorkspaceModule.fieldForce,
            type: WorkspaceActivityType.visit,
            defaultStatus: 'Completed',
            buildTitle: (entity) => 'Visit: ${entity.name}',
            buildSummary: (entity) =>
                'Discussed ${entity.specialty.toLowerCase()} support points with ${entity.name}. Capture outcome and next visit timing.',
          ),
          _EntityQuickAction(
            label: 'Issue Sample',
            helper:
                'Start a sample support entry for this doctor so product movement and follow-up stay connected.',
            icon: Icons.inventory_2_outlined,
            workflowKind: _EntityWorkflowKind.visit,
            module: WorkspaceModule.fieldForce,
            type: WorkspaceActivityType.sample,
            defaultStatus: 'Pending',
            buildTitle: (entity) => 'Sample support for ${entity.name}',
            buildSummary: (entity) =>
                'Record sample requirement, product focus, and any follow-up requested by ${entity.name}.',
          ),
        ]);
      case NetworkEntityType.hospital:
        actions.add(
          _EntityQuickAction(
            label: 'Log Institutional Visit',
            helper:
                'Create a hospital-facing visit entry with institutional context already filled in.',
            icon: Icons.local_hospital_outlined,
            workflowKind: _EntityWorkflowKind.visit,
            module: WorkspaceModule.fieldForce,
            type: WorkspaceActivityType.visit,
            defaultStatus: 'Completed',
            buildTitle: (entity) => 'Institutional visit: ${entity.name}',
            buildSummary: (entity) =>
                'Capture the latest institutional follow-up, department discussions, and next steps for ${entity.name}.',
          ),
        );
      case NetworkEntityType.stockist || NetworkEntityType.retailer:
        actions.add(
          _EntityQuickAction(
            label: 'Capture Order',
            helper:
                'Start an order capture item for this trade account with territory and profile context filled in.',
            icon: Icons.shopping_cart_checkout_outlined,
            workflowKind: _EntityWorkflowKind.commercial,
            module: WorkspaceModule.fieldForce,
            type: WorkspaceActivityType.order,
            defaultStatus: 'Pending',
            buildTitle: (entity) => 'Order capture for ${entity.name}',
            buildSummary: (entity) =>
                'Capture products, quantities, and dispatch expectations requested by ${entity.name}.',
            suggestsAmount: true,
          ),
        );
    }
  }

  if (availableModules.contains(WorkspaceModule.finance)) {
    switch (entity.type) {
      case NetworkEntityType.stockist || NetworkEntityType.retailer:
        actions.add(
          _EntityQuickAction(
            label: 'Record Collection',
            helper:
                'Create a collection workflow item for this account with payment follow-up details.',
            icon: Icons.payments_outlined,
            workflowKind: _EntityWorkflowKind.commercial,
            module: WorkspaceModule.finance,
            type: WorkspaceActivityType.collection,
            defaultStatus: 'Ready to post',
            buildTitle: (entity) => 'Collection update for ${entity.name}',
            buildSummary: (entity) =>
                'Capture payment status, voucher reference, and next accounting action for ${entity.name}.',
            suggestsAmount: true,
          ),
        );
      case NetworkEntityType.hospital:
        actions.add(
          _EntityQuickAction(
            label: 'Create Procurement Line',
            helper:
                'Start an institutional procurement workflow with the hospital already mapped.',
            icon: Icons.post_add_outlined,
            workflowKind: _EntityWorkflowKind.commercial,
            module: WorkspaceModule.finance,
            type: WorkspaceActivityType.procurement,
            defaultStatus: 'Pending approval',
            buildTitle: (entity) => 'Procurement line for ${entity.name}',
            buildSummary: (entity) =>
                'Capture requested quantities, department notes, and approval requirements for ${entity.name}.',
            suggestsAmount: true,
          ),
        );
      case NetworkEntityType.doctor:
        break;
    }
  }

  if (availableModules.contains(WorkspaceModule.imports)) {
    actions.add(
      _EntityQuickAction(
        label: 'Flag Data Review',
        helper:
            'Open a controlled review item if profile data needs verification, correction, or re-approval.',
        icon: Icons.fact_check_outlined,
        workflowKind: _EntityWorkflowKind.generic,
        module: WorkspaceModule.imports,
        type: WorkspaceActivityType.audit,
        defaultStatus: 'Review',
        buildTitle: (entity) => 'Profile review for ${entity.name}',
        buildSummary: (entity) =>
            'Capture data-quality observations or verification notes for ${entity.name}.',
      ),
    );
  }

  return actions.take(4).toList(growable: false);
}

List<String> _statusOptionsFor(
  WorkspaceActivityType type,
  String currentStatus,
) {
  final options = switch (type) {
    WorkspaceActivityType.visit => const [
      'Scheduled',
      'In progress',
      'Completed',
      'Follow-up',
      'Escalated',
    ],
    WorkspaceActivityType.order => const [
      'Pending',
      'Approved',
      'Dispatched',
      'Completed',
      'Delayed',
    ],
    WorkspaceActivityType.collection => const [
      'Ready to post',
      'Received',
      'Allocated',
      'Completed',
      'Escalated',
    ],
    WorkspaceActivityType.inventory => const [
      'Low stock',
      'Replenishment raised',
      'In transit',
      'Resolved',
    ],
    WorkspaceActivityType.audit => const [
      'Review',
      'Exception',
      'Approved',
      'Closed',
    ],
    WorkspaceActivityType.expense => const [
      'Queue',
      'Under review',
      'Posted',
      'Reimbursed',
    ],
    WorkspaceActivityType.procurement => const [
      'Pending approval',
      'Approved',
      'Released',
      'Completed',
    ],
    WorkspaceActivityType.sample => const [
      'Pending',
      'Approved',
      'Issued',
      'Completed',
    ],
  };

  if (options.contains(currentStatus)) {
    return options;
  }
  return [currentStatus, ...options];
}

List<WorkspaceActivityType> _activityTypesForModule(WorkspaceModule module) {
  return switch (module) {
    WorkspaceModule.fieldForce => const [
      WorkspaceActivityType.visit,
      WorkspaceActivityType.sample,
      WorkspaceActivityType.order,
    ],
    WorkspaceModule.finance => const [
      WorkspaceActivityType.order,
      WorkspaceActivityType.collection,
      WorkspaceActivityType.inventory,
      WorkspaceActivityType.expense,
      WorkspaceActivityType.procurement,
    ],
    WorkspaceModule.imports => const [WorkspaceActivityType.audit],
    WorkspaceModule.network => const [
      WorkspaceActivityType.visit,
      WorkspaceActivityType.audit,
    ],
    WorkspaceModule.reports => const [
      WorkspaceActivityType.audit,
      WorkspaceActivityType.collection,
    ],
    WorkspaceModule.catalog ||
    WorkspaceModule.overview => const [WorkspaceActivityType.visit],
  };
}

List<String> _buildTags(
  String rawTags,
  WorkspaceActivityType type,
  WorkspaceModule module,
) {
  final tags = rawTags
      .split(',')
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .toList(growable: true);
  if (!tags.contains(type.label)) {
    tags.insert(0, type.label);
  }
  if (!tags.contains(module.label)) {
    tags.add(module.label);
  }
  if (!tags.contains('Local')) {
    tags.add('Local');
  }
  return tags;
}

Map<String, String> _compactDetails(Map<String, String> rawDetails) {
  final details = <String, String>{};
  for (final entry in rawDetails.entries) {
    final key = entry.key.trim();
    final value = entry.value.trim();
    if (key.isEmpty || value.isEmpty) {
      continue;
    }
    details[key] = value;
  }
  return details;
}

String _defaultWorkflowTimingLabel() {
  final now = DateTime.now().toLocal();
  final hour = now.hour == 0
      ? 12
      : now.hour > 12
      ? now.hour - 12
      : now.hour;
  final minute = now.minute.toString().padLeft(2, '0');
  final suffix = now.hour >= 12 ? 'PM' : 'AM';
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString();
  return '$day/$month/$year ${hour.toString().padLeft(2, '0')}:$minute $suffix';
}

String _selectedProductsLabel(Set<String> selectedProducts) {
  if (selectedProducts.isEmpty) {
    return '';
  }
  final names = selectedProducts.toList(growable: false)..sort();
  return names.join(', ');
}

String _lineItemsSummary(
  List<_CommercialLineItemDraft> drafts,
  List<Product> products,
) {
  final items = drafts
      .map((draft) {
        final product = (draft.productName ?? '').trim();
        final quantity = draft.quantityController.text.trim();
        final rate = _resolvedLineUnitRate(draft, products);
        final note = draft.noteController.text.trim();
        if (product.isEmpty && quantity.isEmpty && note.isEmpty) {
          return '';
        }

        final estimatedValue = _estimateLineItemValue(draft, products);
        final core = <String>[
          if (product.isNotEmpty) product,
          if (quantity.isNotEmpty) quantity,
        ].join(' x ');
        if (core.isEmpty) {
          return note;
        }
        final annotations = <String>[
          if (rate > 0) '@ ${_currencyLabel(rate)}',
          if (estimatedValue > 0) _currencyLabel(estimatedValue),
          if (note.isNotEmpty) note,
        ];
        if (annotations.isEmpty) {
          return core;
        }
        return '$core (${annotations.join(', ')})';
      })
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  return items.join(', ');
}

String _resolveCommercialAmount({
  required String typedAmount,
  required double estimatedAmount,
}) {
  final trimmed = typedAmount.trim();
  if (trimmed.isNotEmpty && trimmed != 'Rs') {
    return trimmed;
  }
  if (estimatedAmount > 0) {
    return _currencyLabel(estimatedAmount);
  }
  return trimmed;
}

Product? _findProductByName(List<Product> products, String? productName) {
  final target = (productName ?? '').trim();
  if (target.isEmpty) {
    return null;
  }
  for (final product in products) {
    if (product.name == target) {
      return product;
    }
  }
  return null;
}

double _estimateLineItemValue(
  _CommercialLineItemDraft draft,
  List<Product> products,
) {
  final rate = _resolvedLineUnitRate(draft, products);
  final quantity = _parseLeadingNumber(draft.quantityController.text.trim());
  if (rate <= 0 || quantity == null || quantity <= 0) {
    return 0;
  }
  return rate * quantity;
}

double _estimateLineItemsTotal(
  List<_CommercialLineItemDraft> drafts,
  List<Product> products,
) {
  var total = 0.0;
  for (final draft in drafts) {
    total += _estimateLineItemValue(draft, products);
  }
  return total;
}

int _capturedLineItemsCount(List<_CommercialLineItemDraft> drafts) {
  return drafts.where((draft) {
    return (draft.productName ?? '').trim().isNotEmpty &&
        draft.quantityController.text.trim().isNotEmpty;
  }).length;
}

String _currencyLabel(double amount) {
  return 'Rs ${amount.toStringAsFixed(2)}';
}

double _resolvedLineUnitRate(
  _CommercialLineItemDraft draft,
  List<Product> products,
) {
  final enteredRate = _parseCurrencyNumber(
    draft.unitRateController.text.trim(),
  );
  if (enteredRate != null && enteredRate > 0) {
    return enteredRate;
  }
  final product = _findProductByName(products, draft.productName);
  if (product == null) {
    return 0;
  }
  return product.price;
}

double? _parseLeadingNumber(String value) {
  final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value);
  if (match == null) {
    return null;
  }
  return double.tryParse(match.group(1)!);
}

double? _parseCurrencyNumber(String value) {
  final normalized = value.replaceAll('Rs', '').replaceAll(',', '').trim();
  if (normalized.isEmpty) {
    return null;
  }
  return double.tryParse(normalized);
}

String _evidenceSummary(List<_EvidenceDraft> drafts) {
  final items = drafts
      .map((draft) {
        final label = draft.labelController.text.trim();
        final reference = draft.referenceController.text.trim();
        if (label.isEmpty && reference.isEmpty) {
          return '';
        }
        if (label.isEmpty) {
          return reference;
        }
        if (reference.isEmpty) {
          return label;
        }
        return '$label: $reference';
      })
      .where((value) => value.isNotEmpty)
      .toList(growable: false);

  return items.join(', ');
}

String _defaultVisitObjective(_EntityQuickAction action, NetworkEntity entity) {
  return switch (action.type) {
    WorkspaceActivityType.sample =>
      'Record product support and sample requirement for ${entity.name}.',
    WorkspaceActivityType.visit =>
      'Capture the latest engagement outcome for ${entity.name}.',
    _ => action.buildSummary(entity),
  };
}

String _visitObjectiveLabel(_EntityQuickAction action) {
  return switch (action.label) {
    'Log Follow-up' => 'Follow-up note',
    'Issue Sample' => 'Sample support objective',
    _ => 'Visit objective',
  };
}

String _visitProductLabel(_EntityQuickAction action) {
  return switch (action.type) {
    WorkspaceActivityType.sample => 'Products / packs discussed',
    _ => 'Products / therapy focus',
  };
}

String _visitSaveLabel(_EntityQuickAction action) {
  return switch (action.type) {
    WorkspaceActivityType.sample => 'Save Sample Entry',
    _ => 'Save Visit Entry',
  };
}

String _commercialFocusLabel(WorkspaceActivityType type) {
  return switch (type) {
    WorkspaceActivityType.order => 'Products / quantities',
    WorkspaceActivityType.collection => 'Invoice / account focus',
    WorkspaceActivityType.procurement => 'Items / departments',
    _ => 'Commercial focus',
  };
}

String _commercialReferenceLabel(WorkspaceActivityType type) {
  return switch (type) {
    WorkspaceActivityType.order => 'Order reference / dispatch note',
    WorkspaceActivityType.collection => 'Receipt / bank reference',
    WorkspaceActivityType.procurement => 'Indent / approval reference',
    _ => 'Reference',
  };
}

String _commercialSaveLabel(WorkspaceActivityType type) {
  return switch (type) {
    WorkspaceActivityType.order => 'Save Order',
    WorkspaceActivityType.collection => 'Save Collection',
    WorkspaceActivityType.procurement => 'Save Procurement',
    _ => 'Save Workflow',
  };
}

const List<String> _collectionPaymentModes = <String>[
  'Bank transfer',
  'Cheque',
  'Cash',
  'UPI',
  'Credit note adjustment',
];

const List<String> _collectionSettlementTypes = <String>[
  'Part payment',
  'Full settlement',
  'Advance receipt',
  'Adjustment entry',
];

const List<String> _commercialPaymentTerms = <String>[
  '30 days credit',
  'Advance against dispatch',
  '15 days credit',
  'Cash on delivery',
];

String _formatUpdateTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour == 0
      ? 12
      : local.hour > 12
      ? local.hour - 12
      : local.hour;
  final minute = local.minute.toString().padLeft(2, '0');
  final suffix = local.hour >= 12 ? 'PM' : 'AM';
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  return '$day/$month ${hour.toString().padLeft(2, '0')}:$minute $suffix';
}

class _EntityCard extends StatelessWidget {
  const _EntityCard({required this.entity, this.onTap});

  final NetworkEntity entity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: _PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(entity.type.icon, color: NeutraliticalBrand.forest),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entity.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: NeutraliticalBrand.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusPill(label: entity.verified ? 'Verified' : 'Review'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${entity.type.label} • ${entity.city} • ${entity.territory}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF66625D),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _DetailPill(label: entity.specialty),
                  _DetailPill(label: entity.institution),
                  _DetailPill(label: entity.owner),
                  _DetailPill(label: entity.phone),
                  _DetailPill(label: entity.sourceLabel),
                ],
              ),
              if (onTap != null) ...[
                const SizedBox(height: 14),
                Text(
                  'Open profile and quick actions',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: NeutraliticalBrand.forest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.lead, this.onApprove, this.onReject});

  final IngestionLead lead;
  final Future<void> Function()? onApprove;
  final Future<void> Function()? onReject;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(lead.type.icon, color: NeutraliticalBrand.forest),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lead.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(label: lead.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${lead.type.label} • ${lead.city} • ${lead.territory}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF66625D)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DetailPill(label: lead.sourceLabel),
              _DetailPill(label: 'Confidence ${lead.confidenceLabel}'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lead.sourceUrl,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: const Color(0xFF5F625E)),
          ),
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (onReject != null)
                  TextButton.icon(
                    onPressed: () async {
                      await onReject!();
                    },
                    icon: const Icon(Icons.block_outlined),
                    label: const Text('Reject'),
                  ),
                if (onApprove != null)
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      await onApprove!();
                    },
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve to Directory'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadReviewCard extends StatelessWidget {
  const _LeadReviewCard({required this.decision});

  final LeadReviewDecision decision;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      backgroundColor: const Color(0xFFF7F2E9),
      borderColor: const Color(0xFFE7DCC9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(decision.action.icon, color: NeutraliticalBrand.forest),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  decision.leadName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _StatusPill(label: decision.action.label),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${decision.leadType.label} • ${decision.city} • ${decision.territory}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF66625D)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DetailPill(label: decision.sourceLabel),
              _DetailPill(label: decision.reviewedBy),
              _DetailPill(label: _formatUpdateTime(decision.reviewedAt)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionLaunchCard extends StatelessWidget {
  const _QuickActionLaunchCard({required this.action, required this.onTap});

  final _EntityQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: _PanelCard(
          backgroundColor: const Color(0xFFF7F2E9),
          borderColor: const Color(0xFFE6DBC8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFECE1CF),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(action.icon, color: NeutraliticalBrand.forest),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: NeutraliticalBrand.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action.helper,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF67615A),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${action.module.label} • ${action.type.label}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: NeutraliticalBrand.forest,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF897A68)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntityRelatedActivityCard extends StatelessWidget {
  const _EntityRelatedActivityCard({required this.record});

  final _ResolvedActivity record;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.activity.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _StatusPill(label: record.currentStatus),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            record.currentSummary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5E574F),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _DetailPill(label: record.activity.module.label),
              _DetailPill(label: record.activity.dateLabel),
              _DetailPill(label: record.activity.owner),
              if (record.updateCount > 0)
                _DetailPill(label: '${record.updateCount} updates'),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.entity, this.onTap});

  final NetworkEntity entity;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: _PanelCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4EBDC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Today',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: NeutraliticalBrand.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: NeutraliticalBrand.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entity.type.label} • ${entity.city}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF66625D),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entity.status,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5B5853),
                        height: 1.45,
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Tap to open profile actions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: NeutraliticalBrand.forest,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final Future<void> Function()? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      backgroundColor: const Color(0xFFF7F2E9),
      borderColor: const Color(0xFFE6DBC8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: NeutraliticalBrand.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5E574F),
              height: 1.48,
            ),
          ),
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onActionPressed,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _PanelCard(
      child: Column(
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 52,
            color: NeutraliticalBrand.forest,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: NeutraliticalBrand.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF66625D),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.child,
    this.backgroundColor = Colors.white,
    this.borderColor = NeutraliticalBrand.sand,
  });

  final Widget child;
  final Color backgroundColor;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFE8DDD0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EBDC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: NeutraliticalBrand.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EB),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF5C5954),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
