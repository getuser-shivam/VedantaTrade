// Distribution Feature Exports
// Clean Architecture structure

// Domain
export 'domain/entities/distribution_entity.dart';
export 'domain/models/distribution_models.dart';
export 'domain/models/sales_tracking_models.dart';
export 'domain/repositories/distribution_repository.dart';
export 'domain/usecases/distribution_usecases.dart';

// Data
export 'data/services/distribution_service.dart';
export 'data/services/sales_tracking_service.dart';
export 'data/repositories/distribution_repository_impl.dart';

// Presentation
export 'presentation/providers/enhanced_distribution_provider.dart';
export 'presentation/screens/distribution_dashboard_screen.dart';
export 'presentation/screens/distribution_centers_screen.dart';
export 'presentation/screens/inventory_management_screen.dart';
export 'presentation/screens/sales_analytics_dashboard.dart';
export 'presentation/widgets/sales_metrics_card.dart';
export 'presentation/widgets/top_performers_widget.dart';
export 'presentation/widgets/sales_chart_widget.dart';
export 'presentation/widgets/forecast_widget.dart';
