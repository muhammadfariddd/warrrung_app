import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:warrrung_app/providers/location_provider.dart';

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allMockAddresses = [
    'Jl. MH Thamrin No.13, Panggang IV, Jepara',
    'Jl. Pemuda No.53, Potroyudan, Jepara',
    'Jl. Kartini No.25, Kauman, Jepara',
    'Jl. Shima No.10, Pengkol, Jepara',
    'Jl. Kolonel Sugiono No.45, Jobokuto, Jepara',
    'Jl. Raya Undip RT01 / RW01, Telukawur, Tahunan, Jepara',
    'Jl. Ahmad Yani No.5, Pengkol, Jepara',
  ];

  List<String> _filteredAddresses = [];
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _filteredAddresses = List.from(_allMockAddresses);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAddresses = List.from(_allMockAddresses);
      } else {
        _filteredAddresses = _allMockAddresses
            .where((address) => address.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  Future<void> _useCurrentLocation(LocationProvider provider) async {
    setState(() {
      _isLocating = true;
    });

    // Simulasi memuat koordinat GPS dan melakukan geocoding
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLocating = false;
      });
      // Set alamat default lokasi saat ini
      const currentAddress = 'Jl. Raya Undip RT01 / RW01, Telukawur, Jepara, Jawa Tengah';
      provider.selectDeliveryAddress(currentAddress);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menggunakan lokasi saat ini.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    const textDark = Color(0xFF1A1A1A);
    const textGray = Color(0xFF757575);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Pilih Alamat',
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
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(fontSize: 13, color: textDark),
                decoration: InputDecoration(
                  hintText: 'Cari alamat',
                  hintStyle: GoogleFonts.poppins(fontSize: 13, color: textGray),
                  prefixIcon: const Icon(Icons.search, color: textGray, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: textGray, size: 18),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // 2. Use Current Location Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: _isLocating ? null : () => _useCurrentLocation(locationProvider),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC5A880), width: 1.5), // Warna gold border
                ),
                child: Row(
                  children: [
                    _isLocating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                            ),
                          )
                        : const Icon(
                            Icons.location_on_rounded,
                            color: Colors.green,
                            size: 22,
                          ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gunakan lokasi saat ini',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: textDark,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.map_outlined,
                      color: textGray,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1),

          // 3. Suggestions List
          Expanded(
            child: _filteredAddresses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, color: Colors.grey.shade300, size: 64),
                          const SizedBox(height: 16),
                          Text(
                            'Alamat tidak ditemukan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba gunakan kata kunci pencarian yang lain.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredAddresses.length,
                    itemBuilder: (context, index) {
                      final address = _filteredAddresses[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: textGray,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              address.split(',').first, // Nama jalan utama
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: textDark,
                              ),
                            ),
                            subtitle: Text(
                              address, // Alamat lengkap
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: textGray,
                              ),
                            ),
                            onTap: () {
                              locationProvider.selectDeliveryAddress(address);
                              Navigator.of(context).pop();
                            },
                          ),
                          Divider(height: 1, indent: 72, color: Colors.grey.shade100),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
