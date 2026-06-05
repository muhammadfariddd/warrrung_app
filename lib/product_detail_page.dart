import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:warrrung_app/data/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  // Common states
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showHeaderTitle = false;

  // Food states
  int _spicinessLevel = 1; // 0: Level 0, 1: Level 1, 2: Level 2, 3: Level 3
  String _carbOption = 'Nasi Putih'; // 'Tanpa Nasi', 'Nasi Putih', 'Nasi Merah'
  String _portionSize = 'Biasa'; // 'Biasa', 'Jumbo'
  final Map<String, bool> _extraSides = {
    'Telur Ceplok': false,
    'Telur Dadar': false,
    'Tahu & Tempe': false,
    'Ekstra Sambal': false,
    'Ekstra Ayam': false,
  };

  // Beverage states
  String _temperature = 'Ice'; // 'Ice', 'Hot'
  String _beverageSize = 'Regular'; // 'Regular', 'Large'
  String _sugarLevel =
      'Normal Sugar'; // 'Normal Sugar', 'Less Sugar', 'No Sugar'
  String _iceLevel = 'Normal Ice'; // 'Normal Ice', 'Less Ice', 'No Ice'
  final Map<String, bool> _beverageToppings = {
    'Cincau / Grass Jelly': false,
    'Selasih': false,
    'Susu Kental Manis': false,
  };

  // Pricing constants for extras
  static const Map<String, double> _carbPrices = {
    'Tanpa Nasi': 0.0,
    'Nasi Putih': 4000.0,
    'Nasi Merah': 6000.0,
  };

  static const Map<String, double> _extraPrices = {
    'Telur Ceplok': 4000.0,
    'Telur Dadar': 4000.0,
    'Tahu & Tempe': 3000.0,
    'Ekstra Sambal': 2000.0,
    'Ekstra Ayam': 12000.0,
    'Cincau / Grass Jelly': 3000.0,
    'Selasih': 2000.0,
    'Susu Kental Manis': 3000.0,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final double offset =
        _scrollController.hasClients ? _scrollController.offset : 0.0;

    // Background & Title appear together when the name in the body has scrolled past the header
    final double titleThreshold =
        widget.product.strikePrice != null ? 300.0 : 272.0;
    final bool showTitle = offset > titleThreshold;

    if (showTitle != _showHeaderTitle) {
      setState(() {
        _showHeaderTitle = showTitle;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isBeverage {
    final String lowercaseName = widget.product.name.toLowerCase();
    return lowercaseName.contains('es ') ||
        lowercaseName.contains('teh') ||
        lowercaseName.contains('kopi') ||
        lowercaseName.contains('jus') ||
        lowercaseName.contains('jeruk') ||
        lowercaseName.contains('minuman') ||
        lowercaseName.contains('drink') ||
        lowercaseName.contains('water') ||
        lowercaseName.contains('coffee');
  }

  double get _calculateSingleItemPrice {
    double total = widget.product.price;

    if (_isBeverage) {
      if (_beverageSize == 'Large') {
        total += 4000.0;
      }
      _beverageToppings.forEach((key, isSelected) {
        if (isSelected) {
          total += _extraPrices[key] ?? 0.0;
        }
      });
    } else {
      total += _carbPrices[_carbOption] ?? 0.0;
      if (_portionSize == 'Jumbo') {
        total += 6000.0;
      }
      _extraSides.forEach((key, isSelected) {
        if (isSelected) {
          total += _extraPrices[key] ?? 0.0;
        }
      });
    }

    return total;
  }

  double get _calculateTotalPrice {
    return _calculateSingleItemPrice * _quantity;
  }

  double get _calculateTotalDiscount {
    if (widget.product.strikePrice == null) return 0.0;
    final double discountPerItem =
        widget.product.strikePrice! - widget.product.price;
    return discountPerItem > 0 ? discountPerItem * _quantity : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color primaryRed = Color(0xFFC62828);
    const Color selectedGold = Color(0xFFC5A880);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGray = Color(0xFF757575);

    final String formattedTotal =
        'Rp${_calculateTotalPrice.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    final double discount = _calculateTotalDiscount;
    final String? formattedDiscount = discount > 0
        ? 'Hemat Rp${discount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}'
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: _showHeaderTitle ? Colors.white : Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: _showHeaderTitle
            ? Text(
                widget.product.name,
                style: GoogleFonts.poppins(
                  color: textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              )
            : null,
        shape: Border(
          bottom: BorderSide(
            color: _showHeaderTitle ? Colors.grey.shade200 : Colors.transparent,
            width: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // 1. Product Image Header
                  Center(
                    child: Hero(
                      tag: 'product-${widget.product.id}',
                      child: Container(
                        height: 220,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: widget.product.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.product.imageUrl,
                                fit: BoxFit.contain,
                              )
                            : const Icon(
                                Icons.fastfood,
                                size: 100,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),

                  // 2. Product Name & Price Info
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.product.strikePrice != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Promo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp${widget.product.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryRed,
                                  ),
                                ),
                                if (widget.product.strikePrice != null)
                                  Text(
                                    'Rp${widget.product.strikePrice!.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description.isNotEmpty
                              ? widget.product.description
                              : 'Menu lezat pilihan khas dari waRRRung, disiapkan dengan bahan-bahan segar berkualitas tinggi.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: textGray,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // 3. Customizations
                  if (_isBeverage) ...[
                    _buildBeverageCustomizations(
                      selectedGold,
                      textDark,
                      textGray,
                    ),
                  ] else ...[
                    _buildFoodCustomizations(selectedGold, textDark, textGray),
                  ],

                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

                  // 4. Notes Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Catatan Tambahan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            Text(
                              'Opsional',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: textGray,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _notesController,
                          maxLength: 100,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: textDark,
                          ),
                          decoration: InputDecoration(
                            hintText: _isBeverage
                                ? 'Es sedikit saja / Manis kurangi'
                                : 'Tulis catatan (misal: sambal dipisah, dll)...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade400,
                            ),
                            counterText: '',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: selectedGold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 5. Sticky Bottom Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (formattedDiscount != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: const Color(0xFFE8F5E9),
                    alignment: Alignment.center,
                    child: Text(
                      formattedDiscount,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                Row(
                  children: [
                    // Quantity selectors
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Text(
                            '$_quantity',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => setState(() => _quantity++),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Add to Cart Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final List<String> details = [];
                            if (_isBeverage) {
                              details.add(_temperature);
                              details.add(_beverageSize);
                              details.add(_sugarLevel);
                              details.add(_iceLevel);
                              _beverageToppings.forEach((key, value) {
                                if (value) details.add(key);
                              });
                            } else {
                              details.add('Level $_spicinessLevel');
                              details.add(_carbOption);
                              details.add('Porsi $_portionSize');
                              _extraSides.forEach((key, value) {
                                if (value) details.add(key);
                              });
                            }
                            if (_notesController.text.isNotEmpty) {
                              details.add('Catatan: ${_notesController.text}');
                            }

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '"${widget.product.name}" ($formattedTotal) dimasukkan ke keranjang.\nDetail: ${details.join(', ')}',
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '+ Keranjang $formattedTotal',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────── FOOD CUSTOMIZATIONS ──────────────
  Widget _buildFoodCustomizations(Color gold, Color dark, Color gray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. Spiciness Level
        _buildSectionHeader('Tingkat Kepedasan', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(4, (index) {
              final bool isSelected = _spicinessLevel == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _spicinessLevel = index),
                  child: Container(
                    margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                    height: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFDF9)
                          : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lvl $index',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: dark,
                          ),
                        ),
                        if (index == 3)
                          Text(
                            'Sangat Pedas',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 18),

        // B. Carbohydrate Option
        _buildSectionHeader('Pilihan Karbohidrat', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: ['Tanpa Nasi', 'Nasi Putih', 'Nasi Merah'].map((option) {
              final bool isSelected = _carbOption == option;
              final double extraCost = _carbPrices[option] ?? 0.0;
              final String costLabel = extraCost > 0
                  ? '\n+Rp${extraCost.toInt()}'
                  : '\nFree';

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _carbOption = option),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFDF9)
                          : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: option,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: dark,
                            ),
                          ),
                          TextSpan(
                            text: costLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: isSelected ? gold : gray,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // C. Portion Size
        _buildSectionHeader('Porsi', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: ['Biasa', 'Jumbo'].map((option) {
              final bool isSelected = _portionSize == option;
              final String costLabel = option == 'Jumbo'
                  ? '\n+Rp6.000'
                  : '\nFree';

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _portionSize = option),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFDF9)
                          : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Porsi $option',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: dark,
                            ),
                          ),
                          TextSpan(
                            text: costLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: isSelected ? gold : gray,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // D. Extra Sides
        _buildSectionHeader(
          'Lauk Tambahan',
          'Opsional - Bisa pilih lebih dari 1',
          dark,
          gray,
        ),
        ..._extraSides.keys.map((side) {
          final bool isSelected = _extraSides[side] ?? false;
          final double price = _extraPrices[side] ?? 0.0;
          final String formattedPrice =
              '+Rp${price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

          return CheckboxListTile(
            value: isSelected,
            activeColor: gold,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(
              side,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: dark,
              ),
            ),
            subtitle: Text(
              formattedPrice,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: price > 5000 ? Colors.amber.shade900 : gray,
              ),
            ),
            onChanged: (val) {
              setState(() {
                _extraSides[side] = val ?? false;
              });
            },
          );
        }),
      ],
    );
  }

  // ────────────── BEVERAGE CUSTOMIZATIONS ──────────────
  Widget _buildBeverageCustomizations(Color gold, Color dark, Color gray) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A. Temperature
        _buildSectionHeader('Temperature', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildTemperatureCard(
                'Ice',
                Iconsax.empty_wallet_add_copy,
                gold,
                dark,
              ),
              const SizedBox(width: 12),
              _buildTemperatureCard(
                'Hot',
                Iconsax.empty_wallet_copy,
                gold,
                dark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // B. Size
        _buildSectionHeader('Ukuran Gelas', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: ['Regular', 'Large'].map((option) {
              final bool isSelected = _beverageSize == option;
              final String costLabel = option == 'Large'
                  ? '\n+Rp4.000'
                  : '\nFree';

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _beverageSize = option),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 54,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFDF9)
                          : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: option,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: dark,
                            ),
                          ),
                          TextSpan(
                            text: costLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: isSelected ? gold : gray,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // C. Sugar Level
        _buildSectionHeader('Tingkat Kemanisan', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: ['Normal Sugar', 'Less Sugar', 'No Sugar'].map((option) {
              final bool isSelected = _sugarLevel == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _sugarLevel = option),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFDF9)
                          : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: dark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // D. Ice Level
        _buildSectionHeader('Tingkat Es', 'Pilih 1', dark, gray),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: ['Normal Ice', 'Less Ice', 'No Ice'].map((option) {
              final bool isSelected = _iceLevel == option;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _iceLevel = option),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFFDF9)
                          : const Color(0xFFF9F9F9),
                      border: Border.all(
                        color: isSelected ? gold : Colors.grey.shade200,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      option,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: dark,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // E. Toppings
        _buildSectionHeader(
          'Topping Tambahan',
          'Opsional - Bisa pilih lebih dari 1',
          dark,
          gray,
        ),
        ..._beverageToppings.keys.map((topping) {
          final bool isSelected = _beverageToppings[topping] ?? false;
          final double price = _extraPrices[topping] ?? 0.0;
          final String formattedPrice = '+Rp${price.toInt().toString()}';

          return CheckboxListTile(
            value: isSelected,
            activeColor: gold,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(
              topping,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: dark,
              ),
            ),
            subtitle: Text(
              formattedPrice,
              style: GoogleFonts.poppins(fontSize: 11, color: gray),
            ),
            onChanged: (val) {
              setState(() {
                _beverageToppings[topping] = val ?? false;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildTemperatureCard(
    String temp,
    IconData icon,
    Color gold,
    Color dark,
  ) {
    final bool isSelected = _temperature == temp;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _temperature = temp),
        child: Container(
          height: 84,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFFDF9)
                : const Color(0xFFF9F9F9),
            border: Border.all(
              color: isSelected ? gold : Colors.grey.shade200,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                temp == 'Ice' ? Icons.ac_unit : Icons.coffee,
                color: isSelected ? gold : Colors.grey,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                temp,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    Color dark,
    Color gray,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
          const SizedBox(width: 8),
          Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: gray)),
        ],
      ),
    );
  }
}
