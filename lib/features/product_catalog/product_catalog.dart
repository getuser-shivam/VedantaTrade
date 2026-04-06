library product_catalog;

// Domain & Filter Layer (Consolidated)
export 'domain/entities/product_filter_entity.dart';

// Data Layer (Unified Model & Service)
export 'data/models/product_model.dart';
export 'data/services/product_catalog_service.dart';

// Presentation Layer (Consolidated Screens & Providers)
export 'presentation/providers/product_catalog_provider.dart';
export 'presentation/screens/product_catalog_screen.dart';
export 'presentation/screens/product_detail_screen.dart';

// Reusable Components
export 'presentation/widgets/enhanced_product_card.dart';
export 'presentation/widgets/enhanced_search_filter_bar.dart';
export 'presentation/widgets/category_chips.dart';
export 'presentation/widgets/product_detail_sheet.dart';
