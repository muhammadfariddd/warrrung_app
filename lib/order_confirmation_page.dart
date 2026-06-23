import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:warrrung_app/data/models/cart_item_model.dart';
import 'package:warrrung_app/providers/cart_provider.dart';
import 'package:warrrung_app/providers/location_provider.dart';
import 'package:warrrung_app/location_selection_page.dart';
import 'package:warrrung_app/product_detail_page.dart';
import 'package:warrrung_app/navigation_menu.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';

class OrderConfirmationPage extends StatefulWidget {
  final bool isEmbedded;

  const OrderConfirmationPage({super.key, this.isEmbedded = false});

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> with WidgetsBindingObserver {
  String _selectedServiceMode = 'pickup'; // 'pickup', 'dinein', 'delivery'
  bool _isLoading = false;
  void Function()? _unsubscribeOrder;
  String _selectedPaymentMethod = 'qris'; // 'qris', 'gopay', 'shopeepay', 'ovo', 'dana', 'credit_card'
  bool _hasShoppingBag = false;

  // Proteksi Navigasi Latar Belakang & Daur Hidup Aplikasi
  bool _paymentSuccessful = false;
  bool _isAppInForeground = true;
  bool _isTransitioned = false;
  CartProvider? _storedCartProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_unsubscribeOrder != null) {
      _unsubscribeOrder!();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppInForeground = true;
      // Jika pembayaran sukses terdeteksi saat aplikasi di background, eksekusi pop setelah resume
      if (_paymentSuccessful && _storedCartProvider != null) {
        _handlePaymentSuccessTransition();
      }
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _isAppInForeground = false;
    }
  }

  void _handlePaymentSuccessTransition() {
    if (_isTransitioned) return;
    _isTransitioned = true;

    if (_unsubscribeOrder != null) {
      final unsub = _unsubscribeOrder;
      _unsubscribeOrder = null;
      unsub?.call();
    }

    if (context.mounted) {
      Navigator.of(context).pop(); // Tutup bottom sheet menunggu pembayaran
      if (_storedCartProvider != null) {
        _showSuccessSheet(context, _storedCartProvider!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final activeOutlet =
        locationProvider.selectedOutlet ??
        (locationProvider.outlets.isNotEmpty
            ? locationProvider.outlets.first
            : null);

    // Theme Colors
    const Color primaryRed = Color(0xFFE31A22);
    const Color goldColor = Color(0xFFC5A880);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGray = Color(0xFF757575);

    final double subtotal = cartProvider.totalPrice;
    final double deliveryFee = _selectedServiceMode == 'delivery' ? 10000.0 : 0.0;
    final double shoppingBagFee = _hasShoppingBag ? 1000.0 : 0.0;
    final double grandTotal = subtotal + deliveryFee + shoppingBagFee;

    final String formattedTotal =
        'Rp${grandTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    final double discount = cartProvider.totalDiscount;
    final String? formattedDiscount = discount > 0
        ? 'Hemat Rp${discount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
        : null;

    final double strikeSubtotal = cartProvider.totalStrikePrice;
    final double strikeGrandTotal = strikeSubtotal + deliveryFee + shoppingBagFee;
    final String formattedStrikeTotal =
        'Rp${strikeGrandTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    Widget content = Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: textDark),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Konfirmasi Pesanan',
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              shape: Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1),
              ),
            ),
      body: cartProvider.items.isEmpty
          ? _buildEmptyState(context, primaryRed, textDark, textGray)
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Service Type Selector Tabs
                        _buildServiceTabs(
                          goldColor,
                          textDark,
                          textGray,
                          activeOutlet,
                        ),

                        const SizedBox(height: 8),

                        // 2. Outlet Information Card
                        _buildOutletCard(
                          context,
                          activeOutlet,
                          goldColor,
                          textDark,
                          textGray,
                        ),

                        const SizedBox(height: 8),

                        // 2.5 Pembayaran Langsung (Horizontal list of payment methods)
                        _buildPaymentMethodSection(goldColor, textDark, textGray),

                        const SizedBox(height: 8),

                        // 3. Pesan (Items list) Section Header
                        _buildItemsHeader(context, textDark, primaryRed),

                        // 4. Cart Items List
                        _buildCartItemsList(
                          context,
                          cartProvider.items,
                          goldColor,
                          textDark,
                          textGray,
                        ),

                        const SizedBox(height: 8),

                        // 4.5 Kantung Belanja Section
                        _buildShoppingBagSection(textDark, textGray),

                        const SizedBox(height: 8),

                        // 5. Promo & Voucher Section
                        _buildVoucherSection(goldColor, textDark, textGray),

                        const SizedBox(height: 8),

                        // 5.5 Ringkasan Pembayaran Section
                        _buildPaymentSummarySection(cartProvider, textDark, textGray),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // 6. Sticky Bottom Checkout Bar
                _buildBottomCheckoutBar(
                  context,
                  cartProvider,
                  formattedTotal,
                  formattedStrikeTotal,
                  formattedDiscount,
                  primaryRed,
                  textDark,
                  textGray,
                ),
              ],
            ),
    );

    final Widget overlay = _isLoading
        ? Stack(
            children: [
              content,
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryRed),
                  ),
                ),
              ),
            ],
          )
        : content;

    return overlay;
  }

  // ─── SERVICE TYPE TABS ─────────────────────────────────────────────────────
  Widget _buildServiceTabs(
    Color gold,
    Color dark,
    Color gray,
    dynamic activeOutlet,
  ) {
    final bool hasDineIn = activeOutlet != null && activeOutlet.hasDineIn;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          _buildTabButton(
            'pickup',
            'Pickup',
            'Order dan pickup di outlet',
            gold,
            dark,
            gray,
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            'dinein',
            'Dine-In',
            hasDineIn ? 'Makan di tempat' : 'Tidak tersedia di store ini',
            gold,
            dark,
            gray,
            isEnabled: hasDineIn,
          ),
          const SizedBox(width: 8),
          _buildTabButton(
            'delivery',
            'Delivery',
            'Pesanan diantar kealamat',
            gold,
            dark,
            gray,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    String mode,
    String title,
    String subtitle,
    Color gold,
    Color dark,
    Color gray, {
    bool isEnabled = true,
  }) {
    final bool isSelected = _selectedServiceMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                setState(() {
                  _selectedServiceMode = mode;
                });
              }
            : null,
        child: Container(
          height: 68,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFFDF9)
                : const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? gold : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? gold : dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 8.5,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: isSelected ? gold.withValues(alpha: 0.85) : gray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── OUTLET CARD ──────────────────────────────────────────────────────────
  Widget _buildOutletCard(
    BuildContext context,
    dynamic outlet,
    Color gold,
    Color dark,
    Color gray,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Iconsax.shop, color: gold, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outlet != null
                        ? 'Outlet: ${outlet.name}'
                        : 'Belum Memilih Outlet',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    outlet != null
                        ? outlet.address
                        : 'Silakan pilih outlet terdekat untuk mulai memesan.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: gray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationSelectionPage(),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Ubah',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ITEMS HEADER ──────────────────────────────────────────────────────────
  Widget _buildItemsHeader(BuildContext context, Color dark, Color red) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Pesan',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          GestureDetector(
            onTap: () {
              final controller = Get.find<NavigationController>();
              controller.selectedIndex.value = 1; // Direct to Menu tab
              if (!widget.isEmbedded) {
                Navigator.popUntil(context, (route) => route.isFirst);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tambah Pesan',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.add, size: 12, color: Colors.blue.shade700),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CART ITEMS LIST ───────────────────────────────────────────────────────
  Widget _buildCartItemsList(
    BuildContext context,
    List<CartItemModel> items,
    Color gold,
    Color dark,
    Color gray,
  ) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 24, thickness: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final String customizationText = item.customizations.join(', ');

          final String priceText =
              'Rp${item.totalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

          final double discount = item.totalStrikePrice - item.totalPrice;
          final String? strikePriceText = discount > 0
              ? 'Rp${item.totalStrikePrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
              : null;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product detail fields (Left side)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.product.name} $customizationText',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: dark,
                        height: 1.35,
                      ),
                    ),
                    if (item.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Catatan: ${item.notes}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          priceText,
                          style: GoogleFonts.poppins(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: dark,
                          ),
                        ),
                        if (strikePriceText != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            strikePriceText,
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Edit/Ganti Button
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailPage(
                                  product: item.product,
                                  existingCartItem: item,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_outlined, size: 13),
                          label: Text(
                            'Ganti',
                            style: GoogleFonts.poppins(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: dark,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 0,
                            ),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const Spacer(),

                        // Quantity Selector
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 14),
                                onPressed: () {
                                  context.read<CartProvider>().updateQuantity(
                                    item.id,
                                    item.quantity - 1,
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
                                ),
                              ),
                              Text(
                                '${item.quantity}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 14),
                                onPressed: () {
                                  context.read<CartProvider>().updateQuantity(
                                    item.id,
                                    item.quantity + 1,
                                  );
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 28,
                                  minHeight: 28,
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
              const SizedBox(width: 16),

              // Product Image (Right side)
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: item.product.imageUrl.isNotEmpty
                      ? Image.network(
                          item.product.imageUrl,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.fastfood, color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVoucherSection(Color gold, Color dark, Color gray) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFECE6D9), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.8),
          child: Column(
            children: [
              // 1. Voucher hint banner (Orange)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFFFF7ED),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add,
                      color: Color(0xFFEA580C),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tambah pesanan untuk pakai voucher',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                    ),
                    Icon(Icons.more_horiz, color: Colors.grey.shade400, size: 16),
                  ],
                ),
              ),
              // Divider between the hint banner and the voucher picker
              Container(
                height: 1.2,
                color: const Color(0xFFECE6D9),
              ),
              // 2. Voucher selection input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFFAF9F6),
                child: Row(
                  children: [
                    Icon(Iconsax.ticket_discount_copy, color: gold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pakai Kode Voucher',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: dark,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: gold, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BOTTOM STICKY CHECKOUT BAR ───────────────────────────────────────────
  Widget _buildBottomCheckoutBar(
    BuildContext context,
    CartProvider cartProvider,
    String total,
    String strikeTotal,
    String? discount,
    Color red,
    Color dark,
    Color gray,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Tombol Jadwalkan (Kiri)
          SizedBox(
            height: 48,
            width: 130,
            child: OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fitur penjadwalan akan segera hadir!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: red,
                side: BorderSide(color: red, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.clock, size: 18, color: red),
                    const SizedBox(width: 6),
                    Text(
                      'Jadwalkan',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 2. Tombol Bayar (Kanan)
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => _initiateMidtransPayment(context, cartProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Bayar - $total',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── INITIATE MIDTRANS PAYMENT ─────────────────────────────────────────────
  Future<void> _initiateMidtransPayment(BuildContext context, CartProvider cartProvider) async {
    final locationProvider = context.read<LocationProvider>();
    final activeOutlet = locationProvider.selectedOutlet ??
        (locationProvider.outlets.isNotEmpty ? locationProvider.outlets.first : null);

    if (activeOutlet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih outlet terlebih dahulu.')),
      );
      return;
    }

    final pbService = PocketBaseService();
    final user = pbService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu untuk melakukan pesanan.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Siapkan data item keranjang belanja
      final itemsPayload = cartProvider.items.map((item) {
        return {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'notes': item.notes,
          'customizations': item.customizations,
        };
      }).toList();

      final double subtotal = cartProvider.totalPrice;
      final double deliveryFee = _selectedServiceMode == 'delivery' ? 10000.0 : 0.0;
      final double shoppingBagFee = _hasShoppingBag ? 1000.0 : 0.0;
      final double totalPayment = subtotal + deliveryFee + shoppingBagFee;

      // 2. Kirim request checkout ke backend PocketBase Custom Endpoint
      final response = await pbService.client.send(
        '/api/warrierung/midtrans/checkout',
        method: 'POST',
        body: {
          'user_id': user.id,
          'outlet_id': activeOutlet.id,
          'order_type': _selectedServiceMode,
          'delivery_address': _selectedServiceMode == 'delivery' ? activeOutlet.address : '',
          'subtotal': subtotal,
          'delivery_fee': deliveryFee,
          'discount_fee': cartProvider.totalDiscount,
          'total_payment': totalPayment,
          'payment_method': _selectedPaymentMethod,
          'items': itemsPayload,
        },
      );

      setState(() {
        _isLoading = false;
      });

      debugPrint('Midtrans Checkout Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('order_id')) {
        final String orderId = response['order_id'];
        final String paymentType = response['payment_type'] ?? '';
        final String deeplinkUrl = response['deeplink_url'] ?? '';
        final String qrCodeUrl = response['qr_code_url'] ?? '';
        final String qrString = response['qr_string'] ?? '';
        final String redirectUrl = response['redirect_url'] ?? '';

        if (paymentType == 'qris' && qrCodeUrl.isNotEmpty) {
          if (context.mounted) {
            _showQrisDialog(context, cartProvider, orderId, qrCodeUrl, qrString);
          }
        } else if (deeplinkUrl.isNotEmpty) {
          if (context.mounted) {
            _showWaitingPaymentSheet(context, cartProvider, orderId);
          }
          await Future.delayed(const Duration(milliseconds: 150));
          
          try {
            final Uri paymentUri = Uri.parse(deeplinkUrl);
            final bool launched = await launchUrl(
              paymentUri,
              mode: LaunchMode.externalNonBrowserApplication,
            );
            
            if (!launched) {
              debugPrint('Gagal membuka aplikasi secara langsung (mungkin tidak terinstall). Mencoba fallback...');
              if (redirectUrl.isNotEmpty) {
                await launchUrl(
                  Uri.parse(redirectUrl),
                  mode: LaunchMode.externalApplication,
                );
              } else if (qrCodeUrl.isNotEmpty && context.mounted) {
                // Tutup waiting sheet dan tampilkan QRIS
                Navigator.of(context).pop();
                _showQrisDialog(context, cartProvider, orderId, qrCodeUrl, qrString);
              }
            }
          } catch (e) {
            debugPrint('Error saat mencoba membuka deep link: $e. Membuka fallback...');
            if (redirectUrl.isNotEmpty) {
              await launchUrl(
                Uri.parse(redirectUrl),
                mode: LaunchMode.externalApplication,
              );
            } else if (qrCodeUrl.isNotEmpty && context.mounted) {
              Navigator.of(context).pop();
              _showQrisDialog(context, cartProvider, orderId, qrCodeUrl, qrString);
            }
          }
        } else if (redirectUrl.isNotEmpty) {
          if (context.mounted) {
            _showWaitingPaymentSheet(context, cartProvider, orderId);
          }
          await Future.delayed(const Duration(milliseconds: 150));
          final Uri paymentUri = Uri.parse(redirectUrl);
          await launchUrl(
            paymentUri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (context.mounted) {
            _showWaitingPaymentSheet(context, cartProvider, orderId);
          }
        }
      } else {
        throw Exception('Response format dari server tidak valid.');
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat pesanan: ${e.toString()}')),
        );
      }
    }
  }

  // ─── QRIS DIALOG ───────────────────────────────────────────────────────────
  void _showQrisDialog(
    BuildContext context,
    CartProvider cartProvider,
    String orderId,
    String qrCodeUrl,
    String qrString,
  ) {
    final pbService = PocketBaseService();
    _isTransitioned = false;
    _paymentSuccessful = false;
    _storedCartProvider = cartProvider;

    // Hentikan subskripsi sebelumnya jika ada
    if (_unsubscribeOrder != null) {
      _unsubscribeOrder!();
      _unsubscribeOrder = null;
    }

    // Daftarkan subskripsi real-time ke order record
    pbService.client.collection('orders').subscribe(orderId, (event) {
      if (event.action == 'update') {
        final status = event.record?.getStringValue('status');
        if (status == 'processing') {
          _storedCartProvider = cartProvider;
          if (_isAppInForeground) {
            // Jika aplikasi di foreground, langsung jalankan UI transition
            _handlePaymentSuccessTransition();
          } else {
            // Jika aplikasi di background, tunda navigasi sampai aplikasi di-resume
            _paymentSuccessful = true;
            debugPrint('Pembayaran sukses terdeteksi di background. Navigasi ditunda.');
          }
        }
      }
    }).then((unsub) {
      _unsubscribeOrder = unsub;
    }).catchError((err) {
      debugPrint('Error subskripsi real-time: $err');
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        const Color red = Color(0xFFE31A22);
        return PopScope(
          canPop: false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan QRIS waRRRung',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_unsubscribeOrder != null) {
                              _unsubscribeOrder!();
                              _unsubscribeOrder = null;
                            }
                            Navigator.pop(dialogContext);
                          },
                          child: const Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // QRIS Logo atau Info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_2, color: Colors.blue, size: 20),
                          const SizedBox(width: 6),
                          Text(
                            'Gopay, OVO, DANA, ShopeePay, dll',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // QRIS Image
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Image.network(
                        qrCodeUrl,
                        width: 200,
                        height: 200,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(color: red),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const SizedBox(
                            width: 200,
                            height: 200,
                            child: Center(
                              child: Text(
                                'Gagal memuat QRIS. Coba ketuk ulang tombol pembayaran.',
                                style: TextStyle(color: Colors.red, fontSize: 11),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tips Pengguna
                    Text(
                      'TIPS NATIVE APP:',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Screenshot QR Code ini, lalu scan melalui galeri aplikasi pembayaran Anda.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Cek Status Manual
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final order = await pbService.client.collection('orders').getOne(orderId);
                            if (!dialogContext.mounted) return;
                            if (order.getStringValue('status') == 'processing') {
                              if (!_isTransitioned) {
                                _isTransitioned = true;
                                if (_unsubscribeOrder != null) {
                                  final unsub = _unsubscribeOrder;
                                  _unsubscribeOrder = null;
                                  unsub?.call();
                                }
                                Navigator.pop(dialogContext);
                                if (context.mounted) {
                                  _showSuccessSheet(context, cartProvider);
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Pembayaran belum terdeteksi. Silakan bayar terlebih dahulu.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Gagal mengecek status: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Saya Sudah Membayar',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Batal
                    TextButton(
                      onPressed: () {
                        if (_unsubscribeOrder != null) {
                          _unsubscribeOrder!();
                          _unsubscribeOrder = null;
                        }
                        Navigator.pop(dialogContext);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                      ),
                      child: Text(
                        'Kembali ke Konfirmasi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── WAITING PAYMENT SHEET ──────────────────────────────────────────────────
  void _showWaitingPaymentSheet(BuildContext context, CartProvider cartProvider, String orderId) {
    final pbService = PocketBaseService();
    _isTransitioned = false;
    _paymentSuccessful = false;
    _storedCartProvider = cartProvider;

    // Hentikan subskripsi sebelumnya jika ada
    if (_unsubscribeOrder != null) {
      _unsubscribeOrder!();
      _unsubscribeOrder = null;
    }

    // Daftarkan subskripsi real-time ke order record
    pbService.client.collection('orders').subscribe(orderId, (event) {
      if (event.action == 'update') {
        final status = event.record?.getStringValue('status');
        if (status == 'processing') {
          _storedCartProvider = cartProvider;
          if (_isAppInForeground) {
            // Jika aplikasi di foreground, langsung jalankan UI transition
            _handlePaymentSuccessTransition();
          } else {
            // Jika aplikasi di background, tunda navigasi sampai aplikasi di-resume
            _paymentSuccessful = true;
            debugPrint('Pembayaran sukses terdeteksi di background. Navigasi ditunda.');
          }
        }
      }
    }).then((unsub) {
      _unsubscribeOrder = unsub;
    }).catchError((err) {
      debugPrint('Error subskripsi real-time: $err');
    });

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return PopScope(
          canPop: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE31A22)),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Menunggu Pembayaran...',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Silakan selesaikan pembayaran Anda pada halaman Midtrans yang terbuka. Aplikasi akan otomatis mendeteksi ketika pembayaran Anda lunas.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                
                // Cek status pembayaran secara manual
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final order = await pbService.client.collection('orders').getOne(orderId);
                        if (!sheetContext.mounted) return;
                        if (order.getStringValue('status') == 'processing') {
                          if (!_isTransitioned) {
                            _isTransitioned = true;
                            if (_unsubscribeOrder != null) {
                              final unsub = _unsubscribeOrder;
                              _unsubscribeOrder = null;
                              unsub?.call();
                            }

                            Navigator.pop(sheetContext);
                            if (context.mounted) {
                              _showSuccessSheet(context, cartProvider);
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            const SnackBar(
                              content: Text('Pembayaran belum terdeteksi. Silakan bayar terlebih dahulu.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(content: Text('Gagal mengecek status: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFE31A22),
                      side: const BorderSide(color: Color(0xFFE31A22), width: 1.2),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cek Status Pembayaran',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Batal checkout
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () {
                      if (_unsubscribeOrder != null) {
                        _unsubscribeOrder!();
                        _unsubscribeOrder = null;
                      }
                      Navigator.pop(sheetContext);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text(
                      'Kembali ke Konfirmasi',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── SUCCESS SHEET ─────────────────────────────────────────────────────────
  void _showSuccessSheet(BuildContext context, CartProvider cartProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'Pesanan Berhasil Dibuat!',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pembayaran Anda telah lunas dan pesanan sedang diproses oleh outlet. Silakan periksa status di tab riwayat.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    // Bersihkan keranjang
                    cartProvider.clearCart();
                    // Tutup sheet sukses
                    Navigator.pop(context);
                    // Arahkan ke tab riwayat (Tab menu Pesanan -> Riwayat)
                    final controller = Get.find<NavigationController>();
                    controller.selectedIndex.value = 2; // Go to Pesanan/Cart tab (wait! in navigation_menu we mapped Pesanan to index 2)

                    if (!widget.isEmbedded) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE31A22),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Selesai & Belanja Lagi',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── EMPTY STATE WIDGET ────────────────────────────────────────────────────
  Widget _buildEmptyState(
    BuildContext context,
    Color primaryRed,
    Color dark,
    Color gray,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.shopping_cart,
                color: Colors.grey.shade400,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Keranjang Belanja Kosong',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sepertinya Anda belum memilih makanan atau minuman lezat dari waRRRung.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: gray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 160,
              height: 42,
              child: ElevatedButton(
                onPressed: () {
                  final controller = Get.find<NavigationController>();
                  controller.selectedIndex.value = 1; // Navigate to Menu
                  if (!widget.isEmbedded) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Mulai Belanja',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── PEMBAYARAN LANGSUNG (NATIVE SELECTION LIST) ──────────────────────────
  Widget _buildPaymentMethodSection(Color gold, Color dark, Color gray) {
    final List<Map<String, dynamic>> methods = [
      {
        'id': 'qris',
        'name': 'QRIS',
        'subtext': 'Simpan QR & bayar',
        'color': const Color(0xFF6200EE),
        'logo': 'QRIS',
        'hasConnect': false,
      },
      {
        'id': 'gopay',
        'name': 'GoPay',
        'subtext': 'Bayar instan',
        'color': const Color(0xFF00AED6),
        'logo': 'GoPay',
        'hasConnect': true,
      },
      {
        'id': 'shopeepay',
        'name': 'ShopeePay',
        'subtext': 'Bayar instan',
        'color': const Color(0xFFEE4D2D),
        'logo': 'ShopeePay',
        'hasConnect': true,
      },
      {
        'id': 'ovo',
        'name': 'OVO',
        'subtext': 'OVO Cashback 60%*',
        'color': const Color(0xFF4C2A86),
        'logo': 'OVO',
        'hasConnect': false,
      },
      {
        'id': 'dana',
        'name': 'DANA',
        'subtext': 'Bayar via DANA',
        'color': const Color(0xFF118EEA),
        'logo': 'DANA',
        'hasConnect': false,
      },
      {
        'id': 'credit_card',
        'name': 'Credit Card',
        'subtext': 'Min. Rp50.000',
        'color': const Color(0xFF37474F),
        'logo': 'Card',
        'hasConnect': false,
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pembayaran Langsung',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pilih salah satu metode pembayaran di bawah',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: gold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.poppins(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00897B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: methods.length,
              itemBuilder: (context, index) {
                final m = methods[index];
                final isSelected = _selectedPaymentMethod == m['id'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = m['id'];
                    });
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: gold.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Brand Logo Icon
                        Container(
                          height: 32,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: m['color'].withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: m['logo'] == 'QRIS'
                                ? Icon(Icons.qr_code_2, color: m['color'], size: 22)
                                : m['logo'] == 'Card'
                                    ? Icon(Icons.credit_card, color: m['color'], size: 18)
                                    : Text(
                                        m['logo'],
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          color: m['color'],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                          ),
                        ),
                        // Method Name
                        Text(
                          m['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: dark,
                          ),
                        ),
                        // Subtext or Connect Button
                        m['hasConnect'] && !isSelected
                            ? Container(
                                height: 20,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE31A22),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    'Hubungkan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                m['subtext'],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 8.5,
                                  color: gray,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
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

  // ─── KANTUNG BELANJA CHECKBOX ──────────────────────────────────────────────
  Widget _buildShoppingBagSection(Color dark, Color gray) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Checkbox(
            value: _hasShoppingBag,
            activeColor: const Color(0xFFE31A22),
            onChanged: (val) {
              setState(() {
                _hasShoppingBag = val ?? false;
              });
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Kantung Belanja',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dark,
              ),
            ),
          ),
          Text(
            'Rp1.000',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }

  // ─── RINGKASAN PEMBAYARAN ──────────────────────────────────────────────────
  Widget _buildPaymentSummarySection(CartProvider cartProvider, Color dark, Color gray) {
    final double subtotal = cartProvider.totalPrice;
    final double deliveryFee = _selectedServiceMode == 'delivery' ? 10000.0 : 0.0;
    final double shoppingBagFee = _hasShoppingBag ? 1000.0 : 0.0;
    final double discount = cartProvider.totalDiscount;
    final double grandTotal = subtotal + deliveryFee + shoppingBagFee;

    final String formattedSubtotal =
        'Rp${subtotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    final String formattedDelivery =
        'Rp${deliveryFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    final String formattedBag =
        'Rp${shoppingBagFee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    final String formattedDiscount =
        '-Rp${discount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    final String formattedTotal =
        'Rp${grandTotal.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', formattedSubtotal, dark, gray),
          if (_selectedServiceMode == 'delivery') ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Biaya Delivery', formattedDelivery, dark, gray),
          ],
          if (_hasShoppingBag) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Kantung Belanja', formattedBag, dark, gray),
          ],
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Promo', formattedDiscount, const Color(0xFF00897B), gray, isDiscount: true),
          ],
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              Text(
                formattedTotal,
                style: GoogleFonts.poppins(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color labelColor, Color valueColor, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: labelColor,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: isDiscount ? const Color(0xFF00897B) : valueColor,
            fontWeight: isDiscount ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
