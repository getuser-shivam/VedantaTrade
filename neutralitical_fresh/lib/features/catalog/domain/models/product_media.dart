enum ProductMediaType { image, video }

enum ProductMediaOrigin { curated, uploaded }

class ProductMedia {
  const ProductMedia({
    required this.id,
    required this.productId,
    required this.type,
    required this.origin,
    required this.uri,
    required this.title,
    this.caption,
    this.isPrimary = false,
  });

  final String id;
  final String productId;
  final ProductMediaType type;
  final ProductMediaOrigin origin;
  final String uri;
  final String title;
  final String? caption;
  final bool isPrimary;

  bool get isImage => type == ProductMediaType.image;
  bool get isVideo => type == ProductMediaType.video;
  bool get isUploaded => origin == ProductMediaOrigin.uploaded;
  bool get isRemote =>
      uri.startsWith('http://') ||
      uri.startsWith('https://') ||
      uri.startsWith('data:');

  ProductMedia copyWith({
    String? id,
    String? productId,
    ProductMediaType? type,
    ProductMediaOrigin? origin,
    String? uri,
    String? title,
    String? caption,
    bool? isPrimary,
  }) {
    return ProductMedia(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      uri: uri ?? this.uri,
      title: title ?? this.title,
      caption: caption ?? this.caption,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory ProductMedia.fromJson(
    Map<String, dynamic> json, {
    required String productId,
    ProductMediaOrigin defaultOrigin = ProductMediaOrigin.curated,
  }) {
    return ProductMedia(
      id: json['id']?.toString().trim().isNotEmpty == true
          ? json['id'].toString()
          : '${productId}_${json['title'] ?? json['uri'] ?? 'media'}',
      productId: json['productId']?.toString() ?? productId,
      type: _parseType(json['type']?.toString()),
      origin: _parseOrigin(json['origin']?.toString(), fallback: defaultOrigin),
      uri: json['uri']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Product media',
      caption: json['caption']?.toString(),
      isPrimary: json['primary'] == true || json['isPrimary'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'type': type.name,
      'origin': origin.name,
      'uri': uri,
      'title': title,
      'caption': caption,
      'isPrimary': isPrimary,
    };
  }

  static ProductMediaType _parseType(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'video':
        return ProductMediaType.video;
      case 'image':
      default:
        return ProductMediaType.image;
    }
  }

  static ProductMediaOrigin _parseOrigin(
    String? value, {
    required ProductMediaOrigin fallback,
  }) {
    switch (value?.trim().toLowerCase()) {
      case 'uploaded':
        return ProductMediaOrigin.uploaded;
      case 'curated':
        return ProductMediaOrigin.curated;
      default:
        return fallback;
    }
  }
}
