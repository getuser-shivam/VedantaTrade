# Changelog

All notable changes to this repository are documented in this file.

## [Unreleased] - 2026-03-22

### Added

- Added a registered-products dataset at `assets/data/products.json` for the main app catalog.
- Added `ProductCatalogService` to load catalog data outside the provider.
- Added loading, error, empty, and refresh handling to the main catalog flow.
- Added GitHub Actions workflows for CI and GitHub Pages deployment.
- Added root `TODO.md` and `CHANGELOG.md` documentation files.

### Changed

- Refactored `ProductProvider` to load registered products from a dedicated data source instead of hardcoded inline entries.
- Updated `HomeScreen` to combine text search and category filtering correctly.
- Updated product catalog presentation to better reflect registered-product availability and counts.
- Hardened product model parsing so future backend responses can be adopted more easily.
- Improved route fallback behavior when a product ID is missing from the catalog.

### Documentation

- Rewrote the root README to reflect the current app structure, catalog architecture, and CI/CD setup.
- Clarified the role of the `neutralitical/` starter project and the workflow files under `.github/workflows/`.
