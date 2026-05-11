import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

final _notifications = FlutterLocalNotificationsPlugin();

const _channelId = 'standup_channel';
const _channelName = 'Standup Reminders';
const _taskName = 'standupReminder';
const _taskId = 'standup-reminder';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _taskName) {
      await _notifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _notifications.show(
        0,
        'Standup Time! 📱',
        'Your standup update is ready. Tap to review and send.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
    return true;
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await Workmanager().initialize(callbackDispatcher);

    await Workmanager().registerPeriodicTask(
      _taskId,
      _taskName,
      frequency: const Duration(days: 1),
      initialDelay: _delayUntil9_55AM(),
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Duration _delayUntil9_55AM() {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, 9, 55);
    if (now.isAfter(target)) target = target.add(const Duration(days: 1));
    return target.difference(now);
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
