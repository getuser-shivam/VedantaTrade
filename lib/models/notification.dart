class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  // Helper methods to create different types of notifications
  factory AppNotification.orderStatusUpdate({
    required String orderId,
    required String status,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Order Status Update',
      body: 'Your order #$orderId has been $status',
      type: 'order_status',
      createdAt: createdAt,
      data: {
        'orderId': orderId,
        'status': status,
      },
    );
  }

  factory AppNotification.promotionalOffer({
    required String title,
    required String description,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: description,
      type: 'promotion',
      createdAt: createdAt,
      data: {
        'promotionType': 'offer',
      },
    );
  }

  factory AppNotification.newProduct({
    required String productName,
    required String category,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Product Available',
      body: 'Check out $productName in $category category',
      type: 'new_product',
      createdAt: createdAt,
      data: {
        'productName': productName,
        'category': category,
      },
    );
  }

  factory AppNotification.wishlistPriceDrop({
    required String productName,
    required double oldPrice,
    required double newPrice,
    required DateTime createdAt,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Price Drop Alert',
      body: '$productName is now ₹${newPrice.toStringAsFixed(2)} (was ₹${oldPrice.toStringAsFixed(2)})',
      type: 'price_drop',
      createdAt: createdAt,
      data: {
        'productName': productName,
        'oldPrice': oldPrice,
        'newPrice': newPrice,
      },
    );
  }

  // Get icon based on notification type
  String get icon {
    switch (type) {
      case 'order_status':
        return '📦';
      case 'promotion':
        return '🎉';
      case 'new_product':
        return '🆕';
      case 'price_drop':
        return '💰';
      default:
        return '🔔';
    }
  }

  // Get color based on notification type
  String getColor(BuildContext context) {
    switch (type) {
      case 'order_status':
        return Theme.of(context).colorScheme.primary.value.toString();
      case 'promotion':
        return '#FF9800'; // Orange
      case 'new_product':
        return '#4CAF50'; // Green
      case 'price_drop':
        return '#9C27B0'; // Purple
      default:
        return '#757575'; // Grey
    }
  }
}
