# App Screenshots Directory

This directory contains screenshots for the App Gallery feature and store listings.

## Required Screenshots

### App Gallery (versions.json)
- `v3_1_1_gallery_mockup.png` - App Gallery v3.1.1 showcase
- `v3_1_0_mr_dashboard_mockup.png` - MR Dashboard v3.1.0
- `v3_1_0_product_catalog_mockup.png` - Product Catalog v3.1.0
- `v3_1_0_visit_trace_mockup.png` - Visit Trace Map v3.1.0
- `v3_0_0_gps.png` - GPS Tracking v3.0.0
- `v3_0_0_inventory.png` - Inventory Management v3.0.0
- `v3_0_0_vat.png` - VAT Reporting v3.0.0
- `v2_1_0_dashboard.png` - Dashboard v2.1.0
- `v2_1_0_distribution.png` - Distribution v2.1.0

### App Store (6-Role Display)
- `admin_dashboard.png` - Admin role dashboard
- `mr_dashboard.png` - Medical Representative dashboard
- `stockist_dashboard.png` - Stockist/Inventory view
- `retailer_dashboard.png` - Retailer ordering interface
- `doctor_catalog.png` - Doctor product catalog
- `accountant_vat.png` - Accountant VAT reporting

## Generation Instructions

Run the app in each role and capture screenshots at 1080x1920 resolution (portrait) for:
1. Google Play Store
2. HUAWEI AppGallery
3. Internal App Gallery

Use the command:
```bash
flutter screenshot --device-id=<device_id> --out=assets/screenshots/<name>.png
```

## Nepal Market Requirements
- Screenshots must show NPR currency formatting
- VAT 13% labels visible in financial screenshots
- Nepali language support where applicable
