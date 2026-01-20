class WishlistModel {
  final int? id;
  final String userId;
  final int wisataId;
  final DateTime? createdAt;

  WishlistModel({
    this.id,
    required this.userId,
    required this.wisataId,
    this.createdAt,
  });

  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    return WishlistModel(
      id: json['id'] as int?,
      userId: json['user_id'] as String? ?? '',
      wisataId: json['wisata_id'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'wisata_id': wisataId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}
