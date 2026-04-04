import 'package:flutter/material.dart';
import '../../../shared/widgets/premium_glassmorphic_theme.dart';
import '../../domain/models/sales_tracking_models.dart';

class ForecastWidget extends StatelessWidget {
  final List<SalesForecast> forecasts;
  final bool isLoading;
  final String? error;
  final VoidCallback onGenerateForecast;

  const ForecastWidget({
    Key? key,
    required this.forecasts,
    required this.isLoading,
    this.error,
    required this.onGenerateForecast,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumGlassmorphicTheme.glassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Sales Forecast',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onGenerateForecast,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Generate'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (error != null)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else if (forecasts.isEmpty)
            _buildEmptyState(context)
          else
            _buildForecastList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: Colors.white.withOpacity(0.6),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No forecasts available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first sales forecast to see predictions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onGenerateForecast,
            icon: const Icon(Icons.add),
            label: const Text('Generate Forecast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastList(BuildContext context) {
    return Column(
      children: forecasts.map((forecast) => _buildForecastItem(context, forecast)).toList(),
    );
  }

  Widget _buildForecastItem(BuildContext context, SalesForecast forecast) {
    final confidenceColor = _getConfidenceColor(forecast.confidence);
    final confidenceText = _getConfidenceText(forecast.confidence);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      forecast.productName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      forecast.region,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: confidenceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: confidenceColor),
                ),
                child: Text(
                  confidenceText,
                  style: TextStyle(
                    color: confidenceColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildForecastMetric(
                  'Predicted Sales',
                  '${forecast.predictedSales.toInt()} units',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildForecastMetric(
                  'Predicted Revenue',
                  'NPR ${forecast.predictedRevenue.toInt()}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildForecastMetric(
                  'Forecast Date',
                  _formatDate(forecast.forecastDate),
                  Icons.calendar_today,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildForecastMetric(
                  'Confidence',
                  '${(forecast.confidence * 100).toStringAsFixed(0)}%',
                  Icons.trending_up,
                  confidenceColor,
                ),
              ),
            ],
          ),
          if (forecast.factors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Factors',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...forecast.factors.take(3).map((factor) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            factor,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastMetric(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.amber;
    return Colors.red;
  }

  String _getConfidenceText(double confidence) {
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.6) return 'Medium';
    return 'Low';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
