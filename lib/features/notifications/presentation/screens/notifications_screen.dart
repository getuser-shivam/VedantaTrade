import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vedanta_trade/features/notifications/presentation/providers/notification_provider.dart';
import 'package:vedanta_trade/features/notifications/domain/models/app_notification.dart' as app_notification;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              if (notificationProvider.unreadCount > 0) {
                return TextButton(
                  onPressed: () async {
                    await notificationProvider.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        backgroundColor: Color(0xFF2E7D32),
                      ),
                    );
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.notifications.isEmpty) {
            return _buildEmptyNotifications(context);
          }

          return Column(
            children: [
              if (notificationProvider.unreadCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                  child: Text(
                    '${notificationProvider.unreadCount} unread notification${notificationProvider.unreadCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: const Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notificationProvider.notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notificationProvider.notifications[index];
                    return _buildNotificationCard(
                      context,
                      notification,
                      notificationProvider,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyNotifications(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you about important updates',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    app_notification.AppNotification notification,
    NotificationProvider notificationProvider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? Colors.white : Colors.grey[50],
      child: InkWell(
        onTap: () async {
          if (!notification.isRead) {
            await notificationProvider.markAsRead(notification.id);
          }
          _handleNotificationTap(context, notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    notification.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead 
                                  ? FontWeight.normal 
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'mark_read':
                                await notificationProvider.markAsRead(notification.id);
                                break;
                              case 'delete':
                                await notificationProvider.deleteNotification(notification.id);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            if (!notification.isRead)
                              const PopupMenuItem(
                                value: 'mark_read',
                                child: Row(
                                  children: [
                                    Icon(Icons.mark_email_read, size: 16),
                                    SizedBox(width: 8),
                                    Text('Mark as read'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          child: Icon(Icons.more_vert, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(notification.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2E7D32),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order_status':
        return const Color(0xFF2E7D32);
      case 'promotion':
        return const Color(0xFFFF9800);
      case 'new_product':
        return const Color(0xFF4CAF50);
      case 'price_drop':
        return const Color(0xFF9C27B0);
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  void _handleNotificationTap(BuildContext context, app_notification.AppNotification notification) {
    switch (notification.type) {
      case 'order_status':
        // Navigate to order details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Opening order details...')),
        );
        break;
      case 'promotion':
        // Navigate to promotions or home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing promotional offers...')),
        );
        break;
      case 'new_product':
        // Navigate to product catalog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Browsing new products...')),
        );
        break;
      case 'price_drop':
        // Navigate to product details
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Viewing product...')),
        );
        break;
      default:
        // Default action
        break;
    }
  }
}
