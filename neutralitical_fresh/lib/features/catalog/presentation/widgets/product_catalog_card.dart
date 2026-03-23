import 'package:flutter/material.dart';

import '../../domain/models/product.dart';
import '../../domain/models/product_media.dart';
import 'product_media_image.dart';

class ProductCatalogCard extends StatelessWidget {
  const ProductCatalogCard({
    super.key,
    required this.product,
    required this.onTap,
    this.primaryMedia,
    this.mediaCount = 0,
  });

  final Product product;
  final VoidCallback onTap;
  final ProductMedia? primaryMedia;
  final int mediaCount;

  @override
  Widget build(BuildContext context) {
    final palette = _productPalette(product.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE6DEC9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 24,
                offset: Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CatalogVisual(
                  product: product,
                  palette: palette,
                  primaryMedia: primaryMedia,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _PillLabel(label: product.category, color: palette.primary),
                    _PillLabel(
                      label: product.form,
                      color: palette.secondary,
                      foregroundColor: const Color(0xFF3D3128),
                    ),
                    if (mediaCount > 0)
                      _PillLabel(
                        label: '$mediaCount media',
                        color: const Color(0xFFF4EEE2),
                        foregroundColor: const Color(0xFF4B453D),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2522),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5C615E),
                    height: 1.45,
                  ),
                ),
                const Spacer(),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.ingredients
                      .take(2)
                      .map((ingredient) => _TagLabel(label: ingredient))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      product.priceLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1C5B45),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.open_in_new, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeaturedProductCard extends StatelessWidget {
  const FeaturedProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.primaryMedia,
    this.mediaCount = 0,
  });

  final Product product;
  final VoidCallback onTap;
  final ProductMedia? primaryMedia;
  final int mediaCount;

  @override
  Widget build(BuildContext context) {
    final palette = _productPalette(product.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Ink(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.primary,
                Color.lerp(palette.primary, palette.secondary, 0.45)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: 0.28),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final featuredPill = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                  final mediaPill = Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$mediaCount media',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );

                  if (constraints.maxWidth < 274) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            featuredPill,
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        if (mediaCount > 0) ...[
                          const SizedBox(height: 10),
                          mediaPill,
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      featuredPill,
                      const Spacer(),
                      if (mediaCount > 0) mediaPill,
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _CatalogVisual(
                  product: product,
                  palette: palette,
                  primaryMedia: primaryMedia,
                  compact: true,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final priceText = Text(
                    product.priceLabel,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  );

                  if (constraints.maxWidth < 268) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PillLabel(
                          label: product.form,
                          color: Colors.white.withValues(alpha: 0.16),
                          foregroundColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: priceText,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      _PillLabel(
                        label: product.form,
                        color: Colors.white.withValues(alpha: 0.16),
                        foregroundColor: Colors.white,
                      ),
                      const Spacer(),
                      priceText,
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogVisual extends StatelessWidget {
  const _CatalogVisual({
    required this.product,
    required this.palette,
    this.primaryMedia,
    this.compact = false,
  });

  final Product product;
  final _ProductPalette palette;
  final ProductMedia? primaryMedia;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fallback = _GeneratedCatalogArtwork(
      product: product,
      palette: palette,
      compact: compact,
    );

    if (primaryMedia == null || !primaryMedia!.isImage) {
      return fallback;
    }

    final borderRadius = BorderRadius.circular(24);
    return SizedBox(
      height: compact ? 118 : 136,
      child: Stack(
        children: [
          Positioned.fill(
            child: buildProductMediaImage(
              uri: primaryMedia!.uri,
              fit: BoxFit.cover,
              borderRadius: borderRadius,
              fallback: fallback,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: compact ? 0.38 : 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    primaryMedia!.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    primaryMedia!.isUploaded ? 'Upload' : 'Drive',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneratedCatalogArtwork extends StatelessWidget {
  const _GeneratedCatalogArtwork({
    required this.product,
    required this.palette,
    this.compact = false,
  });

  final Product product;
  final _ProductPalette palette;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 118 : 136,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            palette.primary.withValues(alpha: compact ? 0.94 : 0.18),
            palette.secondary.withValues(alpha: compact ? 0.78 : 0.34),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              width: compact ? 58 : 72,
              height: compact ? 58 : 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: compact ? 0.2 : 0.82),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  product.name.substring(0, 1),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: compact ? Colors.white : palette.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            left: compact ? 92 : 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ArtLine(
                  widthFactor: 0.85,
                  color: compact
                      ? Colors.white.withValues(alpha: 0.92)
                      : palette.primary,
                ),
                const SizedBox(height: 8),
                _ArtLine(
                  widthFactor: 0.6,
                  color: compact
                      ? Colors.white.withValues(alpha: 0.68)
                      : palette.primary.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),
          Positioned(
            right: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: compact ? 0.18 : 0.72),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Generated',
                style: TextStyle(
                  color: compact ? Colors.white : const Color(0xFF3D3128),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtLine extends StatelessWidget {
  const _ArtLine({required this.widthFactor, required this.color});

  final double widthFactor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({
    required this.label,
    required this.color,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TagLabel extends StatelessWidget {
  const _TagLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFE2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF6B615A),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

_ProductPalette _productPalette(String category) {
  switch (category) {
    case 'Prenatal Care':
      return const _ProductPalette(
        primary: Color(0xFF1B5E50),
        secondary: Color(0xFFE3B673),
      );
    case 'Omega Supplements':
      return const _ProductPalette(
        primary: Color(0xFF2A5C8B),
        secondary: Color(0xFF89C2D9),
      );
    case 'Women\'s Health':
      return const _ProductPalette(
        primary: Color(0xFF7C4D79),
        secondary: Color(0xFFF1C8B8),
      );
    case 'Urinary Health':
      return const _ProductPalette(
        primary: Color(0xFF386641),
        secondary: Color(0xFFA7C957),
      );
    case 'Bone Health':
      return const _ProductPalette(
        primary: Color(0xFF5C6B73),
        secondary: Color(0xFFE7CBA9),
      );
    default:
      return const _ProductPalette(
        primary: Color(0xFF5A6650),
        secondary: Color(0xFFD8C8B2),
      );
  }
}

class _ProductPalette {
  const _ProductPalette({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;
}
