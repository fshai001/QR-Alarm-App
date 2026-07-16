import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm.dart';

class AlarmService extends ChangeNotifier {
  List<Alarm> _alarms = [];
  List<Alarm> get alarms => _alarms;

  static const String _prefKey = 'saved_alarms';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Call once from main() before runApp().
  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'qr_alarm_channel_id',
      'QR Alarm Notifications',
      description: 'Fires when your QR alarm rings',
      importance: Importance.max,
    );
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();
  }

  Future<void> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(_prefKey);
    if (alarmsJson != null) {
      final List<dynamic> decoded = jsonDecode(alarmsJson);
      _alarms = decoded.map((item) => Alarm.fromMap(item)).toList();
    } else {
      // Default Alarm
      _alarms = [
        Alarm(
          id: '1',
          time: '07:00',
          label: 'Wake Up & Scan Mug',
          isActive: true,
          qrValue: 'MUG_QR',
          days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        ),
      ];
    }
    notifyListeners();
  }

  Future<void> saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_alarms.map((a) => a.toMap()).toList());
    await prefs.setString(_prefKey, encoded);
    notifyListeners();
  }

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    if (alarm.isActive) {
      _scheduleDeviceAlarm(alarm);
    }
    saveAlarms();
  }

  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updatedAlarm = _alarms[index].copyWith(isActive: !_alarms[index].isActive);
      _alarms[index] = updatedAlarm;
      if (updatedAlarm.isActive) {
        _scheduleDeviceAlarm(updatedAlarm);
      } else {
        _cancelDeviceAlarm(updatedAlarm);
      }
      saveAlarms();
    }
  }

  void deleteAlarm(String id) {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    _cancelDeviceAlarm(alarm);
    _alarms.removeWhere((a) => a.id == id);
    saveAlarms();
  }

  // --- OS-Level Scheduling via flutter_local_notifications ---
  // No separate background isolate/plugin needed: a full-screen-intent
  // notification is scheduled directly with the OS, which wakes/unlocks
  // the device and launches the app to AlarmRingScreen at the right time.

  static Future<void> _scheduleDeviceAlarm(Alarm alarm) async {
    final parts = alarm.time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = DateTime.now();
    var scheduledLocal = DateTime(now.year, now.month, now.day, hour, minute);
    if (scheduledLocal.isBefore(now)) {
      scheduledLocal = scheduledLocal.add(const Duration(days: 1));
    }

    // We only need the correct absolute instant (Dart's local DateTime
    // already carries the device's real UTC offset), so wrapping it as a
    // UTC-referenced TZDateTime is sufficient and avoids needing a separate
    // timezone-name plugin.
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(scheduledLocal.toUtc(), tz.UTC);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'qr_alarm_channel_id',
      'QR Alarm Notifications',
      channelDescription: 'Fires when your QR alarm rings',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true, // Wakes/unlocks screen and launches the app
      ongoing: true,
      category: AndroidNotificationCategory.alarm,
      styleInformation: BigTextStyleInformation(''),
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      alarm.id.hashCode,
      'ALARM RINGING!',
      'Scan your registered QR Code to dismiss!',
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // repeats daily automatically
      payload: alarm.qrValue,
    );
  }

  static Future<void> _cancelDeviceAlarm(Alarm alarm) async {
    await _notifications.cancel(alarm.id.hashCode);
  }
}
