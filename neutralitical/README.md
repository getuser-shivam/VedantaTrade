# Neutralitical Starter Project

This directory contains the standalone Flutter starter project created for Neutralitical.

## Local Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## CI/CD

GitHub Actions workflows in the repository root validate and deploy this project:

- `../.github/workflows/ci.yml` runs formatting checks, analysis, tests, and a web build
- `../.github/workflows/deploy.yml` builds `neutralitical/` for web and deploys it to GitHub Pages from `main`

## Notes

- The app entry point is `lib/main.dart`
- The starter widget test lives in `test/widget_test.dart`
- Web metadata has been updated for the Neutralitical app name and description
