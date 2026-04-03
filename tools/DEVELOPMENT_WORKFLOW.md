# VedantaTrade - Development Workflow Automation

This document outlines automated workflows and scripts for maintaining project structure and code quality.

---

## 🔄 **Automated Structure Validation**

### **Directory Structure Checker**
```bash
# tools/scripts/check_structure.sh
#!/bin/bash

echo "🔍 Checking VedantaTrade project structure..."

# Define expected directories
EXPECTED_DIRS=(
    "lib/app"
    "lib/core"
    "lib/data"
    "lib/features"
    "lib/shared"
    "test/unit"
    "test/widget"
    "test/integration"
    "test/e2e"
    "docs"
    "tools"
)

# Check if directories exist
for dir in "${EXPECTED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir exists"
    else
        echo "❌ $dir missing - creating..."
        mkdir -p "$dir"
    fi
done

# Check feature structure
FEATURES_DIR="lib/features"
if [ -d "$FEATURES_DIR" ]; then
    for feature in "$FEATURES_DIR"/*; do
        if [ -d "$feature" ]; then
            feature_name=$(basename "$feature")
            echo "🔍 Checking $feature_name feature structure..."
            
            # Check required subdirectories
            REQUIRED_SUBDIRS=("domain" "data" "presentation")
            for subdir in "${REQUIRED_SUBDIRS[@]}"; do
                if [ ! -d "$feature/$subdir" ]; then
                    echo "❌ $feature_name/$subdir missing - creating..."
                    mkdir -p "$feature/$subdir"
                fi
            done
        fi
    done
fi

echo "✅ Structure validation completed"
```

### **Naming Convention Validator**
```bash
# tools/scripts/validate_naming.sh
#!/bin/bash

echo "🔍 Validating file naming conventions..."

# Function to check file naming
check_file_naming() {
    local directory=$1
    local pattern=$2
    local description=$3
    
    echo "🔍 Checking $description in $directory..."
    
    # Find files that don't match the pattern
    find "$directory" -name "*.dart" -not -path "*/.*" | while read file; do
        filename=$(basename "$file")
        if [[ ! "$filename" =~ $pattern ]]; then
            echo "⚠️  Invalid naming: $filename (should match: $pattern)"
        fi
    done
}

# Check different directories
check_file_naming "lib/features/*/presentation/screens" "^[a-z_]+_screen\.dart$" "Screen files"
check_file_naming "lib/features/*/presentation/providers" "^[a-z_]+_provider\.dart$" "Provider files"
check_file_naming "lib/features/*/data/models" "^[a-z_]+_model\.dart$" "Model files"
check_file_naming "lib/features/*/data/services" "^[a-z_]+_service\.dart$" "Service files"

echo "✅ Naming convention validation completed"
```

---

## 🛠️ **Code Generation Tools**

### **Feature Generator Script**
```bash
# tools/scripts/generate_feature.sh
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./generate_feature.sh <feature_name>"
    echo "Example: ./generate_feature.sh user_management"
    exit 1
fi

FEATURE_NAME=$1
FEATURE_DIR="lib/features/$FEATURE_NAME"

echo "🏗️  Generating feature: $FEATURE_NAME"

# Create feature directory structure
mkdir -p "$FEATURE_DIR"/{domain/{entities,repositories,usecases},data/{models,repositories,services,datasources/{local,remote}},presentation/{providers,screens,widgets,pages}}

# Create barrel export file
cat > "$FEATURE_DIR/$FEATURE_NAME.dart" << EOF
// $FEATURE_NAME Feature
export 'domain/entities/${FEATURE_NAME}_entity.dart';
export 'domain/repositories/${FEATURE_NAME}_repository.dart';
export 'domain/usecases/${FEATURE_NAME}_usecase.dart';
export 'data/models/${FEATURE_NAME}_model.dart';
export 'data/repositories/${FEATURE_NAME}_repository_impl.dart';
export 'data/services/${FEATURE_NAME}_service.dart';
export 'presentation/providers/${FEATURE_NAME}_provider.dart';
export 'presentation/screens/${FEATURE_NAME}_screen.dart';
export 'presentation/widgets/${FEATURE_NAME}_widget.dart';
EOF

# Create domain entity
cat > "$FEATURE_DIR/domain/entities/${FEATURE_NAME}_entity.dart" << EOF
/// ${FEATURE_NAME^} Entity
/// 
/// Represents the core business logic for ${FEATURE_NAME//_/ } functionality.
class ${FEATURE_NAME^}Entity {
  final String id;
  final DateTime createdAt;

  const ${FEATURE_NAME^}Entity({
    required this.id,
    required this.createdAt,
  });
}
EOF

# Create data model
cat > "$FEATURE_DIR/data/models/${FEATURE_NAME}_model.dart" << EOF
/// ${FEATURE_NAME^} Model
/// 
/// Data model for ${FEATURE_NAME//_/ } API responses and local storage.
class ${FEATURE_NAME^}Model {
  final String id;
  final DateTime createdAt;

  const ${FEATURE_NAME^}Model({
    required this.id,
    required this.createdAt,
  });

  factory ${FEATURE_NAME^}Model.fromJson(Map<String, dynamic> json) {
    return ${FEATURE_NAME^}Model(
      id: json['id']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
EOF

# Create provider
cat > "$FEATURE_DIR/presentation/providers/${FEATURE_NAME}_provider.dart" << EOF
import 'package:flutter/material.dart';
import '../data/repositories/${FEATURE_NAME}_repository_impl.dart';
import '../domain/entities/${FEATURE_NAME}_entity.dart';

class ${FEATURE_NAME^}Provider extends ChangeNotifier {
  final List<${FEATURE_NAME^}Entity> _items = [];
  bool _isLoading = false;
  String? _error;

  List<${FEATURE_NAME^}Entity> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadItems() async {
    _setLoading(true);
    try {
      // TODO: Implement data loading
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
EOF

echo "✅ Feature $FEATURE_NAME generated successfully!"
echo "📁 Location: $FEATURE_DIR"
echo "🔄 Don't forget to:"
echo "   1. Add the feature to lib/vedanta_trade.dart"
echo "   2. Update routing configuration"
echo "   3. Add tests for the new feature"
```

---

## 🧪 **Automated Testing Setup**

### **Test Generator Script**
```bash
# tools/scripts/generate_tests.sh
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./generate_tests.sh <feature_name>"
    exit 1
fi

FEATURE_NAME=$1
TEST_DIR="test/unit/features/$FEATURE_NAME"

echo "🧪 Generating tests for: $FEATURE_NAME"

# Create test directory
mkdir -p "$TEST_DIR"

# Create provider test
cat > "$TEST_DIR/${FEATURE_NAME}_provider_test.dart" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vedanta_trade/features/$FEATURE_NAME/presentation/providers/${FEATURE_NAME}_provider.dart';

class Mock${FEATURE_NAME^}Repository extends Mock implements ${FEATURE_NAME^}Repository {}

void main() {
  group('${FEATURE_NAME^}Provider Tests', () {
    late ${FEATURE_NAME^}Provider provider;
    late Mock${FEATURE_NAME^}Repository mockRepository;

    setUp(() {
      mockRepository = Mock${FEATURE_NAME^}Repository();
      provider = ${FEATURE_NAME^}Provider(repository: mockRepository);
    });

    test('should load items successfully', () async {
      // Arrange
      final mockItems = [
        ${FEATURE_NAME^}Entity(id: '1', createdAt: DateTime.now()),
      ];
      when(mockRepository.getItems()).thenAnswer((_) async => mockItems);

      // Act
      await provider.loadItems();

      // Assert
      expect(provider.items, equals(mockItems));
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
    });

    test('should handle loading errors', () async {
      // Arrange
      when(mockRepository.getItems()).thenThrow(Exception('Network error'));

      // Act
      await provider.loadItems();

      // Assert
      expect(provider.items, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.error, equals('Exception: Network error'));
    });
  });
}
EOF

# Create widget test
cat > "$TEST_DIR/${FEATURE_NAME}_screen_test.dart" << EOF
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_trade/features/$FEATURE_NAME/presentation/screens/${FEATURE_NAME}_screen.dart';
import 'package:vedanta_trade/features/$FEATURE_NAME/presentation/providers/${FEATURE_NAME}_provider.dart';

void main() {
  group('${FEATURE_NAME^}Screen Tests', () {
    testWidgets('should display loading state', (WidgetTester tester) async {
      // Arrange
      final mockProvider = Mock${FEATURE_NAME^}Provider();
      
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<${FEATURE_NAME^}Provider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: ${FEATURE_NAME^}Screen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display items when loaded', (WidgetTester tester) async {
      // Arrange
      final mockProvider = Mock${FEATURE_NAME^}Provider();
      final mockItems = [
        ${FEATURE_NAME^}Entity(id: '1', createdAt: DateTime.now()),
      ];
      
      // Act
      await tester.pumpWidget(
        ChangeNotifierProvider<${FEATURE_NAME^}Provider>.value(
          value: mockProvider,
          child: MaterialApp(
            home: ${FEATURE_NAME^}Screen(),
          ),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
EOF

echo "✅ Tests for $FEATURE_NAME generated successfully!"
echo "📁 Location: $TEST_DIR"
```

---

## 📊 **Code Quality Automation**

### **Linting and Formatting Script**
```bash
# tools/scripts/quality_check.sh
#!/bin/bash

echo "🔍 Running code quality checks..."

# Run Flutter analyze
echo "🔍 Running Flutter analyze..."
flutter analyze --fatal-infos

# Check code formatting
echo "🔍 Checking code formatting..."
dart format --set-exit-if-changed lib/

# Run tests with coverage
echo "🧪 Running tests with coverage..."
flutter test --coverage

# Generate coverage report
echo "📊 Generating coverage report..."
genhtml coverage/lcov.info -o coverage/html

echo "✅ Code quality checks completed!"
echo "📊 Coverage report available at: coverage/html/index.html"
```

### **Dependency Update Script**
```bash
# tools/scripts/update_dependencies.sh
#!/bin/bash

echo "🔄 Updating dependencies..."

# Get current dependencies
echo "📦 Getting current dependencies..."
flutter pub deps

# Update dependencies
echo "🔄 Updating dependencies..."
flutter pub upgrade

# Check for outdated packages
echo "📋 Checking for outdated packages..."
flutter pub outdated

# Run tests after update
echo "🧪 Running tests after dependency update..."
flutter test

echo "✅ Dependency update completed!"
```

---

## 🚀 **Build and Deployment Automation**

### **Build Automation Script**
```bash
# tools/scripts/build.sh
#!/bin/bash

echo "🏗️  Building VedantaTrade..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for different platforms
echo "📱 Building for Android..."
flutter build apk --release

echo "📱 Building for Android (AppBundle)..."
flutter build appbundle --release

echo "🌐 Building for Web..."
flutter build web --release

echo "🍎 Building for iOS (if on macOS)..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    flutter build ios --release
fi

echo "✅ Build completed!"
echo "📁 Build artifacts:"
echo "   - Android APK: build/app/outputs/flutter-apk/app-release.apk"
echo "   - Android AAB: build/app/outputs/bundle/release/app-release.aab"
echo "   - Web: build/web"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   - iOS: build/ios/Runner.xcarchive"
fi
```

---

## 📋 **Development Workflow**

### **Pre-commit Hook**
```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Run Flutter analyze
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Flutter analyze failed. Please fix issues before committing."
    exit 1
fi

# Run tests
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Please fix failing tests before committing."
    exit 1
fi

# Check code formatting
dart format --set-exit-if-changed lib/
if [ $? -ne 0 ]; then
    echo "❌ Code formatting issues found. Please run 'dart format lib/' and commit again."
    exit 1
fi

echo "✅ Pre-commit checks passed!"
exit 0
```

### **Installation Script**
```bash
# tools/scripts/setup.sh
#!/bin/bash

echo "🚀 Setting up VedantaTrade development environment..."

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Get Flutter version
echo "📱 Flutter version:"
flutter --version

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p lib/{app,core,data,features,shared}
mkdir -p test/{unit,widget,integration,e2e}
mkdir -p docs
mkdir -p tools/{scripts,build_runner}

# Make scripts executable
chmod +x tools/scripts/*.sh

# Setup pre-commit hooks
echo "🔧 Setting up Git hooks..."
cp tools/scripts/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit

echo "✅ Development environment setup completed!"
echo "🚀 You can now start developing VedantaTrade!"
```

---

## 📈 **Continuous Integration**

### **GitHub Actions Workflow**
```yaml
# .github/workflows/quality-check.yml
name: Quality Check

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  quality-check:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.19.0'

    - name: Install dependencies
      run: flutter pub get

    - name: Analyze code
      run: flutter analyze --fatal-infos

    - name: Format code
      run: dart format --set-exit-if-changed lib/

    - name: Run tests
      run: flutter test --coverage

    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info

    - name: Check project structure
      run: ./tools/scripts/check_structure.sh

    - name: Validate naming conventions
      run: ./tools/scripts/validate_naming.sh
```

---

## 📚 **Usage Guide**

### **Quick Start**
```bash
# Setup development environment
./tools/scripts/setup.sh

# Generate new feature
./tools/scripts/generate_feature.sh user_management

# Run quality checks
./tools/scripts/quality_check.sh

# Build project
./tools/scripts/build.sh
```

### **Daily Development**
```bash
# Before starting work
flutter pub get
flutter analyze

# During development
flutter test --watch
flutter run

# Before committing
./tools/scripts/quality_check.sh
```

### **Release Preparation**
```bash
# Update dependencies
./tools/scripts/update_dependencies.sh

# Run full test suite
flutter test
flutter test integration/
flutter test e2e/

# Build for all platforms
./tools/scripts/build.sh

# Update documentation
./tools/scripts/update_docs.sh
```

---

*Last Updated: April 3, 2026*  
*Project: VedantaTrade - Enterprise Pharmaceutical Distribution*  
*Version: v3.2.1-alpha*
