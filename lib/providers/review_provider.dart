import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review_model.dart';

class ReviewProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get average rating for a wisata
  double getAverageRating(int wisataId) {
    final wisataReviews = _reviews
        .where((r) => r.wisataId == wisataId)
        .toList();
    if (wisataReviews.isEmpty) return 0.0;

    final sum = wisataReviews.fold<int>(
      0,
      (prev, review) => prev + review.rating,
    );
    return sum / wisataReviews.length;
  }

  // Get review count for a wisata
  int getReviewCount(int wisataId) {
    return _reviews.where((r) => r.wisataId == wisataId).length;
  }

  // Check if user has already reviewed this wisata
  bool hasUserReviewed(String userId, int wisataId) {
    return _reviews.any((r) => r.userId == userId && r.wisataId == wisataId);
  }

  // Load reviews for a specific wisata
  Future<void> loadReviews(int wisataId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('reviews')
          .select()
          .eq('wisata_id', wisataId)
          .order('created_at', ascending: false);

      _reviews = (response as List)
          .map((json) => ReviewModel.fromMap(json))
          .toList();

      debugPrint('Loaded ${_reviews.length} reviews for wisata $wisataId');
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading reviews: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new review
  Future<bool> addReview({
    required int wisataId,
    required String userId,
    required String namaUser,
    required int rating,
    required String comment,
  }) async {
    try {
      // Check if user already reviewed this wisata
      if (hasUserReviewed(userId, wisataId)) {
        _error = 'Anda sudah memberikan review untuk destinasi ini';
        debugPrint('User already reviewed this wisata');
        return false;
      }

      final review = ReviewModel(
        wisataId: wisataId,
        userId: userId,
        namaUser: namaUser,
        rating: rating,
        comment: comment,
      );

      final response = await _supabase
          .from('reviews')
          .insert(review.toMap())
          .select()
          .single();

      final newReview = ReviewModel.fromMap(response);
      _reviews.insert(0, newReview);
      notifyListeners();

      debugPrint('Review added successfully');
      return true;
    } catch (e) {
      // Handle specific error for duplicate review
      if (e.toString().contains('reviews_user_id_wisata_id_key') ||
          e.toString().contains('duplicate key')) {
        _error = 'Anda sudah memberikan review untuk destinasi ini';
      } else {
        _error = 'Gagal menambahkan review: ${e.toString()}';
      }
      debugPrint('Error adding review: $e');
      return false;
    }
  }

  // Update an existing review
  Future<bool> updateReview({
    required int reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      await _supabase
          .from('reviews')
          .update({
            'rating': rating,
            'comment': comment,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', reviewId);

      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = ReviewModel(
          id: reviewId,
          wisataId: _reviews[index].wisataId,
          userId: _reviews[index].userId,
          namaUser: _reviews[index].namaUser,
          rating: rating,
          comment: comment,
          createdAt: _reviews[index].createdAt,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      debugPrint('Review updated successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating review: $e');
      return false;
    }
  }

  // Delete a review
  Future<bool> deleteReview(int reviewId) async {
    try {
      await _supabase.from('reviews').delete().eq('id', reviewId);

      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();

      debugPrint('Review deleted successfully');
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting review: $e');
      return false;
    }
  }

  // Get user's review for a specific wisata
  ReviewModel? getUserReview(String userId, int wisataId) {
    try {
      return _reviews.firstWhere(
        (r) => r.userId == userId && r.wisataId == wisataId,
      );
    } catch (e) {
      return null;
    }
  }
}
