import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleExpirationNotification({
    required int id,
    required String title,
    required String body,
    required DateTime expirationDate,
  }) async {
    final scheduledDate = expirationDate.subtract(const Duration(days: 5));

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'expiration_channel',
          'Validade de Produtos',
          channelDescription: 'Notificações sobre validade de produtos',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showLowStockNotification({
    required int id,
    required String productName,
    required double currentStock,
  }) async {
    await _notificationsPlugin.show(
      id,
      'Estoque Baixo',
      '$productName está com estoque crítico (${currentStock.toStringAsFixed(2)} ${_getUnitName(currentStock)})',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'stock_channel',
          'Controle de Estoque',
          channelDescription: 'Alertas de estoque mínimo',
          importance: Importance.high,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(sound: 'default', presentAlert: true),
      ),
    );
  }

  String _getUnitName(double quantity) =>
      quantity == 1 ? 'unidade' : 'unidades';

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
