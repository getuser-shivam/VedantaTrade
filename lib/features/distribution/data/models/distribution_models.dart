import 'package:vedanta_trade/features/distribution/data/models/inventory_models.dart';

// Distribution Center Model
class DistributionCenter {
  final String id;
  final String name;
  final String location;
  final String address;
  final String phone;
  final String email;
  final String manager;
  final int capacity;
  final int currentStock;
  final bool isActive;
  final GeoCoordinates coordinates;
  final DateTime createdAt;

  const DistributionCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.phone,
    required this.email,
    required this.manager,
    required this.capacity,
    required this.currentStock,
    required this.isActive,
    required this.coordinates,
    required this.createdAt,
  });

  factory DistributionCenter.fromJson(Map<String, dynamic> json) {
    return DistributionCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      manager: json['manager'] as String,
      capacity: (json['capacity'] as num).toInt(),
      currentStock: (json['currentStock'] as num).toInt(),
      isActive: json['isActive'] as bool,
      coordinates: GeoCoordinates.fromJson(json['coordinates']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'address': address,
      'phone': phone,
      'email': email,
      'manager': manager,
      'capacity': capacity,
      'currentStock': currentStock,
      'isActive': isActive,
      'coordinates': coordinates.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DistributionCenter copyWith({
    String? id,
    String? name,
    String? location,
    String? address,
    String? phone,
    String? email,
    String? manager,
    int? capacity,
    int? currentStock,
    bool? isActive,
    GeoCoordinates? coordinates,
    DateTime? createdAt,
  }) {
    return DistributionCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      manager: manager ?? this.manager,
      capacity: capacity ?? this.capacity,
      currentStock: currentStock ?? this.currentStock,
      isActive: isActive ?? this.isActive,
      coordinates: coordinates ?? this.coordinates,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get utilizationRate => capacity > 0 ? (currentStock / capacity) * 100 : 0;
  
  String get capacityStatus {
    final rate = utilizationRate;
    if (rate >= 90) return 'Near Full';
    if (rate >= 70) return 'Moderate';
    if (rate >= 40) return 'Low';
    return 'Very Low';
  }
}

// Geo Coordinates
class GeoCoordinates {
  final double latitude;
  final double longitude;

  const GeoCoordinates({
    required this.latitude,
    required this.longitude,
  });

  factory GeoCoordinates.fromJson(Map<String, dynamic> json) {
    return GeoCoordinates(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

// Distribution Metrics
class DistributionMetrics {
  final int totalProducts;
  final int lowStockItems;
  final int outOfStockItems;
  final double totalSalesValue;
  final int todaySales;
  final int pendingOrders;
  final int criticalAlerts;
  final double averageOrderValue;
  final DateTime lastUpdated;

  const DistributionMetrics({
    required this.totalProducts,
    required this.lowStockItems,
    required this.outOfStockItems,
    required this.totalSalesValue,
    required this.todaySales,
    required this.pendingOrders,
    required this.criticalAlerts,
    required this.averageOrderValue,
    required this.lastUpdated,
  });

  DistributionMetrics({
    int? totalProducts,
    int? lowStockItems,
    int? outOfStockItems,
    double? totalSalesValue,
    int? todaySales,
    int? pendingOrders,
    int? criticalAlerts,
    double? averageOrderValue,
    DateTime? lastUpdated,
  }) : totalProducts = totalProducts ?? 0,
       lowStockItems = lowStockItems ?? 0,
       outOfStockItems = outOfStockItems ?? 0,
       totalSalesValue = totalSalesValue ?? 0.0,
       todaySales = todaySales ?? 0,
       pendingOrders = pendingOrders ?? 0,
       criticalAlerts = criticalAlerts ?? 0,
       averageOrderValue = averageOrderValue ?? 0.0,
       lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'totalProducts': totalProducts,
      'lowStockItems': lowStockItems,
      'outOfStockItems': outOfStockItems,
      'totalSalesValue': totalSalesValue,
      'todaySales': todaySales,
      'pendingOrders': pendingOrders,
      'criticalAlerts': criticalAlerts,
      'averageOrderValue': averageOrderValue,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  double get inventoryHealth {
    if (totalProducts == 0) return 100.0;
    final healthyProducts = totalProducts - lowStockItems - outOfStockItems;
    return (healthyProducts / totalProducts) * 100;
  }

  String get overallStatus {
    if (criticalAlerts > 0) return 'Critical';
    if (outOfStockItems > 0) return 'Warning';
    if (lowStockItems > totalProducts * 0.2) return 'Caution';
    return 'Good';
  }
}

// Stock Transfer Request
class StockTransferRequest {
  final String id;
  final String sku;
  final String productName;
  final int quantity;
  final String fromCenterId;
  final String fromCenterName;
  final String toCenterId;
  final String toCenterName;
  final TransferStatus status;
  final DateTime requestedAt;
  final DateTime? approvedAt;
  final DateTime? completedAt;
  final String? requestedBy;
  final String? approvedBy;
  final String? notes;

  const StockTransferRequest({
    required this.id,
    required this.sku,
    required this.productName,
    required this.quantity,
    required this.fromCenterId,
    required this.fromCenterName,
    required this.toCenterId,
    required this.toCenterName,
    required this.status,
    required this.requestedAt,
    this.approvedAt,
    this.completedAt,
    this.requestedBy,
    this.approvedBy,
    this.notes,
  });

  factory StockTransferRequest.fromJson(Map<String, dynamic> json) {
    return StockTransferRequest(
      id: json['id'] as String,
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      quantity: (json['quantity'] as num).toInt(),
      fromCenterId: json['fromCenterId'] as String,
      fromCenterName: json['fromCenterName'] as String,
      toCenterId: json['toCenterId'] as String,
      toCenterName: json['toCenterName'] as String,
      status: TransferStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TransferStatus.pending,
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      requestedBy: json['requestedBy'] as String?,
      approvedBy: json['approvedBy'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'productName': productName,
      'quantity': quantity,
      'fromCenterId': fromCenterId,
      'fromCenterName': fromCenterName,
      'toCenterId': toCenterId,
      'toCenterName': toCenterName,
      'status': status.toString(),
      'requestedAt': requestedAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'requestedBy': requestedBy,
      'approvedBy': approvedBy,
      'notes': notes,
    };
  }
}

// Transfer Status Enum
enum TransferStatus {
  pending,
  approved,
  rejected,
  inTransit,
  completed,
  cancelled,
}

// Route Optimization
class DeliveryRoute {
  final String id;
  final String driverName;
  final String vehicleNumber;
  final List<DeliveryStop> stops;
  final DateTime departureTime;
  final DateTime? estimatedArrival;
  final RouteStatus status;
  final double totalDistance;
  final Duration estimatedDuration;

  const DeliveryRoute({
    required this.id,
    required this.driverName,
    required this.vehicleNumber,
    required this.stops,
    required this.departureTime,
    this.estimatedArrival,
    required this.status,
    required this.totalDistance,
    required this.estimatedDuration,
  });

  factory DeliveryRoute.fromJson(Map<String, dynamic> json) {
    return DeliveryRoute(
      id: json['id'] as String,
      driverName: json['driverName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      stops: (json['stops'] as List)
          .map((stop) => DeliveryStop.fromJson(stop))
          .toList(),
      departureTime: DateTime.parse(json['departureTime'] as String),
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.parse(json['estimatedArrival'] as String)
          : null,
      status: RouteStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => RouteStatus.planned,
      ),
      totalDistance: (json['totalDistance'] as num).toDouble(),
      estimatedDuration: Duration(hours: (json['estimatedDurationHours'] as num).toInt()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverName': driverName,
      'vehicleNumber': vehicleNumber,
      'stops': stops.map((stop) => stop.toJson()).toList(),
      'departureTime': departureTime.toIso8601String(),
      'estimatedArrival': estimatedArrival?.toIso8601String(),
      'status': status.toString(),
      'totalDistance': totalDistance,
      'estimatedDurationHours': estimatedDuration.inHours,
    };
  }
}

// Delivery Stop
class DeliveryStop {
  final String retailerId;
  final String retailerName;
  final String address;
  final GeoCoordinates coordinates;
  final List<String> orderIds;
  final DateTime estimatedArrival;
  final DateTime? actualArrival;
  final DeliveryStatus status;
  final String? notes;

  const DeliveryStop({
    required this.retailerId,
    required this.retailerName,
    required this.address,
    required this.coordinates,
    required this.orderIds,
    required this.estimatedArrival,
    this.actualArrival,
    required this.status,
    this.notes,
  });

  factory DeliveryStop.fromJson(Map<String, dynamic> json) {
    return DeliveryStop(
      retailerId: json['retailerId'] as String,
      retailerName: json['retailerName'] as String,
      address: json['address'] as String,
      coordinates: GeoCoordinates.fromJson(json['coordinates']),
      orderIds: List<String>.from(json['orderIds'] as List),
      estimatedArrival: DateTime.parse(json['estimatedArrival'] as String),
      actualArrival: json['actualArrival'] != null
          ? DateTime.parse(json['actualArrival'] as String)
          : null,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DeliveryStatus.pending,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retailerId': retailerId,
      'retailerName': retailerName,
      'address': address,
      'coordinates': coordinates.toJson(),
      'orderIds': orderIds,
      'estimatedArrival': estimatedArrival.toIso8601String(),
      'actualArrival': actualArrival?.toIso8601String(),
      'status': status.toString(),
      'notes': notes,
    };
  }
}

// Route Status Enum
enum RouteStatus {
  planned,
  inProgress,
  completed,
  cancelled,
}

// Delivery Status Enum
enum DeliveryStatus {
  pending,
  inTransit,
  delivered,
  failed,
  cancelled,
}

// Performance Metrics
class CenterPerformanceMetrics {
  final String centerId;
  final String centerName;
  final DateTime period;
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final int onTimeDeliveries;
  final int totalDeliveries;
  final double deliverySuccessRate;
  final int inventoryTurnover;
  final double fillRate;
  final List<ProductPerformance> topProducts;

  const CenterPerformanceMetrics({
    required this.centerId,
    required this.centerName,
    required this.period,
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.onTimeDeliveries,
    required this.totalDeliveries,
    required this.deliverySuccessRate,
    required this.inventoryTurnover,
    required this.fillRate,
    required this.topProducts,
  });

  factory CenterPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return CenterPerformanceMetrics(
      centerId: json['centerId'] as String,
      centerName: json['centerName'] as String,
      period: DateTime.parse(json['period'] as String),
      totalOrders: (json['totalOrders'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      onTimeDeliveries: (json['onTimeDeliveries'] as num).toInt(),
      totalDeliveries: (json['totalDeliveries'] as num).toInt(),
      deliverySuccessRate: (json['deliverySuccessRate'] as num).toDouble(),
      inventoryTurnover: (json['inventoryTurnover'] as num).toInt(),
      fillRate: (json['fillRate'] as num).toDouble(),
      topProducts: (json['topProducts'] as List)
          .map((product) => ProductPerformance.fromJson(product))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'centerId': centerId,
      'centerName': centerName,
      'period': period.toIso8601String(),
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'averageOrderValue': averageOrderValue,
      'onTimeDeliveries': onTimeDeliveries,
      'totalDeliveries': totalDeliveries,
      'deliverySuccessRate': deliverySuccessRate,
      'inventoryTurnover': inventoryTurnover,
      'fillRate': fillRate,
      'topProducts': topProducts.map((product) => product.toJson()).toList(),
    };
  }
}

// Product Performance
class ProductPerformance {
  final String sku;
  final String productName;
  final String brand;
  final int unitsSold;
  final double revenue;
  final double profitMargin;
  final int rank;

  const ProductPerformance({
    required this.sku,
    required this.productName,
    required this.brand,
    required this.unitsSold,
    required this.revenue,
    required this.profitMargin,
    required this.rank,
  });

  factory ProductPerformance.fromJson(Map<String, dynamic> json) {
    return ProductPerformance(
      sku: json['sku'] as String,
      productName: json['productName'] as String,
      brand: json['brand'] as String,
      unitsSold: (json['unitsSold'] as num).toInt(),
      revenue: (json['revenue'] as num).toDouble(),
      profitMargin: (json['profitMargin'] as num).toDouble(),
      rank: (json['rank'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'productName': productName,
      'brand': brand,
      'unitsSold': unitsSold,
      'revenue': revenue,
      'profitMargin': profitMargin,
      'rank': rank,
    };
  }
}
