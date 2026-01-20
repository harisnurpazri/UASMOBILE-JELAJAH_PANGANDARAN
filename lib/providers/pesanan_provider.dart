import 'package:flutter/material.dart';
import '../models/pesanan_model.dart';
import '../services/api_service.dart';

class PesananProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PesananModel> _allPesanan = [];
  List<PesananModel> _userPesanan = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _filterStatus = 'all';

  List<PesananModel> get allPesanan => _filterStatus == 'all'
      ? _allPesanan
      : _allPesanan.where((p) => p.status == _filterStatus).toList();

  List<PesananModel> get userPesanan => _userPesanan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;

  // Statistics
  int get totalPesanan => _allPesanan.length;
  int get confirmedCount =>
      _allPesanan.where((p) => p.status == 'confirmed').length;
  int get completedCount =>
      _allPesanan.where((p) => p.status == 'completed').length;
    double get totalPendapatan => _allPesanan
      .where((p) => p.status == 'completed')
      .fold<double>(0.0, (sum, p) => sum + p.totalHarga);

  void setFilterStatus(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Future<void> loadUserPesanan(String userId, String token) async {
    debugPrint('🔄 loadUserPesanan called for userId: $userId');
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔑 Setting access token...');
      _apiService.setAccessToken(token);
      
      debugPrint('📡 Fetching pesanan from API...');
      _userPesanan = await _apiService.getPesananByUser(userId);

      debugPrint('✅ Successfully loaded ${_userPesanan.length} pesanan');
      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('❌ Error in loadUserPesanan: $e');
      debugPrint('📍 Stack trace: $stackTrace');
      
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllPesanan(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _apiService.setAccessToken(token);
      _allPesanan = await _apiService.getAllPesanan();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPesanan({
    required PesananModel pesanan,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPesanan = await _apiService.createPesanan(pesanan);
      _userPesanan.insert(0, newPesanan);
      _allPesanan.insert(0, newPesanan);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(int id, String status, String token) async {
    try {
      _apiService.setAccessToken(token);
      await _apiService.updatePesananStatus(id, status);

      // Update local data
      final index = _allPesanan.indexWhere((p) => p.id == id);
      if (index != -1) {
        _allPesanan[index] = _allPesanan[index].copyWith(status: status);
      }

      final userIndex = _userPesanan.indexWhere((p) => p.id == id);
      if (userIndex != -1) {
        _userPesanan[userIndex] = _userPesanan[userIndex].copyWith(
          status: status,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePesanan(int id, String token) async {
    try {
      _apiService.setAccessToken(token);
      await _apiService.deletePesanan(id);
      _allPesanan.removeWhere((p) => p.id == id);
      _userPesanan.removeWhere((p) => p.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
