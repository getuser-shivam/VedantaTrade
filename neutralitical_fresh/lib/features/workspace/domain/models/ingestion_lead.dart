import 'network_entity.dart';

class IngestionLead {
  const IngestionLead({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    required this.territory,
    required this.status,
    required this.sourceLabel,
    required this.sourceUrl,
    required this.confidence,
  });

  final String id;
  final String name;
  final NetworkEntityType type;
  final String city;
  final String territory;
  final String status;
  final String sourceLabel;
  final String sourceUrl;
  final double confidence;

  String get confidenceLabel => '${(confidence * 100).round()}%';

  factory IngestionLead.fromJson(Map<String, dynamic> json) {
    return IngestionLead(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: NetworkEntityTypeX.fromValue(json['type']?.toString()),
      city: json['city']?.toString() ?? '',
      territory: json['territory']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      sourceLabel: json['sourceLabel']?.toString() ?? '',
      sourceUrl: json['sourceUrl']?.toString() ?? '',
      confidence: ((json['confidence'] as num?) ?? 0).toDouble(),
    );
  }
}
