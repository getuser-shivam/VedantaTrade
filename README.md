# VedantaTrade: Enterprise Pharma Trade Management Platform

Welcome to the **VedantaTrade** repository. This is the master technical document for the enterprise-grade pharmaceutical distribution and management platform.

---

## 🚀 **Platform Overview**

**VedantaTrade** (v3.7.0-beta) is a full-stack ecosystem designed for the pharmaceutical trade in Nepal. It integrates ERP, accounting, inventory management, and field force tracking into a single, unified platform.

- **Current Milestone:** Infrastructure Hardening & Premium UI.
- **Key Focus:** IRDN Compliance (Nepal VAT), Real-time Logistics, and Field Force Efficiency.

---

## 🛠️ **Technology Stack**

VedantaTrade leverages a modern, scalable stack to ensure performance across all layers.

### **Frontend (Mobile/Web/Tablet)**
- **Framework:** [Flutter](https://flutter.dev/) (>=3.0.0)
- **Language:** Dart
- **Architecture:** Clean Architecture (Data, Domain, Presentation)
- **State Management:** Provider
- **Navigation:** Go Router
- **UI:** Material 3 + Premium Glassmorphic Design

### **Backend (API)**
- **Runtime:** Node.js with TypeScript
- **Framework:** Express.js
- **ORM:** [Prisma](https://www.prisma.io/)
- **Protocol:** RESTful API + WebSockets (Socket.io)
- **Security:** JWT + bcrypt + MFA (Speakeasy)

### **Database (SQL Server)**
- **Engine:** Microsoft SQL Server
- **Schema:** Comprehensive relational model for ERP/CRM/Logistics.

---

## 📋 **Unified Master TODO List**

This list organizes the path to production-ready status across the entire stack.

### 🔴 **High Priority (Core Infrastructure)**
- [x] **Dart (Flutter):**
  - Consolidated redundant features into unified modules (`authentication`, `product_catalog`, `accounting`).
  - Integrated robust product catalog with advanced filtering and enterprise-grade data models.
  - Finalized Clean Architecture implementation across the entire `lib/features` directory.
- [ ] **NodeJS/Prisma:**
  - Resolve Prisma engine locks during background process execution.
  - Hardened API validation for all 13% Flat VAT calculations.
- [ ] **SQL (Database):**
  - Fix unique constraints on user/profile relational tables.
  - Optimize indexing for large-scale inventory lookups.

### 🟠 **Medium Priority (Business Logic)**
- [ ] **Real-time Logistics:**
  - Complete WebSocket implementation for live order status updates.
  - Implement GPS-validated checkout for Stockist-to-Retailer delivery.
- [ ] **Compliance:**
  - Finalize IRDN-compliant PDF export functionality for Tax Reports (NPR/VAT).
- [ ] **Scraper System:**
  - Optimize the Playwright-based lead scraper for multi-city processing.

### 🟡 **Low Priority (UX & Optimization)**
- [x] **App Gallery:**
  - Synchronize UI evolution showcase with v3.7.0-beta features.
- [ ] **Performance:**
  - Implement hardware-level GPS validation for Field Force visits.
  - Implement intelligent caching for product catalog images.

---

## 🏗️ **Project Structure**

We follow a strict **Clean Architecture** and **Feature-Based** organization.

### **Backend (`/backend`)**
```text
backend/
├── prisma/             # Prisma schema and migrations
├── src/
│   ├── routes/         # Express API route definitions
│   ├── middleware/      # Auth, Logging, Error handlers
│   ├── services/       # Business logic (ERP, Scraping, Email)
│   └── server.ts       # Application entry point
```

### **Frontend (`/lib`)**
```text
lib/
├── app/                # Global config (Router, Theme, Constants)
├── core/               # Shared utilities (Network, Storage, Lints)
├── features/           # Modular business features
│   ├── authentication/ # JWT, Biometrics, MFA
│   ├── product_catalog/# Search, Filter, Stockist views
│   └── field_force/    # Visit logs, GPS, MR Targets
└── shared/             # Reusable UI components (Glassmorphism)
```

---

## 📊 **Database Architecture**

The database manages complex relationships across several core domains:
- **ERP/Accounting:** Chart of Accounts, Journal Entries, Tax Transactions.
- **Supply Chain:** Inventory Items, Batches, Purchase/Sales Orders.
- **CRM:** Users (Doctors, MRs, Stockists, Retailers) and Visit Tracking.
- **Logistics:** Distribution Centers, Routes, and Order Sequencing.

---

## ⚙️ **Quick Start**

### **Prerequisites**
- Flutter SDK (>=3.0)
- Node.js (>=18) & npm/pnpm
- Microsoft SQL Server Instance

### **Setup Development**
1. **Backend:**
   ```bash
   cd backend
   npm install
   npx prisma generate
   npm run dev
   ```
2. **Frontend:**
   ```bash
   flutter pub get
   flutter run
   ```

---

## 🔐 **Documentation Pillars**
- [Changelog](file:///i:/Path/Projects/VedantaTrade/CHANGELOG.md) - Version history and release notes.
- [Privacy Policy](file:///i:/Path/Projects/VedantaTrade/PRIVACY_POLICY.md) - Data protection standards.
- [Terms of Service](file:///i:/Path/Projects/VedantaTrade/TERMS_OF_SERVICE.md) - Platform usage terms.

---
*Last Updated: April 6, 2026*
*Current Version: v3.7.0-beta*
