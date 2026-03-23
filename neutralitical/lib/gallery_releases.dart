import 'gallery_release.dart';

const galleryReleases = <GalleryRelease>[
  GalleryRelease(
    version: 'v1.4.0',
    label: 'Gallery Launch',
    releaseDate: 'March 2026',
    summary:
        'Introduced a polished visual release gallery to track UI evolution and showcase the latest refinements.',
    highlights: [
      'Added a hero carousel for the most recent screens',
      'Grouped UI updates by release version',
      'Improved typography, spacing, and visual hierarchy',
    ],
    screenshots: [
      GalleryScreenshot(
        title: 'Release Overview',
        caption:
            'New hero section with version highlights and editorial framing.',
        style: GalleryPreviewStyle.heroDashboard,
        primaryColorHex: 0xFF193C32,
        secondaryColorHex: 0xFFE9C46A,
      ),
      GalleryScreenshot(
        title: 'Catalog Grid',
        caption:
            'Sharper product browsing with stronger cards and cleaner spacing.',
        style: GalleryPreviewStyle.productGrid,
        primaryColorHex: 0xFF2A6F97,
        secondaryColorHex: 0xFFF4A261,
      ),
    ],
  ),
  GalleryRelease(
    version: 'v1.3.0',
    label: 'Catalog Refresh',
    releaseDate: 'February 2026',
    summary:
        'Refined the browsing experience for registered products with clearer categorization and richer visual previews.',
    highlights: [
      'Redesigned category filtering',
      'Improved product card density for mobile',
      'Added stronger highlight states for featured releases',
    ],
    screenshots: [
      GalleryScreenshot(
        title: 'Featured Products',
        caption:
            'Carousel cards gained stronger contrast and clearer pricing treatment.',
        style: GalleryPreviewStyle.productGrid,
        primaryColorHex: 0xFF355070,
        secondaryColorHex: 0xFFEAAC8B,
      ),
      GalleryScreenshot(
        title: 'Product Story',
        caption:
            'Detail pages now feel more editorial, with ingredient and dosage emphasis.',
        style: GalleryPreviewStyle.productDetail,
        primaryColorHex: 0xFF6D597A,
        secondaryColorHex: 0xFFF2CC8F,
      ),
    ],
  ),
  GalleryRelease(
    version: 'v1.2.0',
    label: 'Checkout Focus',
    releaseDate: 'January 2026',
    summary:
        'Simplified purchase flow visuals and made ordering actions feel more confident and guided.',
    highlights: [
      'Stronger checkout CTA hierarchy',
      'Cleaner order summary presentation',
      'More compact cart item layout',
    ],
    screenshots: [
      GalleryScreenshot(
        title: 'Cart Review',
        caption:
            'Totals, delivery states, and next actions are now easier to scan.',
        style: GalleryPreviewStyle.cartFlow,
        primaryColorHex: 0xFF264653,
        secondaryColorHex: 0xFF2A9D8F,
      ),
      GalleryScreenshot(
        title: 'Conversion Metrics',
        caption:
            'Internal analytics views gained visual summaries for iteration reviews.',
        style: GalleryPreviewStyle.analytics,
        primaryColorHex: 0xFF3D405B,
        secondaryColorHex: 0xFFE07A5F,
      ),
    ],
  ),
];
