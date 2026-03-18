class Order {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final double finalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String paymentMethod;
  final String? trackingNumber;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.finalAmount,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.trackingNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'].toDouble(),
      deliveryFee: json['deliveryFee'].toDouble(),
      finalAmount: json['finalAmount'].toDouble(),
      status: json['status'],
      orderDate: DateTime.parse(json['orderDate']),
      deliveryDate: json['deliveryDate'] != null
          ? DateTime.parse(json['deliveryDate'])
          : null,
      deliveryAddress: json['deliveryAddress'],
      paymentMethod: json['paymentMethod'],
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'finalAmount': finalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod,
      'trackingNumber': trackingNumber,
    };
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final String productForm;
  final double price;
  final int quantity;
  final String imageUrl;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productForm,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get totalPrice => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productName: json['productName'],
      productForm: json['productForm'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productForm': productForm,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}
