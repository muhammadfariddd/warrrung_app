import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          'Kebijakan Privasi',
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
              'KEBIJAKAN PRIVASI WARRRUNG',
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
              'Kebijakan Privasi ini berlaku untuk Aplikasi waRRRung dan aplikasi atau situs web lain yang terkait dengan merek atau produk waRRRung ("Aplikasi") yang mengarahkan Pengguna ke Kebijakan Privasi ini. PT waRRRung Indonesia ("waRRRung" atau "Kami") membangun Aplikasi sebagai aplikasi dengan tujuan bisnis dan dimaksudkan untuk digunakan apa adanya.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // Paragraph 2
            Text(
              'Kebijakan Privasi ini digunakan untuk memberi tahu Pengguna mengenai kebijakan waRRRung dengan pengumpulan, penggunaan, pengolahan, penyimpanan, penguasaan dan pengungkapan Informasi Pribadi jika ada yang memutuskan untuk menggunakan Layanan dan Aplikasi waRRRung.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // Paragraph 3
            Text(
              'Jika Pengguna memilih untuk menggunakan Layanan dan Aplikasi waRRRung, maka Pengguna mengakui bahwa Pengguna telah membaca dan memahami Kebijakan Privasi ini dan menyetujui segala ketentuannya. Secara khusus, Pengguna setuju dan memberikan persetujuan kepada waRRRung untuk mengumpulkan, menggunakan, membagikan, mengungkapkan, menyimpan, mentransfer, atau mengolah Informasi Pribadi Pengguna sesuai dengan Kebijakan Privasi ini.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade800,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 16),

            // Paragraph 4
            Text(
              'Kebijakan Privasi ini berlaku efektif pada tanggal yang tercantum di Kebijakan Privasi ini. waRRRung dapat mengubah, menambah, menghapus, mengoreksi dan/atau memperbarui Kebijakan Privasi ini dari waktu ke waktu untuk memastikan privasi serta keamanan data Pengguna tetap terjaga.',
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
