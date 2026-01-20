import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ApiService _apiService = ApiService();

  ProfileModel? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  SupabaseClient get supabase => _supabase;
  ProfileModel? get currentProfile => _currentProfile;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => currentUser != null;
  bool get isAdmin => _currentProfile?.isAdmin ?? false;

  // Constructor - Load user on init
  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = currentUser;
    if (user != null) {
      await loadProfile();
      _apiService.setAccessToken(_supabase.auth.currentSession?.accessToken);
    }
  }

  // Sign Up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String namaLengkap,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // 1. Sign up with Supabase Auth (with metadata for trigger)
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'nama_lengkap': namaLengkap},
      );

      if (response.user == null) {
        _errorMessage = 'Gagal membuat akun';
        return false;
      }

      // 2. Set access token
      _apiService.setAccessToken(response.session?.accessToken);

      // 3. Load profile (already created by database trigger)
      // Wait a bit for trigger to complete
      await Future.delayed(const Duration(milliseconds: 500));

      try {
        final profile = await _apiService.getProfile(response.user!.id);
        _currentProfile = profile;
      } catch (e) {
        // If profile not found, create it manually (fallback)
        debugPrint('Profile not found, creating manually: $e');
        final profile = ProfileModel(
          id: response.user!.id,
          namaLengkap: namaLengkap,
          email: email,
          role: 'user',
        );

        try {
          await _apiService.createProfile(profile);
          _currentProfile = profile;
        } catch (createError) {
          // Profile might already exist, try to fetch again
          debugPrint('Create failed, fetching again: $createError');
          _currentProfile = await _apiService.getProfile(response.user!.id);
        }
      }

      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      debugPrint('SignUp error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign In with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        _errorMessage = 'Gagal masuk';
        return false;
      }

      _apiService.setAccessToken(response.session?.accessToken);
      await loadProfile();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;

      // Handle specific errors
      if (e.message.toLowerCase().contains('email not confirmed')) {
        _errorMessage = 'Email belum diverifikasi. Cek email Anda.';
      } else if (e.message.toLowerCase().contains('invalid')) {
        _errorMessage = 'Email atau password salah';
      }

      return false;
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load user profile from database
  Future<void> loadProfile() async {
    try {
      final user = currentUser;
      if (user == null) return;

      // Ensure access token is set
      final token = _supabase.auth.currentSession?.accessToken;
      if (token != null) {
        _apiService.setAccessToken(token);
      }

      final profile = await _apiService.getProfile(user.id);
      if (profile != null) {
        _currentProfile = profile;
        debugPrint(
          'Profile loaded: ${profile.namaLengkap}, Role: ${profile.role}',
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading profile: $e');
      _errorMessage = 'Gagal memuat profil';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabase.auth.signOut();
      _currentProfile = null;
      _apiService.setAccessToken(null);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal keluar: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Alias untuk logout (compatibility)
  Future<void> logout() => signOut();

  // Update profile
  Future<bool> updateProfile({
    required String namaLengkap,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = currentUser;
      if (user == null || _currentProfile == null) {
        _errorMessage = 'User tidak ditemukan';
        return false;
      }

      final updatedProfile = _currentProfile!.copyWith(
        namaLengkap: namaLengkap,
        avatarUrl: avatarUrl,
      );

      final result = await _apiService.updateProfile(user.id, updatedProfile);
      _currentProfile = result;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal update profil: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
