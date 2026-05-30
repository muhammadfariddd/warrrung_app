import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/providers/location_provider.dart';
import 'package:warrrung_app/providers/home_provider.dart';
import 'package:warrrung_app/location_selection_page.dart';
import 'package:warrrung_app/data/models/product_model.dart';
import 'package:warrrung_app/core/widgets/login_bottom_sheet.dart';
import 'package:warrrung_app/providers/auth_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? _activeCategoryName;

  // Colors
  static const Color _primaryRed = Color(0xFFC62828);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGray = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final homeState = homeProvider.state;

    // Check if location is selected
    if (locationProvider.selectedOutlet == null) {
      return _buildNoLocationState(context);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── TOP SELECTOR BAR ───────────────────────────────────────────
            _buildTopSelectorBar(context, locationProvider),
            Divider(color: Colors.grey.shade200, height: 1, thickness: 1),

            // ─── MENU CONTENT ────────────────────────────────────────────────
            Expanded(
              child: _buildMenuContent(homeState, homeProvider),
            ),
          ],
        ),
      ),
    );
  }

  // State when no location has been chosen yet
  Widget _buildNoLocationState(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rounded location icon decoration
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Iconsax.location_copy,
                    color: _primaryRed,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Pilih Lokasi Terlebih Dahulu',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Silakan pilih outlet waRRRung terdekat untuk melihat menu makanan dan minuman yang tersedia.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _textGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Button to open store selector
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LocationSelectionPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryRed,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Pilih Lokasi',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSelectorBar(BuildContext context, LocationProvider provider) {
    final outlet = provider.selectedOutlet!;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.store_rounded, color: _primaryRed, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Outlet Anda',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  outlet.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Change button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSelectionPage(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Ubah',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00897B), // Teal
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuContent(HomeState homeState, HomeProvider homeProvider) {
    if (homeState is HomeStateLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(_primaryRed),
        ),
      );
    }

    if (homeState is HomeStateError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gagal memuat menu',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _textDark),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: homeProvider.loadHomeData,
              child: const Text('Coba Lagi', style: TextStyle(color: _primaryRed)),
            ),
          ],
        ),
      );
    }

    if (homeState is HomeStateLoaded) {
      final categories = homeState.categories;
      final productsMap = homeState.productsByCategory;

      if (categories.isEmpty) {
        return const Center(child: Text('Tidak ada kategori menu'));
      }

      // Initialize active category if not set
      _activeCategoryName ??= categories.first.name;

      // Ensure active category actually exists
      if (!productsMap.containsKey(_activeCategoryName)) {
        _activeCategoryName = categories.first.name;
      }

      final activeProducts = productsMap[_activeCategoryName] ?? [];

      return Column(
        children: [
          // ─── HORIZONTAL CATEGORIES TAB LIST ──────────────────────────────
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final bool isActive = _activeCategoryName == category.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeCategoryName = category.name;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? _primaryRed : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      category.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        color: isActive ? Colors.white : _textGray,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── PRODUCTS LIST VIEW ──────────────────────────────────────────
          Expanded(
            child: activeProducts.isEmpty
                ? Center(
                    child: Text(
                      'Menu belum tersedia di kategori ini.',
                      style: GoogleFonts.poppins(color: _textGray, fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: activeProducts.length,
                    itemBuilder: (context, index) {
                      final product = activeProducts[index];
                      return _buildProductCard(context, product);
                    },
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final authProvider = context.watch<AuthProvider>();

    // Dynamic price formatting
    final String formattedPrice = 'Rp ${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    final String? formattedStrikePrice = product.strikePrice != null && product.strikePrice! > 0
        ? 'Rp ${product.strikePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.fastfood, color: Colors.grey, size: 30),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade100,
                      alignment: Alignment.center,
                      child: const Icon(Icons.fastfood, color: Colors.grey, size: 30),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Middle: Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _textGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Prices
                Row(
                  children: [
                    Text(
                      formattedPrice,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _primaryRed,
                      ),
                    ),
                    if (formattedStrikePrice != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        formattedStrikePrice,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Right: Add Button
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.only(top: 48),
              child: InkWell(
                onTap: () {
                  if (!authProvider.isAuthenticated) {
                    LoginBottomSheet.show(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${product.name}" ditambahkan ke keranjang.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: _primaryRed,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
