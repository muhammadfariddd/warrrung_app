import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/core/widgets/custom_icons.dart';
import 'package:warrrung_app/core/widgets/login_bottom_sheet.dart';
import 'package:warrrung_app/providers/auth_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Helper method to extract initials from the display name
  String _getInitials(String name) {
    if (name.isEmpty) return 'G';
    // Remove content inside parenthesis (like "(Tester)")
    final cleanName = name.replaceAll(RegExp(r'\([^)]*\)'), '').trim();
    if (cleanName.isEmpty) return 'G';
    final parts = cleanName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isLoggedIn = authProvider.isAuthenticated;
    final user = authProvider.currentUser;

    // Extract user details
    final String name = user?.data['name'] as String? ?? '';
    final String phone = user?.data['phone_number'] as String? ?? '';
    final String email = user?.data['email'] as String? ?? '';
    final int points = user?.data['points'] as int? ?? 0;
    final String role = user?.data['role'] as String? ?? 'customer';

    // Display name: prioritizes name, then phone, then email, then Guest
    final String displayName = isLoggedIn
        ? (name.isNotEmpty
              ? name
              : (phone.isNotEmpty
                    ? phone
                    : (email.isNotEmpty ? email : 'Pengguna')))
        : 'Guest';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── 1. HEADER SECTION & OVERLAY STATS CARD ──────────────────────
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildHeader(context, isLoggedIn, displayName, user),
                Positioned(
                  bottom: -24,
                  left: 0,
                  right: 0,
                  child: _buildStatsCard(isLoggedIn, points, role),
                ),
              ],
            ),

            const SizedBox(
              height: 30,
            ), // Spacing to push down content below the overlapping card
            // ─── 3. WHATSAPP PROMO BANNER (GUEST ONLY) ──────────────────────
            if (!isLoggedIn) _buildWhatsAppPromo(context),

            // ─── 4. DAILY CHECK-IN SECTION ──────────────────────────────────
            _buildDailyCheckIn(context, isLoggedIn),

            const SizedBox(height: 24),

            // ─── 5. MENU SECTIONS ───────────────────────────────────────────
            _buildMenuListSection(
              title: 'Akun',
              items: [
                _MenuListItem(
                  icon: Iconsax.sms,
                  title: 'Kotak Masuk',
                  onTap: () => _showComingSoon(context, 'Kotak Masuk'),
                ),
                _MenuListItem(
                  icon: Iconsax.location,
                  title: 'Alamat Pengiriman',
                  onTap: () => _showComingSoon(context, 'Alamat Pengiriman'),
                ),
                _MenuListItem(
                  icon: Iconsax.scan,
                  title: 'Scan Merchandise',
                  onTap: () => _showComingSoon(context, 'Scan Merchandise'),
                ),
                _MenuListItem(
                  icon: Iconsax.global,
                  title: 'Ubah Bahasa Aplikasi',
                  onTap: () => _showComingSoon(context, 'Ubah Bahasa'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildMenuListSection(
              title: 'Pesan',
              items: [
                _MenuListItem(
                  icon: Iconsax.document_text,
                  title: 'Riwayat Pesanan',
                  onTap: () => _showComingSoon(context, 'Riwayat Pesanan'),
                ),
                _MenuListItem(
                  icon: Iconsax.card,
                  title: 'Metode Pembayaran',
                  onTap: () => _showComingSoon(context, 'Metode Pembayaran'),
                ),
                _MenuListItem(
                  icon: Iconsax.box,
                  title: 'Pesanan Jumlah Besar',
                  showBadge: true,
                  onTap: () => _showComingSoon(context, 'Pesanan Jumlah Besar'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _buildMenuListSection(
              title: 'Warrrung',
              items: [
                _MenuListItem(
                  icon: Iconsax.info_circle,
                  title: 'Bantuan',
                  onTap: () => _showComingSoon(context, 'Bantuan'),
                ),
                _MenuListItem(
                  icon: Iconsax.shield_security,
                  title: 'Kebijakan Privasi',
                  onTap: () => _showComingSoon(context, 'Kebijakan Privasi'),
                ),
                _MenuListItem(
                  icon: Iconsax.document_text_1,
                  title: 'Ketentuan Layanan',
                  onTap: () => _showComingSoon(context, 'Ketentuan Layanan'),
                ),
                _MenuListItem(
                  icon: Iconsax.message_question,
                  title: 'Lapor Masalah',
                  onTap: () => _showComingSoon(context, 'Lapor Masalah'),
                ),
                _MenuListItem(
                  customIcon: WhatsAppIcon(
                    size: 22,
                    color: Colors.grey.shade700,
                  ),
                  title: 'Layanan WhatsApp',
                  onTap: () => _showComingSoon(context, 'WhatsApp Support'),
                ),
                _MenuListItem(
                  icon: Iconsax.setting_2,
                  title: 'Tentang Warrrung',
                  onTap: () => _showComingSoon(context, 'Tentang Warrrung'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ─── 6. FOOTER SECTION ──────────────────────────────────────────
            Center(
              child: Text(
                'Versi Aplikasi 1.0.0',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ─── HEADER WIDGET ────────────────────────────────────────────────
  Widget _buildHeader(
    BuildContext context,
    bool isLoggedIn,
    String displayName,
    dynamic user,
  ) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;
    final double headerHeight = statusBarHeight + 150;

    return Container(
      width: double.infinity,
      height: headerHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEBF3F9), // Soft light-blue background gradient
            Color(0xFFF9F9F9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Steaming Bowl Watermark on right-middle background
          Positioned(
            right: 100,
            top: statusBarHeight + 30,
            child: CustomPaint(
              size: const Size(110, 110),
              painter: _SteamingBowlPainter(
                color: const Color(0xFFD4E3ED).withValues(alpha: 0.5),
              ),
            ),
          ),

          // Header Content (Avatar, Greeting, Masuk/Keluar link)
          Padding(
            padding: EdgeInsets.only(top: statusBarHeight - 10),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 20.0,
                  top: 0.0,
                  bottom: 30.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Circular Avatar Frame
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2.5),
                        child: CircleAvatar(
                          backgroundColor: const Color(
                            0xFF2E7D32,
                          ), // Green background color
                          backgroundImage:
                              (isLoggedIn &&
                                  user?.data['avatar'] != null &&
                                  (user.data['avatar'] as String).isNotEmpty)
                              ? NetworkImage(user.data['avatar'] as String)
                              : null,
                          child:
                              (isLoggedIn &&
                                  user?.data['avatar'] != null &&
                                  (user.data['avatar'] as String).isNotEmpty)
                              ? null
                              : Text(
                                  _getInitials(displayName),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Greeting Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hai,',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF1A1A1A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Masuk or Keluar Action Link
                    GestureDetector(
                      onTap: () {
                        if (isLoggedIn) {
                          // Confirm logout
                          _showLogoutConfirmation(context);
                        } else {
                          LoginBottomSheet.show(context);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLoggedIn ? 'Keluar' : 'Masuk',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFF8C5E3C,
                                ), // Accent gold/brown
                              ),
                            ),
                            if (!isLoggedIn) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 16,
                                color: Color(0xFF8C5E3C),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── USER STATS CARD ──────────────────────────────────────────────
  Widget _buildStatsCard(bool isLoggedIn, int points, String role) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left Half: Level
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Level',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.heart_circle,
                          color: Color(0xFF8C5E3C),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLoggedIn
                              ? (role == 'admin' ? 'Admin' : 'Silver')
                              : 'Silver 0%',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Vertical divider line
            VerticalDivider(
              color: Colors.grey.shade100,
              thickness: 1.5,
              indent: 14,
              endIndent: 14,
            ),

            // Right Half: Points
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Warrrung Points',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFD54F), // Yellow/gold coin base
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'W',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF8C5E3C),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLoggedIn ? '$points pts' : '0 pts',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1A1A1A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  // ─── WHATSAPP PROMO BANNER ────────────────────────────────────────
  Widget _buildWhatsAppPromo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // Light green container
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Promo Spesial Buat Member!',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gabung sekarang dan jangan lewatkan penawaran menarik setiap saat.',
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Cup vector mockup
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.receipt_disscount_copy,
                  color: Color(0xFF2E7D32),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Green WhatsApp Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => LoginBottomSheet.show(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WhatsAppIcon(size: 20, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Gabung Sekarang',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DAILY CHECK-IN SECTION ───────────────────────────────────────
  Widget _buildDailyCheckIn(BuildContext context, bool isLoggedIn) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Check-In',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Berakhir 30 Jun 2026',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _showComingSoon(context, 'Daily Check-In Detail'),
                child: Text(
                  'Detail',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(
                      0xFF1E88E5,
                    ), // Kopi Kenangan blue link color
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Horizontal grid/scroll of 7 check-in cards
          SizedBox(
            height: 94,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final int day = index + 1;
                // Alternate between point coin and voucher icons
                final bool isVoucher = day == 3 || day == 6 || day == 7;
                final bool isChecked =
                    isLoggedIn &&
                    day <= 2; // Simulating first 2 days checked if logged in

                return Container(
                  width: 72,
                  margin: const EdgeInsets.only(
                    right: 10.0,
                    top: 4.0,
                    bottom: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: isChecked ? const Color(0xFFFFFDF9) : Colors.white,
                    border: Border.all(
                      color: isChecked
                          ? const Color(0xFF8C5E3C).withValues(alpha: 0.6)
                          : Colors.grey.shade200,
                      width: isChecked ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (!isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Silakan masuk terlebih dahulu untuk Check-In.',
                              ),
                            ),
                          );
                          LoginBottomSheet.show(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Berhasil Check-In Hari ke-$day!'),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Small coin / voucher icon
                          if (isVoucher)
                            const Icon(
                              Iconsax.receipt_disscount,
                              color: Color(0xFFE57373),
                              size: 20,
                            )
                          else
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFFFD54F,
                                ).withValues(alpha: isChecked ? 1.0 : 0.6),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'W',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF8C5E3C),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(
                            isVoucher ? 'Voucher' : '+25',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isChecked
                                  ? const Color(0xFF8C5E3C)
                                  : const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Hari ke-$day',
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── MENU SECTION CONTAINER ───────────────────────────────────────
  Widget _buildMenuListSection({
    required String title,
    required List<_MenuListItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.grey.shade100,
                thickness: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 2.0,
                  ),
                  leading:
                      item.customIcon ??
                      Icon(item.icon, color: Colors.grey.shade700, size: 22),
                  title: Text(
                    item.title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.showBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Baru',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                    ],
                  ),
                  onTap: item.onTap,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOGOUT CONFIRMATION DIALOG ────────────────────────────────────
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Konfirmasi Keluar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Anda?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<AuthProvider>().logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Anda berhasil keluar.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Keluar',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── COMING SOON TOAST ────────────────────────────────────────────
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur "$feature" akan segera hadir.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// ─── SUB-CLASSES ──────────────────────────────────────────────────

class _MenuListItem {
  final IconData? icon;
  final Widget? customIcon;
  final String title;
  final bool showBadge;
  final VoidCallback onTap;

  const _MenuListItem({
    this.icon,
    this.customIcon,
    required this.title,
    this.showBadge = false,
    required this.onTap,
  });
}

// Custom Painter to draw a steaming food/soup bowl watermark for waRRRung app
class _SteamingBowlPainter extends CustomPainter {
  final Color color;

  _SteamingBowlPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // We will draw the bowl and clip the stripes inside it.
    final bowlPath = Path();

    // Draw bowl outline path (flat top, curved bottom)
    bowlPath.moveTo(w * 0.15, h * 0.45);
    bowlPath.lineTo(w * 0.85, h * 0.45);
    bowlPath.quadraticBezierTo(w * 0.85, h * 0.85, w * 0.5, h * 0.85);
    bowlPath.quadraticBezierTo(w * 0.15, h * 0.85, w * 0.15, h * 0.45);
    bowlPath.close();

    // Base foot of the bowl
    bowlPath.moveTo(w * 0.38, h * 0.85);
    bowlPath.lineTo(w * 0.38, h * 0.92);
    bowlPath.lineTo(w * 0.62, h * 0.92);
    bowlPath.lineTo(w * 0.62, h * 0.85);

    // Save canvas to clip stripes inside the bowl body
    canvas.save();
    canvas.clipPath(bowlPath);

    // Draw diagonal stripes inside the bowl
    const double spacing = 16.0;
    for (double i = -w; i < w + h; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + h, h), paint);
    }
    canvas.restore();

    // Draw solid bowl outline and base
    final borderPaint = Paint()
      ..color = color.withValues(alpha: color.a * 1.3)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bowlPath, borderPaint);

    // Draw Chopsticks sticking out of the bowl
    // Chopstick 1
    canvas.drawLine(
      Offset(w * 0.28, h * 0.30),
      Offset(w * 0.72, h * 0.58),
      borderPaint..strokeWidth = 3.5,
    );
    // Chopstick 2
    canvas.drawLine(
      Offset(w * 0.22, h * 0.34),
      Offset(w * 0.68, h * 0.62),
      borderPaint..strokeWidth = 3.5,
    );

    // Draw 3 waves of steam rising from the bowl using bezier curves
    final steamPaint = Paint()
      ..color = color.withValues(alpha: color.a * 1.1)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Steam wave 1 (left)
    final steam1 = Path()
      ..moveTo(w * 0.35, h * 0.38)
      ..quadraticBezierTo(w * 0.30, h * 0.26, w * 0.38, h * 0.18)
      ..quadraticBezierTo(w * 0.44, h * 0.10, w * 0.36, h * 0.02);
    canvas.drawPath(steam1, steamPaint);

    // Steam wave 2 (middle)
    final steam2 = Path()
      ..moveTo(w * 0.5, h * 0.38)
      ..quadraticBezierTo(w * 0.45, h * 0.26, w * 0.53, h * 0.18)
      ..quadraticBezierTo(w * 0.59, h * 0.10, w * 0.51, h * 0.02);
    canvas.drawPath(steam2, steamPaint);

    // Steam wave 3 (right)
    final steam3 = Path()
      ..moveTo(w * 0.65, h * 0.38)
      ..quadraticBezierTo(w * 0.60, h * 0.26, w * 0.68, h * 0.18)
      ..quadraticBezierTo(w * 0.74, h * 0.10, w * 0.66, h * 0.02);
    canvas.drawPath(steam3, steamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
