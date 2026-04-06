# VedantaTrade Project Architecture

This document outlines the standardized, scalable directory structure and Clean Architecture principles used in the VedantaTrade project.

## Development Standards
- **Naming Convention**: `snake_case` for files and directories (Flutter), `camelCase` for directories (Backend src).
- **Organization**: Features are logically grouped into business domains.
- **Independence**: Features should be as decoupled as possible, communicating through shared domains or events.

---

## 1. Frontend (Flutter) Structure

The frontend follows the **Clean Architecture + Provider/Cubit** pattern.

### Root Structure
```text
lib/
├── app/                # Application-wide configuration
│   ├── config/         # Environment constants, global config
│   ├── theme/          # AppTheme, text styles, colors
│   └── routes/         # Navigation (GoRouter or Modular)
├── core/               # Shared logic across features
│   ├── error/          # Exceptions and Failure mappings
│   ├── network/        # API clients (Dio), network info
│   ├── usecases/       # Base usecase contract
│   ├── utils/          # Formatters, validators, extensions
│   └── widgets/        # Universal UI components (Buttons, Inputs)
├── features/           # BUSINESS DOMAINS (Primary workspace)
│   └── [feature_name]/
│       ├── data/       # Implementation details
│       │   ├── datasources/  # Remote/Local DB implementations
│       │   ├── models/       # Data transfer objects (JSON map)
│       │   ├── repositories/ # Repository implementation
│       │   └── services/     # Feature-specific API clients
│       ├── domain/     # Pure business logic (Infrastructure-free)
│       │   ├── entities/     # Plain Dart business objects
│       │   ├── repositories/ # Repository contracts (Interfaces)
│       │   └── usecases/     # Executable business logic
│       └── presentation/ # UI and State Management
│           ├── pages/        # High-level screen scaffolds
│           ├── providers/    # State management (Provider/Cubit)
│           ├── states/       # State definitions
│           └── widgets/      # Screen-specific atomic UI
└── shared/             # Shared entities across features
    ├── domain/         # Shared entities (User, Product)
    └── presentation/   # Shared UI (Nav bars, Loading screens)
```

---

## 2. Backend (Node.js/Prisma) Structure

The backend follows a **Service-Repository** pattern for high scalability.

### Structure
```text
backend/
├── prisma/             # Database orchestration
│   └── schema.prisma   # Single source of truth for DB
└── src/
    ├── config/         # Security (JWT), ENV, Database init
    ├── controllers/    # Express/Fastify request handlers
    │   └── [module]/   # Grouped by business domain
    ├── middleware/     # Auth checks, logging, error handlers
    ├── services/       # Core business logic (Prisma calls)
    │   └── [module]/   # Logic isolated by domain
    ├── repositories/   # Optional: DB abstraction layer
    ├── types/          # TypeScript interfaces/enums
    └── utils/          # Shared helpers (Logger, Mailer)
```

## 3. Implementation Workflow
1.  **Define Schema**: Update `schema.prisma`.
2.  **Logic First**: Create `Domain Entities` and `Repository Contracts`.
3.  **Data Implementation**: Create `Models` and `RepositoryImpl`.
4.  **Backend implementation**: Build `Service` then `Controller`.
5.  **State management**: Build `Provider/States` in the UI.
6.  **Presentation**: Build the final `Pages` and `Widgets`.
