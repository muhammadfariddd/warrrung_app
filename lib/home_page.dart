import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:warrrung_app/data/models/product_model.dart';
import 'package:warrrung_app/providers/home_provider.dart';
import 'package:warrrung_app/providers/auth_provider.dart';
import 'package:warrrung_app/core/widgets/login_bottom_sheet.dart';
import 'package:warrrung_app/providers/location_provider.dart';
import 'package:warrrung_app/location_selection_page.dart';
import 'package:warrrung_app/product_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();
  Timer? _bannerTimer;
  String? _lastSelectedOutletId;

  // Design color tokens
  static const Color _primaryRed = Color(0xFFC62828);
  static const Color _deepRed = Color(0xFF9B1B30);
  static const Color _softPink = Color(0xFFFCE4EC);
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGray = Color(0xFF757575);
  static const Color _greenAccent = Color(0xFF2E7D32);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locationProvider = Provider.of<LocationProvider>(context);
    final selectedOutletId = locationProvider.selectedOutlet?.id;
    if (_lastSelectedOutletId != selectedOutletId) {
      _lastSelectedOutletId = selectedOutletId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<HomeProvider>(
          context,
          listen: false,
        ).loadHomeData(outletId: selectedOutletId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        final nextPage = (_currentBannerIndex + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();
    final homeState = homeProvider.state;
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Scrollable content with sticky header
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    statusBarHeight: MediaQuery.of(context).padding.top,
                    greetingWidget: _buildGreetingWidget(),
                    selectorWidget: _buildLocationSelectorRow(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (homeState is HomeStateLoading) ...[
                        _buildLoadingState(),
                      ] else if (homeState is HomeStateError) ...[
                        _buildErrorState(
                          homeState.message,
                          homeProvider.loadHomeData,
                        ),
                      ] else if (homeState is HomeStateLoaded) ...[
                        _buildPromoBanner(),
                        if (homeState.specialDeals.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildSpecialSection(homeState.specialDeals),
                        ],
                        const SizedBox(height: 20),
                        _buildVoucherSection(),
                        if (homeState.productsByCategory.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _buildMenuSections(homeState.productsByCategory),
                        ],
                      ],
                      const SizedBox(height: 100), // space for sticky button
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky CTA Button (only if not logged in)
          if (!authProvider.isAuthenticated) _buildStickyButton(),
        ],
      ),
    );
  }

  // ─── GREETING WIDGET ──────────────────────────────────────────────
  Widget _buildGreetingWidget() {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Vektor Siang image at the top right
          Positioned(
            right: 0,
            top: -30,
            child: Image.asset(
              'images/vektor_siang.png',
              width: 180,
              fit: BoxFit.contain,
            ),
          ),

          // Greeting text
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Builder(
              builder: (context) {
                final authProvider = context.watch<AuthProvider>();
                final userName = authProvider.isAuthenticated
                    ? (authProvider.currentUser?.data['name'] as String? ??
                          authProvider.currentUser?.data['email']
                              as String? ??
                          'Sahabat')
                    : 'Sahabat waRRRung';

                return RichText(
                  text: TextSpan(
                    text: 'Hai, ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _textGray,
                    ),
                    children: [
                      TextSpan(
                        text: userName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _textDark,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── LOCATION SELECTOR ROW ────────────────────────────────────────
  Widget _buildLocationSelectorRow(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final selectedOutlet = locationProvider.selectedOutlet;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationSelectionPage(),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedOutlet?.name ?? 'Pilih Outlet',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    if (selectedOutlet != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        selectedOutlet.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: _textGray,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _primaryRed,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // // ─── DELIVERY / PICKUP TOGGLE ─────────────────────────────────────
  // Widget _buildDeliveryToggle() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //     child: Container(
  //       height: 44,
  //       decoration: BoxDecoration(
  //         color: _lightGray,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         children: [
  //           // Delivery tab (active)
  //           Expanded(
  //             child: Container(
  //               margin: const EdgeInsets.all(4),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.circular(10),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.06),
  //                     blurRadius: 4,
  //                     offset: const Offset(0, 1),
  //                   ),
  //                 ],
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     width: 8,
  //                     height: 8,
  //                     decoration: const BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: Color(0xFF4CAF50),
  //                     ),
  //                   ),
  //                   const SizedBox(width: 6),
  //                   Text(
  //                     'Delivery',
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w600,
  //                       color: _textDark,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           // Pickup tab (inactive)
  //           Expanded(
  //             child: Container(
  //               margin: const EdgeInsets.all(4),
  //               decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Row(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Container(
  //                     width: 8,
  //                     height: 8,
  //                     decoration: BoxDecoration(
  //                       shape: BoxShape.circle,
  //                       color: Colors.grey.shade400,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 6),
  //                   Text(
  //                     'Pickup',
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 13,
  //                       fontWeight: FontWeight.w500,
  //                       color: _textGray,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ─── PROMO BANNER CAROUSEL ────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Column(
      children: [
        // Banner carousel
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildBannerCard(index);
            },
          ),
        ),
        const SizedBox(height: 10),

        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == index ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? _primaryRed
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBannerCard(int index) {
    final bannerData = [
      {'image': 'images/banner/banner-1.jpg'},
      {'image': 'images/banner/banner-2.jpg'},
      {'image': 'images/banner/banner-3.jpg'},
    ];

    final data = bannerData[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: data['bgColor'] as Color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            data['image'] as String,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  // ─── SAJIAN SPESIAL HARI INI SECTION ─────────────────────────────
  // Style: Kopi Kenangan — clean typography, chevron on right, flat horizontal scroll
  Widget _buildSpecialSection(List<ProductModel> products) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spesial Hari Ini',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _textDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal scroll of special deal cards
        SizedBox(
          height: 180, // Tighter height for completely flat cards
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 8),
            itemCount: products.length,
            itemBuilder: (context, index) => _buildProductCard(products[index]),
          ),
        ),
      ],
    );
  }

  // ─── FLAT PREMIUM SPECIAL PRODUCT CARD (KOPI KENANGAN STYLE) ──────
  Widget _buildProductCard(ProductModel product) {
    final formattedPrice = 'Rp${product.price.toInt()}';

    return GestureDetector(
      onTap: () {
        final locationProvider = context.read<LocationProvider>();
        final authProvider = context.read<AuthProvider>();

        if (locationProvider.selectedOutlet == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan pilih outlet terlebih dahulu.'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationSelectionPage(),
            ),
          );
        } else if (!authProvider.isAuthenticated) {
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
        width: 130, // Narrow compact sizing
        margin: const EdgeInsets.only(right: 12),
        color: Colors.transparent, // Completely flat, no border, no shadow
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image — centered in a clean white box without border or shadow
            Container(
              height: 108,
              width: double.infinity,
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
              child: product.imageUrl.isNotEmpty
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, st) => const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: _primaryRed,
                          size: 30,
                        ),
                      ),
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _primaryRed,
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: _primaryRed,
                        size: 30,
                      ),
                    ),
            ),

            // Product details below the image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _textDark,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Red Price pill (capsule style)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: _softPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(1.2),
                          decoration: const BoxDecoration(
                            color: _primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.percent_rounded,
                            size: 8,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 3.5),
                        Text(
                          formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _primaryRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── KATEGORI SECTION ─────────────────────────────────────────────
  // Widget _buildCategorySection(List<CategoryModel> categories) {
  //   if (categories.isEmpty) return const SizedBox.shrink();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.symmetric(horizontal: 20),
  //         child: Text(
  //           'Kategori Menu',
  //           style: GoogleFonts.poppins(
  //             fontSize: 16,
  //             fontWeight: FontWeight.w700,
  //             color: _textDark,
  //           ),
  //         ),
  //       ),
  //       const SizedBox(height: 12),
  //       SizedBox(
  //         height: 105,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           padding: const EdgeInsets.symmetric(horizontal: 16),
  //           itemCount: categories.length,
  //           itemBuilder: (context, index) {
  //             final category = categories[index];
  //             return Container(
  //               width: 80,
  //               margin: const EdgeInsets.symmetric(horizontal: 6),
  //               child: Column(
  //                 children: [
  //                   // Dynamic rounded container for icon
  //                   Container(
  //                     width: 60,
  //                     height: 60,
  //                     decoration: BoxDecoration(
  //                       color: _softPink,
  //                       shape: BoxShape.circle,
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withOpacity(0.04),
  //                           blurRadius: 6,
  //                           offset: const Offset(0, 2),
  //                         ),
  //                       ],
  //                     ),
  //                     child: ClipOval(
  //                       child: category.iconUrl.isNotEmpty
  //                           ? Image.network(
  //                               category.iconUrl,
  //                               fit: BoxFit.cover,
  //                               errorBuilder: (context, error, stackTrace) =>
  //                                   Icon(Icons.category_rounded, color: _primaryRed, size: 28),
  //                               loadingBuilder: (context, child, loadingProgress) {
  //                                 if (loadingProgress == null) return child;
  //                                 return const Center(
  //                                   child: SizedBox(
  //                                     width: 20,
  //                                     height: 20,
  //                                     child: CircularProgressIndicator(
  //                                       strokeWidth: 2,
  //                                       valueColor: AlwaysStoppedAnimation<Color>(_primaryRed),
  //                                     ),
  //                                   ),
  //                                 );
  //                               },
  //                             )
  //                           : Icon(Icons.category_rounded, color: _primaryRed, size: 28),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 8),
  //                   // Category Name
  //                   Text(
  //                     category.name,
  //                     textAlign: TextAlign.center,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     style: GoogleFonts.poppins(
  //                       fontSize: 11,
  //                       fontWeight: FontWeight.w500,
  //                       color: _textDark,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ─── LOADING STATE UI ─────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryRed),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Memuat hidangan spesial...',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _textGray,
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }

  // ─── ERROR STATE UI ───────────────────────────────────────────────
  Widget _buildErrorState(String message, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade100, width: 1.5),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: _primaryRed,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Aduh, Terjadi Kesalahan!',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _primaryRed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'Coba Lagi',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── VOUCHER / DISKON & CASHBACK SECTION ──────────────────────────
  Widget _buildVoucherSection() {
    final vouchers = [
      {
        'tag': 'Ongkir',
        'title': 'Ongkir Flat Rp10.000',
        'subtitle': 'waRRRung Express',
      },
      {
        'tag': 'Cashback',
        'title': 'Cashback 20% s/d 25rb',
        'subtitle': 'waRRRung Pay',
      },
      {
        'tag': 'Diskon',
        'title': 'Diskon 30% Menu Baru',
        'subtitle': 'Min. belanja Rp50.000',
      },
    ];

    return Column(
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.percent_rounded,
                  size: 14,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Diskon & Cashback',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal list of voucher cards
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: vouchers.length,
            itemBuilder: (context, index) {
              final voucher = vouchers[index];
              return _buildVoucherCard(voucher);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherCard(Map<String, String> voucher) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              voucher['tag']!,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            voucher['title']!,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 2),

          // Subtitle + Klaim button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                voucher['subtitle']!,
                style: GoogleFonts.poppins(fontSize: 11, color: _textGray),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _deepRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Klaim',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MENU SECTIONS (2-COLUMN GRID PER CATEGORY — KOPI KENANGAN STYLE) ───
  Widget _buildMenuSections(
    Map<String, List<ProductModel>> productsByCategory,
  ) {
    return Column(
      children: productsByCategory.entries.map((entry) {
        return _buildMenuGridSection(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildMenuGridSection(
    String categoryName,
    List<ProductModel> products,
  ) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (category name + arrow chevron)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                categoryName,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: _textDark),
            ],
          ),
        ),

        // 2-column flat grid of products
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 24, // Clean wide spacing between columns
              mainAxisSpacing: 24, // Clean spacing between rows
              childAspectRatio:
                  0.82, // Perfect ratio for flat centered image + name + price
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return _buildGridProductCard(products[index]);
            },
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  // ─── FLAT MENU GRID CARD (NO BORDERS, NO SHADOWS — KOPI KENANGAN STYLE) ──
  Widget _buildGridProductCard(ProductModel product) {
    final formattedPrice = 'Rp${product.price.toInt()}';

    return GestureDetector(
      onTap: () {
        final locationProvider = context.read<LocationProvider>();
        final authProvider = context.read<AuthProvider>();

        if (locationProvider.selectedOutlet == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Silakan pilih outlet terlebih dahulu.'),
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LocationSelectionPage(),
            ),
          );
        } else if (!authProvider.isAuthenticated) {
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
        color: Colors.transparent, // Completely flat
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered Isolated Image
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.transparent,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, st) => const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: _primaryRed,
                            size: 36,
                          ),
                        ),
                        loadingBuilder: (ctx, child, prog) {
                          if (prog == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _primaryRed,
                              ),
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          color: _primaryRed,
                          size: 36,
                        ),
                      ),
              ),
            ),
            // const SizedBox(height: 8),

            // Product name
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: _textDark,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),

            // Simple Price Text (No Pill, exactly like Kopi Kenangan Makanan list)
            Text(
              formattedPrice,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textDark.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STICKY CTA BUTTON ────────────────────────────────────────────

  // ─── STICKY CTA BUTTON ────────────────────────────────────────────

  Widget _buildStickyButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () => _showLoginBottomSheet(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryRed,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Daftar atau Masuk',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  void _showLoginBottomSheet(BuildContext context) {
    LoginBottomSheet.show(context);
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double statusBarHeight;
  final Widget greetingWidget;
  final Widget selectorWidget;

  _StickyHeaderDelegate({
    required this.statusBarHeight,
    required this.greetingWidget,
    required this.selectorWidget,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double maxShrink = maxExtent - minExtent;
    final double scrollPercentage = (shrinkOffset / maxShrink).clamp(0.0, 1.0);

    return SizedBox(
      width: double.infinity,
      height: maxExtent,
      child: Stack(
        children: [
          // 1. Gradient background (fades out as we scroll)
          Positioned.fill(
            child: Opacity(
              opacity: (1.0 - scrollPercentage).clamp(0.0, 1.0),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE3F2FD), Colors.white],
                  ),
                ),
              ),
            ),
          ),

          // 2. White background (fades in as we scroll)
          Positioned.fill(
            child: Opacity(
              opacity: scrollPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: scrollPercentage > 0.8
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Opacity(
                  opacity: (1.0 - scrollPercentage).clamp(0.0, 1.0),
                  child: SizedBox(
                    height: 52.0 * (1.0 - scrollPercentage),
                    child: greetingWidget,
                  ),
                ),
                SizedBox(height: 76.0, child: selectorWidget),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 128.0 + statusBarHeight;

  @override
  double get minExtent => 76.0 + statusBarHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.statusBarHeight != statusBarHeight ||
        oldDelegate.greetingWidget != greetingWidget ||
        oldDelegate.selectorWidget != selectorWidget;
  }
}
