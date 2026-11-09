import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Filter Background Notification:
  // 1. Cek target aplikasi
  if (message.data['targetApp'] != null && message.data['targetApp'] != 'SCHOOL_BK_APP') {
    return;
  }
  // 2. Cek apakah pengguna saat ini sedang login sebagai Guru BK
  const storage = FlutterSecureStorage();
  final userJson = await storage.read(key: 'school_bk_user_data');
  if (userJson == null && message.data['missedNotification'] != 'true') {
    // Pengguna belum login atau sudah logout di aplikasi BK, abaikan notifikasi
    return;
  }

  // Tampilkan notifikasi lokal di background jika user sedang login
  final localNotifications = FlutterLocalNotificationsPlugin();
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  await localNotifications.initialize(const InitializationSettings(android: androidSettings));

  final title = message.data['title'] ?? 'Notifikasi Tilang Siswa';
  final body = message.data['body'] ?? '';

  await localNotifications.show(
    message.hashCode,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'bk_school_violation_channel',
        'Notifikasi Tilang Siswa Sekolah',
        channelDescription: 'Disposisi penindakan tilang siswa khusus Guru BK sekolah terkait',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

class BkNotificationService {
  static final BkNotificationService instance = BkNotificationService._internal();
  BkNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'bk_school_violation_channel',
    'Notifikasi Tilang Siswa Sekolah',
    description: 'Disposisi penindakan tilang siswa khusus Guru BK sekolah terkait',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Setup Local Notifications
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initSettings);

      // Create Android Notification Channel
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(_channel);
      }

      // Request permission for push notifications (Android 13+)
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground message listener dengan filter khusus aplikasi Guru BK
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final data = message.data;
        final String? targetApp = data['targetApp'];

        // 1. Tolak jika notifikasi ini BUKAN untuk aplikasi Guru BK (misalnya alert untuk Polri)
        if (targetApp != null && targetApp != 'SCHOOL_BK_APP') {
          return;
        }

        // 2. Pastikan akun Guru BK sedang login (kecuali missedNotification yang baru dikirim saat login)
        final userJson = await _storage.read(key: 'school_bk_user_data');
        if (userJson == null && data['missedNotification'] != 'true') {
          return;
        }

        final notification = message.notification;
        final title = notification?.title ?? data['title'] ?? 'Notifikasi Tilang Siswa';
        final body = notification?.body ?? data['body'] ?? '';

        _localNotifications.show(
          message.hashCode,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      });

      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('FCM initialization warning: $e');
      }
    }
  }

  Future<String?> getFcmToken() async {
    try {
      if (!_initialized) {
        await initialize();
      }
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get FCM token: $e');
      }
      return null;
    }
  }
}

