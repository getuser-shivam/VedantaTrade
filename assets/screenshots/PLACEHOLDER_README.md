# Placeholder Screenshots for v3.2.0-alpha

This directory contains placeholder images for the App Gallery feature.

## v3.2.0-alpha Screenshots Required

1. **v3_2_0_gps_tracking.png** - Background GPS tracking with trajectory visualization
2. **v3_2_0_product_catalog.png** - Product catalog with Clean Architecture UI
3. **v3_2_0_distribution.png** - Distribution & marketing management screen
4. **v3_2_0_ui_transitions.png** - Page transitions and enhanced UX

## Generation Instructions

Run the app and capture screenshots at 1080x1920 resolution (portrait):

```bash
# GPS Tracking Screen
flutter screenshot --device-id=<device_id> --out=assets/screenshots/v3_2_0_gps_tracking.png

# Product Catalog Screen
flutter screenshot --device-id=<device_id> --out=assets/screenshots/v3_2_0_product_catalog.png

# Distribution Screen
flutter screenshot --device-id=<device_id> --out=assets/screenshots/v3_2_0_distribution.png

# UI Transitions Demo
flutter screenshot --device-id=<device_id> --out=assets/screenshots/v3_2_0_ui_transitions.png
```

## Alternative: Generate Placeholder Images

Use the placeholder generator script:

```bash
dart tools/generate_placeholders.dart
```

Or manually create 1080x1920 PNG images with:
- Background: Dark slate (#1A1F2C)
- Text: "VedantaTrade v3.2.0 - [Feature Name]"
- Accent: Indigo primary color
