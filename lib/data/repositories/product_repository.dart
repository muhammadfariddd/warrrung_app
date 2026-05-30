import 'package:pocketbase/pocketbase.dart';
import 'package:warrrung_app/core/errors/failures.dart';
import 'package:warrrung_app/data/models/category_model.dart';
import 'package:warrrung_app/data/models/product_model.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';

/// Repository for handling all category and product-related data operations.
///
/// Maps PocketBase SDK's [ClientException] to custom application [Failure] instances
/// to maintain a clean architecture separation of concerns.
class ProductRepository {
  final PocketBaseService _pbService;

  ProductRepository(this._pbService);

  /// Fetches all active category records from the `categories` collection.
  ///
  /// Throws [NetworkFailure] or [ServerFailure] on connection or database errors.
  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final records = await _pbService.client
          .collection('categories')
          .getFullList(sort: 'name');

      return records
          .map((record) => CategoryModel.fromJson(record.toJson()))
          .toList();
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw NetworkFailure('Koneksi internet bermasalah. Silakan coba lagi.');
      }
      final message = e.response['message'] ?? 'Gagal mengambil data kategori.';
      throw ServerFailure(message, statusCode: e.statusCode);
    } catch (e) {
      throw Failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Fetches special deals from the `products` collection where the category name matches
  /// "Sajian Spesial Hari Ini" and the product is marked as available.
  ///
  /// Throws [NetworkFailure] or [ServerFailure] on connection or database errors.
  Future<List<ProductModel>> fetchSpecialDeals() async {
    try {
      final records = await _pbService.client
          .collection('products')
          .getFullList(
            filter: 'is_special = true && is_available = true',
            expand: 'category_id',
          );

      return records
          .map((record) => ProductModel.fromJson(record.toJson()))
          .toList();
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw NetworkFailure('Koneksi internet bermasalah. Silakan coba lagi.');
      }
      final message =
          e.response['message'] ?? 'Gagal mengambil data sajian spesial.';
      throw ServerFailure(message, statusCode: e.statusCode);
    } catch (e) {
      throw Failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Fetches ALL available products with their category expanded in a single request.
  /// Returns a map of category name -> list of products, for efficient grouped display.
  /// Excludes the "Sajian Spesial Hari Ini" category (shown separately).
  ///
  /// Throws [NetworkFailure] or [ServerFailure] on connection or database errors.
  Future<Map<String, List<ProductModel>>>
  fetchProductsGroupedByCategory() async {
    try {
      final records = await _pbService.client
          .collection('products')
          .getFullList(
            filter:
                'is_available = true && category_id.name != "Sajian Spesial Hari Ini"',
            expand: 'category_id',
            sort: 'category_id.name,name',
          );

      final Map<String, List<ProductModel>> grouped = {};
      for (final record in records) {
        // Get the category name from the expanded relation
        final expandedCategory = record.get<List<RecordModel>?>('expand.category_id');
        final categoryName =
            (expandedCategory != null && expandedCategory.isNotEmpty)
            ? (expandedCategory.first.data['name'] as String? ?? 'Lainnya')
            : 'Lainnya';

        grouped.putIfAbsent(categoryName, () => []);
        grouped[categoryName]!.add(ProductModel.fromJson(record.toJson()));
      }
      return grouped;
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw NetworkFailure('Koneksi internet bermasalah. Silakan coba lagi.');
      }
      final message = e.response['message'] ?? 'Gagal mengambil data produk.';
      throw ServerFailure(message, statusCode: e.statusCode);
    } catch (e) {
      throw Failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Fetches all products by a specific [categoryId] which are available.
  ///
  /// Throws [NetworkFailure] or [ServerFailure] on connection or database errors.
  Future<List<ProductModel>> fetchProductsByCategory(String categoryId) async {
    try {
      final records = await _pbService.client
          .collection('products')
          .getFullList(
            filter: 'category_id = "$categoryId" && is_available = true',
          );

      return records
          .map((record) => ProductModel.fromJson(record.toJson()))
          .toList();
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw NetworkFailure('Koneksi internet bermasalah. Silakan coba lagi.');
      }
      final message = e.response['message'] ?? 'Gagal mengambil data produk.';
      throw ServerFailure(message, statusCode: e.statusCode);
    } catch (e) {
      throw Failure('Terjadi kesalahan tidak terduga: $e');
    }
  }

  /// Fetches products based on a custom section type name or category name.
  ///
  /// Useful for dynamic section loads based on the category name.
  /// Throws [NetworkFailure] or [ServerFailure] on connection or database errors.
  Future<List<ProductModel>> fetchProductsBySection(String sectionType) async {
    try {
      final records = await _pbService.client
          .collection('products')
          .getFullList(
            filter: 'category_id.name = "$sectionType" && is_available = true',
          );

      return records
          .map((record) => ProductModel.fromJson(record.toJson()))
          .toList();
    } on ClientException catch (e) {
      if (e.statusCode == 0) {
        throw NetworkFailure('Koneksi internet bermasalah. Silakan coba lagi.');
      }
      final message =
          e.response['message'] ??
          'Gagal mengambil produk bagian $sectionType.';
      throw ServerFailure(message, statusCode: e.statusCode);
    } catch (e) {
      throw Failure('Terjadi kesalahan tidak terduga: $e');
    }
  }
}
