import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

/// Сервис для управления уведомлениями.
///
/// Этот класс предоставляет методы для инициализации уведомлений,
/// их отображения, планирования и отмены.
class NotiService {
  static final FlutterLocalNotificationsPlugin notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInit = false; // Флаг инициализации сервиса

  bool get isInit => _isInit; // Геттер для проверки инициализации

  /// Инициализация уведомлений.
  Future<void> initNotification() async {
    if (_isInit) return; // Если уже инициализировано, выходим

    try {
      const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );

      await notificationPlugin.initialize(initSettings); // Инициализация плагина уведомлений

      // Запрос разрешений на уведомления
      var notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        notificationStatus = await Permission.notification.request();
      }

      if (notificationStatus.isGranted) {
      } else {
        if (Platform.isAndroid) {
          openAppSettings(); // Перенаправление в настройки только на Android
        }
      }

      _isInit = true; // Установка флага инициализации
    } catch (e) {
      print('Ошибка инициализации уведомлений: $e');
    }
  }

  /// Создает детали уведомления.
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channel_id',
        'notifications',
        channelDescription: 'Notifications channel', // Описание канала
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true, // Включить вибрацию
        playSound: true, // Включить звук
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Показывает уведомление.
  Future<void> showNotifications({
    int id = 0,
    String? title,
    String? body,
  }) async {
    try {
      await notificationPlugin.show(id, title, body, notificationDetails());
    } catch (e) {
      print('Ошибка показа уведомления $id: $e');
    }
  }

  /// Планирует уведомление на указанную дату.
  Future<void> scheduleNotification(
      DateTime dueDate, {
        int id = 0,
        String? title,
        String? body,
      }) async {
    try {
      // Проверка разрешения на точные будильники
      if (Platform.isAndroid && await Permission.scheduleExactAlarm.request().isGranted) {
        await notificationPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(dueDate, tz.local),
          notificationDetails(),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );

      } else if (!Platform.isAndroid) {
        await notificationPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(dueDate, tz.local),
          notificationDetails(),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
        );
      } else {
        if (Platform.isAndroid) {
          openAppSettings(); // Открыть настройки для предоставления разрешения только на Android
        }
      }
    } catch (e) {
      print('Ошибка планирования уведомления $id: $e');
    }
  }

  /// Отменяет уведомление по указанному идентификатору.
  Future<void> cancelNotification(int id) async {
    try {
      await notificationPlugin.cancel(id);
    } catch (e) {
      print('Ошибка отмены уведомления $id: $e');
    }
  }
}
