import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:warrrung_app/order_confirmation_page.dart';
import 'package:warrrung_app/providers/home_provider.dart';
import 'package:warrrung_app/providers/location_provider.dart';
import 'package:warrrung_app/core/widgets/error_state_widget.dart';

class PesananTabScreen extends StatelessWidget {
  const PesananTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFE31A22);
    const Color textDark = Color(0xFF1A1A1A);
    const Color textGray = Color(0xFF757575);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Text(
            'Pesanan',
            style: GoogleFonts.poppins(
              color: textDark,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          bottom: TabBar(
            indicatorColor: primaryRed,
            labelColor: primaryRed,
            unselectedLabelColor: textGray,
            labelStyle: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Keranjang Saya'),
              Tab(text: 'Riwayat Transaksi'),
            ],
          ),
          shape: Border(
            bottom: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Keranjang Saya (Review Cart/Checkout)
            const OrderConfirmationPage(isEmbedded: true),

            // Tab 2: Riwayat Transaksi (Past Orders)
            _buildOrderHistory(context, textDark, textGray, primaryRed),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory(BuildContext context, Color dark, Color gray, Color primaryRed) {
    final homeProvider = context.watch<HomeProvider>();
    final locationProvider = context.watch<LocationProvider>();

    if (homeProvider.state is HomeStateError || locationProvider.hasError) {
      return RefreshIndicator(
        onRefresh: () async {
          final selectedOutlet = locationProvider.selectedOutlet;
          await homeProvider.loadHomeData(outletId: selectedOutlet?.id);
          await locationProvider.loadOutlets();
        },
        color: primaryRed,
        child: SingleChildScrollView(
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
                    final selectedOutlet = locationProvider.selectedOutlet;
                    homeProvider.loadHomeData(outletId: selectedOutlet?.id);
                    locationProvider.loadOutlets();
                  },
                );
              },
            ),
          ),
        ),
      );
    }

    final List<Map<String, dynamic>> mockOrders = [
      {
        'id': 'WRG-903741',
        'date': '04 Juni 2026, 18:30',
        'items': 'Double Ayam Geprek Level 2 + Nasi Putih',
        'totalPrice': 34000.0,
        'status': 'Selesai',
        'isSuccess': true,
      },
      {
        'id': 'WRG-890212',
        'date': '02 Juni 2026, 13:15',
        'items': 'Es Teh Manis Less Ice + Kopi Susu Kenangan',
        'totalPrice': 27000.0,
        'status': 'Selesai',
        'isSuccess': true,
      },
      {
        'id': 'WRG-870390',
        'date': '28 Mei 2026, 20:05',
        'items': 'Nasi Goreng Ayam Spesial Biasa',
        'totalPrice': 22000.0,
        'status': 'Dibatalkan',
        'isSuccess': false,
      }
    ];

    return RefreshIndicator(
      onRefresh: () async {
        final selectedOutlet = locationProvider.selectedOutlet;
        await homeProvider.loadHomeData(outletId: selectedOutlet?.id);
        await locationProvider.loadOutlets();
      },
      color: primaryRed,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: mockOrders.length,
        itemBuilder: (context, index) {
          final order = mockOrders[index];
        final String formattedPrice =
            'Rp${order['totalPrice'].toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: ID & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      order['id'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: order['isSuccess'] ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order['status'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: order['isSuccess'] ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Date
                Text(
                  order['date'],
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: gray,
                  ),
                ),
                const Divider(height: 20, thickness: 0.8),

                // Item description
                Text(
                  order['items'],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: dark,
                  ),
                ),
                const SizedBox(height: 8),

                // Price & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: gray,
                          ),
                        ),
                        Text(
                          formattedPrice,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: dark,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Detail transaksi ini sedang disiapkan.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: Text(
                        'Detail',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}
