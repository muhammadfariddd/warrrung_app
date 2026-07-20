import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutWarrrungPage extends StatelessWidget {
  const AboutWarrrungPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1A1A1A);

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
          'Tentang waRRRung',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Top Brand Logo / Styling (Persis Gambar 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'waRRRung',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: textDark,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFC62828),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Text Card Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'waRRRung merupakan salah satu kedai kopi non-waralaba dengan pertumbuhan tercepat di Indonesia. Dimulai dari mimpi para pendiri waRRRung untuk membawa rasa cinta terhadap kopi Indonesia dan memperkenalkannya ke seluruh dunia.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Di waRRRung, kami berusaha mewujudkan mimpi menjadi kedai kopi terkemuka di Indonesia, bahkan dunia, dengan mengambil pendekatan "New Retail" di mana tak ada lagi batasan antara interaksi online dan offline. Kami belajar setiap hari untuk memastikan seluruh pelanggan mendapat pengalaman terbaik dengan pelayanan kelas dunia.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impian kami adalah menjadi kedai kopi terbesar di Indonesia, bahkan dunia dengan mengedepankan produk yang terjangkau namun tetap berkualitas tinggi. Dengan menggabungkan keahlian kami di bidang teknologi serta pelayanan yang berkualitas, kami akan memberikan pelayanan yang cepat dan ramah agar setiap pelanggan waRRRung dapat menikmati secangkir kebahagiaan di dalam genggaman mereka, setiap harinya.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
