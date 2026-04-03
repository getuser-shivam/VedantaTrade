# VedantaTrade: Enterprise Pharmaceutical Distribution (Nepal)

[![Enhanced CI/CD](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/enhanced-ci-cd.yml/badge.svg)](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/enhanced-ci-cd.yml)
[![Test Automation](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/test-automation.yml/badge.svg)](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/test-automation.yml)
[![Deployment Automation](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/deployment-automation.yml/badge.svg)](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/deployment-automation.yml)
[![Monitoring & Alerting](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/monitoring-alerting.yml/badge.svg)](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/monitoring-alerting.yml)
[![GitHub Pages](https://github.com/getuser-shivam/VedantaTrade/actions/workflows/github-pages.yml/badge.svg)](https://getuser-shivam.github.io/VedantaTrade/)
[![codecov](https://codecov.io/gh/getuser-shivam/VedantaTrade/branch/main/graph/badge.svg)](https://codecov.io/gh/getuser-shivam/VedantaTrade)

🚀 **Production Finalization** | 🇳🇵 **IRDN Compliant** | 📱 **Multi-Role System** | 🎨 **Premium Glassmorphic UI**

VedantaTrade is a hardened, enterprise-grade pharmaceutical distribution platform specifically engineered for the Nepal market. It transforms complex supply chain logistics into a seamless, role-based ecosystem featuring advanced geospatial field force tracking, real-time inventory dynamics, and comprehensive marketing management.

---

## ✨ Latest Features (v3.2.1-alpha)

### 🚀 Comprehensive CI/CD Pipeline
- **Enhanced CI/CD Workflow**: Automated quality checks, testing, and deployment
- **Test Automation Suite**: Unit, widget, integration, E2E, performance, and accessibility tests
- **Deployment Automation**: Multi-platform deployment with rollback capabilities
- **Monitoring & Alerting**: Real-time health checks, performance monitoring, and security scanning
- **Release Management**: Automated version tagging and GitHub releases

### 🛠️ Advanced Development Tools
- **Master Workflow**: Complete development lifecycle management
- **GitHub Automation**: Repository management and release automation
- **Development Workflow**: Day-to-day development tasks and code analysis
- **Code Quality Tools**: Comprehensive linting, formatting, and security scanning

### 🎨 Enhanced UI Components
- **Micro-interactions**: Advanced button animations and user feedback
- **Responsive Design**: Adaptive layouts for all screen sizes
- **Accessibility Widgets**: WCAG compliant components with semantic labels
- **Enhanced Loading**: Multiple loading animations with glassmorphic effects
- **Glassmorphic Design**: Premium UI with consistent branding

### 🔧 Code Quality Improvements
- **Print Statement Cleanup**: All print statements replaced with debugPrint
- **Barrel Export Optimization**: Removed non-existent file references
- **Import Optimization**: Cleaned up unused dependencies
- **Static Analysis**: Reduced lint issues from 2,319+ to 171
- **Production Readiness**: All critical issues resolved

### 🗺️ Geospatial Field Force
- **Background GPS Service**: Continuous MR tracking with persistent storage
- **High-Accuracy Validation**: Mandatory <50m GPS accuracy for visit logging
- **Live Trajectory**: Real-time movement visualization on interactive maps

### 📦 Product & Distribution
- **Product Catalog**: Clean Architecture implementation with category filtering
- **Sales Analytics**: Track product sales by center, campaign, and date
- **Marketing Campaigns**: Create campaigns with product discounts and special pricing
- **Inventory Transfer**: Move stock between distribution centers

### 🎨 Premium UI/UX
- **Page Transitions**: Smooth slide, fade, and scale animations
- **Skeleton Loading**: Perceived performance enhancement
- **Toast Notifications**: Non-intrusive user feedback system
- **Micro-interactions**: Haptic feedback and animated buttons

### 📋 Legal & Compliance
- **Privacy Policy**: Nepal market-compliant with GDPR-style rights
- **Terms of Service**: 6-role specific legal provisions
- **GPS Consent**: Data retention and tracking policies

---

## 🏛️ The 6-Role Architecture
| Role | Responsibility | Key Finalization Modules |
| :--- | :--- | :--- |
| **Admin** | System Governance | Multi-role management & Advanced Analytics |
| **MR** | Field Workforce | Real-time Trajectory mapping & Mandatory GPS |
| **Stockist** | Distribution Hub | SKU-level Inventory & Order Lifecycle management |
| **Retailer** | Pharmacy Point | Real-time Ordering & Statement tracking |
| **Doctor** | Interaction Hub | Product Catalog & Territory coverage |
| **Accountant** | Financial Core | 13% Flat VAT Returns & Expense reconciliation |

---

## 🇳🇵 Nepal Localized Features
*   **VAT Management**: Automated 13% Flat VAT calculation and IRDN-compliant PDF exports.
*   **Currency Support**: Native NPR formatting across all ledgers and invoices.
*   **Janakpur Ecosystem**: Pre-seeded with 2,000+ medical entities for the Dhanusa district.
*   **GPS Hardening**: Mandatory high-accuracy coordinate validation for all field services.

---

## 🧪 Production Stack
*   **Frontend**: Flutter (Provider + GoRouter) with a Slate & Indigo **Glassmorphic** design system.
*   **Backend**: Node.js/TypeScript (Express + Prisma) on **Microsoft SQL Server**.
*   **DevOps**: CI/CD automated release pipeline for APK/AAB and Web distributions.

---

## 🛠️ Developer Workflow (CLI)
VedantaTrade includes a built-in automation orchestration for enterprise maintenance:
```powershell
# Run the Master Workflow for full analysis, fix, and build
dart tools/master_workflow.dart full
```

---

*Current Platform Status: v3.2.0-alpha (Production Hardening - 95% Complete)*
*Live Demo: [https://getuser-shivam.github.io/VedantaTrade/](https://getuser-shivam.github.io/VedantaTrade/)*
*Built with ❤️ for the Nepal Healthcare Community.*
  - Daily dependency vulnerability scanning
  - Code security analysis with Semgrep and CodeQL
  - Container security scanning with Trivy
  - Secrets detection with Gitleaks and TruffleHog
  - Infrastructure security validation
  - Security scoring and badge generation

- **Performance Monitoring** (`.github/workflows/performance.yml`): Real-time performance tracking
  - Flutter performance testing and profiling
  - Backend API performance monitoring
  - Load testing with k6 integration
  - Memory profiling and leak detection
  - Network performance analysis
  - Performance regression detection
  - Automated performance dashboard updates

- **Code Quality** (`.github/workflows/code-quality.yml`): Comprehensive quality assurance
  - Flutter code quality metrics and analysis
  - Backend code quality with ESLint/TypeScript
  - Coverage analysis with threshold enforcement
  - Technical debt analysis and scoring
  - Quality gates with automated validation

#### Development Tools Integration
- **Master Workflow Script** (`tools/master_workflow.dart`): Ultimate development orchestrator
  - Complete development lifecycle management
  - Environment verification and setup
  - Integrated testing and building
  - Automated documentation updates
  - GitHub synchronization
  - Comprehensive error handling and reporting

- **Build Optimization** (`tools/build_helper.dart`): Specialized build automation
  - Multi-platform build configurations
  - Asset optimization and compression
  - Build size analysis and reporting
  - Performance optimization
  - Build manifest generation

- **GitHub Automation** (`tools/github_automation.dart`): Repository management
  - Automated commit message generation
  - Branch management and merging
  - Release and tag creation
  - Documentation updates integration
  - Repository synchronization and cleanup

### 🖼️ Enhanced App Gallery

#### Interactive Features
- **Version Showcase**: Advanced carousel with auto-play and navigation
- **Comparison Tool**: Side-by-side version and feature comparison
- **Advanced Filtering**: Real-time search and filter capabilities
- **Statistics Dashboard**: Gallery metrics and insights
- **Screenshot Management**: Visual history with carousel display
- **Version History**: Complete changelog integration

#### Technical Improvements
- **Performance Optimization**: Smooth animations and transitions
- **Responsive Design**: Optimized for all screen sizes
- **Accessibility**: WCAG compliant components
- **State Management**: Enhanced provider architecture
- **Error Handling**: Comprehensive error recovery

### 📊 Enhanced Distribution Management

#### Dashboard Improvements
- **Real-time Statistics**: Live data updates with trend indicators
- **Quick Actions**: Floating action button for common tasks
- **Recent Activity**: Live activity feed with detailed tracking
- **Responsive Layout**: Mobile, tablet, and desktop optimization
- **Advanced Filtering**: Multi-criteria filtering and search

#### Backend Enhancements
- **API Optimization**: Improved response times and caching
- **Database Performance**: Query optimization and indexing
- **Security Enhancements**: Enhanced authentication and authorization
- **Monitoring**: Real-time system health monitoring

### 🛠️ Development Workflow Automation

#### Local Development
- **Automated Setup**: One-command project initialization
- **Environment Validation**: Automatic Flutter/Node.js version checking
- **Dependency Management**: Automated installation and updates
- **Code Quality**: Real-time linting and formatting
- **Testing**: Integrated test runner with coverage

#### Continuous Integration
- **Multi-Stage Pipeline**: Analysis → Test → Build → Deploy
- **Quality Gates**: Automated quality validation
- **Security Scanning**: Comprehensive vulnerability detection
- **Performance Testing**: Automated performance regression detection
- **Artifact Management**: Build artifact storage and optimization

#### Deployment Automation
- **Environment Management**: Staging and production deployments
- **Health Checks**: Post-deployment validation
- **Rollback Capability**: Automatic rollback on failure
- **Release Management**: Automated GitHub releases
- **Monitoring**: Real-time deployment monitoring

## 🏗️ Repository Structure

```text
.
|-- assets/
|   |-- data/
|   |-- images/
|   |-- screenshots/
|   `-- fonts/
|-- backend/
|   |-- prisma/
|   |-- src/
|   |   |-- controllers/
|   |   |-- middleware/
|   |   |-- routes/
|   |   |-- services/
|   |   `-- tests/
|-- lib/
|   |-- app/
|   |-- core/
|   |-- features/
|   |   |-- auth/
|   |   |-- catalog/
|   |   |-- distribution/
|   |   |-- gallery/
|   |   |-- orders/
|   |   |-- profile/
|   |   `-- reviews/
|   |-- shared/
|   |   |-- theme/
|   |   |-- widgets/
|   |   `-- utils/
|   |-- models/
|   |-- providers/
|   |-- screens/
|   `-- services|
|-- .github/workflows/
|-- docs/
`-- tests/
```

## 🛠 Tech Stack

### Frontend (Flutter)
- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **GoRouter**: Navigation and routing
- **Material Design 3**: Modern UI components
- **Custom Theme System**: Consistent branding

### Backend (Node.js/TypeScript)
- **Express.js**: Web framework
- **Prisma**: Database ORM
- **PostgreSQL**: Database
- **JWT**: Authentication
- **WebSocket**: Real-time updates

### Development Tools
- **GitHub Actions**: CI/CD pipeline
- **ESLint/Prettier**: Code formatting
- **Jest**: Testing framework
- **Docker**: Containerization

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Node.js (>= 18.0.0)
- PostgreSQL
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/your-org/VedantaTrade.git
cd VedantaTrade
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Install backend dependencies**
```bash
cd backend
npm install
```

4. **Setup environment**
```bash
# Copy environment template
cp .env.example .env
# Update with your configuration
```

5. **Setup database**
```bash
cd backend
npx prisma migrate dev
npx prisma generate
```

6. **Run the application**
```bash
# Terminal 1: Backend
cd backend
npm run dev

# Terminal 2: Flutter
flutter run
```

## 📱 App Gallery Usage

The app gallery provides a comprehensive view of the application's evolution:

### Navigation Tabs
- **Carousel**: Featured versions with auto-play
- **Grid View**: All versions in a scrollable grid
- **Compare**: Side-by-side version comparison

### Features
- **Search**: Find versions by name, description, or features
- **Filter**: Filter by features and sort options
- **Statistics**: View gallery metrics and insights
- **Version Details**: Detailed version information with screenshots

### Comparison Tool
- Select any two versions for side-by-side comparison
- View feature differences and similarities
- Compare UI screenshots side by side
- Analyze changelog differences

## 🧪 Testing

### Flutter Tests
```bash
flutter test
flutter test --coverage
```

### Backend Tests
```bash
cd backend
npm test
npm run test:coverage
```

### Integration Tests
```bash
flutter test integration_test/
```

## 📦 Deployment

### Frontend (Flutter Web)
```bash
flutter build web
# Deploy to hosting service
```

### Backend (Production)
```bash
cd backend
npm run build
npm start
```

### Docker Deployment
```bash
docker-compose up -d
```

## 🔄 CI/CD Pipeline

The repository includes automated workflows:

### GitHub Actions
- **CI Pipeline**: Code quality, testing, and building
- **Deployment**: Automated deployment to staging/production
- **Security**: Dependency scanning and vulnerability checks

### Pipeline Stages
1. **Code Analysis**: Linting and formatting checks
2. **Testing**: Unit, integration, and E2E tests
3. **Build**: Application compilation and optimization
4. **Security**: Vulnerability scanning
5. **Deploy**: Automated deployment to target environment

## 📊 Analytics & Monitoring

### Application Metrics
- User engagement and retention
- Performance monitoring
- Error tracking and reporting
- Usage analytics and insights

### Gallery Analytics
- Version view statistics
- Feature popularity tracking
- User interaction patterns
- Screenshot engagement metrics

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow the established naming conventions
- Write comprehensive tests
- Update documentation
- Ensure code quality standards

## 📝 Documentation

- **[API Documentation](./docs/API.md)**: Backend API reference
- **[UI Components](./docs/COMPONENTS.md)**: Custom widget documentation
- **[Database Schema](./docs/DATABASE.md)**: Database structure and relationships
- **[Deployment Guide](./docs/DEPLOYMENT.md)**: Production deployment instructions

## 🐛 Issue Tracking

Report bugs and request features through [GitHub Issues](https://github.com/your-org/VedantaTrade/issues).

### Bug Report Template
- **Description**: Clear description of the issue
- **Steps to Reproduce**: Detailed reproduction steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Environment**: OS, Flutter version, device info

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for valuable contributions
- Vedanta TradeLink team for requirements and feedback

## 📞 Support

For support and questions:
- **Email**: support@vedantatrade.com
- **Documentation**: [docs.vedantatrade.com](https://docs.vedantatrade.com)
- **Community**: [Discord Server](https://discord.gg/vedantatrade)

---

**Built with ❤️ for Vedanta TradeLink**
