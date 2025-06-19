import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expiring_notification.dart';
import '../models/ingredient.dart';
import '../models/leftover.dart';
import '../services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  static const _shownKeysKey = 'shownNotificationKeys';
  static const _notificationsKey = 'storedNotifications';

  final List<ExpiringNotification> _notifications = [];

  List<ExpiringNotification> get notifications => _notifications;

  /// Load stored notifications from SharedPreferences, only if notifications are enabled
  Future<void> loadStoredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    if (!notificationsEnabled) {
      _notifications.clear();
      notifyListeners();
      return;
    }

    final jsonList = prefs.getStringList(_notificationsKey) ?? [];
    _notifications.clear();
    _notifications.addAll(jsonList.map((e) => ExpiringNotification.fromJson(json.decode(e))));
    notifyListeners();
  }

  /// Save all notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _notifications.map((n) => json.encode(n.toJson())).toList();
    await prefs.setStringList(_notificationsKey, jsonList);
  }

  Future<bool> _areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notificationsEnabled') ?? true;
  }

  String _generateKey(String title, String message) {
    return '$title|$message';
  }

  Future<Set<String>> _getShownNotificationKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_shownKeysKey)?.toSet() ?? {};
  }

  Future<void> _addNotificationKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_shownKeysKey)?.toSet() ?? {};
    keys.add(key);
    await prefs.setStringList(_shownKeysKey, keys.toList());
  }

  Future<void> _removeNotificationKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_shownKeysKey)?.toSet() ?? {};
    keys.remove(key);
    await prefs.setStringList(_shownKeysKey, keys.toList());
  }

  /// Add a single notification, respecting enabled status
  Future<void> addNotification(ExpiringNotification notification) async {
    final enabled = await _areNotificationsEnabled();
    if (!enabled) return;

    final key = _generateKey(notification.title, notification.message);
    final shownKeys = await _getShownNotificationKeys();
    if (!shownKeys.contains(key)) {
      _notifications.add(notification);
      await _saveNotifications();
      await _addNotificationKey(key);
      NotificationService.showNotification(
        title: notification.title,
        body: notification.message,
      );
      notifyListeners();
    }
  }

  /// Generate all notifications (ingredients + leftovers), only if notifications are enabled
  Future<void> generateNotifications(
      List<Ingredient> ingredients, List<Leftover> leftovers) async {
    final now = DateTime.now();
    final notificationsEnabled = await _areNotificationsEnabled();
    if (!notificationsEnabled) return;

    for (var ing in ingredients) {
      final daysLeft = ing.expiredDate.difference(now).inDays;
      String message;

      if (daysLeft < 0) {
        message = 'Ingredient "${ing.name}" has expired.';
      } else if (daysLeft == 0) {
        message = 'Ingredient "${ing.name}" expires today!';
      } else if (daysLeft <= 5) {
        message = 'Ingredient "${ing.name}" expires in $daysLeft day(s).';
      } else {
        continue;
      }

      final notification = ExpiringNotification(
        title: 'Ingredient Expiry Alert',
        message: message,
        image: ing.image,
        expiryDate: ing.expiredDate,
      );

      await addNotification(notification);
    }

    for (var l in leftovers) {
      if (l.expiryDate == null) continue;

      final daysLeft = l.expiryDate!.difference(now).inDays;
      String message;

      if (daysLeft < 0) {
        message = 'Leftover "${l.name}" has expired.';
      } else if (daysLeft == 0) {
        message = 'Leftover "${l.name}" expires today!';
      } else if (daysLeft <= 5) {
        message = 'Leftover "${l.name}" expires in $daysLeft day(s).';
      } else {
        continue;
      }

      final notification = ExpiringNotification(
        title: 'Leftover Expiry Alert',
        message: message,
        image: l.imageUrl ?? '',
        expiryDate: l.expiryDate!,
      );

      await addNotification(notification);
    }
  }

  /// Remove a specific notification and update stored keys
  Future<void> removeNotification(int index) async {
    if (index < 0 || index >= _notifications.length) return;
    final removed = _notifications.removeAt(index);
    final key = _generateKey(removed.title, removed.message);
    await _removeNotificationKey(key);
    await _saveNotifications();
    notifyListeners();
  }

  /// Clear all notifications and stored keys
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownKeysKey);
    await prefs.remove(_notificationsKey);
    notifyListeners();
  }
}
