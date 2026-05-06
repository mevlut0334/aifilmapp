// lib/core/jobs/job_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class JobNotificationService {
  JobNotificationService._internal();
  static final instance = JobNotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId = 'upload_jobs';
  static const _channelName = 'Upload Jobs';
  static const _channelDesc = 'Görsel ve video yükleme bildirimleri';

  // ─── Init ────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS),
    );

    // Tek satırda yazılmalı — çok satırlı generic Dart'ta parse hatası verir
    final AndroidFlutterLocalNotificationsPlugin? androidImpl =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      await androidImpl.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );
    }
  }

  // ─── Bildirimler ─────────────────────────────────────────────────────────

  Future<void> showSuccess({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _details());
  }

  Future<void> showFailure({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _details());
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  // ─── Private ─────────────────────────────────────────────────────────────

  NotificationDetails _details() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}