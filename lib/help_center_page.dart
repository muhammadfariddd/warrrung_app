import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final List<Map<String, String>> _faqs = [
    {
      'question':
          'Siapa yang bisa saya hubungi jika ada pertanyaan atau kendala pemesanan?',
      'answer':
          'Kamu bisa menghubungi tim waRRRung melalui Whatsapp +62895363648153 (khusus chat) atau email ke warrrung@gmail.com',
    },
    {
      'question':
          'Bagaimana cara menghubungi layanan pengaduan konsumen Direktorat Perlindungan Konsumen dan Tertib Niaga?',
      'answer':
          'Layanan Pengaduan Konsumen Ditjen PKTN Kementerian Perdagangan RI dapat dihubungi via WhatsApp 0853-1111-1010 atau email pengaduan.konsumen@kemendag.go.id',
    },
    {
      'question': 'Berapa batas maksimal komplain setelah melakukan transaksi?',
      'answer':
          'Batas maksimal pengajuan komplain adalah 1x24 jam setelah pesanan Anda diterima.',
    },
    {
      'question': 'Minuman waRRRung bisa bertahan berapa lama?',
      'answer':
          'Minuman dalam kemasan cup dapat bertahan hingga 4-6 jam pada suhu ruangan dan hingga 24 jam di dalam lemari es.',
    },
    {
      'question':
          'Apa boleh saya hanya membeli tas belanja yang seharga Rp 3.000 atau Rp 5.000 saja?',
      'answer':
          'Tas belanja waRRRung dijual khusus sebagai pelengkap pesanan menu dan tidak dapat dibeli terpisah tanpa menu utama.',
    },
    {
      'question': 'Mengapa QR code pesanan saya belum keluar?',
      'answer':
          'QR code pesanan akan otomatis terbit setelah pembayaran Anda berhasil dikonfirmasi secara otomatis oleh sistem Midtrans.',
    },
    {
      'question':
          'Apa yang harus saya lakukan jika saya lupa menulis catatan permintaan pesanan saya? (contoh: less coffee)',
      'answer':
          'Anda dapat menginformasikan langsung kepada barista di kasir outlet kami atau menghubungi WhatsApp support outlet terkait.',
    },
    {
      'question': 'Apakah pesanan saya bisa diambil nanti?',
      'answer':
          'Ya, Anda dapat menggunakan fitur "Jadwalkan" pada halaman konfirmasi pesanan untuk menentukan jam pengambilan.',
    },
    {
      'question':
          'Bagaimana cara untuk pembelian dalam jumlah banyak (big/bulk order) atau terkait acara?',
      'answer':
          'Untuk pemesanan jumlah besar atau acara, Anda dapat langsung menghubungi layanan WhatsApp resmi waRRRung di +62895363648153.',
    },
  ];

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
          'Bantuan',
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
            // Category Dropdown Box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Semua Kategori',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // FAQ Accordion List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFF0F0F0),
              ),
              itemBuilder: (context, index) {
                final faq = _faqs[index];
                return Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    title: Text(
                      faq['question']!,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                        height: 1.35,
                      ),
                    ),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          faq['answer']!,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
