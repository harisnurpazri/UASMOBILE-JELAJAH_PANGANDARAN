import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/wisata_model.dart';
import '../models/profile_model.dart';
import '../models/wishlist_model.dart';
import '../models/pesanan_model.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConstants.supabaseUrl;
  final String apiKey = AppConstants.supabaseAnonKey;

  String? _accessToken;

  // Set access token untuk authenticated requests
  void setAccessToken(String? token) {
    _accessToken = token;
  }

  // Get headers dengan authentication
  Map<String, String> _getHeaders({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'apikey': apiKey,
      'Prefer': 'return=representation',
    };

    // Selalu sertakan Authorization header
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    } else {
      // Gunakan anon key untuk guest users
      headers['Authorization'] = 'Bearer $apiKey';
    }

    return headers;
  }

  // ==================== WISATA CRUD ====================

  // GET all wisata
  Future<List<WisataModel>> getWisata({
    String? kategori,
    String? search,
  }) async {
    try {
      var url = '$baseUrl${AppConstants.wisataEndpoint}?select=*';

      if (kategori != null && kategori.isNotEmpty) {
        url += '&kategori=eq.$kategori';
      }

      if (search != null && search.isNotEmpty) {
        url += '&nama=ilike.*$search*';
      }

      final response = await http.get(Uri.parse(url), headers: _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WisataModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wisata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wisata: $e');
    }
  }

  // GET wisata by ID
  Future<WisataModel> getWisataById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.wisataEndpoint}?id=eq.$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) {
          throw Exception('Wisata not found');
        }
        return WisataModel.fromJson(data.first);
      } else {
        throw Exception('Failed to load wisata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wisata: $e');
    }
  }

  // POST create wisata
  Future<WisataModel> createWisata(WisataModel wisata) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.wisataEndpoint}'),
        headers: _getHeaders(requiresAuth: true),
        body: jsonEncode(wisata.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return WisataModel.fromJson(data.first);
      } else {
        throw Exception(
          'Failed to create wisata: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error creating wisata: $e');
    }
  }

  // PATCH update wisata
  Future<WisataModel> updateWisata(int id, WisataModel wisata) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${AppConstants.wisataEndpoint}?id=eq.$id'),
        headers: _getHeaders(requiresAuth: true),
        body: jsonEncode(wisata.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return WisataModel.fromJson(data.first);
      } else {
        throw Exception('Failed to update wisata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating wisata: $e');
    }
  }

  // DELETE wisata
  Future<void> deleteWisata(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConstants.wisataEndpoint}?id=eq.$id'),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete wisata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting wisata: $e');
    }
  }

  // ==================== PROFILE CRUD ====================

  // GET profile by user ID
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.profilesEndpoint}?id=eq.$userId'),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isEmpty) return null;
        return ProfileModel.fromJson(data.first);
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  // POST create profile
  Future<ProfileModel> createProfile(ProfileModel profile) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.profilesEndpoint}'),
        headers: _getHeaders(requiresAuth: true),
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return ProfileModel.fromJson(data.first);
      } else {
        throw Exception('Failed to create profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating profile: $e');
    }
  }

  // PATCH update profile
  Future<ProfileModel> updateProfile(
    String userId,
    ProfileModel profile,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl${AppConstants.profilesEndpoint}?id=eq.$userId'),
        headers: _getHeaders(requiresAuth: true),
        body: jsonEncode(profile.toJson()),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return ProfileModel.fromJson(data.first);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  // ==================== WISHLIST CRUD ====================

  // GET wishlist by user ID
  Future<List<WishlistModel>> getWishlist(String userId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.wishlistEndpoint}?user_id=eq.$userId&select=*',
        ),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => WishlistModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load wishlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching wishlist: $e');
    }
  }

  // POST add to wishlist
  Future<WishlistModel> addToWishlist(String userId, int wisataId) async {
    try {
      final wishlist = WishlistModel(userId: userId, wisataId: wisataId);

      final response = await http.post(
        Uri.parse('$baseUrl${AppConstants.wishlistEndpoint}'),
        headers: _getHeaders(requiresAuth: true),
        body: jsonEncode(wishlist.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = jsonDecode(response.body);
        return WishlistModel.fromJson(data.first);
      } else {
        throw Exception('Failed to add to wishlist: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding to wishlist: $e');
    }
  }

  // DELETE from wishlist
  Future<void> removeFromWishlist(String userId, int wisataId) async {
    try {
      final response = await http.delete(
        Uri.parse(
          '$baseUrl${AppConstants.wishlistEndpoint}?user_id=eq.$userId&wisata_id=eq.$wisataId',
        ),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception(
          'Failed to remove from wishlist: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error removing from wishlist: $e');
    }
  }

  // Check if wisata is in wishlist
  Future<bool> isInWishlist(String userId, int wisataId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl${AppConstants.wishlistEndpoint}?user_id=eq.$userId&wisata_id=eq.$wisataId',
        ),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.isNotEmpty;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== PESANAN CRUD ====================

  // GET pesanan by user ID
  Future<List<PesananModel>> getPesananByUser(String userId) async {
    try {
      developer.log('🔍 Fetching pesanan for user: $userId', name: 'ApiService');
      
      final response = await http.get(
        Uri.parse(
          '$baseUrl/rest/v1/pesanan?user_id=eq.$userId&order=created_at.desc',
        ),
        headers: _getHeaders(requiresAuth: true),
      );

      developer.log('📡 Response status: ${response.statusCode}', name: 'ApiService');
      
      if (response.statusCode == 200) {
        developer.log('📦 Raw response body: ${response.body}', name: 'ApiService');
        
        final List<dynamic> data = json.decode(response.body);
        developer.log('📊 Total data pesanan: ${data.length}', name: 'ApiService');
        
        if (data.isEmpty) {
          developer.log('ℹ️ No pesanan found for this user', name: 'ApiService');
          return [];
        }
        
        // Debug setiap item SEBELUM parsing
        for (var i = 0; i < data.length; i++) {
          developer.log('\n🔢 ===== Pesanan #$i =====', name: 'ApiService');
          developer.log('📄 Full data: ${data[i]}', name: 'ApiService');
          developer.log('   - id: ${data[i]['id']} (${data[i]['id'].runtimeType})', name: 'ApiService');
          developer.log('   - user_id: ${data[i]['user_id']} (${data[i]['user_id'].runtimeType})', name: 'ApiService');
          developer.log('   - wisata_id: ${data[i]['wisata_id']} (${data[i]['wisata_id'].runtimeType})', name: 'ApiService');
          developer.log('   - jumlah_tiket: ${data[i]['jumlah_tiket']} (${data[i]['jumlah_tiket'].runtimeType})', name: 'ApiService');
          developer.log('   - total_harga: ${data[i]['total_harga']} (${data[i]['total_harga'].runtimeType})', name: 'ApiService');
          developer.log('   - status: ${data[i]['status']} (${data[i]['status'].runtimeType})', name: 'ApiService');
        }
        
        // Parse dengan try-catch per item
        List<PesananModel> pesananList = [];
        for (var i = 0; i < data.length; i++) {
            try {
            developer.log('\n🔄 Attempting to parse pesanan #$i...', name: 'ApiService');
            final pesanan = PesananModel.fromJson(data[i]);
            pesananList.add(pesanan);
            developer.log('✅ Successfully parsed pesanan #$i', name: 'ApiService');
          } catch (e, stackTrace) {
            developer.log('❌ ERROR parsing pesanan #$i', name: 'ApiService');
            developer.log('   Error: $e', name: 'ApiService');
            developer.log('   Stack trace: $stackTrace', name: 'ApiService');
            developer.log('   Data yang error: ${data[i]}', name: 'ApiService');
            // Don't rethrow, continue with other items
          }
        }
        
        developer.log('\n✅ Total successfully parsed: ${pesananList.length}/${data.length}', name: 'ApiService');
        return pesananList;
        
      } else {
        throw Exception('Gagal memuat pesanan: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      developer.log('\n❌ FATAL Error getPesananByUser: $e', name: 'ApiService');
      developer.log('📍 Stack trace: $stackTrace', name: 'ApiService');
      rethrow;
    }
  }

  // GET all pesanan (admin only)
  Future<List<PesananModel>> getAllPesanan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/pesanan?order=created_at.desc'),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PesananModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat semua pesanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getAllPesanan: $e');
    }
  }

  // POST create pesanan
  Future<PesananModel> createPesanan(PesananModel pesanan) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/rest/v1/pesanan'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode(pesanan.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return PesananModel.fromJson(data[0]);
      } else {
        throw Exception(
          'Gagal membuat pesanan: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Error createPesanan: $e');
    }
  }

  // PATCH update pesanan status
  Future<void> updatePesananStatus(int id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/rest/v1/pesanan?id=eq.$id'),
        headers: _getHeaders(requiresAuth: true),
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Gagal update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updatePesananStatus: $e');
    }
  }

  // DELETE pesanan
  Future<void> deletePesanan(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/rest/v1/pesanan?id=eq.$id'),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Gagal hapus pesanan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deletePesanan: $e');
    }
  }

  // GET statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/rest/v1/pesanan'),
        headers: _getHeaders(requiresAuth: true),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pesananList = data
            .map((json) => PesananModel.fromJson(json))
            .toList();

        final totalPesanan = pesananList.length;
        final pendingCount = pesananList
            .where((p) => p.status == 'pending')
            .length;
        final confirmedCount = pesananList
            .where((p) => p.status == 'confirmed')
            .length;
        final completedCount = pesananList
            .where((p) => p.status == 'completed')
            .length;

        final totalPendapatan = pesananList
            .where((p) => p.status == 'completed')
            .fold<double>(0.0, (sum, p) => sum + p.totalHarga); // ubah jadi 0.0

        return {
          'totalPesanan': totalPesanan,
          'pendingCount': pendingCount,
          'confirmedCount': confirmedCount,
          'completedCount': completedCount,
          'totalPendapatan': totalPendapatan,
        };
      } else {
        throw Exception('Gagal memuat statistik: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getStatistics: $e');
    }
  }
}
