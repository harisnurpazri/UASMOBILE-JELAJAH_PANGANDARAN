import 'package:flutter/foundation.dart';
import '../models/wisata_model.dart';
import '../services/api_service.dart';

class WisataProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<WisataModel> _allWisata = [];
  List<WisataModel> _filteredWisata = [];
  WisataModel? _selectedWisata;

  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedCategory;
  String _searchQuery = '';

  // Getters
  List<WisataModel> get allWisata => _allWisata;
  List<WisataModel> get filteredWisata => _filteredWisata;
  WisataModel? get selectedWisata => _selectedWisata;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Get wisata by category
  List<WisataModel> getWisataByCategory(String category) {
    return _allWisata.where((w) => w.kategori == category).toList();
  }

  // Load all wisata
  Future<void> loadWisata({
    bool forceRefresh = false,
    bool clearFilters = false,
  }) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _errorMessage = null;

      final wisata = await _apiService.getWisata();
      _allWisata = wisata;

      // Clear filters if requested (for admin dashboard)
      if (clearFilters) {
        _selectedCategory = null;
        _searchQuery = '';
      }

      _applyFilters();
    } catch (e) {
      _errorMessage = 'Gagal memuat data wisata: $e';
      debugPrint('Error loading wisata: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search wisata
  Future<void> searchWisata(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _applyFilters();
      return;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      final wisata = await _apiService.getWisata(search: query);
      _filteredWisata = wisata;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal mencari wisata: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Apply filters (category and search)
  void _applyFilters() {
    _filteredWisata = _allWisata;

    // Apply category filter
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      _filteredWisata = _filteredWisata
          .where((w) => w.kategori == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      _filteredWisata = _filteredWisata
          .where(
            (w) =>
                w.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                w.deskripsi.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                w.lokasi.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _searchQuery = '';
    _applyFilters();
  }

  // Select wisata (for detail page)
  void selectWisata(WisataModel wisata) {
    _selectedWisata = wisata;
    notifyListeners();
  }

  // Get wisata by ID
  Future<WisataModel?> getWisataById(int id) async {
    try {
      _setLoading(true);
      final wisata = await _apiService.getWisataById(id);
      _selectedWisata = wisata;
      notifyListeners();
      return wisata;
    } catch (e) {
      _errorMessage = 'Gagal memuat detail wisata: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ==================== ADMIN OPERATIONS ====================

  // Create wisata (Admin only)
  Future<bool> createWisata(WisataModel wisata, String token) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _apiService.setAccessToken(token);
      final newWisata = await _apiService.createWisata(wisata);
      _allWisata.add(newWisata);
      _applyFilters();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah wisata: $e';
      debugPrint('Error creating wisata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update wisata (Admin only)
  Future<bool> updateWisata(int id, WisataModel wisata, String token) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _apiService.setAccessToken(token);
      final updatedWisata = await _apiService.updateWisata(id, wisata);

      final index = _allWisata.indexWhere((w) => w.id == id);
      if (index != -1) {
        _allWisata[index] = updatedWisata;
        _applyFilters();
      }

      return true;
    } catch (e) {
      _errorMessage = 'Gagal update wisata: $e';
      debugPrint('Error updating wisata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete wisata (Admin only)
  Future<bool> deleteWisata(int id, String token) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      _apiService.setAccessToken(token);
      await _apiService.deleteWisata(id);
      _allWisata.removeWhere((w) => w.id == id);
      _applyFilters();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal hapus wisata: $e';
      debugPrint('Error deleting wisata: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
