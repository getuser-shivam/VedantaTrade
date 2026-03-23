import 'package:flutter/material.dart';

import 'gallery_release.dart';

class GalleryPreviewCard extends StatelessWidget {
  const GalleryPreviewCard({
    super.key,
    required this.screenshot,
    this.versionLabel,
    this.compact = false,
  });

  final GalleryScreenshot screenshot;
  final String? versionLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final primary = Color(screenshot.primaryColorHex);
    final secondary = Color(screenshot.secondaryColorHex);

    return Container(
      width: compact ? 260 : double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, Color.lerp(primary, secondary, 0.55)!],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.25),
            blurRadius: 32,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (versionLabel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                versionLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (versionLabel != null) const SizedBox(height: 14),
          Expanded(
            child: _PhonePreview(
              screenshot: screenshot,
              primary: primary,
              secondary: secondary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            screenshot.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 18 : 22,
              fontWeight: FontWeight.w800,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            screenshot.caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.84),
              fontSize: compact ? 13 : 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhonePreview extends StatelessWidget {
  const _PhonePreview({
    required this.screenshot,
    required this.primary,
    required this.secondary,
  });

  final GalleryScreenshot screenshot;
  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.72,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF7F3ED),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: [
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.94),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const Spacer(),
                      ...List.generate(
                        3,
                        (index) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: switch (screenshot.style) {
                      GalleryPreviewStyle.heroDashboard => _DashboardPreview(
                        primary: primary,
                        secondary: secondary,
                      ),
                      GalleryPreviewStyle.productGrid => _ProductGridPreview(
                        primary: primary,
                        secondary: secondary,
                      ),
                      GalleryPreviewStyle.productDetail =>
                        _ProductDetailPreview(
                          primary: primary,
                          secondary: secondary,
                        ),
                      GalleryPreviewStyle.cartFlow => _CartFlowPreview(
                        primary: primary,
                        secondary: secondary,
                      ),
                      GalleryPreviewStyle.analytics => _AnalyticsPreview(
                        primary: primary,
                        secondary: secondary,
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardPreview extends StatelessWidget {
  const _DashboardPreview({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [primary, secondary]),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 96,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _MetricCard(color: primary)),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(color: secondary)),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DDD0)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index == 3 ? 0 : 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? primary.withValues(alpha: 0.12)
                              : secondary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          children: [
                            _Line(widthFactor: 1 - (index * 0.1)),
                            const SizedBox(height: 6),
                            _Line(widthFactor: 0.65 - (index * 0.06)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductGridPreview extends StatelessWidget {
  const _ProductGridPreview({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight =
            constraints.maxHeight < 220 || constraints.maxWidth < 150;
        final tileImageHeight = isTight ? 38.0 : 58.0;
        final tileInset = isTight ? 8.0 : 10.0;
        final tileSpacing = isTight ? 8.0 : 10.0;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _Pill(
                    color: primary.withValues(alpha: 0.14),
                    height: isTight ? 22 : 26,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Pill(
                    color: secondary.withValues(alpha: 0.18),
                    height: isTight ? 22 : 26,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _Pill(
                    color: const Color(0xFFF1ECE4),
                    height: isTight ? 22 : 26,
                  ),
                ),
              ],
            ),
            SizedBox(height: isTight ? 10 : 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: isTight ? 8 : 10,
                mainAxisSpacing: isTight ? 8 : 10,
                childAspectRatio: isTight ? 0.94 : 0.78,
                children: List.generate(
                  4,
                  (index) => Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8DDD0)),
                    ),
                    padding: EdgeInsets.all(tileInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: tileImageHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: index.isEven
                                  ? [primary.withValues(alpha: 0.85), secondary]
                                  : [
                                      secondary,
                                      primary.withValues(alpha: 0.85),
                                    ],
                            ),
                          ),
                        ),
                        SizedBox(height: tileSpacing),
                        _Line(widthFactor: 0.9, height: isTight ? 7 : 10),
                        SizedBox(height: isTight ? 4 : 6),
                        _Line(
                          widthFactor: isTight ? 0.7 : 0.55,
                          height: isTight ? 6 : 10,
                        ),
                        const Spacer(),
                        Container(
                          width: isTight ? 40 : 54,
                          height: isTight ? 10 : 12,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductDetailPreview extends StatelessWidget {
  const _ProductDetailPreview({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 132,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(colors: [primary, secondary]),
          ),
          child: Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _Line(widthFactor: 0.72),
        const SizedBox(height: 8),
        const _Line(widthFactor: 0.46),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _Pill(color: primary.withValues(alpha: 0.15))),
            const SizedBox(width: 8),
            Expanded(child: _Pill(color: secondary.withValues(alpha: 0.16))),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DDD0)),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: index == 4 ? 0 : 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: index.isEven ? primary : secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _Line(widthFactor: 0.9 - (index * 0.08))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartFlowPreview extends StatelessWidget {
  const _CartFlowPreview({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                margin: EdgeInsets.only(bottom: index == 2 ? 0 : 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE8DDD0)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? primary.withValues(alpha: 0.15)
                            : secondary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          _Line(widthFactor: 0.82 - (index * 0.1)),
                          const SizedBox(height: 6),
                          _Line(widthFactor: 0.44),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [primary, secondary]),
          ),
          child: Column(
            children: [
              const _Line(widthFactor: 0.55, color: Colors.white),
              const SizedBox(height: 10),
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalyticsPreview extends StatelessWidget {
  const _AnalyticsPreview({required this.primary, required this.secondary});

  final Color primary;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _MetricCard(color: primary)),
            const SizedBox(width: 8),
            Expanded(child: _MetricCard(color: secondary)),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8DDD0)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                6,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 5 ? 0 : 8),
                    height: 32 + (index * 18).toDouble(),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: index.isEven
                            ? [primary, primary.withValues(alpha: 0.25)]
                            : [secondary, secondary.withValues(alpha: 0.25)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFF1ECE4),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8DDD0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Line(widthFactor: 0.42, color: color),
          const Spacer(),
          Container(
            width: 46,
            height: 16,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.color, this.height = 26});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.widthFactor,
    this.color = const Color(0xFF2A2B2F),
    this.height = 10,
  });

  final double widthFactor;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor.clamp(0.15, 1.0),
      alignment: Alignment.centerLeft,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
