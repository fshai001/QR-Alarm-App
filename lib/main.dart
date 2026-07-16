import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'services/alarm_service.dart';
import 'screens/home_screen.dart';
import 'screens/alarm_ring_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up notification channel + permissions (exact alarms, notifications)
  await AlarmService.initNotifications();

  // If the app was fully closed and got launched by tapping/opening the
  // alarm notification, jump straight into the ring screen.
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  final NotificationAppLaunchDetails? launchDetails =
      await notifications.getNotificationAppLaunchDetails();
  final String? launchPayload =
      launchDetails?.didNotificationLaunchApp == true
          ? launchDetails!.notificationResponse?.payload
          : null;

  runApp(
    ChangeNotifierProvider(
      create: (context) => AlarmService()..loadAlarms(),
      child: QRAlarmApp(initialAlarmPayload: launchPayload),
    ),
  );

  // If the app was already running (foreground/background) and the user
  // taps the alarm notification, navigate to the ring screen.
  final FlutterLocalNotificationsPlugin taps = FlutterLocalNotificationsPlugin();
  taps.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      final payload = response.payload ?? '';
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(
            targetQrValue: payload,
            alarmLabel: 'Alarm Ringing',
          ),
        ),
      );
    },
  );
}

class QRAlarmApp extends StatelessWidget {
  final String? initialAlarmPayload;
  const QRAlarmApp({super.key, this.initialAlarmPayload});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'QR Alarm Clock',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.amberAccent,
        ),
        useMaterial3: true,
      ),
      home: initialAlarmPayload != null
          ? AlarmRingScreen(
              targetQrValue: initialAlarmPayload!,
              alarmLabel: 'Alarm Ringing',
            )
          : const HomeScreen(),
    );
  }
}
