import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String redirectUrl;
  final String orderId;

  const PaymentWebViewPage({
    super.key,
    required this.redirectUrl,
    required this.orderId,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  bool _isLoading = true;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await _showExitConfirmationDialog() ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFC62828),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () async {
              final shouldExit = await _showExitConfirmationDialog();
              if (shouldExit == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'Pembayaran waRRRung',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.redirectUrl),
              ),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                mediaPlaybackRequiresUserGesture: false,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                supportMultipleWindows: false,
              ),
              onWebViewCreated: (controller) {
                // Controller created but unused currently
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                });
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                  if (progress >= 100) {
                    _isLoading = false;
                  }
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final url = navigationAction.request.url;
                if (url == null) return NavigationActionPolicy.ALLOW;

                final scheme = url.scheme.toLowerCase();
                debugPrint('[PAYMENT WEBVIEW] Menilai URL: $url dengan skema: $scheme');

                // Jika skema URL bukan http/https (seperti gopay://, intent://, shopeepay://, ovo://, dll.)
                if (scheme != 'http' && scheme != 'https') {
                  debugPrint('[PAYMENT WEBVIEW] Mendeteksi skema non-web ($scheme). Mencegat dan meluncurkan aplikasi eksternal...');
                  try {
                    final bool launched = await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                    if (launched) {
                      debugPrint('[PAYMENT WEBVIEW] Sukses meluncurkan aplikasi eksternal untuk: $url');
                    } else {
                      debugPrint('[PAYMENT WEBVIEW] Gagal meluncurkan aplikasi eksternal untuk: $url');
                    }
                  } catch (e) {
                    debugPrint('[PAYMENT WEBVIEW] Gagal meluncurkan deep link: $e');
                  }
                  // Batalkan pemuatan URL di dalam WebView agar tidak terjadi ERR_UNKNOWN_URL_SCHEME
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
            ),
            if (_isLoading)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Menghubungkan ke Midtrans...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading && _progress < 1.0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC62828)),
                  minHeight: 3,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Batalkan Pembayaran?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari halaman pembayaran? Pesanan Anda belum dibayar.',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Lanjutkan Bayar',
              style: GoogleFonts.poppins(color: const Color(0xFFC62828), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Ya, Keluar',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
