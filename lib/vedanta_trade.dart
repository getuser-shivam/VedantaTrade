// VedantaTrade Project Structure Organization
// This file contains barrel exports for organized imports

// Core app configuration
export 'app/app.dart';
export 'app/router/app_router.dart';
export 'app/theme/app_theme.dart';

// Core utilities and services
export 'core/api_config.dart';
export 'core/constants/app_constants.dart';
export 'core/constants/route_constants.dart';
export 'core/services/storage_service.dart';
export 'core/services/network_service.dart';
export 'core/utils/date_utils.dart';
export 'core/utils/validation_utils.dart';
export 'core/utils/format_utils.dart';

// Global data models
export 'data/models/user_model.dart';
export 'data/models/response_model.dart';
export 'data/repositories/user_repository.dart';

// Feature modules
export 'features/auth/enhanced_auth.dart';
export 'features/catalog/enhanced_catalog.dart';
export 'features/distribution/distribution_management.dart';
export 'features/mr/visit_log_management.dart';
export 'features/stockist/inventory_management.dart';
export 'features/retailer/order_management.dart';
export 'features/doctor/prescription_management.dart';
export 'features/accountant/financial_management.dart';
export 'features/admin/system_management.dart';

// Shared components
export 'shared/app_scaffold.dart';
export 'shared/theme/premium_glassmorphic_theme.dart';
export 'shared/theme/theme_extensions.dart';
export 'shared/ui/buttons/primary_button.dart';
export 'shared/ui/buttons/secondary_button.dart';
export 'shared/ui/buttons/glassmorphic_button.dart';
export 'shared/ui/cards/product_card.dart';
export 'shared/ui/cards/user_card.dart';
export 'shared/ui/cards/analytics_card.dart';
export 'shared/ui/dialogs/confirmation_dialog.dart';
export 'shared/ui/dialogs/error_dialog.dart';
export 'shared/widgets/glassmorphic_widgets.dart';
export 'shared/widgets/common_widgets.dart';
