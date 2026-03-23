import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'gallery_preview_card.dart';
import 'gallery_release.dart';
import 'gallery_releases.dart';

void main() {
  runApp(const NeutraliticalApp());
}

class NeutraliticalApp extends StatelessWidget {
  const NeutraliticalApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.light().textTheme;

    return MaterialApp(
      title: 'Neutralitical Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF18392B),
          secondary: Color(0xFFDE8F5F),
          surface: Color(0xFFF6F1E8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3EEE5),
        textTheme: GoogleFonts.spaceGroteskTextTheme(baseTextTheme).copyWith(
          bodyMedium: GoogleFonts.inter(
            fontSize: 15,
            height: 1.5,
            color: const Color(0xFF2C2D32),
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            height: 1.6,
            color: const Color(0xFF2C2D32),
          ),
        ),
        useMaterial3: true,
      ),
      home: const GalleryHomePage(),
    );
  }
}

class GalleryHomePage extends StatefulWidget {
  const GalleryHomePage({super.key});

  @override
  State<GalleryHomePage> createState() => _GalleryHomePageState();
}

class _GalleryHomePageState extends State<GalleryHomePage> {
  late final PageController _pageController;
  late final List<_FeaturedSlide> _featuredSlides;
  Timer? _autoPlayTimer;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.86);
    _featuredSlides = galleryReleases
        .expand(
          (release) => release.screenshots.map(
            (screenshot) =>
                _FeaturedSlide(release: release, screenshot: screenshot),
          ),
        )
        .toList();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted ||
          !_pageController.hasClients ||
          _featuredSlides.length < 2) {
        return;
      }

      final nextIndex = (_activeIndex + 1) % _featuredSlides.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeSlide = _featuredSlides[_activeIndex];

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2EBE1), Color(0xFFF8F5EF), Color(0xFFEDE5D7)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroBanner(
                        totalVersions: galleryReleases.length,
                        totalScreenshots: _featuredSlides.length,
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'UI release timeline',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C1D21),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Browse the featured carousel first, then scan each release archive to see exactly how the interface evolved across versions.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF575A61),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification &&
                        notification.dragDetails != null) {
                      _autoPlayTimer?.cancel();
                    } else if (notification is ScrollEndNotification) {
                      _startAutoPlay();
                    }

                    return false;
                  },
                  child: SizedBox(
                    height: 468,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _featuredSlides.length,
                      onPageChanged: (index) {
                        setState(() {
                          _activeIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = _featuredSlides[index];
                        return AnimatedPadding(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.fromLTRB(
                            6,
                            index == _activeIndex ? 6 : 20,
                            6,
                            index == _activeIndex ? 6 : 20,
                          ),
                          child: GalleryPreviewCard(
                            screenshot: slide.screenshot,
                            versionLabel: slide.release.version,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _featuredSlides.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _activeIndex ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _activeIndex
                              ? const Color(0xFF18392B)
                              : const Color(0xFFC9B9A4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  child: _FeaturedSpotlightCard(
                    slide: activeSlide,
                    slideIndex: _activeIndex + 1,
                    totalSlides: _featuredSlides.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Version archive',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1C1D21),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Each release groups the major catalog, checkout, and gallery refinements into a single scan-friendly section.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF575A61),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemCount: galleryReleases.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final release = galleryReleases[index];
                    return _ReleaseSection(release: release);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.totalVersions,
    required this.totalScreenshots,
  });

  final int totalVersions;
  final int totalScreenshots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18392B),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F1E8).withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Neutralitical UI release gallery',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Track every visual refinement in one seamless gallery.',
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Designed to present version updates, interface changes, and screenshot previews in a format that feels closer to a product story than a changelog.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE8DDD0),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(label: '$totalVersions versions', value: 'Timeline'),
              const _StatChip(label: 'Swipe gallery', value: 'Carousel'),
              const _StatChip(label: 'UI updates', value: 'Screenshots'),
              _StatChip(
                label: '$totalScreenshots featured',
                value: 'Preview set',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReleaseSection extends StatelessWidget {
  const _ReleaseSection({required this.release});

  final GalleryRelease release;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF18392B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                release.version,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  release.label,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1C1D21),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  release.releaseDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7A6D5E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          release.summary,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF383A40),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: release.highlights
              .map(
                (highlight) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4ECE0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    highlight,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF383A40),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFE6DAC9)),
          ),
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 5, child: details),
                    const SizedBox(width: 18),
                    Expanded(
                      flex: 6,
                      child: _ReleasePreviewRail(release: release),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 18),
                    _ReleasePreviewRail(release: release),
                  ],
                ),
        );
      },
    );
  }
}

class _ReleasePreviewRail extends StatelessWidget {
  const _ReleasePreviewRail({required this.release});

  final GalleryRelease release;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 560) {
          return SizedBox(
            height: 368,
            child: Row(
              children: [
                for (
                  var index = 0;
                  index < release.screenshots.length;
                  index++
                ) ...[
                  if (index > 0) const SizedBox(width: 14),
                  Expanded(
                    child: GalleryPreviewCard(
                      screenshot: release.screenshots[index],
                      compact: true,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return SizedBox(
          height: 368,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: release.screenshots.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return GalleryPreviewCard(
                screenshot: release.screenshots[index],
                compact: true,
              );
            },
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFFE8DDD0),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSpotlightCard extends StatelessWidget {
  const _FeaturedSpotlightCard({
    required this.slide,
    required this.slideIndex,
    required this.totalSlides,
  });

  final _FeaturedSlide slide;
  final int slideIndex;
  final int totalSlides;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE6DAC9)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: Column(
          key: ValueKey('${slide.release.version}-${slide.screenshot.title}'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SpotlightBadge(
                  label:
                      'Featured ${slideIndex.toString().padLeft(2, '0')}/$totalSlides',
                ),
                const Spacer(),
                _SpotlightBadge(label: slide.release.version),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              slide.screenshot.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1C1D21),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              slide.screenshot.caption,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF575A61),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SpotlightBadge(label: slide.release.label),
                _SpotlightBadge(label: slide.release.releaseDate),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightBadge extends StatelessWidget {
  const _SpotlightBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF4ECE0),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF383A40),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeaturedSlide {
  const _FeaturedSlide({required this.release, required this.screenshot});

  final GalleryRelease release;
  final GalleryScreenshot screenshot;
}
