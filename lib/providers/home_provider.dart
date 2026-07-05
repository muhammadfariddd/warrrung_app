import 'package:flutter/material.dart';
import 'package:warrrung_app/data/models/category_model.dart';
import 'package:warrrung_app/data/models/product_model.dart';
import 'package:warrrung_app/data/repositories/product_repository.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';

/// Base class representing all states for the home screen logic.
abstract class HomeState {}

/// State representing that home page data is currently being fetched.
class HomeStateLoading extends HomeState {}

/// State representing that home page data has been successfully loaded.
///
/// Contains:
/// - [categories]: all menu categories
/// - [specialDeals]: products in the "Sajian Spesial Hari Ini" category
/// - [productsByCategory]: all other products grouped by their category name (`Map<String, List<ProductModel>>`)
class HomeStateLoaded extends HomeState {
  final List<CategoryModel> categories;
  final List<ProductModel> specialDeals;
  final Map<String, List<ProductModel>> productsByCategory;

  HomeStateLoaded({
    required this.categories,
    required this.specialDeals,
    required this.productsByCategory,
  });
}

/// State representing an error encountered during the loading process.
///
/// Contains an error [message] to show to the user.
class HomeStateError extends HomeState {
  final String message;

  HomeStateError(this.message);
}

/// State management Provider for the home page business logic.
///
/// Concurrently fetches categories, special deals, and all products grouped
/// by category using [ProductRepository], then exposes the current [HomeState]
/// to the UI layer.
class HomeProvider extends ChangeNotifier {
  final ProductRepository _productRepository;

  HomeState _state = HomeStateLoading();

  /// Gets the current state of the home page.
  HomeState get state => _state;

  HomeProvider(this._productRepository) {
    loadHomeData();
  }

  /// Concurrently fetches categories, special deals, and grouped products.
  ///
  /// Updates the UI states: [HomeStateLoading] -> [HomeStateLoaded] or [HomeStateError].
  Future<void> loadHomeData({String? outletId}) async {
    // Use microtask to defer notifyListeners to avoid calling it during
    // the widget build phase, which would cause 'setState called during build' errors.
    if (_state is! HomeStateLoading) {
      _state = HomeStateLoading();
      Future.microtask(() => notifyListeners());
    }

    final url = PocketBaseService.baseUrl;
    debugPrint('[HOME] Memulai loadHomeData dari URL: $url (outletId: $outletId)');

    try {
      // Execute all three repository calls concurrently to minimize loading time
      // Menambahkan timeout 10 detik agar tidak memicu ANR jika jaringan terhambat
      final results = await Future.wait([
        _productRepository.fetchCategories(),
        _productRepository.fetchSpecialDeals(outletId: outletId),
        _productRepository.fetchProductsGroupedByCategory(outletId: outletId),
      ]).timeout(const Duration(seconds: 10));

      final categories = results[0] as List<CategoryModel>;
      final specialDeals = results[1] as List<ProductModel>;
      final productsByCategory = results[2] as Map<String, List<ProductModel>>;

      debugPrint('[HOME] Sukses memuat data home. Kategori: ${categories.length}, Spesial: ${specialDeals.length}');

      _state = HomeStateLoaded(
        categories: categories,
        specialDeals: specialDeals,
        productsByCategory: productsByCategory,
      );
    } catch (e) {
      debugPrint('[HOME] Gagal memuat data home: $e');
      // Exceptions are already cleanly mapped to Failure types in the repository
      _state = HomeStateError(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
