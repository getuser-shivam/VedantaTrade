import 'dart:convert';

class SalesTransaction {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String distributorId;
  final String retailerId;
  final String distributionCenterId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final double discountAmount;
  final double taxAmount;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime transactionDate;
  final String? salesmanId;
  final String? salesmanName;
  final String region;
  final String? campaignId;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesTransaction({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.distributorId,
    required this.retailerId,
    required this.distributionCenterId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.discountAmount,
    required this.taxAmount,
    required this.finalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.transactionDate,
    this.salesmanId,
    this.salesmanName,
    required this.region,
    this.campaignId,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesTransaction.fromJson(Map<String, dynamic> json) {
    return SalesTransaction(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      distributorId: json['distributor_id'] as String,
      retailerId: json['retailer_id'] as String,
      distributionCenterId: json['distribution_center_id'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      finalAmount: (json['final_amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: json['payment_status'] as String,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      salesmanId: json['salesman_id'] as String?,
      salesmanName: json['salesman_name'] as String?,
      region: json['region'] as String,
      campaignId: json['campaign_id'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'distributor_id': distributorId,
      'retailer_id': retailerId,
      'distribution_center_id': distributionCenterId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'final_amount': finalAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'transaction_date': transactionDate.toIso8601String(),
      'salesman_id': salesmanId,
      'salesman_name': salesmanName,
      'region': region,
      'campaign_id': campaignId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SalesAnalytics {
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalOrders;
  final double averageOrderValue;
  final int totalUnitsSold;
  final Map<String, double> revenueByRegion;
  final Map<String, double> revenueByProduct;
  final Map<String, double> revenueByDistributor;
  final List<TopProduct> topProducts;
  final List<TopDistributor> topDistributors;
  final double growthRate;
  final double targetRevenue;
  final double targetAchievement;
  final Map<String, dynamic> metrics;

  SalesAnalytics({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.totalUnitsSold,
    required this.revenueByRegion,
    required this.revenueByProduct,
    required this.revenueByDistributor,
    required this.topProducts,
    required this.topDistributors,
    required this.growthRate,
    required this.targetRevenue,
    required this.targetAchievement,
    required this.metrics,
  });

  factory SalesAnalytics.fromJson(Map<String, dynamic> json) {
    return SalesAnalytics(
      period: json['period'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      totalOrders: (json['total_orders'] as num).toDouble(),
      averageOrderValue: (json['average_order_value'] as num).toDouble(),
      totalUnitsSold: json['total_units_sold'] as int,
      revenueByRegion: Map<String, double>.from(json['revenue_by_region'] as Map),
      revenueByProduct: Map<String, double>.from(json['revenue_by_product'] as Map),
      revenueByDistributor: Map<String, double>.from(json['revenue_by_distributor'] as Map),
      topProducts: (json['top_products'] as List)
          .map((item) => TopProduct.fromJson(item as Map<String, dynamic>))
          .toList(),
      topDistributors: (json['top_distributors'] as List)
          .map((item) => TopDistributor.fromJson(item as Map<String, dynamic>))
          .toList(),
      growthRate: (json['growth_rate'] as num).toDouble(),
      targetRevenue: (json['target_revenue'] as num).toDouble(),
      targetAchievement: (json['target_achievement'] as num).toDouble(),
      metrics: Map<String, dynamic>.from(json['metrics'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'average_order_value': averageOrderValue,
      'total_units_sold': totalUnitsSold,
      'revenue_by_region': revenueByRegion,
      'revenue_by_product': revenueByProduct,
      'revenue_by_distributor': revenueByDistributor,
      'top_products': topProducts.map((item) => item.toJson()).toList(),
      'top_distributors': topDistributors.map((item) => item.toJson()).toList(),
      'growth_rate': growthRate,
      'target_revenue': targetRevenue,
      'target_achievement': targetAchievement,
      'metrics': metrics,
    };
  }
}

class TopProduct {
  final String productId;
  final String productName;
  final int unitsSold;
  final double revenue;
  final double marketShare;

  TopProduct({
    required this.productId,
    required this.productName,
    required this.unitsSold,
    required this.revenue,
    required this.marketShare,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    return TopProduct(
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      unitsSold: json['units_sold'] as int,
      revenue: (json['revenue'] as num).toDouble(),
      marketShare: (json['market_share'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'units_sold': unitsSold,
      'revenue': revenue,
      'market_share': marketShare,
    };
  }
}

class TopDistributor {
  final String distributorId;
  final String distributorName;
  final double revenue;
  final int ordersCount;
  final double performanceScore;

  TopDistributor({
    required this.distributorId,
    required this.distributorName,
    required this.revenue,
    required this.ordersCount,
    required this.performanceScore,
  });

  factory TopDistributor.fromJson(Map<String, dynamic> json) {
    return TopDistributor(
      distributorId: json['distributor_id'] as String,
      distributorName: json['distributor_name'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      ordersCount: json['orders_count'] as int,
      performanceScore: (json['performance_score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distributor_id': distributorId,
      'distributor_name': distributorName,
      'revenue': revenue,
      'orders_count': ordersCount,
      'performance_score': performanceScore,
    };
  }
}

class SalesForecast {
  final String id;
  final String productId;
  final String productName;
  final String region;
  final DateTime forecastDate;
  final double predictedSales;
  final double predictedRevenue;
  final double confidence;
  final List<String> factors;
  final Map<String, dynamic> modelMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalesForecast({
    required this.id,
    required this.productId,
    required this.productName,
    required this.region,
    required this.forecastDate,
    required this.predictedSales,
    required this.predictedRevenue,
    required this.confidence,
    required this.factors,
    required this.modelMetrics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalesForecast.fromJson(Map<String, dynamic> json) {
    return SalesForecast(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      region: json['region'] as String,
      forecastDate: DateTime.parse(json['forecast_date'] as String),
      predictedSales: (json['predicted_sales'] as num).toDouble(),
      predictedRevenue: (json['predicted_revenue'] as num).toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
      factors: List<String>.from(json['factors'] as List),
      modelMetrics: Map<String, dynamic>.from(json['model_metrics'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'region': region,
      'forecast_date': forecastDate.toIso8601String(),
      'predicted_sales': predictedSales,
      'predicted_revenue': predictedRevenue,
      'confidence': confidence,
      'factors': factors,
      'model_metrics': modelMetrics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
