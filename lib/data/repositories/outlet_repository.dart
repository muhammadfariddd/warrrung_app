import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:warrrung_app/data/models/outlet_model.dart';
import 'package:warrrung_app/services/pocketbase_service.dart';

class OutletRepository {
  final PocketBaseService _pbService;

  OutletRepository(this._pbService);

  /// Fetches the list of active outlets from PocketBase.
  /// 
  /// Falls back to localized mock data if PocketBase is offline or the collection does not exist.
  Future<List<OutletModel>> fetchOutlets() async {
    try {
      final records = await _pbService.client
          .collection('outlets')
          .getFullList(sort: 'name');
      
      if (records.isEmpty) {
        return _getMockOutlets();
      }
      return records.map((record) => OutletModel.fromJson(record.toJson())).toList();
    } on ClientException catch (e) {
      debugPrint('PocketBase ClientException fetching outlets: ${e.toString()} (status: ${e.statusCode}), response: ${e.response}');
      return _getMockOutlets();
    } catch (e) {
      debugPrint('General error fetching outlets: $e');
      return _getMockOutlets();
    }
  }

  /// Mock data matching Kopi Kenangan styling & requirements
  List<OutletModel> _getMockOutlets() {
    return [
      OutletModel(
        id: 'outlet_1',
        name: 'Lippo Mall Puri',
        address: 'Lippo Mall Puri, Lantai Lower Ground Floor, Jl. Puri Indah Raya, Kembangan, Jakarta Barat',
        latitude: -6.1884,
        longitude: 106.7387,
        isActive: false, // Override forced closed
        openTime: '10:00',
        closeTime: '22:00',
        operationalHours: 'BUKA BESOK JAM 10:00',
        hasPickup: true,
        hasDelivery: true,
        hasDineIn: false,
      ),
      OutletModel(
        id: 'outlet_2',
        name: 'Menara Standard Chartered',
        address: 'Menara Standard Chartered, Lantai Ground Floor, Jl. Prof. Dr. Satrio, Karet Semanggi, Jakarta Selatan',
        latitude: -6.2201,
        longitude: 106.8214,
        isActive: false, // Override forced closed
        openTime: '07:00',
        closeTime: '21:00',
        operationalHours: 'BUKA BESOK JAM 07:00',
        hasPickup: true,
        hasDelivery: true,
        hasDineIn: true,
      ),
      OutletModel(
        id: 'outlet_3',
        name: 'Setiabudi One',
        address: 'Setiabudi One, Lantai 1 Unit B211, Jl. H. R. Rasuna Said, Kuningan, Jakarta Selatan',
        latitude: -6.2136,
        longitude: 106.8302,
        isActive: true,
        openTime: '08:00',
        closeTime: '22:00',
        operationalHours: 'BUKA - TUTUP JAM 22:00',
        hasPickup: true,
        hasDelivery: true,
        hasDineIn: false,
      ),
      OutletModel(
        id: 'outlet_4',
        name: 'waRRRung Utama - Cabang Merdeka',
        address: 'Jl. Merdeka No. 123, Sumur Bandung, Kota Bandung',
        latitude: -6.9147,
        longitude: 107.6098,
        isActive: true,
        openTime: '08:00',
        closeTime: '23:00',
        operationalHours: 'BUKA - TUTUP JAM 23:00',
        hasPickup: true,
        hasDelivery: true,
        hasDineIn: true,
      ),
    ];
  }
}
