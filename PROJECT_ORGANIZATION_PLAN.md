# Project Organization Plan

## Current Issues Identified

### 1. **Inconsistent Naming Conventions**
- Multiple distribution files: `distribution*.ts` (10+ variants)
- Mixed naming patterns: `auth.ts` vs `enhancedAuth.ts`
- Inconsistent file naming: `mr.ts` vs `medical_rep.ts`

### 2. **Poor Directory Structure**
- All routes in single `routes/` directory (33 files)
- No logical grouping by functionality
- Mixed concerns in same directory

### 3. **Duplicate and Redundant Files**
- Multiple distribution implementations
- Duplicate authentication files
- Outdated test files mixed with production code

### 4. **Missing Organization**
- No proper utilities structure
- Poor middleware organization
- No configuration management structure

---

## New Directory Structure

```
backend/
├── src/
│   ├── controllers/           # Route controllers
│   │   ├── auth/
│   │   │   ├── auth.controller.ts
│   │   │   └── session.controller.ts
│   │   ├── distribution/
│   │   │   ├── distribution.controller.ts
│   │   │   ├── inventory.controller.ts
│   │   │   └── order.controller.ts
│   │   ├── marketing/
│   │   │   ├── campaign.controller.ts
│   │   │   ├── lead.controller.ts
│   │   │   └── commission.controller.ts
│   │   ├── analytics/
│   │   │   ├── sales.controller.ts
│   │   │   ├── performance.controller.ts
│   │   │   └── dashboard.controller.ts
│   │   ├── users/
│   │   │   ├── user.controller.ts
│   │   │   ├── doctor.controller.ts
│   │   │   ├── retailer.controller.ts
│   │   │   └── stockist.controller.ts
│   │   └── products/
│   │       ├── product.controller.ts
│   │       └── catalog.controller.ts
│   ├── middleware/             # All middleware
│   │   ├── auth/
│   │   │   ├── authentication.middleware.ts
│   │   │   ├── authorization.middleware.ts
│   │   │   └── rbac.middleware.ts
│   │   ├── validation/
│   │   │   ├── request.validation.middleware.ts
│   │   │   └── schema.validation.middleware.ts
│   │   ├── security/
│   │   │   ├── rate-limit.middleware.ts
│   │   │   ├── cors.middleware.ts
│   │   │   └── audit.middleware.ts
│   │   └── error/
│   │       └── error-handling.middleware.ts
│   ├── services/              # Business logic services
│   │   ├── auth/
│   │   │   ├── auth.service.ts
│   │   │   ├── session.service.ts
│   │   │   └── password.service.ts
│   │   ├── distribution/
│   │   │   ├── distribution.service.ts
│   │   │   ├── inventory.service.ts
│   │   │   └── order.service.ts
│   │   ├── marketing/
│   │   │   ├── campaign.service.ts
│   │   │   ├── lead.service.ts
│   │   │   └── commission.service.ts
│   │   ├── analytics/
│   │   │   ├── sales.service.ts
│   │   │   ├── performance.service.ts
│   │   │   └── dashboard.service.ts
│   │   └── notification/
│   │       └── notification.service.ts
│   ├── models/                # Database models
│   │   ├── user.model.ts
│   │   ├── product.model.ts
│   │   ├── order.model.ts
│   │   ├── campaign.model.ts
│   │   └── index.ts
│   ├── database/              # Database configuration
│   │   ├── connection.ts
│   │   ├── migrations/
│   │   └── seeds/
│   ├── utils/                 # Utility functions
│   │   ├── logger.ts
│   │   ├── validator.ts
│   │   ├── formatter.ts
│   │   ├── constants.ts
│   │   └── helpers.ts
│   ├── config/                # Configuration files
│   │   ├── database.config.ts
│   │   ├── auth.config.ts
│   │   ├── server.config.ts
│   │   └── environment.config.ts
│   ├── types/                 # TypeScript type definitions
│   │   ├── auth.types.ts
│   │   ├── user.types.ts
│   │   ├── product.types.ts
│   │   ├── order.types.ts
│   │   └── common.types.ts
│   ├── routes/                # Route definitions only
│   │   ├── auth.routes.ts
│   │   ├── distribution.routes.ts
│   │   ├── marketing.routes.ts
│   │   ├── analytics.routes.ts
│   │   ├── users.routes.ts
│   │   └── products.routes.ts
│   ├── tests/                 # Test files
│   │   ├── unit/
│   │   ├── integration/
│   │   ├── e2e/
│   │   └── fixtures/
│   └── server.ts              # Main server file
├── docs/                      # Documentation
│   ├── api/
│   ├── database/
│   └── deployment/
├── scripts/                   # Build and deployment scripts
├── logs/                      # Log files
└── temp/                      # Temporary files
```

---

## Naming Conventions

### **File Naming**
- **Controllers**: `*.controller.ts`
- **Services**: `*.service.ts`
- **Middleware**: `*.middleware.ts`
- **Models**: `*.model.ts`
- **Types**: `*.types.ts`
- **Config**: `*.config.ts`
- **Utils**: `*.ts` (simple names like `logger.ts`, `validator.ts`)
- **Routes**: `*.routes.ts`

### **Directory Naming**
- **Lowercase with hyphens**: `auth/`, `distribution/`, `user-management/`
- **Plural for collections**: `controllers/`, `services/`, `models/`
- **Singular for specific**: `auth/`, `config/`, `database/`

### **Function/Variable Naming**
- **CamelCase**: `getUserById`, `calculateCommission`
- **Constants**: `UPPER_SNAKE_CASE`: `MAX_LOGIN_ATTEMPTS`, `DEFAULT_PAGE_SIZE`
- **Classes**: **PascalCase**: `UserService`, `OrderController`
- **Interfaces**: **PascalCase with 'I' prefix**: `IUser`, `IOrder`

### **API Endpoint Naming**
- **RESTful conventions**:
  - `GET /api/users` - List users
  - `GET /api/users/:id` - Get specific user
  - `POST /api/users` - Create user
  - `PUT /api/users/:id` - Update user
  - `DELETE /api/users/:id` - Delete user
- **Nested resources**: `/api/users/:id/orders`
- **Action endpoints**: `/api/orders/:id/cancel`

---

## Migration Strategy

### **Phase 1: Create New Structure**
1. Create new directory structure
2. Set up proper configuration files
3. Create utility and helper files

### **Phase 2: Migrate Core Files**
1. Move and refactor authentication files
2. Organize distribution-related files
3. Restructure marketing and analytics

### **Phase 3: Clean Up**
1. Remove duplicate and obsolete files
2. Update imports and references
3. Update documentation

### **Phase 4: Testing**
1. Ensure all functionality works
2. Run comprehensive tests
3. Update deployment configurations

---

## Benefits of New Structure

### **1. Maintainability**
- Clear separation of concerns
- Logical grouping of related files
- Easy to locate and modify code

### **2. Scalability**
- Modular structure supports growth
- Easy to add new features
- Clear patterns for new development

### **3. Team Collaboration**
- Consistent naming conventions
- Clear ownership of modules
- Reduced merge conflicts

### **4. Code Quality**
- Reduced duplication
- Better organization of business logic
- Easier testing and debugging

---

## Implementation Checklist

- [ ] Create new directory structure
- [ ] Set up configuration management
- [ ] Create utility functions
- [ ] Migrate authentication system
- [ ] Organize distribution modules
- [ ] Restructure marketing system
- [ ] Reorganize analytics system
- [ ] Clean up duplicate files
- [ ] Update all imports
- [ ] Update documentation
- [ ] Test all functionality
- [ ] Update deployment scripts
