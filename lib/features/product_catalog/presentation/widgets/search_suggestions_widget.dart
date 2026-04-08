import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../providers/search_provider.dart';
import 'package:provider/provider.dart';

/// Search Suggestions Widget
/// Displays search suggestions and autocomplete
class SearchSuggestionsWidget extends StatelessWidget {
  const SearchSuggestionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SearchProvider>();

    if (!provider.hasQuery) {
      return const SizedBox.shrink();
    }

    if (provider.isLoadingSuggestions) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: provider.suggestions.length,
        itemBuilder: (context, index) {
          final suggestion = provider.suggestions[index];
          return ListTile(
            leading: Icon(Icons.search, color: theme.colorScheme.primary),
            title: Text(suggestion),
            onTap: () {
              HapticFeedback.lightImpact();
              provider.applySuggestion(suggestion);
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }
}
