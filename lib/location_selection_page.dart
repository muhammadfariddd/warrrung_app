import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/data/models/outlet_model.dart';
import 'package:warrrung_app/providers/location_provider.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({super.key});

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _favoriteOutlets = {};
  bool _showPermissionBanner = true;

  // Active filters
  String _selectedOrderFilter = 'Semua Order';
  String _selectedBrandFilter = 'Semua Brand';

  @override
  void initState() {
    super.initState();
    // Re-fetch outlets from server when opening the location page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadOutlets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            _buildTabButton(
              title: 'Pickup',
              isActive: locationProvider.activeTab == 'pickup',
              onTap: () => locationProvider.setActiveTab('pickup'),
            ),
            const SizedBox(width: 24),
            _buildTabButton(
              title: 'Delivery',
              isActive: locationProvider.activeTab == 'delivery',
              onTap: () => locationProvider.setActiveTab('delivery'),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider below AppBar
          Divider(color: Colors.grey.shade200, height: 1, thickness: 1),

          // ─── SEARCH BAR ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => locationProvider.setSearchQuery(val),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Cari lokasi',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        locationProvider.setSearchQuery('');
                      },
                      child: const Icon(
                        Icons.clear,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── HORIZONTAL FILTER PILLS ──────────────────────────────────────
          _buildFilterScrolls(),

          // ─── LOCATION PERMISSION BANNER ──────────────────────────────────
          if (_showPermissionBanner) _buildPermissionBanner(),

          // ─── OUTLETS LIST ────────────────────────────────────────────────
          Expanded(
            child: locationProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFC62828),
                      ),
                    ),
                  )
                : locationProvider.outlets.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: locationProvider.outlets.length,
                    itemBuilder: (context, index) {
                      final outlet = locationProvider.outlets[index];
                      if (!_applyCustomFilters(outlet)) {
                        return const SizedBox.shrink();
                      }

                      return _buildOutletCard(
                        context,
                        outlet,
                        locationProvider,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Checkbox/filter verification logic
  bool _applyCustomFilters(OutletModel outlet) {
    if (_selectedOrderFilter == 'Pickup' && !outlet.hasPickup) return false;
    if (_selectedOrderFilter == 'Delivery' && !outlet.hasDelivery) return false;

    final nameLower = outlet.name.toLowerCase();
    if (_selectedBrandFilter == 'waRRRung Kopi') {
      return nameLower.contains('kopi') ||
          nameLower.contains('mall') ||
          nameLower.contains('marina') ||
          nameLower.contains('bungalows');
    }
    if (_selectedBrandFilter == 'waRRRung Makan') {
      return nameLower.contains('standard') ||
          nameLower.contains('utama') ||
          nameLower.contains('gudeg') ||
          nameLower.contains('ihsan');
    }
    return true;
  }

  Widget _buildTabButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF00897B)
                  : Colors.grey.shade500, // Teal matching Kopi Kenangan
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 2.5,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF00897B) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterScrolls() {
    return Column(
      children: [
        // Row 1: Order Type Pills
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterPill(
                title: 'Semua Order',
                group: 'order',
                isActive: _selectedOrderFilter == 'Semua Order',
              ),
              _buildFilterPill(
                title: 'Pickup',
                group: 'order',
                isActive: _selectedOrderFilter == 'Pickup',
              ),
              _buildFilterPill(
                title: 'Drive Thru',
                group: 'order',
                isActive: _selectedOrderFilter == 'Drive Thru',
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Row 2: Brand/Shop Pills
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildFilterPill(
                title: 'Semua Brand',
                group: 'brand',
                isActive: _selectedBrandFilter == 'Semua Brand',
              ),
              _buildFilterPill(
                title: 'waRRRung Kopi',
                group: 'brand',
                isActive: _selectedBrandFilter == 'waRRRung Kopi',
              ),
              _buildFilterPill(
                title: 'waRRRung Makan',
                group: 'brand',
                isActive: _selectedBrandFilter == 'waRRRung Makan',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildFilterPill({
    required String title,
    required String group,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (group == 'order') {
            _selectedOrderFilter = title;
          } else {
            _selectedBrandFilter = title;
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFF5F5F5),
          border: Border.all(
            color: isActive
                ? const Color(0xFFC62828)
                : Colors.transparent, // Kopi Kenangan red border
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? const Color(0xFFC62828) : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1F5FE), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF1976D2),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akses Lokasi Dibutuhkan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Izinkan akses untuk mendapat lokasi yang lebih akurat',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPermissionBanner = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Akses lokasi diberikan (Simulasi)'),
                      ),
                    );
                  },
                  child: Text(
                    'Izinkan',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showPermissionBanner = false;
              });
            },
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOutletCard(
    BuildContext context,
    OutletModel outlet,
    LocationProvider locationProvider,
  ) {
    final bool isFavorite = _favoriteOutlets.contains(outlet.id);

    return GestureDetector(
      onTap: () {
        locationProvider.selectOutlet(outlet);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lokasi aktif diubah ke: ${outlet.name}'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Heart/Like Icon
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isFavorite) {
                    _favoriteOutlets.remove(outlet.id);
                  } else {
                    _favoriteOutlets.add(outlet.id);
                  }
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: isFavorite
                      ? const Color(0xFFC62828)
                      : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Column: Info Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Red Operational Hours Badge (only show if closed)
                  if (!outlet.isOpen) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        outlet.closedStatusText,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFC62828),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Store Name
                  Text(
                    outlet.name,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C2C2C),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Store Address
                  Text(
                    outlet.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badges: Delivery, Pickup, Dine-in
                  Row(
                    children: [
                      if (outlet.hasDelivery)
                        _buildServiceBadge('Delivery', Colors.green),
                      if (outlet.hasPickup)
                        _buildServiceBadge('Pickup', Colors.teal),
                      if (outlet.hasDineIn)
                        _buildServiceBadge('Dine-In', Colors.purple),
                    ],
                  ),
                ],
              ),
            ),

            // Right Column: Detail link
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Detail',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00897B),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF00897B),
                      size: 16,
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

  Widget _buildServiceBadge(String title, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.location_cross_copy,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Lokasi tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba cari dengan kata kunci lain atau ubah filter pencarian Anda.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
