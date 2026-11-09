import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/bk_academic_theme.dart';
import 'core/services/bk_notification_service.dart';
import 'features/bk_dashboard/presentation/screens/bk_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await BkNotificationService.instance.initialize();
  } catch (e) {
    debugPrint('Init notification error: $e');
  }
  runApp(
    const ProviderScope(
      child: SiMonpelBkSekolahApp(),
    ),
  );
}

class SiMonpelBkSekolahApp extends StatelessWidget {
  const SiMonpelBkSekolahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SI-MONPEL GURU BK SEKOLAH MOJOKERTO',
      debugShowCheckedModeBanner: false,
      theme: BkAcademicTheme.theme,
      home: const BkSplashScreen(),
    );
  }
}
