import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class ActivityItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final ActivityType type;

  ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.timestamp,
    required this.type,
  });
}

enum ActivityType {
  center,
  inventory,
  campaign,
  route,
  alert,
  success,
  error,
}

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activities = _getSampleActivities();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => _viewAllActivity(context),
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ActivityTile(activity: activity);
              },
            ),
          ],
        ),
      ),
    );
  }

  List<ActivityItem> _getSampleActivities() {
    final now = DateTime.now();
    return [
      ActivityItem(
        id: '1',
        title: 'New Distribution Center Added',
        description: 'Mumbai Central Center has been added to the system',
        icon: Icons.add_location,
        color: AppTheme.primaryColor,
        timestamp: now.subtract(const Duration(hours: 2)),
        type: ActivityType.center,
      ),
      ActivityItem(
        id: '2',
        title: 'Inventory Allocated',
        description: '500 units of Product A allocated to Delhi Center',
        icon: Icons.inventory_2,
        color: AppTheme.successColor,
        timestamp: now.subtract(const Duration(hours: 4)),
        type: ActivityType.inventory,
      ),
      ActivityItem(
        id: '3',
        title: 'Campaign Launched',
        description: 'Summer Sale 2024 campaign has been launched',
        icon: Icons.campaign,
        color: AppTheme.secondaryColor,
        timestamp: now.subtract(const Duration(hours: 6)),
        type: ActivityType.campaign,
      ),
      ActivityItem(
        id: '4',
        title: 'Low Stock Alert',
        description: 'Product B is running low on Bangalore Center',
        icon: Icons.warning,
        color: AppTheme.warningColor,
        timestamp: now.subtract(const Duration(hours: 8)),
        type: ActivityType.alert,
      ),
      ActivityItem(
        id: '5',
        title: 'Route Completed',
        description: 'Delivery route #123 has been completed successfully',
        icon: Icons.route,
        color: AppTheme.infoColor,
        timestamp: now.subtract(const Duration(days: 1)),
        type: ActivityType.route,
      ),
    ];
  }

  void _viewAllActivity(BuildContext context) {
    // Navigate to all activity screen
  }
}

class ActivityTile extends StatelessWidget {
  final ActivityItem activity;

  const ActivityTile({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(activity.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activity.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity.icon,
              color: activity.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class ActivityDetailScreen extends StatelessWidget {
  final ActivityItem activity;

  const ActivityDetailScreen({
    Key? key,
    required this.activity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    activity.color.withOpacity(0.1),
                    activity.color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: activity.color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: activity.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      activity.icon,
                      color: activity.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    activity.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Activity Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      theme,
                      'Type',
                      _getActivityTypeString(activity.type),
                    ),
                    _buildDetailRow(
                      theme,
                      'Time',
                      _formatDateTime(activity.timestamp),
                    ),
                    _buildDetailRow(
                      theme,
                      'Status',
                      'Completed',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActivityTypeString(ActivityType type) {
    switch (type) {
      case ActivityType.center:
        return 'Distribution Center';
      case ActivityType.inventory:
        return 'Inventory Management';
      case ActivityType.campaign:
        return 'Marketing Campaign';
      case ActivityType.route:
        return 'Route Management';
      case ActivityType.alert:
        return 'System Alert';
      case ActivityType.success:
        return 'Success';
      case ActivityType.error:
        return 'Error';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
