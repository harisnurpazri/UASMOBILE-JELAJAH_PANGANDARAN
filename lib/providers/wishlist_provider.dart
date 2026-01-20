import 'package:flutter/foundation.dart';
import '../models/wisata_model.dart';
import '../models/wishlist_model.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';

class WishlistProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final WishlistService _wishlistService = WishlistService();

  List<WishlistModel> _wishlist = [];
  List<WisataModel> _wishlistWisata = [];
  Set<int> _wishlistIds = {};

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<WishlistModel> get wishlist => _wishlist;
  List<WisataModel> get wishlistWisata => _wishlistWisata;
  Set<int> get wishlistIds => _wishlistIds;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get wishlistCount => _wishlist.length;

  // Check if wisata is in wishlist
  bool isInWishlist(int wisataId) {
    return _wishlistIds.contains(wisataId);
  }

  // Load wishlist
  Future<void> loadWishlist(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Get wishlist using Supabase client
      _wishlist = await _wishlistService.getWishlist(userId);

      // Extract wishlist IDs for quick lookup
      _wishlistIds = _wishlist.map((w) => w.wisataId).toSet();

      // Load full wisata details for each wishlist item
      _wishlistWisata = [];
      for (final item in _wishlist) {
        try {
          final wisata = await _apiService.getWisataById(item.wisataId);
          _wishlistWisata.add(wisata);
        } catch (e) {
          debugPrint('Error loading wisata ${item.wisataId}: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat wishlist: $e';
      debugPrint('Error loading wishlist: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add to wishlist
  Future<bool> addToWishlist(
    String userId,
    int wisataId,
    WisataModel wisata,
  ) async {
    // Check if user is logged in
    if (userId.isEmpty) {
      _errorMessage =
          'Silakan login terlebih dahulu untuk menambahkan ke wishlist';
      notifyListeners();
      return false;
    }

    // Check if already in wishlist
    if (isInWishlist(wisataId)) {
      _errorMessage = 'Wisata sudah ada di wishlist';
      notifyListeners();
      return false;
    }

    try {
      _setLoading(true);
      _errorMessage = null;

      // Use Supabase client instead of REST API
      final wishlistItem = await _wishlistService.addToWishlist(
        userId,
        wisataId,
      );

      // Update local state
      _wishlist.add(wishlistItem);
      _wishlistIds.add(wisataId);
      _wishlistWisata.add(wisata);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah ke wishlist. $e';
      debugPrint('Error adding to wishlist: $e');
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove from wishlist
  Future<bool> removeFromWishlist(String userId, int wisataId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Use Supabase client instead of REST API
      await _wishlistService.removeFromWishlist(userId, wisataId);

      // Update local state
      _wishlist.removeWhere((w) => w.wisataId == wisataId);
      _wishlistIds.remove(wisataId);
      _wishlistWisata.removeWhere((w) => w.id == wisataId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menghapus dari wishlist: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Toggle wishlist (add if not exists, remove if exists)
  Future<bool> toggleWishlist(
    String userId,
    int wisataId,
    WisataModel wisata,
  ) async {
    // Check if user is logged in
    if (userId.isEmpty) {
      _errorMessage =
          'Silakan login terlebih dahulu untuk menggunakan wishlist';
      notifyListeners();
      return false;
    }

    if (isInWishlist(wisataId)) {
      return await removeFromWishlist(userId, wisataId);
    } else {
      return await addToWishlist(userId, wisataId, wisata);
    }
  }

  // Clear wishlist
  void clearWishlist() {
    _wishlist.clear();
    _wishlistWisata.clear();
    _wishlistIds.clear();
    notifyListeners();
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
