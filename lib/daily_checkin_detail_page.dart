import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/providers/auth_provider.dart';
import 'package:warrrung_app/providers/reward_provider.dart';

class DailyCheckInDetailPage extends StatelessWidget {
  const DailyCheckInDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final rewardProvider = context.watch<RewardProvider>();
    final bool isLoggedIn = authProvider.isAuthenticated;

    const Color primaryColor = Color(0xFF8C5E3C);
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
          'Daily Check-In',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF1E88E5)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Info Daily Check-In',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Lakukan Check-In setiap hari untuk mendapatkan tambahan Poin waRRRung dan Voucher Diskon menarik!',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Mengerti',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Days 1 to 6 Grid (3 Columns)
                  _buildDaysGrid(
                    context: context,
                    startDay: 1,
                    endDay: 6,
                    isLoggedIn: isLoggedIn,
                    rewardProvider: rewardProvider,
                    authProvider: authProvider,
                  ),
                  const SizedBox(height: 12),

                  // Day 7 Full Width Special Reward Card
                  _buildSpecialDayCard(
                    context: context,
                    day: 7,
                    title: 'DISKON 10% - Daily Check-In',
                    isLoggedIn: isLoggedIn,
                    rewardProvider: rewardProvider,
                    authProvider: authProvider,
                  ),
                  const SizedBox(height: 12),

                  // Days 8 to 13 Grid (3 Columns)
                  _buildDaysGrid(
                    context: context,
                    startDay: 8,
                    endDay: 13,
                    isLoggedIn: isLoggedIn,
                    rewardProvider: rewardProvider,
                    authProvider: authProvider,
                  ),
                  const SizedBox(height: 12),

                  // Day 14 Full Width Special Reward Card
                  _buildSpecialDayCard(
                    context: context,
                    day: 14,
                    title: 'DISKON 15% - Daily Check-In',
                    isLoggedIn: isLoggedIn,
                    rewardProvider: rewardProvider,
                    authProvider: authProvider,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Bar Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  rewardProvider.isDayClaimed(1) ? 'Check-in lagi besok' : 'Check-In Sekarang',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Grid builder for 3 columns (matching Image 3 layout)
  Widget _buildDaysGrid({
    required BuildContext context,
    required int startDay,
    required int endDay,
    required bool isLoggedIn,
    required RewardProvider rewardProvider,
    required AuthProvider authProvider,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: (endDay - startDay) + 1,
      itemBuilder: (context, index) {
        final day = startDay + index;
        final bool isClaimed = isLoggedIn && rewardProvider.isDayClaimed(day);
        final bool isVoucher = day == 3 || day == 6 || day == 10 || day == 13;
        final int pointAmount = (day >= 8) ? 50 : 25;

        return GestureDetector(
          onTap: () {
            rewardProvider.claimCheckIn(context, isLoggedIn, day);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isClaimed ? const Color(0xFFFBF4EB) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isClaimed
                    ? const Color(0xFF8C5E3C).withValues(alpha: 0.5)
                    : Colors.grey.shade200,
                width: isClaimed ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isClaimed) ...[
                  // Gold Checkmark Circle Icon
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8C5E3C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ] else if (isVoucher) ...[
                  // Grey Voucher Icon
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    child: const Icon(
                      Iconsax.ticket_discount,
                      color: Colors.grey,
                      size: 24,
                    ),
                  ),
                ] else ...[
                  // Coin Icon Base
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'W',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // Amount / Label
                Text(
                  isVoucher ? 'Voucher' : '+$pointAmount',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isClaimed ? const Color(0xFF8C5E3C) : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),

                // Day Label
                Text(
                  'Hari ke-$day',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    color: isClaimed ? const Color(0xFF8C5E3C) : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Full-width special reward card for Day 7 & Day 14 (matching Image 3 layout)
  Widget _buildSpecialDayCard({
    required BuildContext context,
    required int day,
    required String title,
    required bool isLoggedIn,
    required RewardProvider rewardProvider,
    required AuthProvider authProvider,
  }) {
    final bool isClaimed = isLoggedIn && rewardProvider.isDayClaimed(day);

    return GestureDetector(
      onTap: () {
        rewardProvider.claimCheckIn(context, isLoggedIn, day);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: isClaimed ? const Color(0xFFFBF4EB) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isClaimed
                ? const Color(0xFF8C5E3C).withValues(alpha: 0.5)
                : Colors.grey.shade300,
            width: isClaimed ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.card_giftcard_rounded,
              color: Colors.grey,
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isClaimed ? const Color(0xFF8C5E3C) : const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Hari ke-$day',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
