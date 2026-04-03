import 'package:flutter/material.dart';
import 'package:vedanta_trade/shared/widgets/premium_glassmorphic_theme.dart';
import 'package:vedanta_trade/features/gallery/gallery.dart';

class GalleryNavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const GalleryNavigationButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
              PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumGlassmorphicTheme.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                    PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: PremiumGlassmorphicTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: PremiumGlassmorphicTheme.primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String version;
  final VoidCallback onTap;

  const GalleryFeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.version,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
              PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
            ],
          ),
          border: Border.all(
            color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumGlassmorphicTheme.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumGlassmorphicTheme.primaryColor.withOpacity(0.2),
                        PremiumGlassmorphicTheme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: PremiumGlassmorphicTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        PremiumGlassmorphicTheme.successColor.withOpacity(0.2),
                        PremiumGlassmorphicTheme.successColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: PremiumGlassmorphicTheme.successColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    version,
                    style: TextStyle(
                      color: PremiumGlassmorphicTheme.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: PremiumGlassmorphicTheme.primaryTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: PremiumGlassmorphicTheme.secondaryTextColor,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: PremiumGlassmorphicTheme.primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'View Gallery',
                  style: TextStyle(
                    color: PremiumGlassmorphicTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GalleryStatsWidget extends StatelessWidget {
  final int totalScreenshots;
  final int totalVersions;
  final int totalFeatures;

  const GalleryStatsWidget({
    Key? key,
    required this.totalScreenshots,
    required this.totalVersions,
    required this.totalFeatures,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumGlassmorphicTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery Statistics',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Screenshots',
                  totalScreenshots.toString(),
                  Icons.image,
                  PremiumGlassmorphicTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Versions',
                  totalVersions.toString(),
                  Icons.history,
                  PremiumGlassmorphicTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Features',
                  totalFeatures.toString(),
                  Icons.star,
                  PremiumGlassmorphicTheme.successColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: PremiumGlassmorphicTheme.secondaryTextColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryQuickActions extends StatelessWidget {
  const GalleryQuickActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.9),
            PremiumGlassmorphicTheme.cardColor.withOpacity(0.7),
          ],
        ),
        border: Border.all(
          color: PremiumGlassmorphicTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: PremiumGlassmorphicTheme.shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: PremiumGlassmorphicTheme.primaryTextColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GalleryNavigationButton(
                  icon: Icons.photo_library,
                  label: 'View Gallery',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AppGalleryScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GalleryNavigationButton(
                  icon: Icons.compare,
                  label: 'Compare Versions',
                  onTap: () {
                    // Navigate to comparison view
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GalleryNavigationButton(
                  icon: Icons.download,
                  label: 'Download',
                  onTap: () {
                    // Download gallery assets
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
