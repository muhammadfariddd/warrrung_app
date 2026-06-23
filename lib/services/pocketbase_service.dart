import 'package:pocketbase/pocketbase.dart';

/// Service Singleton for managing the connection pool to PocketBase.
///
/// Automatically switches the base URL between the local development environment
/// (adjusted automatically for Web, Android emulator, and iOS simulator) and a
/// production environment defined using `--dart-define=POCKETBASE_URL=<URL>`.
class PocketBaseService {
  // Private constructor
  PocketBaseService._internal() {
    client = PocketBase(baseUrl);
  }

  // Static private instance
  static final PocketBaseService _instance = PocketBaseService._internal();

  // Factory constructor returning the singleton instance
  factory PocketBaseService() => _instance;

  // Environment-defined production URL
  static const String _prodUrl = String.fromEnvironment(
    'POCKETBASE_URL',
    defaultValue: '',
  );

  // Resolve local development URL dynamically based on current platform
  static String get _localUrl {
    // Menggunakan ngrok static domain untuk koneksi nirkabel permanen
    return 'https://leotard-lid-easily.ngrok-free.dev';
  }

  /// Automatically resolved base URL based on build configuration.
  static final String baseUrl = _prodUrl.isNotEmpty ? _prodUrl : _localUrl;

  /// PocketBase SDK client instance
  late final PocketBase client;

  /// Quick check if the client has a valid, non-expired authentication token.
  bool get isAuthenticated => client.authStore.isValid;

  /// Retrieve the current authenticated user's record model.
  RecordModel? get currentUser => client.authStore.record;

  /// Clears the auth store, effectively logging the user out.
  void logout() {
    client.authStore.clear();
  }
}
