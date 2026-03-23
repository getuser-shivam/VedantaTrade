import 'package:flutter/material.dart';

import 'neutralitical_brand.dart';
import '../features/auth/data/services/auth_repository.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/screens/auth_screen.dart';
import '../features/catalog/data/services/product_catalog_service.dart';
import '../features/catalog/data/services/product_media_library_service.dart';
import '../features/workspace/data/services/workspace_activity_draft_service.dart';
import '../features/workspace/data/services/workspace_activity_journal_service.dart';
import '../features/workspace/data/services/workspace_lead_review_service.dart';
import '../features/workspace/data/services/workspace_service.dart';
import '../features/workspace/presentation/screens/workspace_screen.dart';

class NeutraliticalApp extends StatelessWidget {
  const NeutraliticalApp({
    super.key,
    this.productCatalogService,
    this.productMediaLibraryService,
    this.authRepository,
    this.workspaceService,
    this.activityJournalService,
    this.activityDraftService,
    this.leadReviewService,
  });

  final ProductCatalogService? productCatalogService;
  final ProductMediaLibraryService? productMediaLibraryService;
  final AuthRepository? authRepository;
  final WorkspaceService? workspaceService;
  final WorkspaceActivityJournalService? activityJournalService;
  final WorkspaceActivityDraftService? activityDraftService;
  final WorkspaceLeadReviewService? leadReviewService;

  @override
  Widget build(BuildContext context) {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: NeutraliticalBrand.forest,
      onPrimary: Colors.white,
      secondary: NeutraliticalBrand.gold,
      onSecondary: NeutraliticalBrand.ink,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: NeutraliticalBrand.cream,
      onSurface: NeutraliticalBrand.ink,
    );

    return MaterialApp(
      title: 'Neutralitical',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: NeutraliticalBrand.cream,
        cardColor: Colors.white,
        dividerColor: NeutraliticalBrand.sand,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: NeutraliticalBrand.sand),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: NeutraliticalBrand.sand),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: NeutraliticalBrand.forest,
              width: 1.4,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: NeutraliticalBrand.forest,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: NeutraliticalBrand.gold,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: NeutraliticalBrand.ink,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        useMaterial3: true,
      ),
      home: _NeutraliticalHome(
        productCatalogService:
            productCatalogService ?? const AssetProductCatalogService(),
        productMediaLibraryService:
            productMediaLibraryService ?? LocalProductMediaLibraryService(),
        authRepository: authRepository ?? LocalAuthRepository(),
        workspaceService: workspaceService ?? const AssetWorkspaceService(),
        activityJournalService:
            activityJournalService ?? LocalWorkspaceActivityJournalService(),
        activityDraftService:
            activityDraftService ?? LocalWorkspaceActivityDraftService(),
        leadReviewService:
            leadReviewService ?? LocalWorkspaceLeadReviewService(),
      ),
    );
  }
}

class _NeutraliticalHome extends StatefulWidget {
  const _NeutraliticalHome({
    required this.productCatalogService,
    required this.productMediaLibraryService,
    required this.authRepository,
    required this.workspaceService,
    required this.activityJournalService,
    required this.activityDraftService,
    required this.leadReviewService,
  });

  final ProductCatalogService productCatalogService;
  final ProductMediaLibraryService productMediaLibraryService;
  final AuthRepository authRepository;
  final WorkspaceService workspaceService;
  final WorkspaceActivityJournalService activityJournalService;
  final WorkspaceActivityDraftService activityDraftService;
  final WorkspaceLeadReviewService leadReviewService;

  @override
  State<_NeutraliticalHome> createState() => _NeutraliticalHomeState();
}

class _NeutraliticalHomeState extends State<_NeutraliticalHome> {
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _authController = AuthController(authRepository: widget.authRepository)
      ..restoreSession();
  }

  @override
  void dispose() {
    _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, child) {
        if (_authController.isInitializing) {
          return const _AuthLoadingScreen();
        }

        if (!_authController.isAuthenticated) {
          return AuthScreen(authController: _authController);
        }

        final user = _authController.currentUser!;
        return WorkspaceScreen(
          currentUser: user,
          workspaceService: widget.workspaceService,
          activityJournalService: widget.activityJournalService,
          activityDraftService: widget.activityDraftService,
          leadReviewService: widget.leadReviewService,
          productCatalogService: widget.productCatalogService,
          productMediaLibraryService: widget.productMediaLibraryService,
          onSignOut: _authController.signOut,
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                borderRadius: BorderRadius.circular(28),
                child: Image.asset(
                  NeutraliticalBrand.markAsset,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
              const SizedBox(height: 18),
              Text(
                'Restoring Neutralitical...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: NeutraliticalBrand.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
