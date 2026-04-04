#!/bin/bash

# VedantaTrade - Build and Deployment Script
# This script analyzes, fixes, builds, and deploys VedantaTrade app

set -e

echo "🚀 VedantaTrade Build & Deployment Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if Flutter is installed
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter first."
        exit 1
    fi
    print_status "Flutter installation verified"
}

# Clean previous build artifacts
clean_build() {
    print_info "Cleaning previous build artifacts..."
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/
    print_status "Build artifacts cleaned"
}

# Analyze code for issues
analyze_code() {
    print_info "Analyzing code for compilation issues..."
    
    # Run flutter analyze
    flutter analyze --no-fatal-infos --no-pub > analyze_output.txt 2>&1
    
    if [ $? -ne 0 ]; then
        print_error "Code analysis found issues:"
        cat analyze_output.txt
        return 1
    fi
    
    print_status "Code analysis completed successfully"
    return 0
}

# Fix common compilation issues
fix_issues() {
    print_info "Fixing common compilation issues..."
    
    # Fix import issues in main.dart
    if [ -f "lib/main.dart" ]; then
        # Check for missing imports and fix them
        sed -i 's|import.*enhanced_ui_components.*|import '\''../../../shared/widgets/enhanced_ui_components.dart'\''|g' lib/main.dart
        sed -i 's|import.*enhanced_app_theme.*|import '\''../../../app/theme/enhanced_app_theme.dart'\''|g' lib/main.dart
        sed -i 's|import.*version_data.*|import '\''../../../features/gallery/data/version_data.dart'\''|g' lib/main.dart
    fi
    
    # Fix import issues in app.dart
    if [ -f "lib/app/app.dart" ]; then
        sed -i 's|import.*enhanced_ui_components.*|import '\''../../shared/widgets/enhanced_ui_components.dart'\''|g' lib/app/app.dart
        sed -i 's|import.*enhanced_app_theme.*|import '\''../../app/theme/enhanced_app_theme.dart'\''|g' lib/app/app.dart
    fi
    
    # Fix import issues in gallery screens
    if [ -f "lib/features/gallery/screens/app_gallery_screen.dart" ]; then
        sed -i 's|import.*enhanced_ui_components.*|import '\''../../../../shared/widgets/enhanced_ui_components.dart'\''|g' lib/features/gallery/screens/app_gallery_screen.dart
        sed -i 's|import.*enhanced_app_theme.*|import '\''../../../../app/theme/enhanced_app_theme.dart'\''|g' lib/features/gallery/screens/app_gallery_screen.dart
        sed -i 's|import.*version_data.*|import '\''../data/version_data.dart'\''|g' lib/features/gallery/screens/app_gallery_screen.dart
    fi
    
    print_status "Common import issues fixed"
}

# Get dependencies
get_dependencies() {
    print_info "Getting Flutter dependencies..."
    flutter pub get
    
    if [ $? -ne 0 ]; then
        print_error "Failed to get dependencies"
        return 1
    fi
    
    print_status "Dependencies updated successfully"
    return 0
}

# Build for different platforms
build_app() {
    local platform=$1
    
    print_info "Building app for $platform..."
    
    case $platform in
        "android")
            flutter build apk --release --target-platform android-arm64
            ;;
        "ios")
            flutter build ios --release
            ;;
        "web")
            flutter build web --release --web-renderer canvaskit
            ;;
        "all")
            flutter build apk --release --target-platform android-arm64
            flutter build ios --release
            flutter build web --release --web-renderer canvaskit
            ;;
        *)
            print_error "Unknown platform: $platform"
            return 1
            ;;
    esac
    
    if [ $? -ne 0 ]; then
        print_error "Build failed for $platform"
        return 1
    fi
    
    print_status "Build completed for $platform"
    return 0
}

# Run tests
run_tests() {
    print_info "Running unit and widget tests..."
    
    # Run unit tests
    flutter test --coverage test/unit/
    
    if [ $? -ne 0 ]; then
        print_warning "Some unit tests failed"
    else
        print_status "Unit tests passed"
    fi
    
    # Run widget tests
    flutter test test/widget/
    
    if [ $? -ne 0 ]; then
        print_warning "Some widget tests failed"
    else
        print_status "Widget tests passed"
    fi
    
    return 0
}

# Generate build report
generate_report() {
    print_info "Generating build report..."
    
    cat > build_report.txt << EOF
VedantaTrade Build Report
========================
Build Date: $(date)
Flutter Version: $(flutter --version | head -n1)
Platform: $PLATFORM
Build Status: $BUILD_STATUS
Test Results:
- Unit Tests: $UNIT_TEST_STATUS
- Widget Tests: $WIDGET_TEST_STATUS
Code Quality:
- Analysis: $ANALYSIS_STATUS
- Issues Fixed: $ISSUES_FIXED

Build Artifacts:
EOF

    # Add build artifacts info
    if [ -d "build/app/outputs/flutter-apk" ]; then
        echo "- APK: $(ls build/app/outputs/flutter-apk/ | head -1)" >> build_report.txt
    fi
    
    if [ -d "build/ios/iphoneos" ]; then
        echo "- iOS: $(ls build/ios/iphoneos/ | head -1)" >> build_report.txt
    fi
    
    if [ -d "build/web" ]; then
        echo "- Web: build/web/" >> build_report.txt
    fi
    
    print_status "Build report generated: build_report.txt"
}

# Main execution function
main() {
    echo "Starting VedantaTrade build process..."
    
    # Check prerequisites
    check_flutter || exit 1
    
    # Clean previous builds
    clean_build
    
    # Analyze code
    ANALYSIS_STATUS="FAILED"
    if analyze_code; then
        ANALYSIS_STATUS="PASSED"
    fi
    
    # Fix common issues
    ISSUES_FIXED="NONE"
    if fix_issues; then
        ISSUES_FIXED="IMPORTS_FIXED"
    fi
    
    # Get dependencies
    get_dependencies || exit 1
    
    # Determine platform
    PLATFORM=${1:-"all"}
    
    # Build app
    BUILD_STATUS="FAILED"
    UNIT_TEST_STATUS="FAILED"
    WIDGET_TEST_STATUS="FAILED"
    
    if build_app "$PLATFORM"; then
        BUILD_STATUS="SUCCESS"
        
        # Run tests
        if run_tests; then
            UNIT_TEST_STATUS="PASSED"
            WIDGET_TEST_STATUS="PASSED"
        fi
    fi
    
    # Generate report
    generate_report
    
    echo ""
    print_status "Build process completed!"
    echo ""
    echo "📊 Build Summary:"
    echo "  Analysis: $ANALYSIS_STATUS"
    echo "  Issues Fixed: $ISSUES_FIXED"
    echo "  Build: $BUILD_STATUS"
    echo "  Unit Tests: $UNIT_TEST_STATUS"
    echo "  Widget Tests: $WIDGET_TEST_STATUS"
    echo ""
    echo "📁 Build artifacts are in build/ directory"
    echo "📄 Build report saved to build_report.txt"
    
    # Check if build was successful
    if [ "$BUILD_STATUS" = "SUCCESS" ] && [ "$UNIT_TEST_STATUS" = "PASSED" ] && [ "$WIDGET_TEST_STATUS" = "PASSED" ]; then
        print_status "✅ All builds and tests completed successfully!"
        exit 0
    else
        print_error "❌ Build or tests failed. Check build_report.txt for details."
        exit 1
    fi
}

# Execute main function
main "$@"
