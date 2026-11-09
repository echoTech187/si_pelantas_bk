import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/bk_dio_client.dart';
import '../../../../core/theme/bk_academic_theme.dart';
import '../widgets/bk_feedback_dialog.dart';
import 'guru_bk_home_screen.dart';

final bkInspectionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(bkDioClientProvider);
  final res = await dio.get('/inspections');
  final list = res.data['data']['inspections'] as List<dynamic>? ?? [];
  return list.cast<Map<String, dynamic>>();
});

class BkGuidanceScreen extends ConsumerStatefulWidget {
  const BkGuidanceScreen({super.key});

  @override
  ConsumerState<BkGuidanceScreen> createState() => _BkGuidanceScreenState();
}

class _BkGuidanceScreenState extends ConsumerState<BkGuidanceScreen> {
  int _selectedTabIndex = 0; // 0: Konseling Siswa, 1: Riwayat Sidak Kamsel

  String _formatIndonesianDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(bkDashboardDataProvider);
    final inspectionsAsync = ref.watch(bkInspectionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A1220),
      appBar: AppBar(
        title: const Text(
          'BIMBINGAN & RIWAYAT SIDAK',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: BkAcademicColors.emeraldAccent,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: BkAcademicColors.emeraldAccent),
            onPressed: () {
              ref.invalidate(bkDashboardDataProvider);
              ref.invalidate(bkInspectionsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Segment Tab Selector
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0 ? BkAcademicColors.emeraldAccent : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Pelanggaran Siswa',
                            style: TextStyle(
                              color: _selectedTabIndex == 0 ? Colors.white : const Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1 ? const Color(0xFF38BDF8) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Riwayat Sidak Kamsel',
                            style: TextStyle(
                              color: _selectedTabIndex == 1 ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Views
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildStudentViolationsTab(dashboardAsync)
                : _buildInspectionsHistoryTab(inspectionsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentViolationsTab(AsyncValue<Map<String, dynamic>> dashboardAsync) {
    return dashboardAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: BkAcademicColors.emeraldAccent),
      ),
      error: (err, _) => Center(
        child: Text('Gagal memuat data: $err', style: const TextStyle(color: Colors.redAccent)),
      ),
      data: (data) {
        final recentViolations = (data['recent_violations'] as List?) ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Guidance info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: BkAcademicColors.emeraldAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BkAcademicColors.emeraldAccent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.psychology_outlined, color: BkAcademicColors.emeraldAccent, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Protokol Konseling Presisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Setiap siswa pelanggar wajib mendapatkan pendampingan edukatif, bukan hukuman fisik.',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Daftar Pelanggaran Siswa Aktif',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Laporan tilang siswa dari Satlantas Polres Mojokerto',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
              ),
              const SizedBox(height: 12),

              if (recentViolations.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.verified_outlined, color: Color(0xFF10B981), size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Semua Siswa Tertib',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Belum ada laporan tilang yang perlu tindakan konseling.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                    ],
                  ),
                )
              else
                ...recentViolations.map((v) {
                  final studentName = v['student_name'] ?? 'Siswa';
                  final studentClass = v['student_class'] ?? '-';
                  final plateNumber = v['vehicle_plate_number'] ?? '-';
                  final violations = (v['violation_types'] as List?)?.join(', ') ?? 'Pelanggaran Lalu Lintas';
                  final date = v['violation_date']?.toString().split('T')[0] ?? '-';
                  final isCounselled = v['counseling_status'] == 'COMPLETED';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isCounselled
                            ? const Color(0xFF10B981).withValues(alpha: 0.3)
                            : const Color(0xFFFF8A3D).withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8A3D).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'TILANG POLRES',
                                style: TextStyle(
                                  color: Color(0xFFFF8A3D),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelas: $studentClass  •  Plat: $plateNumber  •  $date',
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  violations,
                                  style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInspectionsHistoryTab(AsyncValue<List<Map<String, dynamic>>> inspectionsAsync) {
    return inspectionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text('Gagal memuat riwayat sidak: $err', style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(bkInspectionsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
      data: (inspections) {
        if (inspections.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.history_edu_rounded, size: 54, color: Color(0xFF475569)),
                  SizedBox(height: 14),
                  Text(
                    'Belum Ada Kunjungan Sidak Kamsel',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Setiap selesai memberikan arahan/sidak, Unit Kamsel Satlantas Polres Mojokerto akan mencatat berita acara dan Anda dapat memberikan penilaian di sini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: inspections.length,
          itemBuilder: (ctx, idx) {
            final item = inspections[idx];
            final seq = item['inspectionSequence'] ?? (inspections.length - idx);
            final date = _formatIndonesianDate(item['visitDate']?.toString());
            final topic = item['counselingTopic'] ?? 'Penyuluhan Tertib Berlalu Lintas';
            final directive = item['kamselDirectiveSummary'] ?? '-';
            final evaluation = item['schoolEvaluationResult'] ?? '-';
            final commitment = item['schoolFollowUpCommitment'] ?? '-';
            final attendees = item['studentAttendeeCount'] ?? 0;
            final violationCount = item['violationCountAtVisit'] ?? 0;
            final officerName = item['officerName'] ?? 'Unit Kamsel';
            final officerRank = item['officerRank'] ?? 'Petugas';
            final feedbackId = item['feedbackId'];
            final feedbackRating = item['feedbackRating'];
            final feedbackNotes = item['feedbackNotes'];
            final feedbackDate = _formatIndonesianDate(item['feedbackSubmittedAt']?.toString());
            final List violationsSnapshot = (item['violationsSnapshot'] as List?) ?? [];

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: feedbackId != null
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.25)
                      : const Color(0xFFFBBF24).withValues(alpha: 0.5),
                  width: feedbackId != null ? 1 : 1.4,
                ),
              ),
              child: ExpansionTile(
                initiallyExpanded: idx == 0,
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const Border(),
                collapsedShape: const Border(),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: feedbackId != null
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                        : const Color(0xFFFBBF24).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    feedbackId != null ? Icons.verified_rounded : Icons.pending_actions_rounded,
                    color: feedbackId != null ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24),
                    size: 24,
                  ),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Sidak Ke-$seq',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    officerRank.isNotEmpty && officerName.toLowerCase().startsWith(officerRank.toLowerCase())
                        ? officerName
                        : '$officerRank $officerName'.trim(),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Color(0xFF1E293B)),
                        const SizedBox(height: 6),

                        // Detail Topik & Petugas
                        _buildInfoRow('Topik Arahan', topic),
                        _buildInfoRow('Ringkasan Arahan Kamsel', directive),
                        _buildInfoRow('Hasil Evaluasi Sekolah', evaluation),
                        _buildInfoRow('Komitmen Tindak Lanjut', commitment),

                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text('$attendees', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    const Text('Siswa Hadir', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Text('$violationCount', style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    const Text('Pelanggar Saat Sidak', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Snapshot Pelanggaran Siswa Saat Sidak
                        if (violationsSnapshot.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            'Snapshot Pelanggaran Siswa (${violationsSnapshot.length} Siswa):',
                            style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          ...violationsSnapshot.take(5).map((v) {
                            final name = v['studentName'] ?? 'Siswa';
                            final sClass = v['studentClass'] ?? '-';
                            final plate = v['vehiclePlateNumber'] ?? '-';
                            final reason = v['violationSummary'] ?? 'Pelanggaran Lalu Lintas';
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person_pin_outlined, size: 14, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '$name ($sClass) • $plate • $reason',
                                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10.5),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          if (violationsSnapshot.length > 5)
                            Text(
                              '... dan ${violationsSnapshot.length - 5} pelanggaran siswa lainnya tercatat.',
                              style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontStyle: FontStyle.italic),
                            ),
                        ],

                        const SizedBox(height: 14),

                        // Feedback Status Card
                        if (feedbackId != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'Feedback Guru BK Tersimpan',
                                          style: TextStyle(color: Color(0xFF10B981), fontSize: 11.5, fontWeight: FontWeight.w800),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          i < (feedbackRating ?? 5) ? Icons.star_rounded : Icons.star_outline_rounded,
                                          size: 16,
                                          color: const Color(0xFFFBBF24),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (feedbackNotes != null && feedbackNotes.toString().isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '"$feedbackNotes"',
                                    style: const TextStyle(color: Colors.white, fontSize: 11.5, fontStyle: FontStyle.italic),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  'Diulas pada: $feedbackDate',
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF78350F).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Kunjungan ini belum diberikan penilaian oleh Guru BK.',
                                  style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFBBF24),
                                      foregroundColor: const Color(0xFF0F172A),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                    ),
                                    icon: const Icon(Icons.star_rate_rounded, size: 16),
                                    label: const Text('Beri Penilaian Sekarang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                                    onPressed: () {
                                      BkFeedbackDialog.show(
                                        context,
                                        inspectionLogId: item['id']?.toString() ?? '',
                                        inspectionSequence: seq is int ? seq : int.tryParse(seq.toString()) ?? 1,
                                        officerName: officerName,
                                        officerRank: officerRank,
                                        visitDate: item['visitDate']?.toString(),
                                        counselingTopic: topic,
                                      ).then((_) {
                                        ref.invalidate(bkInspectionsProvider);
                                        ref.invalidate(bkDashboardDataProvider);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
