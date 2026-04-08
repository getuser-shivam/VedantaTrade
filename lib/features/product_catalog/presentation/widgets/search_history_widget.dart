import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/search_query_entity.dart';
import '../providers/search_provider.dart';
import 'package:provider/provider.dart';

/// Search History Widget
/// Displays recent searches with quick access
class SearchHistoryWidget extends StatelessWidget {
  final int maxItems;
  final bool showFavorites;

  const SearchHistoryWidget({
    Key? key,
    this.maxItems = 10,
    this.showFavorites = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SearchProvider>();

    final history = showFavorites
        ? provider.searchHistory
        : provider.searchHistory.where((h) => !h.isFavorite).toList();

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  provider.clearHistory();
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length > maxItems ? maxItems : history.length,
            separatorBuilder: (context, index) => Divider(
              color: theme.colorScheme.outlineVariant.withOpacity(0.3),
            ),
            itemBuilder: (context, index) {
              final item = history[index];
              return _buildHistoryItem(context, item, provider, theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    SearchQueryEntity item,
    SearchProvider provider,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        provider.applyHistoryItem(item);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.query,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${item.resultCount} results • ${item.timeAgo}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                item.isFavorite ? Icons.star : Icons.star_border,
                size: 18,
                color: item.isFavorite
                    ? Colors.amber
                    : theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                provider.toggleFavorite(item.id);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                provider.removeFromHistory(item.id);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
