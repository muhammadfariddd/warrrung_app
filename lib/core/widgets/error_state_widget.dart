import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional error banner card "Gagal Memuat Konten" matching reference screenshot.
class ContentErrorCard extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback onRetry;

  const ContentErrorCard({
    super.key,
    this.title = 'Gagal Memuat Konten',
    this.message = 'Coba lagi atau klik Muat Ulang',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFC62828);
    const textDark = Color(0xFF1A1A1A);
    const textGray = Color(0xFF757575);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Error Text Info (Left side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? 'Gagal Memuat Konten',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message ?? 'Coba lagi atau klik Muat Ulang',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: textGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // "Muat Ulang" Pill Button (Right side)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                'Muat Ulang',
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal Bottom Sheet for connection failure notification matching reference screenshot.
void showConnectionErrorModal(BuildContext context, {VoidCallback? onConfirm}) {
  const primaryRed = Color(0xFFC62828);
  const textDark = Color(0xFF1A1A1A);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Soft red/pink circle background with Red Cross (X) icon
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: primaryRed,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Connection Error Message
            Text(
              'Periksa koneksi internet kamu dan cobalah beberapa saat lagi',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),

            // "Mengerti" Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onConfirm != null) {
                    onConfirm();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF5722), // Vibrant orange-red pill button
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Mengerti',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
