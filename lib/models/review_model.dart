class ReviewModel {
  final int? id;
  final int wisataId;
  final String userId;
  final String namaUser;
  final int rating;
  final String comment;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReviewModel({
    this.id,
    required this.wisataId,
    required this.userId,
    required this.namaUser,
    required this.rating,
    required this.comment,
    this.createdAt,
    this.updatedAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as int?,
      wisataId: map['wisata_id'] as int,
      userId: map['user_id'] as String,
      namaUser: map['nama_user'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'wisata_id': wisataId,
      'user_id': userId,
      'nama_user': namaUser,
      'rating': rating,
      'comment': comment,
    };
  }

  // Get relative time (e.g., "2 days ago")
  String getRelativeTime() {
    if (createdAt == null) return 'Just now';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
