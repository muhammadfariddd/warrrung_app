import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  String _selectedLanguage = 'id'; // 'id' for Bahasa Indonesia, 'en' for English

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xFF8C5E3C);
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
          'Pengaturan Bahasa',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Option 1: Bahasa Indonesia
          InkWell(
            onTap: () {
              setState(() {
                _selectedLanguage = 'id';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bahasa aplikasi diubah ke Bahasa Indonesia.'),
                  backgroundColor: Color(0xFF2E7D32),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bahasa Indonesia',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedLanguage == 'id' ? goldColor : textDark,
                    ),
                  ),
                  if (_selectedLanguage == 'id')
                    const Icon(
                      Icons.check_rounded,
                      color: goldColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          // Option 2: English
          InkWell(
            onTap: () {
              setState(() {
                _selectedLanguage = 'en';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Language set to English.'),
                  backgroundColor: Color(0xFF2E7D32),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'English',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _selectedLanguage == 'en' ? goldColor : textDark,
                    ),
                  ),
                  if (_selectedLanguage == 'en')
                    const Icon(
                      Icons.check_rounded,
                      color: goldColor,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
        ],
      ),
    );
  }
}
