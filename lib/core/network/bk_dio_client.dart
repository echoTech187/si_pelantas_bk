import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
const String kDefaultSchoolBkApiBaseUrl =
    'http://192.168.1.52:4000/api/v1/school-bk';

final bkSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

class BkServerUrlNotifier extends StateNotifier<String> {
  final FlutterSecureStorage _storage;

  BkServerUrlNotifier(this._storage)
      : super(
            _envBaseUrl.isNotEmpty ? _envBaseUrl : kDefaultSchoolBkApiBaseUrl) {
    _loadCustomUrl();
  }

  Future<void> _loadCustomUrl() async {
    try {
      final saved = await _storage.read(key: 'custom_bk_api_url');
      if (saved != null && saved.trim().isNotEmpty) {
        state = saved.trim();
      }
    } catch (_) {}
  }

  Future<void> setBaseUrl(String newUrl) async {
    final clean = newUrl.trim();
    await _storage.write(key: 'custom_bk_api_url', value: clean);
    state = clean;
  }
}

final bkServerBaseUrlProvider =
    StateNotifierProvider<BkServerUrlNotifier, String>((ref) {
  final storage = ref.watch(bkSecureStorageProvider);
  return BkServerUrlNotifier(storage);
});

final bkDioClientProvider = Provider<Dio>((ref) {
  final storage = ref.watch(bkSecureStorageProvider);
  final baseUrl = ref.watch(bkServerBaseUrlProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'school_bk_jwt_access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
