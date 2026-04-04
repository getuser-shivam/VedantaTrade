# App Gallery Images

This directory contains images for the VedantaTrade app gallery.

## Directory Structure

```
assets/images/
├── hero-screenshot.png          # Hero section screenshot
├── v34/                         # Version 3.4.0 screenshots
│   ├── dashboard.png
│   ├── vat-returns.png
│   ├── expense-reconciliation.png
│   ├── inventory-management.png
│   ├── checkout-system.png
│   ├── nav-before.png
│   ├── nav-after.png
│   ├── cards-before.png
│   ├── cards-after.png
│   ├── loading-before.png
│   ├── loading-after.png
│   ├── error-before.png
│   └── error-after.png
├── v33/                         # Version 3.3.0 screenshots
│   ├── dashboard.png
│   ├── ci-cd.png
│   ├── monitoring.png
│   └── container.png
├── v32/                         # Version 3.2.0 screenshots
│   ├── glassmorphic.png
│   ├── animations.png
│   ├── responsive.png
│   └── loading.png
├── v31/                         # Version 3.1.0 screenshots
│   ├── performance.png
│   ├── security.png
│   ├── auth.png
│   └── optimization.png
└── v30/                         # Version 3.0.0 screenshots
    ├── localization.png
    ├── redesign.png
    ├── distribution.png
    └── checkout.png
```

## Image Requirements

- **Format**: PNG or JPEG
- **Size**: 1200x800 pixels for carousel images
- **Compression**: Optimized for web (max 500KB per image)
- **Naming**: Use kebab-case for all filenames
- **Alt Text**: Provide descriptive alt text for accessibility

## Adding New Images

1. Create appropriate version directory (v34, v33, etc.)
2. Add images with descriptive names
3. Update the HTML file to reference new images
4. Test the gallery to ensure proper display

## Image Optimization

- Use tools like TinyPNG or ImageOptim
- Maintain aspect ratio (3:2 for carousel images)
- Ensure consistent styling across all screenshots
- Add subtle shadows and borders for professional look

## Placeholder Images

Currently, the gallery uses placeholder images. Replace them with actual app screenshots:

1. Take screenshots of the app for each version
2. Edit screenshots to show UI changes (before/after)
3. Optimize images for web
4. Update the gallery with new images

## Hero Screenshot

The hero section should feature the most impressive screenshot:
- Latest version dashboard
- Clean, professional appearance
- Shows key features
- High resolution and quality
