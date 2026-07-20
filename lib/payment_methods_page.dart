import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGray = Color(0xFF757575);
    const Color deepRed = Color(0xFFC62828);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Atur Metode Pembayaran',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ─── 1. CARD SECTION: PEMBAYARAN LANGSUNG ───────────────────────
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pembayaran Langsung',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildConnectRow(
                    context: context,
                    logoText: 'S',
                    logoBgColor: const Color(0xFFEE4D2D),
                    title: 'SPayLater',
                    subtitle: 'Belum terhubung',
                    deepRed: deepRed,
                    textDark: textDark,
                  ),
                  const SizedBox(height: 16),

                  _buildConnectRow(
                    context: context,
                    logoText: 'G',
                    logoBgColor: const Color(0xFF00AED6),
                    title: 'GoPay',
                    subtitle: 'Belum terhubung',
                    deepRed: deepRed,
                    textDark: textDark,
                  ),
                  const SizedBox(height: 16),

                  _buildConnectRow(
                    context: context,
                    logoText: 'S',
                    logoBgColor: const Color(0xFFEE4D2D),
                    title: 'ShopeePay',
                    subtitle: 'Belum terhubung',
                    deepRed: deepRed,
                    textDark: textDark,
                  ),
                  const SizedBox(height: 16),

                  _buildConnectRow(
                    context: context,
                    logoText: 'S',
                    logoBgColor: const Color(0xFF00A0E9),
                    title: 'GoPayLater',
                    subtitle: 'Belum terhubung',
                    deepRed: deepRed,
                    textDark: textDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ─── 2. CARD SECTION: KARTU DEBIT / KREDIT ──────────────────────
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kartu Debit / Kredit',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Fitur tambah kartu debit/kredit akan segera hadir.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: Text(
                          '+ Tambah Kartu',
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A880),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.credit_card_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Gunakan Kartu Kredit',
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: textGray,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),

                  // Visa & Mastercard badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'VISA',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF1A1F71),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEB001B),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-3, 0),
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF79E1B).withValues(alpha: 0.8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Syarat dan Ketentuan Refund Link
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Syarat & Ketentuan Refund',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    content: Text(
                      'Pengajuan pengembalian dana (refund) dapat dilakukan dalam waktu 1x24 jam jika terdapat kesalahan pesanan atau kegagalan transaksi.',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Tutup',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8C5E3C),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'Syarat dan Ketentuan Refund',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E88E5),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectRow({
    required BuildContext context,
    required String logoText,
    required Color logoBgColor,
    required String title,
    required String subtitle,
    required Color deepRed,
    required Color textDark,
  }) {
    return Row(
      children: [
        // Logo Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: logoBgColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            logoText,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Title & Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFFC62828),
                ),
              ),
            ],
          ),
        ),

        // Hubungkan Button
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Menubungkan ke $title...'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: deepRed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Hubungkan',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
