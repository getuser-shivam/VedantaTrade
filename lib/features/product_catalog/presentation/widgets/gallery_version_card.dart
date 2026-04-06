import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';

import '../../../shared/theme/enhanced_theme.dart';
import '../../../shared/widgets/enhanced_ui_kit.dart';
import '../models/gallery_models.dart';

/// Gallery version card widget
class GalleryVersionCard extends StatelessWidget {
  final GalleryVersion version;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isCurrent;
  
  const GalleryVersionCard({
    Key? key,
    required this.version,
    this.onTap,
    this.onFavoriteToggle,
    this.isCurrent = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blur: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCurrent
            ? Border.all(
                color: EnhancedTheme.of(context).primaryColor,
                width: 2,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            version.version,
                            style: TextStyle(
                              color: EnhancedTheme.of(context).textColor,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            version.title,
                            style: TextStyle(
                              color: EnhancedTheme.of(context).textColor.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (version.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: EnhancedTheme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'CURRENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (version.isFavorite)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: EnhancedTheme.of(context).secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    if (onFavoriteToggle != null)
                      IconButton(
                        icon: Icon(
                          version.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: version.isFavorite ? EnhancedTheme.of(context).secondaryColor : EnhancedTheme.of(context).textColor.withOpacity(0.6),
                        ),
                        onPressed: () => onFavoriteToggle!(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  version.releaseDate.toString().split(' ')[0],
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Released',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${version.features.length} features',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  version.description,
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor,
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
                      Icons.photo_library,
                      color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${version.screenshots.length} screenshots',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.visibility,
                      color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${version.stats['views'] ?? 0} views',
                      style: TextStyle(
                        color: EnhancedTheme.of(context).textColor.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: EnhancedTheme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow,
                        color: EnhancedTheme.of(context).primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'View Details',
                        style: TextStyle(
                          color: EnhancedTheme.of(context).primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
