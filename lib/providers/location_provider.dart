import 'package:flutter/material.dart';
import 'package:warrrung_app/data/models/outlet_model.dart';
import 'package:warrrung_app/data/repositories/outlet_repository.dart';

class LocationProvider extends ChangeNotifier {
  final OutletRepository _outletRepository;

  List<OutletModel> _allOutlets = [];
  List<OutletModel> _filteredOutlets = [];
  bool _isLoading = false;
  OutletModel? _selectedOutlet;
  
  // Tab selection: 'pickup' or 'delivery'
  String _activeTab = 'pickup'; 
  String _searchQuery = '';

  List<OutletModel> get outlets => _filteredOutlets;
  bool get isLoading => _isLoading;
  OutletModel? get selectedOutlet => _selectedOutlet;
  String get activeTab => _activeTab;
  String get searchQuery => _searchQuery;

  LocationProvider(this._outletRepository) {
    loadOutlets();
  }

  /// Fetches outlets and initializes state
  Future<void> loadOutlets() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allOutlets = await _outletRepository.fetchOutlets();
      _filterOutlets();
    } catch (_) {
      _allOutlets = [];
      _filteredOutlets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sets the currently active selected outlet
  void selectOutlet(OutletModel outlet) {
    _selectedOutlet = outlet;
    notifyListeners();
  }

  /// Toggles between 'pickup' and 'delivery' views
  void setActiveTab(String tab) {
    if (tab != 'pickup' && tab != 'delivery') return;
    _activeTab = tab;
    _filterOutlets();
    notifyListeners();
  }

  /// Filters outlets dynamically as user types
  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterOutlets();
    notifyListeners();
  }

  void _filterOutlets() {
    _filteredOutlets = _allOutlets.where((outlet) {
      // 1. Filter by active tab (pickup or delivery availability)
      final bool matchesTab = _activeTab == 'pickup' ? outlet.hasPickup : outlet.hasDelivery;
      
      // 2. Filter by search query
      final bool matchesQuery = _searchQuery.isEmpty || 
          outlet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          outlet.address.toLowerCase().contains(_searchQuery.toLowerCase());
          
      return matchesTab && matchesQuery;
    }).toList();
  }
}
