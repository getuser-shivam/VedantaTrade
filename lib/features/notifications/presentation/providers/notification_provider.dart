import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:vedanta_trade/features/notifications/domain/models/app_notification.dart' as app_notification;

class NotificationProvider extends ChangeNotifier {
  List<app_notification.AppNotification> _notifications = [];
  bool _isLoading = false;

  List<app_notification.AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  List<app_notification.AppNotification> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();

  NotificationProvider() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsData = prefs.getString('notifications');
      
      if (notificationsData != null) {
        final List<dynamic> decoded = json.decode(notificationsData);
        _notifications = decoded
            .map((notification) => app_notification.AppNotification.fromJson(notification))
            .toList();
        notifyListeners();
      } else {
        // Add some sample notifications for demo
        _addSampleNotifications();
      }
    } catch (e) {
      
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsData = json.encode(
          _notifications.map((notification) => notification.toJson()).toList());
      await prefs.setString('notifications', notificationsData);
    } catch (e) {
      
    }
  }

  void _addSampleNotifications() {
    final sampleNotifications = [
      app_notification.AppNotification.orderStatusUpdate(
        orderId: 'ORD123456789',
        status: 'Delivered',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      app_notification.AppNotification.promotionalOffer(
        title: 'Special Offer!',
        description: 'Get 20% off on all prenatal care products this week',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      app_notification.AppNotification.newProduct(
        productName: 'VitaBoost Plus',
        category: 'Vitamin Supplements',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      app_notification.AppNotification.wishlistPriceDrop(
        productName: 'ARGIVIT',
        oldPrice: 350.0,
        newPrice: 299.0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    _notifications = sampleNotifications;
    _saveNotifications();
    notifyListeners();
  }

  Future<void> addNotification(app_notification.AppNotification notification) async {
    _notifications.insert(0, notification);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
    notifyListeners();
  }

  // Helper methods to create different types of notifications
  Future<void> addOrderStatusNotification({
    required String orderId,
    required String status,
  }) async {
    final notification = app_notification.AppNotification.orderStatusUpdate(
      orderId: orderId,
      status: status,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  Future<void> addPromotionalNotification({
    required String title,
    required String description,
  }) async {
    final notification = app_notification.AppNotification.promotionalOffer(
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  Future<void> addNewProductNotification({
    required String productName,
    required String category,
  }) async {
    final notification = app_notification.AppNotification.newProduct(
      productName: productName,
      category: category,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  Future<void> addPriceDropNotification({
    required String productName,
    required double oldPrice,
    required double newPrice,
  }) async {
    final notification = app_notification.AppNotification.wishlistPriceDrop(
      productName: productName,
      oldPrice: oldPrice,
      newPrice: newPrice,
      createdAt: DateTime.now(),
    );
    await addNotification(notification);
  }

  // Get notifications by type
  List<app_notification.AppNotification> getNotificationsByType(String type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Get recent notifications (last 7 days)
  List<app_notification.AppNotification> getRecentNotifications() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notifications.where((n) => n.createdAt.isAfter(sevenDaysAgo)).toList();
  }
}
