import 'package:equatable/equatable.dart';

/// Search Query Entity
/// Represents a search query with metadata
class SearchQueryEntity extends Equatable {
  final String id;
  final String query;
  final DateTime timestamp;
  final int resultCount;
  final bool isFavorite;

  const SearchQueryEntity({
    required this.id,
    required this.query,
    required this.timestamp,
    this.resultCount = 0,
    this.isFavorite = false,
  });

  /// Create copy with updated values
  SearchQueryEntity copyWith({
    String? id,
    String? query,
    DateTime? timestamp,
    int? resultCount,
    bool? isFavorite,
  }) {
    return SearchQueryEntity(
      id: id ?? this.id,
      query: query ?? this.query,
      timestamp: timestamp ?? this.timestamp,
      resultCount: resultCount ?? this.resultCount,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if recent (within 24 hours)
  bool get isRecent => DateTime.now().difference(timestamp).inHours < 24;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
      'isFavorite': isFavorite,
    };
  }

  /// Create from JSON
  factory SearchQueryEntity.fromJson(Map<String, dynamic> json) {
    return SearchQueryEntity(
      id: json['id'] as String,
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      resultCount: json['resultCount'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, query, timestamp, resultCount, isFavorite];
}
