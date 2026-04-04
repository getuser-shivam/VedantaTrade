# Contributing to VedantaTrade

Thank you for your interest in contributing to VedantaTrade! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style Guidelines](#code-style-guidelines)
- [Project Structure](#project-structure)
- [Submitting Changes](#submitting-changes)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Community Guidelines](#community-guidelines)

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.16.0 or higher
- **Dart SDK**: 3.2.0 or higher
- **Git**: Latest version
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA
- **Node.js**: 18.0+ (for backend development)

### Environment Setup

1. **Clone the repository**:
   ```bash
   git clone git@github.com:getuser-shivam/VedantaTrade.git
   cd VedantaTrade
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

## 🛠️ Development Setup

### Required Tools

- **Flutter CLI**: For building and running the app
- **Dart Analyzer**: For code analysis
- **Git**: For version control
- **GitHub CLI**: For repository management

### IDE Configuration

#### VS Code
Install these extensions:
- Flutter
- Dart
- GitLens
- Flutter Tree
- Bracket Pair Colorizer

#### Android Studio
Install these plugins:
- Flutter
- Dart
- Git

### Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the code style guidelines

3. **Run tests**:
   ```bash
   flutter test
   ```

4. **Analyze code**:
   ```bash
   flutter analyze
   ```

5. **Commit changes**:
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

6. **Push to GitHub**:
   ```bash
   git push origin feature/your-feature-name
   ```

## 📝 Code Style Guidelines

### Dart Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

- **Naming Conventions**:
  - `PascalCase` for classes and enums
  - `camelCase` for variables and functions
  - `SCREAMING_SNAKE_CASE` for constants
  - `snake_case` for files and directories

- **File Organization**:
  - Imports at the top
  - Class definition
  - Static methods first
  - Instance methods
  - Private methods

- **Documentation**:
  - Public APIs must have documentation
  - Use `///` for documentation comments
  - Include parameter and return type descriptions

### Flutter Style

- **Widget Organization**:
  - Build method at the bottom
  - Helper methods above build
  - Constants at the top
  - State variables after constants

- **Performance**:
  - Use `const` widgets where possible
  - Prefer `StatelessWidget` over `StatefulWidget`
  - Use `Keys` appropriately

### Example Code

```dart
import 'package:flutter/material.dart';

/// A button that performs an action when pressed.
class CustomButton extends StatelessWidget {
  /// The text displayed on the button.
  final String text;
  
  /// The callback function called when the button is pressed.
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
```

## 📁 Project Structure

### Directory Organization

```
lib/
├── app/                    # App-level configuration
├── core/                   # Core utilities and services
├── features/              # Feature modules
│   ├── auth/              # Authentication
│   ├── catalog/           # Product catalog
│   ├── orders/            # Order management
│   └── ...
├── shared/                # Shared components
│   ├── theme/             # App theming
│   ├── widgets/           # Reusable widgets
│   └── utils/             # Utility functions
└── main.dart              # App entry point
```

### Feature Structure

Each feature follows Clean Architecture:

```
features/feature_name/
├── data/                  # Data layer
│   ├── models/           # Data models
│   ├── repositories/     # Repository implementations
│   └── services/         # API services
├── domain/               # Domain layer
│   ├── entities/         # Domain entities
│   ├── repositories/     # Repository interfaces
│   └── usecases/         # Business logic
├── presentation/         # Presentation layer
│   ├── providers/        # State management
│   ├── screens/          # UI screens
│   └── widgets/          # Feature widgets
└── feature_name.dart     # Feature export
```

## 🔄 Submitting Changes

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

#### Examples:
```bash
feat(auth): add biometric authentication
fix(catalog): resolve image loading issue
docs(readme): update installation instructions
```

### Branch Naming

Use descriptive branch names:

- `feature/feature-name`
- `fix/issue-description`
- `docs/documentation-update`
- `refactor/code-improvement`

## 🎯 Pull Request Process

### Before Creating PR

1. **Update your branch**:
   ```bash
   git checkout main
   git pull origin main
   git checkout your-branch
   git rebase main
   ```

2. **Run all tests**:
   ```bash
   flutter test
   ```

3. **Run code analysis**:
   ```bash
   flutter analyze
   ```

4. **Format code**:
   ```bash
   dart format .
   ```

### Creating Pull Request

1. **Push your branch**:
   ```bash
   git push origin your-branch
   ```

2. **Create PR on GitHub** with:
   - Clear title and description
   - Related issue numbers
   - Testing instructions
   - Screenshots if applicable

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
```

## 🧪 Testing Guidelines

### Test Types

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete user flows

### Writing Tests

#### Unit Test Example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:vedanta_trade/core/utils/calculator.dart';

void main() {
  group('Calculator', () {
    test('should add two numbers correctly', () {
      final calculator = Calculator();
      expect(calculator.add(2, 3), equals(5));
    });
  });
}
```

#### Widget Test Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vedanta_trade/shared/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton renders correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomButton(
            text: 'Test',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
  });
}
```

### Test Coverage

- Aim for **90%+ test coverage**
- Test all public APIs
- Test edge cases and error conditions
- Use meaningful test descriptions

## 📚 Documentation

### Types of Documentation

1. **Code Documentation**: Comments in Dart code
2. **API Documentation**: Document all public APIs
3. **User Documentation**: README, guides, tutorials
4. **Technical Documentation**: Architecture, design decisions

### Documentation Standards

- **README.md**: Project overview and setup
- **CHANGELOG.md**: Version history and changes
- **CONTRIBUTING.md**: Contribution guidelines
- **API docs**: Auto-generated from code comments

### Writing Documentation

- Use clear, concise language
- Include code examples
- Provide step-by-step instructions
- Keep documentation up to date

## 🤝 Community Guidelines

### Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Maintain professional communication

### Communication Channels

- **GitHub Issues**: Bug reports and feature requests
- **Discussions**: General questions and ideas
- **Pull Requests**: Code contributions and reviews

### Getting Help

1. **Check existing documentation**
2. **Search existing issues**
3. **Create a new issue** with detailed description
4. **Join discussions** for general questions

## 🎯 Development Priorities

### Current Focus Areas

1. **UI/UX Enhancement**: Improve user interface
2. **Performance Optimization**: Enhance app performance
3. **Testing**: Increase test coverage
4. **Documentation**: Improve documentation quality

### Feature Requests

- Submit feature requests via GitHub Issues
- Provide detailed requirements and use cases
- Include mockups or designs if applicable

### Bug Reports

- Use the bug report template
- Include steps to reproduce
- Provide environment details
- Add screenshots if applicable

## 🏆 Recognition

### Contributor Recognition

- Contributors are acknowledged in README.md
- Top contributors get special recognition
- Contributions are tracked in project statistics

### Contribution Types

- **Code**: New features, bug fixes, tests
- **Documentation**: Improving docs, tutorials
- **Design**: UI/UX improvements, mockups
- **Community**: Helping others, answering questions

## 📞 Contact

### Project Maintainer

- **Name**: Shivam Singh
- **Email**: getuser.shivam@gmail.com
- **GitHub**: @getuser-shivam

### Support Channels

- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For general questions
- **Email**: For private or sensitive matters

---

Thank you for contributing to VedantaTrade! Your contributions help make this project better for everyone. 🚀
