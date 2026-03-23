class GalleryRelease {
  const GalleryRelease({
    required this.version,
    required this.label,
    required this.releaseDate,
    required this.summary,
    required this.highlights,
    required this.screenshots,
  });

  final String version;
  final String label;
  final String releaseDate;
  final String summary;
  final List<String> highlights;
  final List<GalleryScreenshot> screenshots;
}

class GalleryScreenshot {
  const GalleryScreenshot({
    required this.title,
    required this.caption,
    required this.style,
    required this.primaryColorHex,
    required this.secondaryColorHex,
  });

  final String title;
  final String caption;
  final GalleryPreviewStyle style;
  final int primaryColorHex;
  final int secondaryColorHex;
}

enum GalleryPreviewStyle {
  heroDashboard,
  productGrid,
  productDetail,
  cartFlow,
  analytics,
}
