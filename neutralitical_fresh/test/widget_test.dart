import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neutralitical/app/neutralitical_app.dart';
import 'package:neutralitical/features/auth/data/services/auth_repository.dart';
import 'package:neutralitical/features/auth/domain/models/auth_user.dart';
import 'package:neutralitical/features/auth/domain/models/business_role.dart';
import 'package:neutralitical/features/catalog/data/services/product_catalog_service.dart';
import 'package:neutralitical/features/catalog/data/services/product_media_library_service.dart';
import 'package:neutralitical/features/catalog/domain/models/product.dart';
import 'package:neutralitical/features/catalog/domain/models/product_media.dart';
import 'package:neutralitical/features/workspace/data/services/workspace_service.dart';
import 'package:neutralitical/features/workspace/data/services/workspace_activity_draft_service.dart';
import 'package:neutralitical/features/workspace/data/services/workspace_lead_review_service.dart';
import 'package:neutralitical/features/workspace/domain/models/ingestion_lead.dart';
import 'package:neutralitical/features/workspace/domain/models/lead_review_decision.dart';
import 'package:neutralitical/features/workspace/domain/models/network_entity.dart';
import 'package:neutralitical/features/workspace/domain/models/workspace_activity.dart';
import 'package:neutralitical/features/workspace/domain/models/workspace_activity_update.dart';
import 'package:neutralitical/features/workspace/data/services/workspace_activity_journal_service.dart';
import 'package:neutralitical/features/workspace/domain/models/workspace_module.dart';
import 'package:neutralitical/features/workspace/domain/models/workspace_snapshot.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    Map<String, String>? passwordsByEmail,
    Map<String, AuthUser>? usersByEmail,
  }) : _passwordsByEmail = passwordsByEmail ?? <String, String>{},
       _usersByEmail = usersByEmail ?? <String, AuthUser>{};

  final Map<String, String> _passwordsByEmail;
  final Map<String, AuthUser> _usersByEmail;
  AuthUser? initialSessionUser;

  @override
  Future<AuthUser?> restoreSession() async => initialSessionUser;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_passwordsByEmail[normalizedEmail] != password) {
      throw const AuthFailure('Invalid email or password.');
    }

    final user = _usersByEmail[normalizedEmail];
    if (user == null) {
      throw const AuthFailure('Invalid email or password.');
    }

    initialSessionUser = user;
    return user;
  }

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
    required BusinessRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_usersByEmail.containsKey(normalizedEmail)) {
      throw const AuthFailure(
        'An account with that email already exists. Sign in instead.',
      );
    }

    final user = AuthUser(
      id: (_usersByEmail.length + 1).toString(),
      fullName: fullName.trim(),
      email: normalizedEmail,
      role: role,
    );

    _usersByEmail[normalizedEmail] = user;
    _passwordsByEmail[normalizedEmail] = password;
    initialSessionUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    initialSessionUser = null;
  }
}

class _FakeProductCatalogService implements ProductCatalogService {
  const _FakeProductCatalogService(this.products);

  final List<Product> products;

  @override
  Future<List<Product>> loadRegisteredProducts() async => products;
}

class _FakeProductMediaLibraryService implements ProductMediaLibraryService {
  _FakeProductMediaLibraryService({
    Map<String, List<ProductMedia>>? uploadedMediaByProductId,
  }) : _uploadedMediaByProductId =
           uploadedMediaByProductId ?? <String, List<ProductMedia>>{};

  final Map<String, List<ProductMedia>> _uploadedMediaByProductId;

  @override
  bool get supportsUploads => true;

  @override
  Future<List<ProductMedia>> addMedia({required String productId}) async {
    final updated = [
      ...(_uploadedMediaByProductId[productId] ?? const <ProductMedia>[]),
      ProductMedia(
        id: '${productId}_upload_1',
        productId: productId,
        type: ProductMediaType.image,
        origin: ProductMediaOrigin.uploaded,
        uri: 'https://example.com/uploaded-media.png',
        title: 'Uploaded production shot',
        caption: 'Uploaded from the device',
      ),
    ];
    _uploadedMediaByProductId[productId] = updated;
    return updated;
  }

  @override
  Future<Map<String, List<ProductMedia>>> loadUploadedMedia() async {
    return Map<String, List<ProductMedia>>.from(_uploadedMediaByProductId);
  }

  @override
  Future<void> removeMedia({
    required String productId,
    required ProductMedia media,
  }) async {
    final current = [
      ...(_uploadedMediaByProductId[productId] ?? const <ProductMedia>[]),
    ];
    current.removeWhere((item) => item.id == media.id);
    if (current.isEmpty) {
      _uploadedMediaByProductId.remove(productId);
      return;
    }

    _uploadedMediaByProductId[productId] = current;
  }
}

class _FakeWorkspaceService implements WorkspaceService {
  const _FakeWorkspaceService();

  @override
  Future<List<NetworkEntity>> loadNetworkDirectory() async {
    return const [
      NetworkEntity(
        id: 'doctor_1',
        name: 'Dr. Meera Adhikari',
        type: NetworkEntityType.doctor,
        specialty: 'Gynecology',
        city: 'Kathmandu',
        territory: 'Central Women Care',
        owner: 'Morgan Lee',
        phone: '+977-9801001001',
        status: 'Follow-up due',
        institution: 'Aarogya City Hospital',
        sourceLabel: 'Verified internal master',
        verified: true,
      ),
      NetworkEntity(
        id: 'stockist_1',
        name: 'Omkar Distributors',
        type: NetworkEntityType.stockist,
        specialty: 'Primary stockist',
        city: 'Kathmandu',
        territory: 'Central Trade',
        owner: 'Morgan Lee',
        phone: '+977-9803003001',
        status: 'Outstanding watch',
        institution: 'Central warehouse',
        sourceLabel: 'Verified internal master',
        verified: true,
      ),
    ];
  }

  @override
  Future<List<IngestionLead>> loadIngestionQueue() async {
    return const [
      IngestionLead(
        id: 'lead_1',
        name: 'Sunrise Retail Pharmacy',
        type: NetworkEntityType.retailer,
        city: 'Butwal',
        territory: 'West Retail',
        status: 'Pending review',
        sourceLabel: 'Trade directory import',
        sourceUrl: 'https://example.com/lead_1',
        confidence: 0.8,
      ),
    ];
  }

  @override
  Future<List<WorkspaceActivity>> loadActivities() async {
    return const [
      WorkspaceActivity(
        id: 'activity_1',
        title: 'Dr. Meera Adhikari follow-up',
        subtitle: 'Capture the next action and align the product discussion.',
        type: WorkspaceActivityType.visit,
        module: WorkspaceModule.fieldForce,
        roles: [BusinessRole.medicalRepresentative],
        status: 'Scheduled',
        dateLabel: '11:30 AM',
        owner: 'Morgan Lee',
        territory: 'Central Women Care',
        tags: ['Doctor', 'DCR'],
      ),
    ];
  }

  @override
  WorkspaceSnapshot buildSnapshot(BusinessRole role) {
    return WorkspaceSnapshot(
      headline: '${role.label} command center',
      summary: 'A role-based workspace for testing the control tower flow.',
      metrics: const [
        WorkspaceMetric(
          label: 'Open tasks',
          value: '3',
          detail: 'Role-specific work is visible from one place.',
        ),
        WorkspaceMetric(
          label: 'Visible accounts',
          value: '2',
          detail: 'Master data records are available to the signed-in user.',
        ),
      ],
      tasks: const [
        WorkspaceTask(
          title: 'Review today’s work',
          subtitle: 'Check priorities, catalog updates, and field progress.',
          status: 'Today',
        ),
        WorkspaceTask(
          title: 'Close pending follow-up',
          subtitle: 'Make sure the next action is captured before sign-out.',
          status: 'Pending',
        ),
      ],
      enabledModules: const [
        WorkspaceModule.overview,
        WorkspaceModule.network,
        WorkspaceModule.fieldForce,
        WorkspaceModule.finance,
        WorkspaceModule.catalog,
        WorkspaceModule.imports,
        WorkspaceModule.reports,
      ],
    );
  }
}

class _FakeWorkspaceActivityDraftService
    implements WorkspaceActivityDraftService {
  _FakeWorkspaceActivityDraftService({
    List<WorkspaceActivity>? initialActivities,
  }) : _activities = initialActivities ?? <WorkspaceActivity>[];

  List<WorkspaceActivity> _activities;

  @override
  Future<List<WorkspaceActivity>> loadDraftActivities() async => _activities;

  @override
  Future<List<WorkspaceActivity>> addDraftActivity(
    WorkspaceActivity activity,
  ) async {
    _activities = [activity, ..._activities];
    return _activities;
  }
}

class _FakeWorkspaceActivityJournalService
    implements WorkspaceActivityJournalService {
  _FakeWorkspaceActivityJournalService({
    List<WorkspaceActivityUpdate>? initialUpdates,
  }) : _updates = initialUpdates ?? <WorkspaceActivityUpdate>[];

  List<WorkspaceActivityUpdate> _updates;

  @override
  Future<List<WorkspaceActivityUpdate>> loadUpdates() async => _updates;

  @override
  Future<List<WorkspaceActivityUpdate>> addUpdate({
    required String activityId,
    required String status,
    required String note,
    required String updatedBy,
  }) async {
    final update = WorkspaceActivityUpdate(
      id: '${activityId}_${_updates.length + 1}',
      activityId: activityId,
      status: status,
      note: note,
      updatedBy: updatedBy,
      updatedAt: DateTime.utc(2026, 3, 22, 10, _updates.length + 1),
    );
    _updates = [update, ..._updates];
    return _updates;
  }
}

class _FakeWorkspaceLeadReviewService implements WorkspaceLeadReviewService {
  _FakeWorkspaceLeadReviewService({
    List<LeadReviewDecision>? initialDecisions,
    List<NetworkEntity>? initialPromotedEntities,
  }) : _decisions = initialDecisions ?? <LeadReviewDecision>[],
       _promotedEntities = initialPromotedEntities ?? <NetworkEntity>[];

  List<LeadReviewDecision> _decisions;
  List<NetworkEntity> _promotedEntities;

  @override
  Future<List<LeadReviewDecision>> loadDecisions() async => _decisions;

  @override
  Future<List<NetworkEntity>> loadPromotedEntities() async => _promotedEntities;

  @override
  Future<void> reviewLead({
    required IngestionLead lead,
    required LeadReviewAction action,
    required String reviewedBy,
  }) async {
    _decisions = [
      LeadReviewDecision(
        id: '${lead.id}_${action.name}',
        leadId: lead.id,
        leadName: lead.name,
        leadType: lead.type,
        action: action,
        reviewedBy: reviewedBy,
        reviewedAt: DateTime.utc(2026, 3, 22, 11, 45),
        city: lead.city,
        territory: lead.territory,
        sourceLabel: lead.sourceLabel,
      ),
      ..._decisions.where((item) => item.leadId != lead.id),
    ];

    if (action == LeadReviewAction.approved) {
      _promotedEntities = [
        NetworkEntity(
          id: 'promoted_${lead.id}',
          name: lead.name,
          type: lead.type,
          specialty: 'Imported retail account',
          city: lead.city,
          territory: lead.territory,
          owner: reviewedBy,
          phone: 'Pending verification',
          status: 'Approved from import queue',
          institution: 'Outlet verification pending',
          sourceLabel: '${lead.sourceLabel} · reviewed',
          verified: true,
        ),
        ..._promotedEntities.where((item) => item.id != 'promoted_${lead.id}'),
      ];
      return;
    }

    _promotedEntities = _promotedEntities
        .where((item) => item.id != 'promoted_${lead.id}')
        .toList(growable: false);
  }
}

void main() {
  const sampleProducts = [
    Product(
      id: '1',
      name: 'UTIVA-BV PLUS',
      category: 'Urinary Health',
      form: 'Capsules',
      ingredients: ['Cranberry 300mg', 'D-Mannose 250mg'],
      description: 'Advanced urinary tract health support with probiotics.',
      imageUrl: '',
      media: [
        ProductMedia(
          id: 'utiva_ref_1',
          productId: '1',
          type: ProductMediaType.image,
          origin: ProductMediaOrigin.curated,
          uri: 'https://example.com/utiva-reference.png',
          title: 'Women health reference',
          caption: 'Shared-drive curated reference',
          isPrimary: true,
        ),
      ],
      price: 550,
      featured: true,
      dosage: 'One capsule twice daily',
      packaging: '30 capsules per bottle',
    ),
  ];

  Future<void> pumpApp(
    WidgetTester tester, {
    required AuthRepository authRepository,
    ProductMediaLibraryService? productMediaLibraryService,
    WorkspaceActivityJournalService? activityJournalService,
    WorkspaceActivityDraftService? activityDraftService,
    WorkspaceLeadReviewService? leadReviewService,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1280, 3200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      NeutraliticalApp(
        authRepository: authRepository,
        workspaceService: const _FakeWorkspaceService(),
        activityJournalService:
            activityJournalService ?? _FakeWorkspaceActivityJournalService(),
        activityDraftService:
            activityDraftService ?? _FakeWorkspaceActivityDraftService(),
        leadReviewService:
            leadReviewService ?? _FakeWorkspaceLeadReviewService(),
        productCatalogService: const _FakeProductCatalogService(sampleProducts),
        productMediaLibraryService:
            productMediaLibraryService ?? _FakeProductMediaLibraryService(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('unauthenticated users land on the auth gate', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester, authRepository: _FakeAuthRepository());

    expect(find.text('Secure access'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Open Product Catalog'), findsNothing);
  });

  testWidgets('sign in unlocks the workspace and sign out locks it again', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'morgan@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'morgan@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Morgan Lee',
            email: 'morgan@neutralitical.app',
            role: BusinessRole.medicalRepresentative,
          ),
        },
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'morgan@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Medical Representative workspace'), findsOneWidget);
    expect(find.text('Today at a glance'), findsOneWidget);
    expect(find.text('Open Product Catalog'), findsWidgets);

    await tester.tap(find.byTooltip('Sign out'));
    await tester.pumpAndSettle();

    expect(find.text('Secure access'), findsOneWidget);
    expect(find.text('Medical Representative workspace'), findsNothing);
  });

  testWidgets('catalog details still show curated media and allow uploads', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'morgan@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'morgan@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Morgan Lee',
            email: 'morgan@neutralitical.app',
            role: BusinessRole.medicalRepresentative,
          ),
        },
      ),
      productMediaLibraryService: _FakeProductMediaLibraryService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'morgan@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(OutlinedButton, 'Catalog'));
    await tester.pumpAndSettle();

    expect(find.text('Registered product catalog'), findsOneWidget);
    expect(find.text('Signed in as Morgan'), findsOneWidget);
    expect(find.text('With media'), findsOneWidget);

    await tester.tap(find.text('UTIVA-BV PLUS').first);
    await tester.pumpAndSettle();

    expect(find.text('Product media'), findsOneWidget);
    expect(find.text('Women health reference'), findsWidgets);

    await tester.tap(find.text('Upload images or videos').first);
    await tester.pumpAndSettle();

    expect(find.text('Uploaded production shot'), findsOneWidget);
    expect(find.textContaining('uploaded item'), findsWidgets);
  });

  testWidgets('activity updates can be logged from the workspace', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'morgan@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'morgan@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Morgan Lee',
            email: 'morgan@neutralitical.app',
            role: BusinessRole.medicalRepresentative,
          ),
        },
      ),
      activityJournalService: _FakeWorkspaceActivityJournalService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'morgan@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dr. Meera Adhikari follow-up').first);
    await tester.pumpAndSettle();

    expect(find.text('Update status'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).last,
      'Doctor agreed to continue the current regimen and requested a review next week.',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save Update'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsWidgets);
    expect(
      find.textContaining('Doctor agreed to continue the current regimen'),
      findsOneWidget,
    );
    expect(find.textContaining('1 updates'), findsOneWidget);
  });

  testWidgets('new activities can be created from the workspace', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'morgan@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'morgan@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Morgan Lee',
            email: 'morgan@neutralitical.app',
            role: BusinessRole.medicalRepresentative,
          ),
        },
      ),
      activityDraftService: _FakeWorkspaceActivityDraftService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'morgan@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Log Activity').first);
    await tester.pumpAndSettle();

    expect(find.text('Log activity'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Title'),
      'Janaki Medicos order capture',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Summary'),
      'Captured a fresh UTIVA-BV PLUS outlet order and requested stockist dispatch.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Territory'),
      'Terai Retail',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount (optional)'),
      'Rs 26K',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tags (comma separated)'),
      'Retail, Secondary Order',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create Activity'));
    await tester.pumpAndSettle();

    expect(find.text('Janaki Medicos order capture'), findsOneWidget);
    expect(find.textContaining('Rs 26K'), findsOneWidget);
  });

  testWidgets('approved imported leads move into the visible network', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'admin@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'admin@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Avery Stone',
            email: 'admin@neutralitical.app',
            role: BusinessRole.admin,
          ),
        },
      ),
      leadReviewService: _FakeWorkspaceLeadReviewService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Review Import Queue').first);
    await tester.pumpAndSettle();

    expect(find.text('Safe data intake'), findsOneWidget);
    expect(find.text('Approve to Directory'), findsOneWidget);

    await tester.tap(find.text('Approve to Directory').first);
    await tester.pumpAndSettle();

    expect(find.text('Approve to Directory'), findsNothing);
    expect(find.text('Recent review decisions'), findsOneWidget);

    await tester.tap(find.text('Network').first);
    await tester.pumpAndSettle();

    expect(find.text('Outlet verification pending'), findsOneWidget);
    expect(find.text('Trade directory import · reviewed'), findsOneWidget);
  });

  testWidgets('network profiles can launch prefilled follow-up actions', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'morgan@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'morgan@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Morgan Lee',
            email: 'morgan@neutralitical.app',
            role: BusinessRole.medicalRepresentative,
          ),
        },
      ),
      activityDraftService: _FakeWorkspaceActivityDraftService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'morgan@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Network').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dr. Meera Adhikari').first);
    await tester.pumpAndSettle();

    expect(find.text('Quick actions'), findsOneWidget);
    expect(find.text('Log Follow-up'), findsOneWidget);

    await tester.tap(find.text('Log Follow-up').first);
    await tester.pumpAndSettle();

    expect(find.text('Follow-up note'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'UTIVA-BV PLUS'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Products / therapy focus'),
      'MYOBOOST and UTIVA-BV PLUS',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Next step / commitment'),
      'Plan a review visit next Tuesday.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Evidence label'),
      'Call note',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reference / note'),
      'Detailed discussion recorded after the call.',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Next scheduled follow-up (optional)'),
      '25/03/2026 11:30 AM',
    );
    await tester.ensureVisible(find.text('Save Visit Entry').first);
    await tester.tap(find.text('Save Visit Entry').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Follow-up: Dr. Meera Adhikari'), findsOneWidget);

    await tester.tap(find.text('Follow-up: Dr. Meera Adhikari').first);
    await tester.pumpAndSettle();

    expect(find.text('Captured details'), findsOneWidget);
    expect(find.text('Visit date / time'), findsOneWidget);
    expect(find.text('Selected products'), findsOneWidget);
    expect(find.text('UTIVA-BV PLUS'), findsWidgets);
    expect(find.text('Products / therapy focus'), findsOneWidget);
    expect(find.text('MYOBOOST and UTIVA-BV PLUS'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Next scheduled follow-up'), findsOneWidget);
    expect(find.text('25/03/2026 11:30 AM'), findsOneWidget);
    expect(find.text('Plan a review visit next Tuesday.'), findsOneWidget);
    expect(find.text('Evidence / attachments'), findsOneWidget);
    expect(
      find.text('Call note: Detailed discussion recorded after the call.'),
      findsOneWidget,
    );
  });

  testWidgets('trade profiles can launch structured collection workflows', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'admin@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'admin@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Avery Stone',
            email: 'admin@neutralitical.app',
            role: BusinessRole.admin,
          ),
        },
      ),
      activityDraftService: _FakeWorkspaceActivityDraftService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Network').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Omkar Distributors').first);
    await tester.pumpAndSettle();

    expect(find.text('Record Collection'), findsOneWidget);
    await tester.tap(find.text('Record Collection').first);
    await tester.pumpAndSettle();

    expect(find.text('Invoice / account focus'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'UTIVA-BV PLUS'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Invoice / account focus'),
      'April invoice closure with part-payment allocation',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Amount / value'),
      'Rs 120K',
    );
    await tester.tap(find.byKey(const ValueKey('commercial_payment_mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cheque').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('commercial_settlement_type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Full settlement').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Receipt / bank reference'),
      'NEFT-1182',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Evidence label'),
      'Receipt screenshot',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Reference / note'),
      'Shared in finance WhatsApp group',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Next review / due date (optional)'),
      '26/03/2026 04:00 PM',
    );
    await tester.ensureVisible(find.text('Save Collection').first);
    await tester.tap(find.text('Save Collection').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Finance').first);
    await tester.pumpAndSettle();

    expect(
      find.text('Collection update for Omkar Distributors'),
      findsOneWidget,
    );
    expect(find.textContaining('Rs 120K'), findsWidgets);

    await tester.tap(
      find.text('Collection update for Omkar Distributors').first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Captured details'), findsOneWidget);
    expect(find.text('Action date / time'), findsOneWidget);
    expect(find.text('Selected products'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Payment mode'), findsOneWidget);
    expect(find.text('Cheque'), findsWidgets);
    expect(find.text('Settlement type'), findsOneWidget);
    expect(find.text('Full settlement'), findsOneWidget);
    expect(find.text('Next review / due'), findsOneWidget);
    expect(find.text('26/03/2026 04:00 PM'), findsOneWidget);
    expect(find.text('Receipt / bank reference'), findsOneWidget);
    expect(find.text('NEFT-1182'), findsOneWidget);
    expect(
      find.text('Receipt screenshot: Shared in finance WhatsApp group'),
      findsOneWidget,
    );
  });

  testWidgets('trade order workflows can capture repeatable line items', (
    WidgetTester tester,
  ) async {
    await pumpApp(
      tester,
      authRepository: _FakeAuthRepository(
        passwordsByEmail: {'admin@neutralitical.app': 'Passw0rd'},
        usersByEmail: const {
          'admin@neutralitical.app': AuthUser(
            id: '1',
            fullName: 'Avery Stone',
            email: 'admin@neutralitical.app',
            role: BusinessRole.admin,
          ),
        },
      ),
      activityDraftService: _FakeWorkspaceActivityDraftService(),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@neutralitical.app',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Passw0rd');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Network').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Omkar Distributors').first);
    await tester.pumpAndSettle();

    expect(find.text('Capture Order'), findsOneWidget);
    await tester.tap(find.text('Capture Order').first);
    await tester.pumpAndSettle();

    expect(find.text('Line items'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('commercial_line_product_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('UTIVA-BV PLUS').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Products / quantities'),
      'Outlet replenishment batch',
    );
    await tester.enterText(
      find.byKey(const ValueKey('commercial_line_quantity_0')),
      '24 packs',
    );
    await tester.enterText(
      find.byKey(const ValueKey('commercial_line_note_0')),
      'UTIVA-BV PLUS urgent dispatch',
    );
    await tester.tap(find.text('Add SKU'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('commercial_line_quantity_1')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('commercial_line_quantity_1')),
      '12 packs',
    );
    await tester.enterText(
      find.byKey(const ValueKey('commercial_line_rate_1')),
      '315.50',
    );
    await tester.enterText(
      find.byKey(const ValueKey('commercial_line_note_1')),
      'ARGIVIT week-one starter',
    );
    expect(find.text('Estimated order value'), findsOneWidget);
    expect(
      find.textContaining('across 2 SKU lines', skipOffstage: false),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('commercial_payment_terms')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advance against dispatch').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Use estimate'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save Order'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Field Force').first);
    await tester.pumpAndSettle();

    expect(find.text('Order capture for Omkar Distributors'), findsOneWidget);
    await tester.tap(find.text('Order capture for Omkar Distributors').first);
    await tester.pumpAndSettle();

    expect(find.text('Line items'), findsOneWidget);
    expect(find.text('Estimated total'), findsOneWidget);
    expect(find.text('Amount / value'), findsOneWidget);
    expect(find.text('Payment terms'), findsOneWidget);
    expect(find.text('Advance against dispatch'), findsOneWidget);
    expect(find.text('SKU count'), findsOneWidget);
    expect(find.text('Rs 16986.00'), findsWidgets);
    expect(find.textContaining('24 packs'), findsWidgets);
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();
    expect(find.textContaining('12 packs'), findsWidgets);
  });
}
