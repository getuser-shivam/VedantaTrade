// MR (Medical Representative) Feature Exports

// Domain

// Data
export 'data/services/mr_service.dart' if (dart.library.io) 'data/services/mr_service.dart';

// Presentation
export 'presentation/screens/visit_log_screen.dart';
export 'presentation/screens/tour_plan_screen.dart';
export 'presentation/screens/expense_screen.dart';
export 'presentation/providers/mr_provider.dart';

// Legacy exports
export 'mr_dashboard.dart';
export 'visit_log_screen.dart';
export 'tour_plan_screen.dart';
export 'expense_screen.dart';
