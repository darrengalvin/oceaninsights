import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../features/affirmations/data/affirmations_data.dart';

/// Service for managing push notifications
/// Handles daily affirmation notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  static const String _enabledKey = 'notifications_enabled';
  static const String _timeHourKey = 'notification_time_hour';
  static const String _timeMinuteKey = 'notification_time_minute';
  static const int _dailyAffirmationId = 1001;

  bool _isInitialized = false;
  SharedPreferences? _prefs;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz_data.initializeTimeZones();

      // Initialize preferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
      debugPrint('✅ Notification Service initialized');

      // Reschedule if enabled
      if (isEnabled) {
        await scheduleDailyAffirmation();
      }
    } catch (e) {
      // Plugin not available (simulator, hot restart, or missing native setup)
      debugPrint('⚠️ Notification Service unavailable: $e');
      _isInitialized = false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('🔔 Notification tapped: ${response.payload}');
    // Could navigate to affirmations screen here
  }

  /// Check if notifications are enabled
  bool get isEnabled {
    return _prefs?.getBool(_enabledKey) ?? false;
  }

  /// Get the scheduled notification time
  TimeOfDay get scheduledTime {
    final hour = _prefs?.getInt(_timeHourKey) ?? 8; // Default 8 AM
    final minute = _prefs?.getInt(_timeMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Request notification permissions
  Future<bool> requestPermission() async {
    if (!_isInitialized) return false;
    
    try {
      // iOS permission request
      final iOS = await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // Android permission request (Android 13+)
      final android = await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      final granted = (iOS ?? true) && (android ?? true);
      debugPrint(granted ? '✅ Notifications permission granted' : '❌ Notifications permission denied');
      
      return granted;
    } catch (e) {
      debugPrint('⚠️ Permission request failed: $e');
      return false;
    }
  }

  /// Enable or disable notifications
  Future<void> setEnabled(bool enabled) async {
    await _prefs?.setBool(_enabledKey, enabled);
    
    if (enabled) {
      final permissionGranted = await requestPermission();
      if (permissionGranted) {
        await scheduleDailyAffirmation();
        debugPrint('✅ Daily affirmation notifications enabled');
      } else {
        // Permission denied, disable setting
        await _prefs?.setBool(_enabledKey, false);
      }
    } else {
      await cancelDailyAffirmation();
      debugPrint('🔕 Daily affirmation notifications disabled');
    }
  }

  /// Set the notification time
  Future<void> setNotificationTime(TimeOfDay time) async {
    await _prefs?.setInt(_timeHourKey, time.hour);
    await _prefs?.setInt(_timeMinuteKey, time.minute);
    
    // Reschedule if enabled
    if (isEnabled) {
      await scheduleDailyAffirmation();
    }
  }

  /// Schedule the daily affirmation notification
  Future<void> scheduleDailyAffirmation() async {
    if (!_isInitialized) return;
    
    try {
      // Cancel existing
      await cancelDailyAffirmation();

      // Get a random affirmation
      final affirmation = _getRandomAffirmation();
      
      // Get scheduled time
      final time = scheduledTime;
      
      // Calculate next occurrence
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      
      // If time has passed today, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Notification details
      final androidDetails = AndroidNotificationDetails(
        'daily_affirmation',
        'Daily Affirmations',
        channelDescription: 'Your daily positive affirmation',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule the notification
      await _notifications.zonedSchedule(
        id: _dailyAffirmationId,
        title: 'Daily Affirmation 🌊',
        body: affirmation,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'affirmation',
      );

      debugPrint('📅 Scheduled daily affirmation at ${time.hour}:${time.minute.toString().padLeft(2, '0')}');
    } catch (e) {
      debugPrint('⚠️ Failed to schedule notification: $e');
    }
  }

  /// Cancel the daily affirmation notification
  Future<void> cancelDailyAffirmation() async {
    if (!_isInitialized) return;
    try {
      await _notifications.cancel(id: _dailyAffirmationId);
    } catch (e) {
      debugPrint('⚠️ Failed to cancel notification: $e');
    }
  }

  /// Get a random affirmation
  String _getRandomAffirmation() {
    final random = Random();
    final affirmations = AffirmationsData.affirmations;
    
    if (affirmations.isEmpty) {
      return 'You are capable of amazing things.';
    }
    
    // Pick a random affirmation
    final affirmation = affirmations[random.nextInt(affirmations.length)];
    return affirmation.text;
  }

  /// Send a test notification immediately
  Future<void> sendTestNotification() async {
    if (!_isInitialized) {
      debugPrint('⚠️ Notifications not available');
      return;
    }
    
    try {
      final androidDetails = AndroidNotificationDetails(
        'daily_affirmation',
        'Daily Affirmations',
        channelDescription: 'Your daily positive affirmation',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final affirmation = _getRandomAffirmation();
      
      await _notifications.show(
        id: 0,
        title: 'Daily Affirmation 🌊',
        body: affirmation,
        notificationDetails: details,
      );
      
      debugPrint('📤 Test notification sent: $affirmation');
    } catch (e) {
      debugPrint('⚠️ Failed to send test notification: $e');
    }
  }
  
  /// Check if notification service is available
  bool get isAvailable => _isInitialized;
}
