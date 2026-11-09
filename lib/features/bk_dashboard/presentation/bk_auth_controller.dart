import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/bk_dio_client.dart';
import '../../../core/services/bk_notification_service.dart';

class BkUser {
  final String id;
  final String schoolId;
  final String nipOrNuptk;
  final String username;
  final String fullName;
  final String phoneWa;
  final bool isPrimaryPic;
  final String? schoolName;
  final String? schoolNpsn;
  final String? photoUrl;

  const BkUser({
    required this.id,
    required this.schoolId,
    required this.nipOrNuptk,
    required this.username,
    required this.fullName,
    required this.phoneWa,
    required this.isPrimaryPic,
    this.schoolName,
    this.schoolNpsn,
    this.photoUrl,
  });

  factory BkUser.fromJson(Map<String, dynamic> json) {
    return BkUser(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      nipOrNuptk: json['nipOrNuptk'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      phoneWa: json['phoneWa'] as String,
      isPrimaryPic: json['isPrimaryPic'] as bool? ?? true,
      schoolName: json['schoolName'] as String?,
      schoolNpsn: json['schoolNpsn'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schoolId': schoolId,
        'nipOrNuptk': nipOrNuptk,
        'username': username,
        'fullName': fullName,
        'phoneWa': phoneWa,
        'isPrimaryPic': isPrimaryPic,
        'schoolName': schoolName,
        'schoolNpsn': schoolNpsn,
        'photoUrl': photoUrl,
      };

  BkUser copyWith({
    String? fullName,
    String? phoneWa,
    String? photoUrl,
  }) {
    return BkUser(
      id: id,
      schoolId: schoolId,
      nipOrNuptk: nipOrNuptk,
      username: username,
      fullName: fullName ?? this.fullName,
      phoneWa: phoneWa ?? this.phoneWa,
      isPrimaryPic: isPrimaryPic,
      schoolName: schoolName,
      schoolNpsn: schoolNpsn,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}

class BkAuthState {
  final bool isLoading;
  final BkUser? user;
  final String? errorMessage;

  const BkAuthState({
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;

  BkAuthState copyWith({
    bool? isLoading,
    BkUser? user,
    String? errorMessage,
  }) {
    return BkAuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

class BkAuthNotifier extends StateNotifier<BkAuthState> {
  final Ref ref;

  BkAuthNotifier(this.ref) : super(const BkAuthState()) {
    checkCurrentSession();
  }

  Future<void> checkCurrentSession() async {
    final storage = ref.read(bkSecureStorageProvider);
    final token = await storage.read(key: 'school_bk_jwt_access_token');
    final userJson = await storage.read(key: 'school_bk_user_data');

    if (token != null && userJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(userJson);
        final user = BkUser.fromJson(decoded);
        state = BkAuthState(user: user);

        // Auto-sinkronisasi FCM token setiap kali sesi dicek/aplikasi dibuka
        final fcmToken = await BkNotificationService.instance.getFcmToken();
        if (fcmToken != null) {
          final dio = ref.read(bkDioClientProvider);
          await dio.post('/school-bk/fcm-token', data: {'fcmToken': fcmToken});
        }
      } catch (_) {
        await logout();
      }
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final fcmToken = await BkNotificationService.instance.getFcmToken();
      final dio = ref.read(bkDioClientProvider);
      final response = await dio.post('/auth/login', data: {
        'identifier': identifier.trim(),
        'password': password,
        if (fcmToken != null) 'fcmToken': fcmToken,
      });

      final data = response.data['data'] as Map<String, dynamic>;
      final String token = data['accessToken'] as String;
      final Map<String, dynamic> teacherJson =
          (data['bkTeacher'] ?? data['teacher']) as Map<String, dynamic>;

      final storage = ref.read(bkSecureStorageProvider);
      await storage.write(key: 'school_bk_jwt_access_token', value: token);
      await storage.write(key: 'school_bk_user_data', value: jsonEncode(teacherJson));

      final user = BkUser.fromJson(teacherJson);
      state = BkAuthState(user: user);
      // Invalidate dashboard provider so it fetches cleanly with the new token
      ref.invalidate(bkDioClientProvider);
      return true;
    } on DioException catch (e) {
      String msg;
      if (e.response == null) {
        final currentUrl = ref.read(bkServerBaseUrlProvider);
        msg = 'Tidak dapat terhubung ke server ($currentUrl).\nPastikan HP dan laptop terhubung ke Wi-Fi yang sama.';
      } else {
        msg = e.response?.data?['message'] ?? 'Gagal login. Periksa NIP/Username dan password.';
      }
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Koneksi error: $e');
      return false;
    }
  }

  Future<String?> updateProfile({
    required String fullName,
    required String phoneWa,
    String? photoUrl,
  }) async {
    try {
      final dio = ref.read(bkDioClientProvider);
      final response = await dio.patch('/school-bk/profile', data: {
        'full_name': fullName.trim(),
        'phone_wa': phoneWa.trim(),
        'photo_url': photoUrl?.trim(),
      });

      if (response.statusCode == 200 && state.user != null) {
        final updated = state.user!.copyWith(
          fullName: fullName.trim(),
          phoneWa: phoneWa.trim(),
          photoUrl: photoUrl?.trim(),
        );
        state = state.copyWith(user: updated);

        // Update local storage
        final storage = ref.read(bkSecureStorageProvider);
        await storage.write(key: 'school_bk_user_data', value: jsonEncode(updated.toJson()));
        return null; // success
      }
      return 'Gagal memperbarui profil';
    } on DioException catch (e) {
      return e.response?.data?['message'] ?? 'Gagal memperbarui profil.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final dio = ref.read(bkDioClientProvider);
      final response = await dio.post('/school-bk/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.statusCode == 200) {
        return null; // success
      }
      return 'Gagal mengganti kata sandi';
    } on DioException catch (e) {
      return e.response?.data?['message'] ?? 'Gagal mengganti kata sandi.';
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  Future<void> logout() async {
    try {
      final dio = ref.read(bkDioClientProvider);
      await dio.post('/school-bk/auth/logout');
    } catch (_) {}
    final storage = ref.read(bkSecureStorageProvider);
    await storage.delete(key: 'school_bk_jwt_access_token');
    await storage.delete(key: 'school_bk_user_data');
    state = const BkAuthState();
  }
}

final bkAuthStateProvider = StateNotifierProvider<BkAuthNotifier, BkAuthState>((ref) {
  return BkAuthNotifier(ref);
});
