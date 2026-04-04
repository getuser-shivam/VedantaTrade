# VedantaTrade - Project Structure Reorganization Script

## 🎯 Reorganization Plan

### Phase 1: Complete Auth Feature
1. Move domain models to entities
2. Create use case files
3. Create repository interfaces
4. Update presentation layer naming
5. Update all import statements

### Phase 2: Catalog Feature
1. Apply same reorganization pattern
2. Update naming conventions
3. Update import statements

### Phase 3: High-Priority Features
1. Orders
2. Distribution
3. Marketing
4. Profile

### Phase 4: Remaining Features
1. Accounting
2. Admin
3. Reviews
4. Cart

## 🏗️ Standard Structure Template

For each feature:
```
features/[feature_name]/
├── domain/
│   ├── entities/           # Domain entities
│   ├── repositories/       # Repository interfaces
│   ├── usecases/          # Business use cases
│   └── models/            # Domain models
├── data/
│   ├── datasources/       # Data sources
│   ├── repositories/       # Repository implementations
│   ├── models/            # Data models
│   └── services/          # External services
└── presentation/
    ├── pages/             # Screen pages
    ├── widgets/           # Feature widgets
    ├── providers/         # State management
    └── screens/          # Screen implementations
```

## 📝 Naming Convention Rules

### Files:
- Entities: `snake_case_entity.dart`
- Models: `snake_case_model.dart`
- Use Cases: `snake_case_usecase.dart`
- Repositories: `snake_case_repository.dart`
- Screens: `snake_case_screen.dart`
- Widgets: `snake_case_widget.dart`
- Providers: `snake_case_provider.dart`

### Classes:
- Entities: `PascalCaseEntity`
- Models: `PascalCaseModel`
- Use Cases: `PascalCaseUseCase`
- Repositories: `PascalCaseRepository`
- Screens: `PascalCaseScreen`
- Widgets: `PascalCaseWidget`
- Providers: `PascalCaseProvider`

## 🚀 Implementation Commands

### Auth Feature Reorganization:
```powershell
# Create directories
New-Item -ItemType Directory -Path "lib\features\auth\domain\entities" -Force
New-Item -ItemType Directory -Path "lib\features\auth\domain\repositories" -Force
New-Item -ItemType Directory -Path "lib\features\auth\domain\usecases" -Force

# Move files
Move-Item "lib\features\auth\domain\models\user.dart" "lib\features\auth\domain\entities\user_entity.dart" -Force

# Create use case files
# New-Item -ItemType File -Path "lib\features\auth\domain\usecases\login_usecase.dart" -Force
# New-Item -ItemType File -Path "lib\features\auth\domain\usecases\register_usecase.dart" -Force
# New-Item -ItemType File -Path "lib\features\auth\domain\usecases\logout_usecase.dart" -Force

# Create repository interfaces
# New-Item -ItemType File -Path "lib\features\auth\domain\repositories\auth_repository.dart" -Force
```

### Catalog Feature Reorganization:
```powershell
# Create directories
New-Item -ItemType Directory -Path "lib\features\catalog\domain\entities" -Force
New-Item -ItemType Directory -Path "lib\features\catalog\domain\repositories" -Force
New-Item -ItemType Directory -Path "lib\features\catalog\domain\usecases" -Force

# Move files
Move-Item "lib\features\catalog\domain\models\product.dart" "lib\features\catalog\domain\entities\product_entity.dart" -Force
```

## 📋 Progress Tracking

### Completed:
- ✅ Core directory structure created
- ✅ Auth feature domain structure created
- ✅ User entity moved and renamed

### In Progress:
- 🔄 Auth feature reorganization
- 🔄 Catalog feature reorganization

### Next Steps:
- ⏳ Complete auth feature
- ⏳ Reorganize catalog feature
- ⏳ Update import statements
- ⏳ Test compilation

## ⚠️ Important Notes

1. **Backup**: Always backup before major changes
2. **Test**: Test compilation after each feature
3. **Imports**: Update all import statements
4. **Documentation**: Keep documentation updated
5. **Consistency**: Apply same pattern to all features

## 🎯 Success Metrics

- [ ] All features follow domain/data/presentation structure
- [ ] All files follow naming conventions
- [ ] All imports updated and working
- [ ] App compiles successfully
- [ ] Documentation updated
- [ ] Team trained on new structure
