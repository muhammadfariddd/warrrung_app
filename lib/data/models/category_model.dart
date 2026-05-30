import 'package:warrrung_app/services/pocketbase_service.dart';

/// Dart model representation of the `categories` collection in PocketBase.
class CategoryModel {
  final String id;
  final String name;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  /// Factory constructor to create a [CategoryModel] from a JSON map (PocketBase Record fields).
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
    );
  }

  /// Converts the [CategoryModel] instance back into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  /// Helper getter that returns the fully qualified URL for the category icon, 
  /// conforming to PocketBase files API:
  /// `http://<your-pb-url>/api/files/<collectionId_or_name>/<recordId>/<filename>`
  String get iconUrl {
    if (icon.isEmpty) return '';
    return '${PocketBaseService.baseUrl}/api/files/categories/$id/$icon';
  }
}
