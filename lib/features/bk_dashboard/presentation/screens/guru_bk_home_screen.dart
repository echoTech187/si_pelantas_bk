import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/bk_dio_client.dart';
import '../../../../core/theme/bk_academic_theme.dart';
import '../../../../core/widgets/sipelantas_bottom_nav.dart';
import '../bk_auth_controller.dart';
import 'bk_guidance_screen.dart';
import 'bk_home_dashboard_view.dart';
import 'bk_login_screen.dart';
import 'bk_profile_screen.dart';

final bkNavIndexProvider = StateProvider<int>((ref) => 0);

final bkDashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch authState so when login occurs, this provider automatically invalidates and fetches afresh with the new token
  final authState = ref.watch(bkAuthStateProvider);
  if (!authState.isAuthenticated) {
    return <String, dynamic>{};
  }
  final dio = ref.watch(bkDioClientProvider);
  final res = await dio.get('/dashboard');
  return res.data['data'] as Map<String, dynamic>;
});

class GuruBkHomeScreen extends ConsumerStatefulWidget {
  const GuruBkHomeScreen({super.key});

  @override
  ConsumerState<GuruBkHomeScreen> createState() => _GuruBkHomeScreenState();
}

class _GuruBkHomeScreenState extends ConsumerState<GuruBkHomeScreen> {
  Timer? _pollingTimer;
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    // 1. Polling berkala setiap 5 detik agar data tilang baru otomatis muncul
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        ref.invalidate(bkDashboardDataProvider);
      }
    });

    // 2. Real-time update instan begitu menerima notifikasi tilang siswa dari FCM
    _fcmSubscription = FirebaseMessaging.onMessage.listen((_) {
      if (mounted) {
        ref.invalidate(bkDashboardDataProvider);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BkAuthState>(bkAuthStateProvider, (previous, next) {
      if (previous?.isAuthenticated != next.isAuthenticated && next.isAuthenticated) {
        ref.read(bkNavIndexProvider.notifier).state = 0;
      }
    });

    final authState = ref.watch(bkAuthStateProvider);
    final currentIndex = ref.watch(bkNavIndexProvider);
    final dashboardAsync = ref.watch(bkDashboardDataProvider);

    Widget bodyWidget;
    Widget? bottomNavWidget;

    if (!authState.isAuthenticated || authState.user == null) {
      bodyWidget = const BkLoginScreen(key: ValueKey('bk_login_screen'));
      bottomNavWidget = null;
    } else {
      final user = authState.user!;

      final navItems = [
        const SipelantasNavItem(
          icon: Icons.home_outlined,
          label: 'Beranda',
        ),
        const SipelantasNavItem(
          icon: Icons.psychology_outlined,
          label: 'Bimbingan',
        ),
        const SipelantasNavItem(
          icon: Icons.person_outline,
          label: 'Profile',
        ),
      ];

      final List<Widget> pages = [
        dashboardAsync.when(
          data: (dashboardMap) => BkHomeDashboardView(
            user: user,
            data: dashboardMap,
            onNavigateToGuidance: () {
              ref.read(bkNavIndexProvider.notifier).state = 1;
            },
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: BkAcademicColors.emeraldAccent),
          ),
          error: (err, _) => Center(
            child: Text('Gagal memuat dashboard: $err', style: const TextStyle(color: Colors.redAccent)),
          ),
        ),
        const BkGuidanceScreen(),
        BkProfileScreen(user: user),
      ];

      bodyWidget = IndexedStack(
        key: const ValueKey('bk_main_flow'),
        index: currentIndex,
        children: pages,
      );

      bottomNavWidget = SipelantasBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bkNavIndexProvider.notifier).state = index;
        },
        items: navItems,
        backgroundColor: const Color(0xFF131D31),
        activeColor: BkAcademicColors.emeraldAccent,
        inactiveColor: const Color(0xFF64748B),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0C1322),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: bodyWidget,
      ),
      bottomNavigationBar: bottomNavWidget,
    );
  }
}
