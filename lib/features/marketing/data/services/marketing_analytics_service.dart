import 'package:dio/dio.dart';
import '../../../core/api_config.dart';
import '../../domain/models/marketing_analytics.dart';
import '../../domain/models/marketing_campaign.dart';

class MarketingAnalyticsService {
  final Dio _dio = Dio();
  final String _baseUrl = ApiConfig.baseUrl;

  MarketingAnalyticsService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  // Get campaign analytics
  Future<Map<String, dynamic>> getCampaignAnalytics(String campaignId) async {
    try {
      final response = await _dio.get('/api/marketing/campaigns/$campaignId/analytics');

      if (response.statusCode == 200) {
        final analytics = MarketingAnalytics.fromJson(response.data);
        return {
          'success': true,
          'analytics': analytics,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch campaign analytics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching campaign analytics: ${e.toString()}',
      };
    }
  }

  // Get overall marketing analytics
  Future<Map<String, dynamic>> getMarketingAnalytics({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? campaignIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
      if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();
      if (campaignIds != null) queryParams['campaign_ids'] = campaignIds.join(',');

      final response = await _dio.get(
        '/api/marketing/analytics',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch marketing analytics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching marketing analytics: ${e.toString()}',
      };
    }
  }

  // Calculate marketing ROI
  Future<Map<String, dynamic>> calculateROI({
    required String campaignId,
    required double revenue,
    required double costs,
  }) async {
    try {
      final response = await _dio.post(
        '/api/marketing/roi',
        data: {
          'campaign_id': campaignId,
          'revenue': revenue,
          'costs': costs,
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'roi': response.data['roi'],
          'roi_percentage': response.data['roi_percentage'],
          'break_even_point': response.data['break_even_point'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to calculate ROI',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error calculating ROI: ${e.toString()}',
      };
    }
  }

  // Get customer segments
  Future<Map<String, dynamic>> getCustomerSegments() async {
    try {
      final response = await _dio.get('/api/marketing/customer-segments');

      if (response.statusCode == 200) {
        final segments = (response.data as List)
            .map((item) => CustomerSegment.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'segments': segments,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch customer segments',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching customer segments: ${e.toString()}',
      };
    }
  }

  // Create customer segment
  Future<Map<String, dynamic>> createCustomerSegment({
    required String name,
    required String description,
    required List<String> criteria,
  }) async {
    try {
      final response = await _dio.post(
        '/api/marketing/customer-segments',
        data: {
          'name': name,
          'description': description,
          'criteria': criteria,
        },
      );

      if (response.statusCode == 201) {
        final segment = CustomerSegment.fromJson(response.data);
        return {
          'success': true,
          'segment': segment,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create customer segment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating customer segment: ${e.toString()}',
      };
    }
  }

  // Get marketing channels performance
  Future<Map<String, dynamic>> getMarketingChannelsPerformance() async {
    try {
      final response = await _dio.get('/api/marketing/channels/performance');

      if (response.statusCode == 200) {
        final channels = (response.data as List)
            .map((item) => MarketingChannel.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'channels': channels,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch marketing channels performance',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching marketing channels performance: ${e.toString()}',
      };
    }
  }

  // Get attribution models
  Future<Map<String, dynamic>> getAttributionModels() async {
    try {
      final response = await _dio.get('/api/marketing/attribution/models');

      if (response.statusCode == 200) {
        final models = (response.data as List)
            .map((item) => AttributionModel.fromJson(item as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'models': models,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch attribution models',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching attribution models: ${e.toString()}',
      };
    }
  }

  // Create attribution model
  Future<Map<String, dynamic>> createAttributionModel({
    required String name,
    required String type,
    required Map<String, double> channelWeights,
  }) async {
    try {
      final response = await _dio.post(
        '/api/marketing/attribution/models',
        data: {
          'name': name,
          'type': type,
          'channel_weights': channelWeights,
        },
      );

      if (response.statusCode == 201) {
        final model = AttributionModel.fromJson(response.data);
        return {
          'success': true,
          'model': model,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create attribution model',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating attribution model: ${e.toString()}',
      };
    }
  }

  // Track conversion event
  Future<Map<String, dynamic>> trackConversion({
    required String campaignId,
    required String customerId,
    required String eventType,
    required double value,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/api/marketing/conversions/track',
        data: {
          'campaign_id': campaignId,
          'customer_id': customerId,
          'event_type': eventType,
          'value': value,
          'metadata': metadata ?? {},
        },
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'conversion_id': response.data['conversion_id'],
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to track conversion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error tracking conversion: ${e.toString()}',
      };
    }
  }

  // Get campaign performance comparison
  Future<Map<String, dynamic>> getCampaignComparison(List<String> campaignIds) async {
    try {
      final response = await _dio.post(
        '/api/marketing/campaigns/compare',
        data: {'campaign_ids': campaignIds},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'comparison': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get campaign comparison',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error getting campaign comparison: ${e.toString()}',
      };
    }
  }

  // Generate marketing insights
  Future<Map<String, dynamic>> generateMarketingInsights({
    String? period,
    List<String>? campaignIds,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (period != null) queryParams['period'] = period;
      if (campaignIds != null) queryParams['campaign_ids'] = campaignIds.join(',');

      final response = await _dio.get(
        '/api/marketing/insights',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'insights': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to generate marketing insights',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error generating marketing insights: ${e.toString()}',
      };
    }
  }

  // Update campaign metrics
  Future<Map<String, dynamic>> updateCampaignMetrics(
    String campaignId,
    Map<String, dynamic> metrics,
  ) async {
    try {
      final response = await _dio.put(
        '/api/marketing/campaigns/$campaignId/metrics',
        data: metrics,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Campaign metrics updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update campaign metrics',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating campaign metrics: ${e.toString()}',
      };
    }
  }
}
