import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vedanta_trade/core/api_config.dart';
import '../models/marketing_campaign.dart';

class MarketingService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Get all marketing campaigns
  Future<List<MarketingCampaign>> getAllCampaigns() async {
    try {
      final response = await _dio.get('/api/marketing/campaigns');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MarketingCampaign.fromJson(json)).toList();
      }
      throw Exception('Failed to load campaigns');
    } catch (e) {
      // Return mock data for development
      return _getMockCampaigns();
    }
  }

  // Get campaigns by status
  Future<List<MarketingCampaign>> getCampaignsByStatus(String status) async {
    try {
      final response = await _dio.get('/api/marketing/campaigns', 
        queryParameters: {'status': status});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MarketingCampaign.fromJson(json)).toList();
      }
      throw Exception('Failed to load campaigns by status');
    } catch (e) {
      // Return filtered mock data
      final allCampaigns = _getMockCampaigns();
      return allCampaigns.where((c) => c.status == status).toList();
    }
  }

  // Get campaigns by type
  Future<List<MarketingCampaign>> getCampaignsByType(String type) async {
    try {
      final response = await _dio.get('/api/marketing/campaigns', 
        queryParameters: {'type': type});
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => MarketingCampaign.fromJson(json)).toList();
      }
      throw Exception('Failed to load campaigns by type');
    } catch (e) {
      // Return filtered mock data
      final allCampaigns = _getMockCampaigns();
      return allCampaigns.where((c) => c.type == type).toList();
    }
  }

  // Get campaign by ID
  Future<MarketingCampaign> getCampaignById(String id) async {
    try {
      final response = await _dio.get('/api/marketing/campaigns/$id');
      
      if (response.statusCode == 200) {
        return MarketingCampaign.fromJson(response.data['data']);
      }
      throw Exception('Failed to load campaign');
    } catch (e) {
      // Return mock data
      final allCampaigns = _getMockCampaigns();
      final campaign = allCampaigns.firstWhere((c) => c.id == id);
      return campaign;
    }
  }

  // Create new campaign
  Future<MarketingCampaign> createCampaign(MarketingCampaign campaign) async {
    try {
      final response = await _dio.post('/api/marketing/campaigns', data: campaign.toJson());
      
      if (response.statusCode == 201) {
        return MarketingCampaign.fromJson(response.data['data']);
      }
      throw Exception('Failed to create campaign');
    } catch (e) {
      // Return mock data for development
      final newCampaign = campaign.copyWith(
        id: 'camp_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      return newCampaign;
    }
  }

  // Update campaign
  Future<MarketingCampaign> updateCampaign(MarketingCampaign campaign) async {
    try {
      final response = await _dio.put('/api/marketing/campaigns/${campaign.id}', 
        data: campaign.toJson());
      
      if (response.statusCode == 200) {
        return MarketingCampaign.fromJson(response.data['data']);
      }
      throw Exception('Failed to update campaign');
    } catch (e) {
      // Return mock data for development
      return campaign.copyWith(updatedAt: DateTime.now());
    }
  }

  // Update campaign status
  Future<MarketingCampaign> updateCampaignStatus(String id, String status) async {
    try {
      final response = await _dio.patch('/api/marketing/campaigns/$id/status', 
        data: {'status': status});
      
      if (response.statusCode == 200) {
        return MarketingCampaign.fromJson(response.data['data']);
      }
      throw Exception('Failed to update campaign status');
    } catch (e) {
      // Return mock data for development
      final allCampaigns = _getMockCampaigns();
      final campaign = allCampaigns.firstWhere((c) => c.id == id);
      return campaign.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  // Delete campaign
  Future<bool> deleteCampaign(String id) async {
    try {
      final response = await _dio.delete('/api/marketing/campaigns/$id');
      return response.statusCode == 200;
    } catch (e) {
      // Return true for development
      return true;
    }
  }

  // Get marketing statistics
  Future<Map<String, dynamic>> getMarketingStatistics() async {
    try {
      final response = await _dio.get('/api/marketing/statistics');
      
      if (response.statusCode == 200) {
        return response.data['data'];
      }
      throw Exception('Failed to load marketing statistics');
    } catch (e) {
      // Return mock statistics
      final campaigns = _getMockCampaigns();
      final totalCampaigns = campaigns.length;
      final activeCampaigns = campaigns.where((c) => c.isActive).length;
      final completedCampaigns = campaigns.where((c) => c.isCompleted).length;
      final totalBudget = campaigns.fold<double>(0, (sum, c) => sum + c.budget);
      final totalSpent = campaigns.fold<double>(0, (sum, c) => sum + c.spent);
      final totalImpressions = campaigns.fold<int>(0, (sum, c) => sum + c.impressions);
      final totalClicks = campaigns.fold<int>(0, (sum, c) => sum + c.clicks);
      final totalConversions = campaigns.fold<int>(0, (sum, c) => sum + c.conversions);
      
      return {
        'total_campaigns': totalCampaigns,
        'active_campaigns': activeCampaigns,
        'completed_campaigns': completedCampaigns,
        'total_budget': totalBudget,
        'total_spent': totalSpent,
        'budget_utilization': totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0,
        'total_impressions': totalImpressions,
        'total_clicks': totalClicks,
        'total_conversions': totalConversions,
        'average_ctr': totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0,
        'average_conversion_rate': totalClicks > 0 ? (totalConversions / totalClicks) * 100 : 0,
        'roi': totalSpent > 0 ? ((totalConversions * 50) - totalSpent) / totalSpent * 100 : 0, // Assuming $50 per conversion
      };
    }
  }

  // Mock data for development
  List<MarketingCampaign> _getMockCampaigns() {
    return [
      MarketingCampaign(
        id: 'camp_001',
        name: 'Summer Health Awareness Campaign',
        description: 'Promoting health supplements and vitamins during summer season',
        type: 'awareness',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        budget: 50000.00,
        spent: 32000.00,
        status: 'active',
        targetAudience: 'Adults 25-45, health conscious',
        targetProducts: ['prod_001', 'prod_002', 'prod_003'],
        targetRegions: ['Kathmandu', 'Pokhara', 'Chitwan'],
        imageUrl: 'https://example.com/campaign1.jpg',
        metrics: {
          'impressions': 125000,
          'clicks': 3500,
          'conversions': 180,
          'engagement_rate': 2.8,
          'cost_per_click': 9.14,
        },
        createdBy: 'marketing_001',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MarketingCampaign(
        id: 'camp_002',
        name: 'Paracetamol Discount Offer',
        description: '20% discount on paracetamol products for bulk orders',
        type: 'discount',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 10)),
        budget: 25000.00,
        spent: 18000.00,
        status: 'active',
        targetAudience: 'Pharmacies and medical stores',
        targetProducts: ['prod_001'],
        targetRegions: ['Kathmandu', 'Lalitpur', 'Bhaktapur'],
        imageUrl: 'https://example.com/campaign2.jpg',
        metrics: {
          'impressions': 85000,
          'clicks': 2100,
          'conversions': 95,
          'engagement_rate': 2.5,
          'cost_per_click': 8.57,
        },
        createdBy: 'marketing_002',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      MarketingCampaign(
        id: 'camp_003',
        name: 'New Product Launch - Antibiotic Series',
        description: 'Launch campaign for new antibiotic product line',
        type: 'launch',
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 45)),
        budget: 75000.00,
        spent: 5000.00,
        status: 'draft',
        targetAudience: 'Doctors, hospitals, clinics',
        targetProducts: ['prod_004', 'prod_005'],
        targetRegions: ['All regions'],
        imageUrl: 'https://example.com/campaign3.jpg',
        metrics: {
          'impressions': 0,
          'clicks': 0,
          'conversions': 0,
          'engagement_rate': 0,
          'cost_per_click': 0,
        },
        createdBy: 'marketing_001',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      MarketingCampaign(
        id: 'camp_004',
        name: 'Monsoon Season Promotion',
        description: 'Special offers on cold and flu medications',
        type: 'promotion',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().subtract(const Duration(days: 15)),
        budget: 40000.00,
        spent: 38500.00,
        status: 'completed',
        targetAudience: 'General public, families',
        targetProducts: ['prod_001', 'prod_003', 'prod_004'],
        targetRegions: ['Kathmandu', 'Pokhara', 'Biratnagar'],
        imageUrl: 'https://example.com/campaign4.jpg',
        metrics: {
          'impressions': 180000,
          'clicks': 5400,
          'conversions': 320,
          'engagement_rate': 3.0,
          'cost_per_click': 7.13,
        },
        createdBy: 'marketing_003',
        createdAt: DateTime.now().subtract(const Duration(days: 50)),
        updatedAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      MarketingCampaign(
        id: 'camp_005',
        name: 'Doctor Outreach Program',
        description: 'Direct marketing to medical practitioners',
        type: 'promotion',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 20)),
        budget: 30000.00,
        spent: 12000.00,
        status: 'paused',
        targetAudience: 'Medical practitioners, doctors',
        targetProducts: ['prod_002', 'prod_005'],
        targetRegions: ['Kathmandu Valley'],
        imageUrl: 'https://example.com/campaign5.jpg',
        metrics: {
          'impressions': 45000,
          'clicks': 1200,
          'conversions': 45,
          'engagement_rate': 2.7,
          'cost_per_click': 10.00,
        },
        createdBy: 'marketing_002',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
