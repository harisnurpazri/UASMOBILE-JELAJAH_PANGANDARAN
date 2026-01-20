import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get wishlist for user
  Future<List<WishlistModel>> getWishlist(String userId) async {
    try {
      final response = await _supabase
          .from('wishlist')
          .select()
          .eq('user_id', userId);

      return (response as List)
          .map((json) => WishlistModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal memuat wishlist: $e');
    }
  }

  // Add to wishlist
  Future<WishlistModel> addToWishlist(String userId, int wisataId) async {
    try {
      final response = await _supabase
          .from('wishlist')
          .insert({'user_id': userId, 'wisata_id': wisataId})
          .select()
          .single();

      return WishlistModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan ke wishlist: $e');
    }
  }

  // Remove from wishlist
  Future<void> removeFromWishlist(String userId, int wisataId) async {
    try {
      await _supabase
          .from('wishlist')
          .delete()
          .eq('user_id', userId)
          .eq('wisata_id', wisataId);
    } catch (e) {
      throw Exception('Gagal menghapus dari wishlist: $e');
    }
  }

  // Check if in wishlist
  Future<bool> isInWishlist(String userId, int wisataId) async {
    try {
      final response = await _supabase
          .from('wishlist')
          .select()
          .eq('user_id', userId)
          .eq('wisata_id', wisataId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}
