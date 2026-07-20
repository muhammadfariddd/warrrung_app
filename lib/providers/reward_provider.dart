import 'package:flutter/material.dart';
import 'package:warrrung_app/core/widgets/login_bottom_sheet.dart';

/// Provider for managing User Rewards, Daily Check-In status, Points, and Claimed Vouchers.
class RewardProvider extends ChangeNotifier {
  int _userPoints = 25; // Default points matching Image 1 reference
  final Set<int> _claimedDays = {1}; // Day 1 claimed by default when logged in (matching Image 1)
  final Set<String> _claimedVouchers = {};

  int get userPoints => _userPoints;
  Set<int> get claimedDays => Set.unmodifiable(_claimedDays);
  Set<String> get claimedVouchers => Set.unmodifiable(_claimedVouchers);

  bool isDayClaimed(int day) => _claimedDays.contains(day);
  bool isVoucherClaimed(String voucherId) => _claimedVouchers.contains(voucherId);

  /// Claims a specific check-in day.
  /// Requires authentication. If user is guest, pops open LoginBottomSheet.
  void claimCheckIn(BuildContext context, bool isAuthenticated, int day) {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masuk terlebih dahulu untuk Check-In.'),
          duration: Duration(seconds: 2),
        ),
      );
      LoginBottomSheet.show(context);
      return;
    }

    if (_claimedDays.contains(day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hari ke-$day sudah diklaim sebelumnya.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _claimedDays.add(day);
    
    // Points reward allocation
    int pointsEarned = 25;
    if (day >= 8 && day <= 13 && day != 10) {
      pointsEarned = 50;
    } else if (day == 7 || day == 14) {
      pointsEarned = 0; // Special voucher reward
    }
    
    _userPoints += pointsEarned;
    notifyListeners();

    final String rewardMsg = pointsEarned > 0 
        ? 'Berhasil Check-In Hari ke-$day! (+$pointsEarned Points)'
        : 'Berhasil Check-In Hari ke-$day! Voucher berhasil didapatkan';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(rewardMsg),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Claims a voucher from the Diskon & Cashback section.
  /// Requires authentication. If user is guest, pops open LoginBottomSheet.
  void claimVoucher(BuildContext context, bool isAuthenticated, String voucherId, String voucherTitle) {
    if (!isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masuk terlebih dahulu untuk mengklaim voucher.'),
          duration: Duration(seconds: 2),
        ),
      );
      LoginBottomSheet.show(context);
      return;
    }

    if (_claimedVouchers.contains(voucherId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher "$voucherTitle" sudah Anda klaim.'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    _claimedVouchers.add(voucherId);
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher "$voucherTitle" Berhasil Diklaim!'),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
