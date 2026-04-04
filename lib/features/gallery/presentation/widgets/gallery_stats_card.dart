import 'package:flutter/material.dart';
import 'package:charts_flutter/charts_flutter.dart';

import '../../../shared/theme/enhanced_theme.dart';
import '../../../shared/widgets/enhanced_ui_kit.dart';
import '../models/gallery_models.dart';

/// Gallery statistics card widget
class GalleryStatsCard extends StatelessWidget {
  final String title;
  final GalleryStats stats;
  
  const GalleryStatsCard({
    Key? key,
    required this.title,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatRow(context, 'Total Versions', stats.totalVersions.toString(), Icons.apps),
          _buildStatRow(context, 'Total Screenshots', stats.totalScreenshots.toString(), Icons.photo_library),
          _buildStatRow(context, 'Total Views', stats.totalViews.toString(), Icons.visibility),
          _buildStatRow(context, 'Total Comparisons', stats.totalComparisons.toString(), Icons.compare),
          _buildStatRow(context, 'Avg View Time', '${stats.averageViewTime}s', Icons.access_time),
          const SizedBox(height: 24),
          _buildPopularVersions(context),
          const SizedBox(height: 24),
          _buildCategoryChart(context),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: EnhancedTheme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: EnhancedTheme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularVersions(BuildContext context) {
    if (stats.popularVersions.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EnhancedTheme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Versions',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...stats.popularVersions.map((version) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: EnhancedTheme.of(context).secondaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    version,
                    style: TextStyle(
                      color: EnhancedTheme.of(context).textColor,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${stats.categoryDistribution[version] ?? 0} views',
                  style: TextStyle(
                    color: EnhancedTheme.of(context).textColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context) {
    if (stats.categoryDistribution.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: EnhancedTheme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: EnhancedTheme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Category Distribution',
            style: TextStyle(
              color: EnhancedTheme.of(context).textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                axisTitles: const AxisTitles(
                  leftTitles: AxisTitles(sideTitles: AxisTitles(leftTitles: AxisTitles(reserveSize: 42)),
                  bottomTitles: AxisTitles(sideTitles: AxisTitles(reserveSize: 28)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.transparent),
                ),
                barGroups: [
                  BarChartGroupData(
                    barRods: stats.categoryDistribution.entries.map((entry) {
                      return BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: EnhancedTheme.of(context).primaryColor,
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      );
                    }).toList(),
                    showingTooltipIndicators: true,
                  ),
                ],
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
