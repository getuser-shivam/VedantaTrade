import '../models/distribution_entity.dart';
import '../models/inventory_entity.dart';
import '../models/order_entity.dart';
import '../models/marketing_campaign_entity.dart';

abstract class DistributionRepository {
  // Distribution management
  Future<List<DistributionEntity>> getDistributions({
    String? productId,
    String? fromWarehouseId,
    String? toWarehouseId,
    String? carrierId,
    int page = 1,
    int limit = 20,
  });

  Future<DistributionEntity?> getDistributionById(String id);
  Future<void> createDistribution(DistributionEntity distribution);
  Future<void> updateDistribution(DistributionEntity distribution);
  Future<void> deleteDistribution(String id);
  Future<List<DistributionEntity>> getPendingDistributions();
  Future<List<DistributionEntity>> getInTransitDistributions();
  Future<List<DistributionEntity>> getDeliveredDistributions();
  Future<List<DistributionEntity>> getFailedDistributions();
  Future<void> updateDistributionStatus(String id, DistributionStatus status);
  Future<void> assignCarrier(String distributionId, String carrierId);
  Future<void> updateShipmentTracking(String distributionId, String trackingNumber);
  Future<void> markAsDelivered(String distributionId, DateTime deliveredAt);
  Future<void> markAsReturned(String distributionId, String reason);

  // Inventory management
  Future<List<InventoryEntity>> getInventory({
    String? warehouseId,
    String? productId,
    InventoryStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<InventoryEntity?> getInventoryById(String id);
  Future<void> updateInventory(InventoryEntity inventory);
  Future<void> createStockMovement(StockMovement movement);
  Future<List<StockMovement>> getStockMovements({
    String? productId,
    String? warehouseId,
    StockMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<void> adjustStock(String productId, int quantity, String reason);
  Future<void> transferStock(String productId, String fromWarehouseId, String toWarehouseId, int quantity);
  Future<void> reserveStock(String productId, int quantity, String customerId);
  Future<void> releaseReservation(String productId, String customerId);
  Future<List<InventoryEntity>> getLowStockItems();
  Future<List<InventoryEntity>> getExpiringSoonItems();
  Future<List<InventoryEntity>> getOutOfStockItems();
  Future<Map<String, dynamic>> getInventoryAnalytics();
  Future<void> updateInventoryStatus(String productId, InventoryStatus status);

  // Order management
  Future<List<OrderEntity>> getOrders({
    String? customerId,
    OrderStatus? status,
    OrderType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<OrderEntity?> getOrderById(String id);
  Future<void> createOrder(OrderEntity order);
  Future<void> updateOrder(OrderEntity order);
  Future<void> cancelOrder(String id, String reason);
  Future<void> processOrder(String id);
  Future<void> shipOrder(String id, String carrierId);
  Future<void> markOrderAsDelivered(String id, DateTime deliveredAt);
  Future<void> markOrderAsReturned(String id, String reason);
  Future<void> refundOrder(String id, double amount, String reason);
  Future<List<OrderEntity>> getPendingOrders();
  Future<List<OrderEntity>> getProcessingOrders();
  Future<List<OrderEntity>> getShippedOrders();
  Future<List<OrderEntity>> getDeliveredOrders();
  Future<List<OrderEntity>> getCancelledOrders();
  Future<List<OrderEntity>> getReturnedOrders();
  Future<Map<String, dynamic>> getOrderAnalytics();
  Future<void> updateOrderStatus(String id, OrderStatus status);
  Future<void> assignPriorityProcessing(String id);
  Future<void> updatePaymentStatus(String id, PaymentStatus status);
  Future<void> addPaymentDetails(String id, Map<String, dynamic> paymentDetails);

  // Marketing integration
  Future<List<MarketingCampaignEntity>> getCampaigns({
    CampaignStatus? status,
    CampaignType? type,
    TargetAudience? targetAudience,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<MarketingCampaignEntity?> getCampaignById(String id);
  Future<void> createCampaign(MarketingCampaignEntity campaign);
  Future<void> updateCampaign(MarketingCampaignEntity campaign);
  Future<void> deleteCampaign(String id);
  Future<void> launchCampaign(String id);
  Future<void> pauseCampaign(String id);
  Future<void> resumeCampaign(String id);
  Future<void> cancelCampaign(String id);
  Future<List<MarketingCampaignEntity>> getActiveCampaigns();
  Future<List<MarketingCampaignEntity>> getCompletedCampaigns();
  Future<List<MarketingCampaignEntity>> getDraftCampaigns();
  Future<Map<String, dynamic>> getCampaignAnalytics();
  Future<void> updateCampaignMetrics(String id, Map<String, dynamic> metrics);
  Future<void> addProductToCampaign(String campaignId, String productId);
  Future<void> removeProductFromCampaign(String campaignId, String productId);
  Future<List<MarketingCampaignEntity>> getCampaignsByProduct(String productId);
  Future<List<MarketingCampaignEntity>> getCampaignsByTargetAudience(TargetAudience audience);
  Future<void> sendCampaignCommunication(String campaignId, List<String> channels);
  Future<void> trackCampaignEngagement(String campaignId, String engagementType, Map<String, dynamic> data);

  // Analytics and reporting
  Future<Map<String, dynamic>> getDistributionAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? warehouseId,
  });

  Future<Map<String, dynamic>> getInventoryAnalytics({
    String? warehouseId,
    String? productId,
  });

  Future<Map<String, dynamic>> getOrderAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
  });

  Future<Map<String, dynamic>> getMarketingAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? campaignId,
  });

  Future<Map<String, dynamic>> getSalesAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? productId,
    String? customerId,
    String? warehouseId,
  });

  Future<Map<String, dynamic>> getOverallAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Integration with other systems
  Future<void> syncWithProductCatalog(String productId);
  Future<void> syncWithUserManagement(String customerId);
  Future<void> syncWithAccountingSystem();
  Future<void> generateInventoryReport();
  Future<void> generateDistributionReport();
  Future<void> generateSalesReport();
  Future<void> generateMarketingReport();
  Future<void> exportAnalyticsData({
    String format,
    DateTime? startDate,
    DateTime? endDate,
  });
}
