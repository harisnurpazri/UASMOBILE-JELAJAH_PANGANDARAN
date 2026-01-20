class ChatMessage {
  final int? id;
  final String userId;
  final String? adminId;
  final String message;
  final bool isFromUser;
  final DateTime createdAt;
  final bool isRead;

  ChatMessage({
    this.id,
    required this.userId,
    this.adminId,
    required this.message,
    required this.isFromUser,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      adminId: json['admin_id'] as String?,
      message: json['message'] as String,
      isFromUser: json['is_from_user'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'admin_id': adminId,
      'message': message,
      'is_from_user': isFromUser,
      'is_read': isRead,
    };
  }

  ChatMessage copyWith({
    int? id,
    String? userId,
    String? adminId,
    String? message,
    bool? isFromUser,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      message: message ?? this.message,
      isFromUser: isFromUser ?? this.isFromUser,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

// Model untuk daftar conversation di admin
class ChatConversation {
  final String userId;
  final String userName;
  final String userEmail;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatConversation({
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'User',
      userEmail: json['user_email'] as String? ?? '',
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}
