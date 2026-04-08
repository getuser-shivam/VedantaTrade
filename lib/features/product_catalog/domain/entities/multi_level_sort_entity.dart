import 'package:equatable/equatable.dart';
import 'sort_option_entity.dart';

/// Multi-Level Sort Entity
/// Allows for primary and secondary sorting
class MultiLevelSortEntity extends Equatable {
  final SortOptionEntity primarySort;
  final SortOptionEntity? secondarySort;
  final bool isSecondaryEnabled;

  const MultiLevelSortEntity({
    required this.primarySort,
    this.secondarySort,
    this.isSecondaryEnabled = false,
  });

  /// Create copy with updated values
  MultiLevelSortEntity copyWith({
    SortOptionEntity? primarySort,
    SortOptionEntity? secondarySort,
    bool? isSecondaryEnabled,
  }) {
    return MultiLevelSortEntity(
      primarySort: primarySort ?? this.primarySort,
      secondarySort: secondarySort ?? this.secondarySort,
      isSecondaryEnabled: isSecondaryEnabled ?? this.isSecondaryEnabled,
    );
  }

  /// Get sort query string for API
  String get sortQuery {
    if (isSecondaryEnabled && secondarySort != null) {
      return '${primarySort.sortQuery},${secondarySort!.sortQuery}';
    }
    return primarySort.sortQuery;
  }

  /// Get display label
  String get displayLabel {
    if (isSecondaryEnabled && secondarySort != null) {
      return '${primarySort.label} then ${secondarySort!.label}';
    }
    return primarySort.label;
  }

  @override
  List<Object?> get props => [primarySort, secondarySort, isSecondaryEnabled];
}
