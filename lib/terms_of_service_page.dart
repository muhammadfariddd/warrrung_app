import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Ketentuan Layanan',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Heading Title
            Text(
              'KETENTUAN LAYANAN WARRRUNG',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textDark,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),

            // Effective Date
            Text(
              'Berlaku sejak 20 Juli 2026',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Paragraph 1
            Text(
              'Selamat datang di aplikasi waRRRung. Syarat dan Ketentuan Layanan ini mengatur penggunaan aplikasi, fitur, konten, dan transaksi yang disediakan oleh PT waRRRung Indonesia ("waRRRung" atau "Kami").',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // Paragraph 2
            Text(
              'Dengan mengunduh, mendaftar, atau menggunakan Layanan waRRRung, Anda menyatakan bahwa Anda telah membaca, memahami, dan menyetujui untuk terikat oleh Ketentuan Layanan ini. Jika Anda tidak menyetujui Ketentuan Layanan ini, Anda tidak diperkenankan mengakses atau menggunakan Aplikasi.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // Paragraph 3
            Text(
              'waRRRung berhak untuk memperbarui atau mengubah Ketentuan Layanan ini sewaktu-waktu tanpa pemberitahuan sebelumnya. Perubahan akan berlaku efektif segera setelah diunggah di dalam Aplikasi. Penggunaan berkelanjutan atas Layanan dianggap sebagai persetujuan Pengguna terhadap perubahan tersebut.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
