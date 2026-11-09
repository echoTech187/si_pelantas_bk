import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/bk_dio_client.dart';
import '../../../../core/theme/bk_academic_theme.dart';
import '../screens/guru_bk_home_screen.dart';

class BkFeedbackDialog extends ConsumerStatefulWidget {
  final String inspectionLogId;
  final int inspectionSequence;
  final String officerName;
  final String officerRank;
  final String? visitDate;
  final String? counselingTopic;

  const BkFeedbackDialog({
    super.key,
    required this.inspectionLogId,
    required this.inspectionSequence,
    required this.officerName,
    required this.officerRank,
    this.visitDate,
    this.counselingTopic,
  });

  static Future<void> show(
    BuildContext context, {
    required String inspectionLogId,
    required int inspectionSequence,
    required String officerName,
    required String officerRank,
    String? visitDate,
    String? counselingTopic,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: false,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: const Color(0xFF0A0F1D),
        child: BkFeedbackDialog(
          inspectionLogId: inspectionLogId,
          inspectionSequence: inspectionSequence,
          officerName: officerName,
          officerRank: officerRank,
          visitDate: visitDate,
          counselingTopic: counselingTopic,
        ),
      ),
    );
  }

  @override
  ConsumerState<BkFeedbackDialog> createState() => _BkFeedbackDialogState();
}

class _BkFeedbackDialogState extends ConsumerState<BkFeedbackDialog> {
  int _ratingStars = 5;
  int _clarityRating = 5;
  int _helpfulnessRating = 5;
  int _attitudeRating = 5;
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _getRatingLabel(int stars) {
    switch (stars) {
      case 5:
        return 'Sangat Memuaskan ⭐⭐⭐⭐⭐';
      case 4:
        return 'Baik & Komunikatif ⭐⭐⭐⭐';
      case 3:
        return 'Cukup Memadai ⭐⭐⭐';
      case 2:
        return 'Kurang Efektif ⭐⭐';
      case 1:
        return 'Sangat Kurang ⭐';
      default:
        return '';
    }
  }

  Widget _buildStarRatingBar({
    required int currentRating,
    required ValueChanged<int> onRatingChanged,
    double starSize = 32,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starNumber = index + 1;
        final isSelected = starNumber <= currentRating;
        return IconButton(
          iconSize: starSize,
          splashRadius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: const BoxConstraints(),
          onPressed: () => onRatingChanged(starNumber),
          icon: Icon(
            isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isSelected ? const Color(0xFFFBBF24) : const Color(0xFF475569),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryRatingRow({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              final starVal = index + 1;
              final active = starVal <= value;
              return GestureDetector(
                onTap: () => onChanged(starVal),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    active ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 20,
                    color: active ? const Color(0xFFFBBF24) : const Color(0xFF475569),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _submitFeedback() async {
    final notes = _notesController.text.trim();
    if (notes.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFEF4444),
          content: Text('Mohon berikan catatan testimoni/evaluasi minimal 3 karakter.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(bkDioClientProvider);
      await dio.post('/feedbacks', data: {
        'inspectionLogId': widget.inspectionLogId,
        'ratingStars': _ratingStars,
        'clarityRating': _clarityRating,
        'helpfulnessRating': _helpfulnessRating,
        'attitudeRating': _attitudeRating,
        'feedbackNotes': notes,
      });

      ref.invalidate(bkDashboardDataProvider);

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 4),
          content: Text(
            'Terima kasih! Penilaian dan feedback Guru BK berhasil dikirimkan ke Satlantas Polres Mojokerto.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      String errorMsg = 'Gagal mengirim penilaian.';
      if (e is DioException && e.response?.data is Map) {
        errorMsg = e.response?.data['message'] ?? errorMsg;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFEF4444),
          content: Text(errorMsg),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final officerDisplay = widget.officerRank.isNotEmpty &&
            widget.officerName.startsWith(widget.officerRank)
        ? widget.officerName
        : "${widget.officerRank} ${widget.officerName}".trim();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131D31),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ulasan Sidak Ke-${widget.inspectionSequence} Kamsel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Petugas: $officerDisplay',
              style: const TextStyle(
                color: Color(0xFFFBBF24),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFF1E293B), height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E293B),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.rate_review_rounded,
                        color: Color(0xFFFBBF24),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sidak Ke-${widget.inspectionSequence} Unit Kamsel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Petugas: $officerDisplay',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                          if (widget.counselingTopic != null &&
                              widget.counselingTopic!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Materi: ${widget.counselingTopic}',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Penilaian Kepuasan Umum Guru BK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Overall Star Rating Bar
              _buildStarRatingBar(
                currentRating: _ratingStars,
                onRatingChanged: (newRating) =>
                    setState(() => _ratingStars = newRating),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingLabel(_ratingStars),
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(color: Color(0xFF1E293B)),
              const SizedBox(height: 16),

              const Text(
                'Aspek Kinerja Kamsel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildCategoryRatingRow(
                label: 'Kejelasan Materi Pembinaan',
                value: _clarityRating,
                onChanged: (v) => setState(() => _clarityRating = v),
              ),
              _buildCategoryRatingRow(
                label: 'Dampak & Manfaat Solusi Siswa',
                value: _helpfulnessRating,
                onChanged: (v) => setState(() => _helpfulnessRating = v),
              ),
              _buildCategoryRatingRow(
                label: 'Sikap & Komunikasi Petugas',
                value: _attitudeRating,
                onChanged: (v) => setState(() => _attitudeRating = v),
              ),

              const SizedBox(height: 24),
              const Text(
                'Catatan Testimoni / Evaluasi Anda',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _notesController,
                minLines: 3,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText:
                      'Tuliskan kesan, pesan, atau masukan untuk Unit Kamsel Polres Mojokerto...',
                  hintStyle:
                      const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFF131D31),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1E293B)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: BkAcademicColors.emeraldAccent, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF131D31),
          border: Border(top: BorderSide(color: Color(0xFF1E293B))),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF94A3B8),
                  side: const BorderSide(color: Color(0xFF334155)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed:
                    _isSubmitting ? null : () => Navigator.of(context).pop(),
                child: const Text('Batal',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BkAcademicColors.emeraldAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _isSubmitting ? null : _submitFeedback,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.send_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'KIRIM PENILAIAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

