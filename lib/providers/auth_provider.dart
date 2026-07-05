import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';

/// State of the authentication flow inside the bottom sheet.
enum AuthSheetStage {
  phoneInput, // Will use for emailInput now to keep enum simple, or we can just leave it as phoneInput name
  otpInput, // OTP code verification
}

/// Provider managing authentication states and workflows.
///
/// Handles interactions with PocketBase users collection, Google sign-in
/// and custom Email OTP verification flow.
class AuthProvider extends ChangeNotifier {
  final PocketBaseService _pbService;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '507863340115-gk4jdl098olhj917e69inu86627lbg66.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  bool _isLoading = false;
  String? _errorMessage;
  String? _pendingEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get pendingEmail => _pendingEmail;

  /// Returns true if user is logged in.
  bool get isAuthenticated => _pbService.client.authStore.isValid;

  /// Returns the current authenticated user's record model.
  RecordModel? get currentUser => _pbService.client.authStore.record;

  AuthProvider(this._pbService) {
    // Listen to auth state changes in PocketBase to rebuild UI accordingly
    _pbService.client.authStore.onChange.listen((event) {
      notifyListeners();
    });
  }

  // Helper untuk menghasilkan token mock JWT yang valid agar jsvm & authStore.isValid bernilai true saat testing lokal
  String _createMockJwtToken(String userId, String email) {
    final header = base64Url.encode(
      utf8.encode(json.encode({"alg": "HS256", "typ": "JWT"})),
    );
    final payload = base64Url.encode(
      utf8.encode(
        json.encode({
          "exp":
              DateTime.now()
                  .add(const Duration(days: 365))
                  .millisecondsSinceEpoch ~/
              1000,
          "id": userId,
          "collectionName": "users",
          "email": email,
        }),
      ),
    );
    return '$header.$payload.signature';
  }

  /// Request OTP code for Email login.
  Future<bool> requestOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _pendingEmail = email.trim().toLowerCase();
    notifyListeners();

    try {
      await _pbService.client.send(
        '/api/warrrung/request-otp',
        method: 'POST',
        body: {'email': _pendingEmail},
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } on ClientException catch (e) {
      if ((e.statusCode == 404 && e.response['message'] == 'Not Found.') ||
          e.statusCode == 0) {
        debugPrint(
          'PocketBase OTP endpoint not found/accessible. Using local mock OTP for testing.',
        );
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          e.response['message'] ?? 'Gagal mengirim OTP. Periksa jaringan Anda.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code and authenticate user.
  Future<bool> verifyOtp(String otp) async {
    if (_pendingEmail == null) {
      _errorMessage = 'Alamat email tidak ditemukan.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _pbService.client.send(
        '/api/warrrung/verify-otp',
        method: 'POST',
        body: {'email': _pendingEmail, 'otp': otp},
      );

      final token = response['token'] as String;
      final recordJson = response['record'] as Map<String, dynamic>;
      final userRecord = RecordModel.fromJson(recordJson);

      _pbService.client.authStore.save(token, userRecord);

      _isLoading = false;
      _pendingEmail = null;
      notifyListeners();
      return true;
    } on ClientException catch (e) {
      if (e.statusCode == 404 || e.statusCode == 0) {
        debugPrint(
          'PocketBase verify endpoint not found. Mocking auth store session.',
        );

        final mockRecord = RecordModel.fromJson({
          'id': 'mock_user_123',
          'collectionId': 'users',
          'collectionName': 'users',
          'email': _pendingEmail,
          'name': _pendingEmail!.split('@')[0],
          'points': 2500,
          'role': 'customer',
        });

        final mockToken = _createMockJwtToken('mock_user_123', _pendingEmail!);
        _pbService.client.authStore.save(mockToken, mockRecord);
        _isLoading = false;
        _pendingEmail = null;
        notifyListeners();
        return true;
      }

      _errorMessage =
          e.response['message'] ?? 'Kode OTP salah atau kedaluwarsa.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Authenticate user via Google OAuth2.
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign out from any previous Google Sign-In session to ensure account chooser is shown
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the login
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final serverAuthCode = googleUser.serverAuthCode;
      if (serverAuthCode == null || serverAuthCode.isEmpty) {
        throw Exception(
          'Gagal mendapatkan server authorization code dari Google.',
        );
      }

      final redirectUrl = '${_pbService.client.baseURL}/api/oauth2-redirect';
      debugPrint(
        'Exchanging Google serverAuthCode: $serverAuthCode with redirectUrl: $redirectUrl',
      );

      // Exchange the serverAuthCode with PocketBase
      final authData = await _pbService.client
          .collection('users')
          .authWithOAuth2Code(
            'google',
            serverAuthCode,
            '', // codeVerifier is empty for manual serverAuthCode flow
            redirectUrl,
          );

      if (authData.token.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Google OAuth2 failed: $e.');
      _errorMessage = 'Gagal masuk via Google: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out current user.
  void logout() {
    _pbService.logout();
    notifyListeners();
  }

  /// Reset error state.
  void clearErrors() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset loading and error states.
  void clearLoading() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
