// Stockist Feature Exports
// Clean Architecture: Domain -> Data -> Presentation

// Domain
export 'domain/models/stockist_models.dart' if (dart.library.io) 'domain/models/stockist_models.dart';

// Data
export 'data/services/stockist_service.dart';

// Presentation
export 'presentation/screens/stockist_dashboard_screen.dart';
export 'presentation/screens/inventory_control_screen.dart';
export 'presentation/screens/order_management_screen.dart';
export 'presentation/providers/stockist_provider.dart';

// Legacy (to be migrated)
// export 'stockist_dashboard.dart'; // DEPRECATED: Use presentation/screens/stockist_dashboard_screen.dart
