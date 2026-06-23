import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warrrung_app/core/widgets/custom_icons.dart';
import 'package:warrrung_app/providers/auth_provider.dart';

/// A stateful multi-stage login bottom sheet that matches Kopi Kenangan styling.
class LoginBottomSheet extends StatefulWidget {
  const LoginBottomSheet({super.key});

  /// Static helper to display the login sheet.
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.none, // Allow close button to float outside sheet bounds
      builder: (context) {
        return const LoginBottomSheet();
      },
    );
  }

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  AuthSheetStage _stage = AuthSheetStage.phoneInput;
  final TextEditingController _phoneController = TextEditingController();
  bool _isPhoneValid = false;

  // OTP inputs
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearLoading();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    // Using PopScope for modern Flutter versions instead of deprecated WillPopScope
    return PopScope(
      canPop: _stage == AuthSheetStage.phoneInput,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_stage == AuthSheetStage.otpInput) {
          setState(() {
            _stage = AuthSheetStage.phoneInput;
          });
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Floating Close Button (positioned outside the top boundary)
          Positioned(
            top: -55,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),

          // Main sheet content wrapper with dynamically adjusted padding for keyboard
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPadding),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _buildStageContent(authProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageContent(AuthProvider authProvider) {
    if (authProvider.isLoading) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
        ),
      );
    }

    switch (_stage) {
      case AuthSheetStage.phoneInput:
        return _buildPhoneInputStage(authProvider);
      case AuthSheetStage.otpInput:
        return _buildOtpStage(authProvider);
    }
  }

  // ─── STAGE 1: PHONE INPUT + GOOGLE AUTH SHEET ───────────────────────
  Widget _buildPhoneInputStage(AuthProvider authProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Error message if any
        if (authProvider.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFC62828),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (authProvider.errorMessage!.contains('Telegram') || authProvider.errorMessage!.contains('telegram')) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse('https://t.me/warrrung_bot');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Hubungkan Telegram',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6), // Telegram blue
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],

        // Input container "+62 | Nomor Handphone"
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                '+62',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  onChanged: (val) {
                    setState(() {
                      _isPhoneValid = val.trim().length >= 8;
                    });
                  },
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Nomor Handphone',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF757575).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lanjut Konfirmasi Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isPhoneValid
                ? () async {
                    FocusScope.of(context).unfocus();
                    authProvider.clearErrors();
                    final success = await authProvider.requestOtp(
                      '+62${_phoneController.text.trim()}',
                    );
                    if (success) {
                      setState(() {
                        _stage = AuthSheetStage.otpInput;
                      });
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isPhoneValid
                  ? const Color(0xFF8C5E3C)
                  : const Color(0xFFE0E0E0),
              disabledBackgroundColor: const Color(0xFFE0E0E0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Lanjut Konfirmasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _isPhoneValid ? Colors.white : const Color(0xFF9E9E9E),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // OR Divider: "──────── ATAU ────────"
        Row(
          children: [
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'ATAU',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),
            const Expanded(
              child: Divider(thickness: 1, color: Color(0xFFE0E0E0)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Google capsule button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              final success = await authProvider.loginWithGoogle();
              if (success) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Berhasil masuk via Google!')),
                );
              }
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE0E0E0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GoogleIcon(size: 18),
                const SizedBox(width: 10),
                Text(
                  'Lanjutkan dengan Google',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  // ─── STAGE 3: OTP VERIFICATION SHEET ────────────────────────────────
  Widget _buildOtpStage(AuthProvider authProvider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button
        GestureDetector(
          onTap: () {
            setState(() {
              _stage = AuthSheetStage.phoneInput;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF8C5E3C), width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 16,
                  color: Color(0xFF8C5E3C),
                ),
                const SizedBox(width: 4),
                Text(
                  'Kembali',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF8C5E3C),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // OTP verification title
        Text(
          'Verifikasi Kode OTP',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle containing phone number
        Text(
          'Masukkan 4 digit kode OTP yang dikirim melalui Telegram ke +62 ${_phoneController.text.trim()}\n(Gunakan kode default 1234 jika belum terhubung)',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: const Color(0xFF757575),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Error message if any
        if (authProvider.errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFC62828),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // 4 OTP pin boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return SizedBox(
              width: 64,
              height: 64,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  fillColor: const Color(0xFFF5F5F5),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF8C5E3C),
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    if (index < 3) {
                      _otpFocusNodes[index + 1].requestFocus();
                    } else {
                      _otpFocusNodes[index].unfocus();
                      _verifySubmittedOtp(authProvider);
                    }
                  } else {
                    if (index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Verify button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _verifySubmittedOtp(authProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C5E3C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Verifikasi',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Resend option
        Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {
              authProvider.clearErrors();
              authProvider.requestOtp('+62${_phoneController.text.trim()}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kode OTP berhasil dikirim ulang!'),
                ),
              );
            },
            child: Text(
              'Kirim ulang OTP',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8C5E3C),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  void _verifySubmittedOtp(AuthProvider authProvider) async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan 4 digit kode OTP.')),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await authProvider.verifyOtp(otp);
    if (success) {
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Selamat datang! Login berhasil.')),
      );
    }
  }
}
