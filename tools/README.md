# VedantaTrade Development Tools

This directory contains comprehensive Dart scripts for automating the development workflow of VedantaTrade. These tools provide analysis, building, testing, and GitHub automation capabilities.

## 🛠️ Available Tools

### 1. **dev_workflow.dart** - Main Development Workflow
The primary workflow script that orchestrates all development tasks.

**Usage:**
```bash
dart tools/dev_workflow.dart [command]
```

**Commands:**
- `analyze` - Run code analysis and checks
- `fix` - Run automatic fixes
- `build` - Build application for all platforms
- `test` - Run all tests including coverage
- `deploy` - Deploy application
- `version` - Version control operations
- `docs` - Update all documentation
- `gallery` - Update app gallery
- `all` - Run complete workflow
- `init` - Initialize new project
- `status` - Show project status
- `help` - Show help message

**Features:**
- Flutter code analysis with issue detection
- Automatic dependency management
- Code formatting and linting
- Security vulnerability scanning
- Build optimization and size analysis
- Comprehensive error handling

---

### 2. **build_helper.dart** - Build Optimization Helper
Specialized tool for building and optimizing application artifacts.

**Usage:**
```bash
dart tools/build_helper.dart [command] [config]
```

**Commands:**
- `build [config]` - Build specific configuration
- `build-all` - Build all configurations
- `analyze` - Analyze build performance
- `summary` - Create build summary

**Build Configurations:**
- `debug` - Debug build with full symbols
- `profile` - Profile build for performance analysis
- `release` - Release build with optimizations
- `web` - Web build for deployment
- `apk` - Android APK build
- `ios` - iOS build for App Store

**Features:**
- Multi-platform build support
- Asset optimization and compression
- Build size analysis
- Performance optimization
- Build manifest generation

---

### 3. **github_automation.dart** - GitHub Repository Automation
Comprehensive Git and GitHub automation tool for version control and repository management.

**Usage:**
```bash
dart tools/github_automation.dart [command] [options]
```

**Commands:**
- `init` - Initialize Git repository
- `status` - Show repository status
- `commit [message]` - Commit changes with optional message
- `push` - Push changes to remote
- `pull` - Pull changes from remote
- `branch [name]` - Manage branches
- `release [version]` - Create release
- `tag [name]` - Create tag
- `merge [branch]` - Merge branches
- `changelog` - Update CHANGELOG.md
- `readme` - Update README.md
- `todo` - Update TODO.md
- `appgallery` - Update app gallery
- `sync` - Synchronize repository
- `cleanup` - Clean repository
- `all` - Run full Git workflow

**Features:**
- Automated commit message generation
- Branch management and merging
- Release and tag creation
- Documentation updates
- Repository synchronization
- Cleanup and maintenance

---

### 4. **master_workflow.dart** - Master Workflow Orchestrator
The ultimate workflow script that integrates all development tools and processes.

**Usage:**
```bash
dart tools/master_workflow.dart [command] [options]
```

**Commands:**
- `dev` - Run development workflow (analysis + dev server)
- `build` - Run build workflow (clean + build + optimize)
- `test` - Run test workflow (unit + integration + widget + coverage)
- `deploy` - Run deployment workflow (build + test + deploy)
- `release [version]` - Run release workflow (version + build + test + deploy)
- `analyze` - Run analysis workflow (code + security + performance + deps)
- `docs` - Run documentation workflow (readme + changelog + todo + gallery)
- `gallery` - Run gallery workflow (screenshots + data + validation)
- `status` - Show project status and environment info
- `clean` - Clean project (build cache + temp files)
- `setup` - Initial project setup
- `all` - Run complete workflow (all phases)
- `help` - Show help message

**Features:**
- Complete development lifecycle management
- Environment verification and setup
- Integrated testing and building
- Automated documentation updates
- GitHub synchronization
- Comprehensive reporting

---

## 🚀 Quick Start Guide

### 1. **Initial Setup**
```bash
# Initialize project
dart tools/master_workflow.dart setup

# Install dependencies
dart tools/master_workflow.dart dev

# Run analysis
dart tools/master_workflow.dart analyze
```

### 2. **Daily Development**
```bash
# Start development server
dart tools/master_workflow.dart dev

# Run tests
dart tools/master_workflow.dart test

# Build application
dart tools/master_workflow.dart build
```

### 3. **Release Process**
```bash
# Complete workflow
dart tools/master_workflow.dart all

# Create release
dart tools/master_workflow.dart release 2.1.0
```

### 4. **Gallery Management**
```bash
# Update app gallery
dart tools/master_workflow.dart gallery

# Update documentation
dart tools/master_workflow.dart docs
```

## 📊 Workflow Integration

### **Development Pipeline**
```
Environment Check → Dependencies Install → Code Analysis → Development Server
                ↓
                ↓
            Testing ← Building ← Documentation Updates
                ↓
                ↓
            GitHub Synchronization ← Deployment
```

### **Release Pipeline**
```
Pre-Release Checks → Build Artifacts → Full Test Suite → Documentation Updates
                ↓
                ↓
            Git Release ← Deployment ← Post-Release Verification
```

## 🔧 Configuration

### **Environment Variables**
All tools respect the following environment variables:

- `FLUTTER_PATH` - Path to Flutter SDK (default: 'flutter')
- `GIT_PATH` - Path to Git (default: 'git')
- `PROJECT_ROOT` - Project root directory (default: current directory)

### **Configuration Files**
- `tools/config.json` - Global tool configuration
- `build/config.json` - Build-specific configuration
- `github/config.json` - GitHub automation configuration

## 📋 Generated Files

### **Build Artifacts**
- `build/debug/` - Debug builds
- `build/profile/` - Profile builds
- `build/release/` - Release builds
- `build/web/` - Web builds
- `build/apk/` - Android APKs
- `build/ios/` - iOS builds

### **Reports**
- `build/build_report.json` - Build analysis report
- `build/size_report.json` - Build size analysis
- `build/summary.json` - Build summary
- `test/coverage/` - Test coverage reports
- `analysis/` - Code analysis reports

### **Documentation**
- `README.md` - Project documentation (auto-generated)
- `CHANGELOG.md` - Version history (auto-updated)
- `TODO.md` - Task tracking (auto-updated)
- `docs/API.md` - API documentation (auto-generated)

## 🛡️ Error Handling

All tools implement comprehensive error handling:

1. **Graceful Degradation**: Tools continue with reduced functionality if non-critical errors occur
2. **Detailed Logging**: All errors are logged with context and suggestions
3. **Recovery Mechanisms**: Automatic cleanup and state recovery
4. **User Feedback**: Clear error messages and actionable suggestions

## 🎯 Best Practices

### **Code Quality**
- All tools follow Dart/Flutter best practices
- Comprehensive error handling and logging
- Type safety and null safety
- Performance optimization

### **Automation**
- Idempotent operations (safe to run multiple times)
- Atomic transactions (all or nothing)
- Rollback capabilities for failed operations
- Progress indicators for long-running operations

### **Security**
- No hardcoded secrets or credentials
- Secure file handling with proper permissions
- Input validation and sanitization
- Security scanning and vulnerability detection

## 🔍 Troubleshooting

### **Common Issues**

**Flutter Command Not Found**
```bash
# Add Flutter to PATH
export PATH="$PATH:/path/to/flutter/bin"

# Or use full path
dart tools/dev_workflow.dart --flutter-path /path/to/flutter/bin/flutter
```

**Git Authentication Issues**
```bash
# Configure Git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Or use SSH keys
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

**Build Failures**
```bash
# Clean build cache
dart tools/dev_workflow.dart clean

# Check Flutter doctor
flutter doctor -v

# Update dependencies
dart tools/dev_workflow.dart fix
```

### **Getting Help**

Each tool includes comprehensive help documentation:

```bash
dart tools/dev_workflow.dart help
dart tools/build_helper.dart help
dart tools/github_automation.dart help
dart tools/master_workflow.dart help
```

## 📈 Performance Metrics

The tools track and report various performance metrics:

- **Build Times**: Time taken for each build configuration
- **Test Coverage**: Line and branch coverage percentages
- **Bundle Sizes**: Application size analysis
- **Git Operations**: Commit and push performance
- **Error Rates**: Success/failure ratios for operations

## 🔄 Continuous Integration

These tools are designed to work seamlessly with CI/CD pipelines:

### **GitHub Actions**
```yaml
name: VedantaTrade CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: dart tools/master_workflow.dart test
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: dart tools/master_workflow.dart build
```

### **Local Development**
```bash
# Watch mode for continuous development
dart tools/master_workflow.dart dev --watch

# Auto-commit on changes
dart tools/github_automation.dart sync --auto
```

## 🤝 Contributing

When contributing to the tools:

1. **Follow Dart Conventions**: Use proper naming, typing, and documentation
2. **Add Tests**: Include unit tests for new functionality
3. **Update Documentation**: Keep help strings and README files current
4. **Error Handling**: Implement comprehensive error handling
5. **Performance**: Consider performance implications of changes

## 📄 License

These development tools are part of the VedantaTrade project and follow the same license terms.

---

**For detailed usage instructions, run any tool with the `help` command.**
