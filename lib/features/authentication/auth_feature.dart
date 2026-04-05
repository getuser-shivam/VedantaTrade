// Authentication Feature Exports
// Clean Architecture structure

// Domain
export 'domain/entities/user_entity.dart';
export 'domain/repositories/auth_repository.dart';
export 'domain/usecases/login_usecase.dart';
export 'domain/usecases/logout_usecase.dart';
export 'domain/usecases/register_usecase.dart';

// Data
export 'data/models/user_model.dart';
export 'data/repositories/auth_repository_impl.dart';
export 'data/services/auth_service.dart';

// Presentation
export 'presentation/providers/auth_provider.dart';
export 'presentation/providers/enhanced_auth_provider.dart';
export 'presentation/screens/auth_screen.dart';
export 'presentation/screens/login_screen.dart';
export 'presentation/screens/register_screen.dart';
export 'presentation/screens/enhanced_auth_screen.dart';
export 'presentation/screens/biometric_auth_screen.dart';
export 'presentation/screens/password_reset_screen.dart';
export 'presentation/widgets/auth_widgets.dart';
