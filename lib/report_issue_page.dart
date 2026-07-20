import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warrrung_app/providers/auth_provider.dart';
import 'package:warrrung_app/providers/location_provider.dart';

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  String _selectedSubject = 'Pilih Subjek';
  String? _selectedOutlet;
  late TextEditingController _emailController;
  final TextEditingController _messageController = TextEditingController();
  PlatformFile? _selectedFile;
  bool _isSubmitting = false;

  final List<String> _subjects = [
    'Kendala Pembayaran',
    'Kualitas Produk',
    'Pelayanan Outlet',
    'Aplikasi Error',
    'Pertanyaan Umum',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.currentUser?.data['email'] as String? ?? '';
    // Tanpa default email hardcoded (siap untuk rilis Play Store)
    _emailController = TextEditingController(text: userEmail);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      if (locationProvider.selectedOutlet != null) {
        setState(() {
          _selectedOutlet = locationProvider.selectedOutlet!.name;
        });
      } else if (locationProvider.outlets.isNotEmpty) {
        setState(() {
          _selectedOutlet = locationProvider.outlets.first.name;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _showSubjectPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Subjek',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._subjects.map(
                (subject) => ListTile(
                  title: Text(
                    subject,
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  trailing: _selectedSubject == subject
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF8C5E3C),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedSubject = subject;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOutletPicker() {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final pbOutlets = locationProvider.outlets;
    final List<String> outletNames = pbOutlets.isNotEmpty
        ? pbOutlets.map((o) => o.name).toList()
        : ['Pemuda Jepara', 'Kartini Jepara', 'MH Thamrin Jepara'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pilih Outlet (PocketBase Railway)',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...outletNames.map(
                (outlet) => ListTile(
                  title: Text(outlet, style: GoogleFonts.poppins(fontSize: 14)),
                  trailing: _selectedOutlet == outlet
                      ? const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF8C5E3C),
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedOutlet = outlet;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
    }
  }

  Future<void> _submitReport() async {
    final email = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan email Anda.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan tuliskan pesan kendala Anda terlebih dahulu.'),
          backgroundColor: Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String outletStr = _selectedOutlet ?? 'Belum dipilih';

    // Buka Mail Client langsung mengarah ke warrrung@gmail.com
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: 'warrrung@gmail.com',
      queryParameters: {
        'subject': 'Laporan Kendala: $_selectedSubject ($outletStr)',
        'body':
            'Email Pengirim: $email\nSubjek: $_selectedSubject\nOutlet: $outletStr\n\nPesan:\n$message\n\n${_selectedFile != null ? "Lampiran File: ${_selectedFile!.name}" : ""}',
      },
    );

    try {
      await launchUrl(mailUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch mailto: $e');
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan siap dikirim ke warrrung@gmail.com. Terima kasih!'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = Color(0xFF1A1A1A);
    const Color primaryRed = Color(0xFFC62828);

    final locationProvider = context.watch<LocationProvider>();
    final String activeOutletName = _selectedOutlet ??
        (locationProvider.selectedOutlet?.name ??
            (locationProvider.outlets.isNotEmpty
                ? locationProvider.outlets.first.name
                : 'Pemuda Jepara'));

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
          'Laporan',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Subjek Option Tile
            InkWell(
              onTap: _showSubjectPicker,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subjek',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF8C5E3C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          _selectedSubject,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF8C5E3C),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

            // 2. Outlet Option Tile (Connected to Pocketbase Railway)
            InkWell(
              onTap: _showOutletPicker,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Outlet',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF8C5E3C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          activeOutletName,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            color: textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF8C5E3C),
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
            const SizedBox(height: 20),

            // 3. Email Field
            Row(
              children: [
                Text(
                  'Email',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: textDark,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _emailController,
                style: GoogleFonts.poppins(fontSize: 13, color: textDark),
                decoration: InputDecoration(
                  hintText: 'Masukkan email Anda...',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade400),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Pesan Field
            Row(
              children: [
                Text(
                  'Pesan',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: textDark,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    color: primaryRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _messageController,
                maxLines: 5,
                style: GoogleFonts.poppins(fontSize: 13, color: textDark),
                decoration: InputDecoration(
                  hintText: 'Tulis pesanmu disini...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // 5. Upload File Section (Real FilePicker)
            GestureDetector(
              onTap: _pickFile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.cloud_upload_outlined,
                          color: textDark,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFile != null
                              ? _selectedFile!.name
                              : 'Upload file',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E88E5),
                          ),
                        ),
                      ),
                      if (_selectedFile != null)
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFCCCCCC),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _selectedFile != null
                        ? 'Ukuran: ${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB'
                        : 'Maksimum 5mb, hanya jpg, png, dan pdf.',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 6. Solid Red Bottom Kirim Button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'KIRIM',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
