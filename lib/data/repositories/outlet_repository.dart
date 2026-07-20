import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:warrrung_app/core/errors/failures.dart';
import 'package:warrrung_app/data/models/outlet_model.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';

class OutletRepository {
  final PocketBaseService _pbService;

  OutletRepository(this._pbService);

  /// Fetches the list of active outlets from PocketBase.
  /// 
  /// Throws [NetworkFailure] or [ServerFailure] on connection or database errors.
  Future<List<OutletModel>> fetchOutlets() async {
    try {
      final records = await _pbService.client
          .collection('outlets')
          .getFullList(sort: 'name');
      
      return records.map((record) => OutletModel.fromJson(record.toJson())).toList();
    } on ClientException catch (e) {
      debugPrint('PocketBase ClientException fetching outlets: ${e.toString()} (status: ${e.statusCode})');
      if (e.statusCode == 0) {
        throw NetworkFailure('Koneksi internet bermasalah. Silakan coba lagi.');
      }
      final message = e.response['message'] ?? 'Gagal mengambil data outlet.';
      throw ServerFailure(message, statusCode: e.statusCode);
    } catch (e) {
      debugPrint('General error fetching outlets: $e');
      throw Failure('Terjadi kesalahan tidak terduga saat memuat outlet: $e');
    }
  }
}
