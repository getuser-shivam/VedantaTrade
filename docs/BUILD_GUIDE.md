# VedantaTrade Build Guide

This guide provides comprehensive instructions for building, testing, and deploying the VedantaTrade application.

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.16.0+
- Dart SDK 3.2.0+
- Git
- Node.js (for web development tools)
- Android Studio / Xcode (for mobile development)

### Setup
```bash
# Clone the repository
git clone https://github.com/getuser-shivam/VedantaTrade.git
cd VedantaTrade

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 🛠️ Build System

### Build Scripts Location
All build scripts are located in `tools/build_scripts/`:
- `build_analyzer.dart` - Code analysis and reporting
- `build_runner.dart` - Main build orchestrator
- `web_server.dart` - Test web server

### Running Builds

#### Complete Build
```bash
# Run full build process
dart tools/build_scripts/build_runner.dart build
```

#### Individual Commands
```bash
# Analyze code only
dart tools/build_scripts/build_runner.dart analyze

# Run tests only
dart tools/build_scripts/build_runner.dart test

# Clean build artifacts
dart tools/build_scripts/build_runner.dart clean
```

### Build Outputs
Build artifacts are stored in:
- `build/` - Main build directory
- `build/reports/` - Analysis and test reports
- `build/web/` - Web application build
- `build/app/outputs/` - Android APK builds
- `build/ios/` - iOS application builds

## 🧪 Testing

### Test Structure
```
test/
├── unit/           # Unit tests
├── widget/         # Widget tests
├── integration/    # Integration tests
└── reports/        # Test reports
```

### Running Tests

#### All Tests
```bash
flutter test --reporter=expanded
```

#### Specific Test Types
```bash
# Unit tests
flutter test test/unit

# Widget tests
flutter test test/widget

# Integration tests
flutter test test/integration
```

#### Test Coverage
```bash
# Generate coverage report
flutter test --coverage test/unit

# View coverage in browser
genhtml coverage/lcov.info -o coverage/html
```

## 🔍 Code Analysis

### Static Analysis
```bash
# Flutter analyzer
flutter analyze --fatal-infos

# Dart analyzer
dart analyze --fatal-infos

# Custom build analyzer
dart tools/build_scripts/build_analyzer.dart
```

### Analysis Reports
Analysis reports are generated in `build/reports/`:
- `analysis_report.json` - Machine-readable JSON report
- `analysis_report.md` - Human-readable Markdown report

### Analysis Configuration
Analysis is configured in `analysis_options.yaml`:
- Linting rules
- Code style enforcement
- Security checks
- Performance guidelines

## 🏗️ Platform-Specific Builds

### Web Application
```bash
# Build for web
flutter build web --release --web-renderer canvaskit

# Serve locally
dart tools/build_scripts/web_server.dart
```

### Android APK
```bash
# Build APK
flutter build apk --release --shrink

# Build App Bundle
flutter build appbundle --release
```

### iOS Application
```bash
# Build iOS app
flutter build ios --release --no-codesign

# Build with code signing
flutter build ios --release
```

## 🔄 Continuous Integration

### GitHub Actions
The project uses GitHub Actions for automated builds and testing:

#### Workflows
- `build-and-analyze.yml` - Main build and analysis workflow
- `testing.yml` - Comprehensive test suite
- `security.yml` - Security scanning
- `deployment.yml` - Deployment automation

#### Triggers
- Push to main/develop branches
- Pull requests
- Manual workflow dispatch

### Build Status
Build status is shown in README badges:
- CI/CD pipeline status
- Test coverage
- Security scan results
- Deployment status

## 📊 Build Reports

### Report Types
1. **Analysis Report** - Code quality and issues
2. **Test Report** - Test results and coverage
3. **Build Report** - Build status and artifacts
4. **Performance Report** - Application performance metrics

### Viewing Reports
```bash
# Open reports directory
open build/reports/

# View specific report
cat build/reports/analysis_report.md
```

## 🐛 Troubleshooting

### Common Issues

#### Flutter Doctor
```bash
# Check Flutter environment
flutter doctor -v

# Fix common issues
flutter doctor --android-licenses
```

#### Dependency Issues
```bash
# Clean dependencies
flutter clean
flutter pub cache repair
flutter pub get
```

#### Build Issues
```bash
# Clean build
flutter clean
dart tools/build_scripts/build_runner.dart clean

# Rebuild
dart tools/build_scripts/build_runner.dart build
```

#### Test Issues
```bash
# Clean test cache
flutter clean
rm -rf test/reports/

# Run tests with verbose output
flutter test --verbose
```

### Performance Issues

#### Build Performance
- Use `--no-pub` flag to skip pub get
- Enable `--shrink` for release builds
- Use `--tree-shake-icons` for smaller builds

#### Test Performance
- Run specific test types instead of all tests
- Use `--concurrency` flag for parallel test execution
- Exclude integration tests for faster feedback

## 📱 Deployment

### Web Deployment
```bash
# Build web app
flutter build web --release

# Deploy to hosting
# (platform-specific deployment steps)
```

### Mobile Deployment
```bash
# Android
flutter build appbundle --release
# Upload to Google Play Console

# iOS
flutter build ios --release
# Upload to App Store Connect
```

### Environment Configuration
Environment-specific configuration:
- `lib/config/` - Environment settings
- `.env` files - Environment variables
- `firebase_options.dart` - Firebase configuration

## 🔧 Development Tools

### IDE Setup
- **VS Code**: Flutter extension, Dart extension
- **Android Studio**: Flutter plugin
- **IntelliJ IDEA**: Flutter plugin

### Useful Commands
```bash
# Hot reload
flutter run --hot

# Debug mode
flutter run --debug

# Profile mode
flutter run --profile

# Release mode
flutter run --release
```

### Debugging
```bash
# Enable verbose logging
flutter run --verbose

# Debug specific tests
flutter test test/unit/specific_test.dart --verbose

# Debug builds
flutter build apk --debug --verbose
```

## 📈 Performance Optimization

### Build Optimization
- Enable tree shaking
- Use deferred loading
- Optimize assets
- Minimize dependencies

### Runtime Optimization
- Use const constructors
- Optimize widget rebuilds
- Implement lazy loading
- Cache expensive computations

### Memory Optimization
- Dispose controllers and streams
- Use efficient data structures
- Avoid memory leaks
- Profile memory usage

## 🔒 Security

### Security Scanning
```bash
# Run security scan
dart tools/build_scripts/security_scanner.dart

# Check dependencies
flutter pub deps --style=tree
```

### Security Best Practices
- Keep dependencies updated
- Use HTTPS for network requests
- Validate input data
- Secure sensitive information

## 📚 Additional Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Project Architecture Guide](docs/PROJECT_STRUCTURE_GUIDE.md)

### Tools and Libraries
- [Flutter CLI](https://flutter.dev/docs/reference/flutter-cli)
- [Dart CLI](https://dart.dev/tools/dart-tool)
- [Build Tools](tools/build_scripts/)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Dart Community](https://dart.dev/community)
- [GitHub Discussions](https://github.com/getuser-shivam/VedantaTrade/discussions)

---

## 🤝 Contributing

When contributing to VedantaTrade:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the build and test suite
5. Submit a pull request

Ensure all builds pass and tests succeed before submitting a PR.
