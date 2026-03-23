# Neutralitical App

Neutralitical is a Flutter commerce app for Vedanta TradeLink health supplements. The current app includes a registered product catalog, featured merchandising, product details, cart and wishlist flows, user profile screens, review support, and notification/order scaffolding.

## Current Highlights

- Registered product catalog loaded from `assets/data/products.json`
- Featured products carousel with category chips and combined search filtering
- Product detail pages with ingredients, dosage, packaging, reviews, and cart actions
- Cart, wishlist, authentication, profile, order history, and notifications flows
- Provider-based state management across the app
- GitHub Actions workflows for CI and GitHub Pages deployment of the separate `neutralitical/` starter project

## Product Catalog Enhancements

Recent catalog work moved product data out of hardcoded provider state and into a dedicated catalog data source:

- `assets/data/products.json` now acts as the registered-products source
- `ProductCatalogService` loads and parses registered products
- `ProductProvider` now exposes loading and error state for the catalog
- `HomeScreen` now supports:
  - pull-to-refresh
  - loading, error, and empty states
  - combined category and text filtering
  - registered-product counts
- `ProductCard` and routing were cleaned up so catalog navigation behaves more predictably

## Repository Layout

```text
.
|-- assets/
|   |-- data/products.json
|   `-- images/
|-- backend/
|   |-- prisma/
|   `-- src/
|-- lib/
|   |-- models/
|   |-- providers/
|   |-- screens/
|   |-- services/
|   `-- widgets/
|-- .github/workflows/
`-- neutralitical/
```

## Main App Stack

- Flutter
- Provider
- GoRouter
- Google Fonts
- Card Swiper
- Shared Preferences
- Firebase Core / Analytics / Remote Config

## Local Development

### Main App

```bash
flutter pub get
flutter analyze
flutter run
```

### Starter Project In `neutralitical/`

```bash
cd neutralitical
flutter pub get
flutter analyze
flutter test
flutter run
```

## CI/CD

The repository now includes GitHub Actions workflows under `.github/workflows/`:

- `ci.yml`
  - installs Flutter
  - checks formatting
  - runs `flutter analyze`
  - runs tests
  - builds the web target
- `deploy.yml`
  - builds the Flutter web app in `neutralitical/`
  - uploads the Pages artifact
  - deploys to GitHub Pages from `main`

## Notes

- The main catalog currently reads from the local registered-products dataset.
- Backend product endpoints are scaffolded separately under `backend/` and can be connected to the catalog in a later iteration.
- Supporting project planning and schema documents remain in the repository root for product and backend reference.
