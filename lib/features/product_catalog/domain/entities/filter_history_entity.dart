import 'package:equatable/equatable.dart';
import 'product_filter_entity.dart';

/// Filter History Entity
/// Tracks recently used filter combinations
class FilterHistoryEntity extends Equatable {
  final String id;
  final ProductFilterEntity filter;
  final DateTime appliedAt;
  final int resultCount;

  const FilterHistoryEntity({
    required this.id,
    required this.filter,
    required this.appliedAt,
    required this.resultCount,
  });

  /// Create copy with updated values
  FilterHistoryEntity copyWith({
    String? id,
    ProductFilterEntity? filter,
    DateTime? appliedAt,
    int? resultCount,
  }) {
    return FilterHistoryEntity(
      id: id ?? this.id,
      filter: filter ?? this.filter,
      appliedAt: appliedAt ?? this.appliedAt,
      resultCount: resultCount ?? this.resultCount,
    );
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(appliedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if history is recent (within 24 hours)
  bool get isRecent => DateTime.now().difference(appliedAt).inHours < 24;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filter': filter.toJson(),
      'appliedAt': appliedAt.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  /// Create from JSON
  factory FilterHistoryEntity.fromJson(Map<String, dynamic> json) {
    return FilterHistoryEntity(
      id: json['id'] as String,
      filter: ProductFilterEntity.fromJson(json['filter'] as Map<String, dynamic>),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      resultCount: json['resultCount'] as int,
    );
  }

  @override
  List<Object?> get props => [id, filter, appliedAt, resultCount];
}
