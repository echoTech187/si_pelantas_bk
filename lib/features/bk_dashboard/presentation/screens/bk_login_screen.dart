import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/bk_dio_client.dart';
import '../../../../core/theme/bk_academic_theme.dart';
import '../bk_auth_controller.dart';

final publicSchoolsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final dio = ref.watch(bkDioClientProvider);
    final res = await dio.get('/auth/schools');
    final List<dynamic> list = res.data['data'] as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  } catch (_) {
    return [];
  }
});

class BkLoginScreen extends ConsumerStatefulWidget {
  const BkLoginScreen({super.key});

  @override
  ConsumerState<BkLoginScreen> createState() => _BkLoginScreenState();
}

class _BkLoginScreenState extends ConsumerState<BkLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nipCtrl =
      TextEditingController(text: '197504122005012008'); // NIP Dra. Siti Aminah
  final _passwordCtrl = TextEditingController(text: 'bk123');
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(bkAuthStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Resmi Polres Mojokerto Kota
                  Container(
                    width: 140,
                    height: 140,
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      'assets/images/polres_mojokerto_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'SI-MONPEL GURU BK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: BkAcademicColors.emeraldAccent
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: BkAcademicColors.emeraldAccent
                              .withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      'PORTAL GURU BK SEKOLAH MOJOKERTO',
                      style: TextStyle(
                        color: BkAcademicColors.emeraldAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Penerima Disposisi Pelanggaran Siswa & Koordinasi Kamsel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Login Form Card (Floating Card Style)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.badge_outlined,
                                color: BkAcademicColors.emeraldAccent,
                                size: 18),
                            SizedBox(width: 8),
                            Text(
                              'AUTENTIKASI RESMI GURU BK SEKOLAH',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Input NIP / NUPTK Only
                        TextFormField(
                          controller: _nipCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'NIP / NUPTK Guru BK',
                            labelStyle: const TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 12),
                            hintText: 'Masukkan 18 digit NIP resmi',
                            hintStyle: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                            prefixIcon: const Icon(Icons.numbers_outlined,
                                color: BkAcademicColors.emeraldAccent,
                                size: 20),
                            filled: true,
                            fillColor: const Color(0xFF1A263D),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: BkAcademicColors.emeraldAccent,
                                  width: 1.2),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'NIP/NUPTK wajib diisi';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) {
                              return 'NIP harus berupa angka nomor induk';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Input Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            labelText: 'Kata Sandi Guru BK',
                            labelStyle: const TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 12),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: BkAcademicColors.emeraldAccent,
                                size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF94A3B8),
                                size: 18,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: const Color(0xFF1A263D),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                  color: BkAcademicColors.emeraldAccent,
                                  width: 1.2),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 4)
                              ? 'Kata sandi minimal 4 karakter'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        // Error Message
                        if (authState.errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFFEF4444), size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authState.errorMessage!,
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BkAcademicColors.emeraldAccent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            onPressed: authState.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      ref
                                          .read(bkAuthStateProvider.notifier)
                                          .login(
                                            _nipCtrl.text.trim(),
                                            _passwordCtrl.text,
                                          );
                                    }
                                  },
                            child: authState.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.black, strokeWidth: 2),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'MASUK',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Pangkalan Sekolah Binaan & Pilih Akun Guru BK
                  ref.watch(publicSchoolsProvider).when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (schools) {
                          final selectedSchool = schools.firstWhere(
                            (s) => s['nip'] == _nipCtrl.text,
                            orElse: () =>
                                schools.isNotEmpty ? schools.first : {},
                          );
                          final schoolName = selectedSchool['schoolName'] ??
                              'Pilih Sekolah Binaan...';
                          final teacherName =
                              selectedSchool['teacherName'] ?? '';

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF131D31)
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'PANGKALAN SEKOLAH BINAAN MOJOKERTO:',
                                      style: TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: BkAcademicColors.emeraldAccent
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${schools.length} Sekolah',
                                        style: const TextStyle(
                                          color: BkAcademicColors.emeraldAccent,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () => _showSchoolSelectionModal(
                                      context, schools),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A263D),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: BkAcademicColors.emeraldAccent
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.account_balance_outlined,
                                          color: BkAcademicColors.emeraldAccent,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                schoolName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (teacherName.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Guru BK: $teacherName',
                                                  style: const TextStyle(
                                                    color: Color(0xFF94A3B8),
                                                    fontSize: 10,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          color: BkAcademicColors.emeraldAccent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                  const SizedBox(height: 18),

                  // Pengaturan Server IP
                  Consumer(
                    builder: (context, ref, _) {
                      final serverUrl = ref.watch(bkServerBaseUrlProvider);
                      final displayUrl =
                          serverUrl.replaceAll('/api/v1/school-bk', '');
                      return TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.08)),
                          ),
                        ),
                        icon: const Icon(Icons.dns_rounded,
                            size: 14, color: BkAcademicColors.emeraldAccent),
                        label: Text(
                          'Server: $displayUrl',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        onPressed: () =>
                            _showServerConfigDialog(context, ref, serverUrl),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  // Pengaturan Server IP
                  Consumer(
                    builder: (context, ref, _) {
                      final serverUrl = ref.watch(bkServerBaseUrlProvider);
                      final displayUrl =
                          serverUrl.replaceAll('/api/v1/school-bk', '');
                      return TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.08)),
                          ),
                        ),
                        icon: const Icon(Icons.dns_rounded,
                            size: 14, color: BkAcademicColors.emeraldAccent),
                        label: Text(
                          'Server: $displayUrl',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                        onPressed: () =>
                            _showServerConfigDialog(context, ref, serverUrl),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showServerConfigDialog(
      BuildContext context, WidgetRef ref, String currentUrl) {
    final ctrl = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141E30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.dns_rounded,
                color: BkAcademicColors.emeraldAccent, size: 22),
            SizedBox(width: 10),
            Text('Pengaturan Server API',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alamat IP server backend laptop Anda:',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF0C1322),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                hintText: 'http://192.168.1.52:4000/api/v1/school-bk',
                hintStyle:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Preset Cepat:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildPresetChip(ctrl, '☁️ Vercel Cloud (Prod)',
                    'https://si-pelantas-open-api.vercel.app/api/v1/school-bk'),
                _buildPresetChip(ctrl, 'Wi-Fi Laptop (Dev)',
                    'http://192.168.1.52:4000/api/v1/school-bk'),
                _buildPresetChip(ctrl, 'USB (Reverse)',
                    'http://localhost:4000/api/v1/school-bk'),
                _buildPresetChip(
                    ctrl, 'Emulator', 'http://10.0.2.2:4000/api/v1/school-bk'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BkAcademicColors.emeraldAccent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newUrl = ctrl.text.trim();
              if (newUrl.isNotEmpty) {
                ref.read(bkServerBaseUrlProvider.notifier).setBaseUrl(newUrl);
                ref.invalidate(publicSchoolsProvider);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Simpan',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
      TextEditingController ctrl, String label, String url) {
    return ActionChip(
      label: Text(label,
          style: const TextStyle(fontSize: 10.5, color: Colors.white)),
      backgroundColor: const Color(0xFF1E293B),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      onPressed: () => ctrl.text = url,
    );
  }

  void _showSchoolSelectionModal(
      BuildContext context, List<Map<String, dynamic>> schools) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final filtered = schools.where((s) {
              final q = searchQuery.toLowerCase();
              final name = (s['schoolName'] ?? '').toString().toLowerCase();
              final nip = (s['nip'] ?? '').toString().toLowerCase();
              final teacher = (s['teacherName'] ?? '').toString().toLowerCase();
              return name.contains(q) || nip.contains(q) || teacher.contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (sheetContext, scrollController) {
                return Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const Icon(Icons.school,
                              color: BkAcademicColors.emeraldAccent, size: 24),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pangkalan 41 Sekolah Binaan',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Pilih sekolah untuk autentikasi Guru BK',
                                  style: TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        style:
                            const TextStyle(color: Colors.white, fontSize: 13),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari sekolah, nama guru, atau NIP...',
                          hintStyle: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 12),
                          prefixIcon: const Icon(Icons.search,
                              color: BkAcademicColors.emeraldAccent, size: 20),
                          filled: true,
                          fillColor: const Color(0xFF1A263D),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                                color: Colors.white.withValues(alpha: 0.08)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Color(0xFF1E293B), height: 1),
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final s = filtered[index];
                          final nip = s['nip'] ?? '-';
                          final name = s['schoolName'] ?? 'Sekolah';
                          final teacher = s['teacherName'] ?? 'Guru BK';
                          final isSelected = _nipCtrl.text == nip;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _nipCtrl.text = nip;
                                _passwordCtrl.text = 'bk123';
                              });
                              Navigator.pop(ctx);
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? BkAcademicColors.emeraldAccent
                                        .withValues(alpha: 0.15)
                                    : const Color(0xFF131D31),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? BkAcademicColors.emeraldAccent
                                      : Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A263D),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.school_outlined,
                                      color: isSelected
                                          ? BkAcademicColors.emeraldAccent
                                          : Colors.white70,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? BkAcademicColors.emeraldAccent
                                                : Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$teacher  •  NIP: $nip',
                                          style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 10.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle,
                                        color: BkAcademicColors.emeraldAccent,
                                        size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
