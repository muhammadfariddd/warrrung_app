import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/providers/cart_provider.dart';

class VouchersPage extends StatefulWidget {
  const VouchersPage({super.key});

  @override
  State<VouchersPage> createState() => _VouchersPageState();
}

class _VouchersPageState extends State<VouchersPage> {
  String _selectedCategory = 'Semua';

  final List<Map<String, dynamic>> _vouchers = [
    {
      'id': 'v_banner3',
      'tag': 'Pakai di App',
      'type': 'Diskon',
      'title': 'Diskon Rp20.000',
      'subtitle': 'Min. belanja Rp50.000 untuk semua menu',
      'minSpend': 50000.0,
      'discountAmount': 20000.0,
      'expiry': '31 Jul 2026, 23:59',
    },
    {
      'id': 'v_ongkir',
      'tag': 'Delivery waRRRung Express',
      'type': 'Delivery',
      'title': 'Ongkir Flat Rp10.000',
      'subtitle': 'Minimum belanja Rp30.000 khusus delivery',
      'minSpend': 30000.0,
      'discountAmount': 10000.0,
      'expiry': '31 Jul 2026, 23:59',
    },
    {
      'id': 'v_cashback',
      'tag': 'Pakai di App',
      'type': 'Cashback',
      'title': 'Cashback 20% s/d 25RB',
      'subtitle': 'Min. belanja Rp40.000 untuk semua menu',
      'minSpend': 40000.0,
      'discountAmount': 25000.0,
      'expiry': '31 Jul 2026, 23:59',
    },
    {
      'id': 'v_diskon30',
      'tag': 'Pakai di App',
      'type': 'Diskon',
      'title': 'Diskon 30% s/d 30RB - Menu Baru',
      'subtitle': 'Min. pembelian 60RB untuk semua menu',
      'minSpend': 60000.0,
      'discountAmount': 30000.0,
      'expiry': '31 Jul 2026, 23:59',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final double subtotal = cartProvider.totalPrice;

    const Color goldColor = Color(0xFF8C5E3C);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGray = Color(0xFF757575);

    final filteredVouchers = _vouchers.where((v) {
      if (_selectedCategory == 'Semua') return true;
      return v['type'] == _selectedCategory;
    }).toList();

    // Separate vouchers into eligible and non-eligible based on subtotal
    final eligibleVouchers = filteredVouchers.where((v) {
      final double minSpend = (v['minSpend'] as num).toDouble();
      return subtotal >= minSpend || subtotal == 0; // If opened from profile (subtotal==0), allow viewing all
    }).toList();

    final nonEligibleVouchers = filteredVouchers.where((v) {
      final double minSpend = (v['minSpend'] as num).toDouble();
      return subtotal > 0 && subtotal < minSpend;
    }).toList();

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
          'Vouchers',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_alt_outlined, color: textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills Row
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['Semua', 'Diskon', 'Cashback', 'Delivery'].map((cat) {
                    final bool isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? goldColor : textDark,
                        ),
                        selectedColor: const Color(0xFFFFFDF9),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? goldColor : Colors.grey.shade300,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header section Diskon & Cashback
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.percent_rounded,
                      size: 16,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Diskon & Cashback',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                ],
              ),
            ),

            // 1. Voucher Yang Bisa Dipakai Section
            if (eligibleVouchers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Voucher Yang Bisa Dipakai',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              ...eligibleVouchers.map((voucher) => _buildVoucherCard(
                    context: context,
                    voucher: voucher,
                    isEligible: true,
                    cartProvider: cartProvider,
                    goldColor: goldColor,
                    textDark: textDark,
                    textGray: textGray,
                  )),
            ],

            // 2. Voucher Belum Bisa Dipakai Section
            if (nonEligibleVouchers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  'Voucher Belum Bisa dipakai',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ),
              ...nonEligibleVouchers.map((voucher) => _buildVoucherCard(
                    context: context,
                    voucher: voucher,
                    isEligible: false,
                    cartProvider: cartProvider,
                    goldColor: goldColor,
                    textDark: textDark,
                    textGray: textGray,
                  )),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard({
    required BuildContext context,
    required Map<String, dynamic> voucher,
    required bool isEligible,
    required CartProvider cartProvider,
    required Color goldColor,
    required Color textDark,
    required Color textGray,
  }) {
    final bool isSelected = cartProvider.selectedVoucher?['id'] == voucher['id'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isEligible ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected
              ? goldColor
              : (isEligible ? Colors.grey.shade300 : Colors.grey.shade200),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag (e.g. Pakai di App)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isEligible
                              ? Colors.grey.shade200
                              : Colors.grey.shade200.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          voucher['tag'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isEligible ? textGray : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        voucher['title'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: isEligible ? textDark : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle
                      Text(
                        voucher['subtitle'] as String,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right Ticket Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Iconsax.ticket_discount,
                    color: Color(0xFF1A1A1A),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Dashed Divider
          LayoutBuilder(
            builder: (context, constraints) {
              final boxWidth = constraints.maxWidth;
              const dashWidth = 5.0;
              const dashSpace = 3.0;
              final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
              return Row(
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth + dashSpace,
                    child: Center(
                      child: Container(
                        width: dashWidth,
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Bottom Bar (Expiry date + Action Button)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Berlaku hingga ${voucher['expiry']}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                if (isEligible) ...[
                  GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        cartProvider.removeVoucher();
                      } else {
                        cartProvider.applyVoucher(voucher);
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isSelected
                                ? 'Voucher dilepas.'
                                : 'Voucher "${voucher['title']}" berhasil diterapkan!',
                          ),
                          backgroundColor: isSelected ? Colors.grey.shade800 : const Color(0xFF2E7D32),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.grey.shade200 : goldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSelected ? 'Lepas' : 'Pakai',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? textDark : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Detail',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
