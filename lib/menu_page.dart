import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/providers/location_provider.dart';
import 'package:warrrung_app/providers/home_provider.dart';
import 'package:warrrung_app/location_selection_page.dart';
import 'package:warrrung_app/data/models/category_model.dart';
import 'package:warrrung_app/data/models/product_model.dart';
import 'package:warrrung_app/core/widgets/login_bottom_sheet.dart';
import 'package:warrrung_app/providers/auth_provider.dart';
import 'package:warrrung_app/product_detail_page.dart';
import 'package:warrrung_app/core/widgets/skeleton_loading_widget.dart';
import 'package:warrrung_app/core/widgets/error_state_widget.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? _activeCategoryName;
  String? _lastLoadedOutletId;

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

    // Dynamic product loading based on selected outlet
    final currentOutletId = locationProvider.selectedOutlet?.id;
    if (currentOutletId != _lastLoadedOutletId) {
      _lastLoadedOutletId = currentOutletId;
      if (currentOutletId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<HomeProvider>().loadHomeData(outletId: currentOutletId);
        });
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── UNIFIED HEADER (Location Selector + Categories) ───────────
            _buildUnifiedHeader(context, locationProvider, homeState),

            // ─── MENU CONTENT ────────────────────────────────────────────────
            Expanded(child: _buildMenuContent(homeState, homeProvider)),
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

  Widget _buildUnifiedHeader(
    BuildContext context,
    LocationProvider locationProvider,
    HomeState homeState,
  ) {
    List<CategoryModel> categories = [];
    if (homeState is HomeStateLoaded) {
      categories = homeState.categories;
      if (categories.isNotEmpty) {
        _activeCategoryName ??= categories.first.name;
        final productsMap = homeState.productsByCategory;
        if (!productsMap.containsKey(_activeCategoryName)) {
          _activeCategoryName = categories.first.name;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopSelectorBar(context, locationProvider),
          if (categories.isNotEmpty) ...[
            _buildCategoryTabList(categories),
          ] else ...[
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryTabList(List<CategoryModel> categories) {
    return Container(
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
              margin: const EdgeInsets.only(right: 20),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF8D6E63)
                          : Colors.black87,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 28,
                      height: 2.5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8D6E63),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSelectorBar(BuildContext context, LocationProvider provider) {
    final outlet = provider.selectedOutlet!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LocationSelectionPage(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    outlet.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 11, color: _textGray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFFC62828),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContent(HomeState homeState, HomeProvider homeProvider) {
    final selectedOutlet = context.read<LocationProvider>().selectedOutlet;

    Widget content;
    if (homeState is HomeStateLoading) {
      content = const MenuSkeletonWidget();
    } else if (homeState is HomeStateError) {
      content = SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0),
          child: ContentErrorCard(
            title: 'Gagal Memuat Konten',
            message: 'Coba lagi atau klik Muat Ulang',
            onRetry: () {
              showConnectionErrorModal(
                context,
                onConfirm: () {
                  homeProvider.loadHomeData(outletId: selectedOutlet?.id);
                },
              );
            },
          ),
        ),
      );
    } else if (homeState is HomeStateLoaded) {
      final categories = homeState.categories;
      final productsMap = homeState.productsByCategory;

      if (categories.isEmpty) {
        content = const Center(child: Text('Tidak ada kategori menu'));
      } else {
        // Initialize active category if not set
        _activeCategoryName ??= categories.first.name;

        // Ensure active category actually exists
        if (!productsMap.containsKey(_activeCategoryName)) {
          _activeCategoryName = categories.first.name;
        }

        final activeProducts = productsMap[_activeCategoryName] ?? [];

        content = activeProducts.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0),
                  child: Center(
                    child: Text(
                      'Menu belum tersedia di kategori ini.',
                      style: GoogleFonts.poppins(color: _textGray, fontSize: 13),
                    ),
                  ),
                ),
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.70,
                ),
                itemCount: activeProducts.length,
                itemBuilder: (context, index) {
                  final product = activeProducts[index];
                  return _buildProductCardGrid(context, product);
                },
              );
      }
    } else {
      content = const SizedBox.shrink();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await homeProvider.loadHomeData(outletId: selectedOutlet?.id);
      },
      color: _primaryRed,
      child: content,
    );
  }

  Widget _buildProductCardGrid(BuildContext context, ProductModel product) {
    final authProvider = context.watch<AuthProvider>();

    // Dynamic price formatting
    final String formattedPrice =
        'Rp${product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    final String? formattedStrikePrice =
        product.strikePrice != null && product.strikePrice! > 0
        ? 'Rp${product.strikePrice!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
        : null;

    final bool isPromo = formattedStrikePrice != null;

    return GestureDetector(
      onTap: () {
        if (!authProvider.isAuthenticated) {
          LoginBottomSheet.show(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center Product Image
            Expanded(
              child: Center(
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.fastfood,
                                color: Colors.grey,
                                size: 40,
                              ),
                            ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.fastfood,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),

            // Product Name (max 2 lines)
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _textDark,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6),

            // Prices
            if (isPromo) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_offer,
                          color: Color(0xFFC62828),
                          size: 11,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFC62828),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formattedStrikePrice,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                formattedPrice,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
