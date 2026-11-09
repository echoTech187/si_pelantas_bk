import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/bk_academic_theme.dart';
import '../bk_auth_controller.dart';
import 'guru_bk_home_screen.dart';

class BkProfileScreen extends ConsumerStatefulWidget {
  final BkUser user;

  const BkProfileScreen({super.key, required this.user});

  @override
  ConsumerState<BkProfileScreen> createState() => _BkProfileScreenState();
}

class _BkProfileScreenState extends ConsumerState<BkProfileScreen> {
  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'BK';
    final cleaned = name
        .replaceAll(RegExp(r'\b(Dra\.|Drs\.|S\.Pd\.|M\.Pd\.|S\.Psi\.|M\.Psi\.|Prof\.|Dr\.)\b', caseSensitive: false), '')
        .trim();
    final parts = (cleaned.isNotEmpty ? cleaned : name).trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  void _showEditProfileDialog(BuildContext context, BkUser user) {
    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phoneWa);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131D31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.badge_outlined, color: BkAcademicColors.emeraldAccent, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Ubah Data Diri Guru BK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap Beserta Gelar',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.person_outline, color: BkAcademicColors.emeraldAccent, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A263D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp Aktif',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.phone_android, color: BkAcademicColors.emeraldAccent, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A263D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BkAcademicColors.emeraldAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          setModalState(() => isSaving = true);
                          final err = await ref.read(bkAuthStateProvider.notifier).updateProfile(
                                fullName: nameCtrl.text,
                                phoneWa: phoneCtrl.text,
                              );
                          if (!mounted || !ctx.mounted) return;
                          setModalState(() => isSaving = false);
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: err == null ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              content: Text(err ?? 'Data diri profil Guru BK berhasil diperbarui!'),
                            ),
                          );
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'SIMPAN PERUBAHAN',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isSaving = false;
    bool obscureOld = true;
    bool obscureNew = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131D31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.lock_reset, color: BkAcademicColors.emeraldAccent, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'Ganti Kata Sandi Guru BK',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: oldPassCtrl,
                obscureText: obscureOld,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Saat Ini',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.key, color: BkAcademicColors.emeraldAccent, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(obscureOld ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF94A3B8), size: 18),
                    onPressed: () => setModalState(() => obscureOld = !obscureOld),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A263D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: obscureNew,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru (Min. 6 Karakter)',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.lock_outline, color: BkAcademicColors.emeraldAccent, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF94A3B8), size: 18),
                    onPressed: () => setModalState(() => obscureNew = !obscureNew),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1A263D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPassCtrl,
                obscureText: obscureNew,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi Baru',
                  labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.check_circle_outline, color: BkAcademicColors.emeraldAccent, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF1A263D),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BkAcademicColors.emeraldAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (newPassCtrl.text.trim().length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFEF4444),
                                content: Text('Kata sandi baru minimal 6 karakter.'),
                              ),
                            );
                            return;
                          }
                          if (newPassCtrl.text != confirmPassCtrl.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFFEF4444),
                                content: Text('Konfirmasi kata sandi tidak cocok.'),
                              ),
                            );
                            return;
                          }
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(ctx);
                          setModalState(() => isSaving = true);
                          final err = await ref.read(bkAuthStateProvider.notifier).changePassword(
                                currentPassword: oldPassCtrl.text,
                                newPassword: newPassCtrl.text,
                              );
                          if (!mounted || !ctx.mounted) return;
                          setModalState(() => isSaving = false);
                          nav.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              backgroundColor: err == null ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              content: Text(err ?? 'Kata sandi berhasil diperbarui!'),
                            ),
                          );
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'SIMPAN KATA SANDI',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(bkAuthStateProvider).user ?? widget.user;
    final initials = _getInitials(currentUser.fullName);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // Avatar Initial Name
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF059669),
                        Color(0xFF047857),
                      ],
                    ),
                    border: Border.all(
                      color: BkAcademicColors.emeraldAccent,
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: BkAcademicColors.emeraldAccent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                currentUser.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'NIP / NUPTK: ${currentUser.nipOrNuptk}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: BkAcademicColors.emeraldAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: BkAcademicColors.emeraldAccent,
                    width: 1,
                  ),
                ),
                child: const Text(
                  'GURU BIMBINGAN KONSELING',
                  style: TextStyle(
                    color: BkAcademicColors.emeraldAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons: Ubah Profil & Ganti Kata Sandi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFF131D31),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16, color: BkAcademicColors.emeraldAccent),
                      label: const Text(
                        'Ubah Profil',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showEditProfileDialog(context, currentUser),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: const Color(0xFF131D31),
                      ),
                      icon: const Icon(Icons.lock_outline, size: 16, color: BkAcademicColors.emeraldAccent),
                      label: const Text(
                        'Ganti Sandi',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      onPressed: () => _showChangePasswordDialog(context),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Detail Card - Identitas Personal & Akun Resmi Guru BK
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      icon: Icons.badge_outlined,
                      title: 'NIP / NUPTK Guru BK',
                      value: currentUser.nipOrNuptk,
                    ),
                    const Divider(color: Color(0xFF1E293B), height: 1),
                    _buildInfoTile(
                      icon: Icons.phone_android,
                      title: 'No. WhatsApp Aktif',
                      value: currentUser.phoneWa.isNotEmpty ? currentUser.phoneWa : '-',
                    ),
                    const Divider(color: Color(0xFF1E293B), height: 1),
                    _buildInfoTile(
                      icon: Icons.school_outlined,
                      title: 'Pangkalan Sekolah',
                      value: currentUser.schoolName ?? 'Sekolah Kabupaten Mojokerto',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Export CSV Option
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: BkAcademicColors.skyAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BkAcademicColors.skyAccent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.table_chart_outlined, color: BkAcademicColors.skyAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Unduh Rekap Laporan (.CSV)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rekapitulasi resmi untuk kepala sekolah & dinas',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: BkAcademicColors.skyAccent),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mengunduh rekapan data pelanggaran...'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'KELUAR',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  onPressed: () {
                    ref.read(bkNavIndexProvider.notifier).state = 0;
                    ref.read(bkAuthStateProvider.notifier).logout();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
