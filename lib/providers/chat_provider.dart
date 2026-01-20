import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_model.dart';

class ChatProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<ChatMessage> _messages = [];
  List<ChatConversation> _conversations = [];
  bool _isLoading = false;
  String? _errorMessage;
  RealtimeChannel? _messageChannel;

  List<ChatMessage> get messages => _messages;
  List<ChatConversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Load chat messages
  Future<void> loadMessages(String userId) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: true);

      _messages = (response as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();

      debugPrint('Loaded ${_messages.length} messages for user $userId');
      final unreadFromAdmin = _messages
          .where((msg) => !msg.isFromUser && !msg.isRead)
          .length;
      debugPrint('Unread from admin: $unreadFromAdmin');

      // Subscribe to realtime updates
      _subscribeToMessages(userId);

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat pesan: $e';
      debugPrint('Error loading messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Subscribe to realtime message updates
  void _subscribeToMessages(String userId) {
    _messageChannel?.unsubscribe();

    _messageChannel = _supabase
        .channel('chat_messages_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final newMessage = ChatMessage.fromJson(payload.newRecord);
            _messages.add(newMessage);
            notifyListeners();
          },
        )
        .subscribe();
  }

  // Send message
  Future<bool> sendMessage(
    String userId,
    String message, {
    bool isFromUser = true,
  }) async {
    try {
      _errorMessage = null;

      final data = {
        'user_id': userId,
        'message': message,
        'is_from_user': isFromUser,
        'is_read': false,
      };

      await _supabase.from('chat_messages').insert(data);

      // Don't add optimistically - let realtime subscription handle it
      // to avoid duplicate messages

      return true;
    } catch (e) {
      _errorMessage = 'Gagal mengirim pesan: $e';
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // Mark messages as read
  Future<void> markAsRead(String userId) async {
    try {
      // Mark messages FROM ADMIN TO USER as read (pesan yang diterima user dari admin)
      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_from_user', false) // Pesan dari admin
          .eq('is_read', false);

      // Update local messages
      _messages = _messages.map((msg) {
        if (!msg.isFromUser && !msg.isRead) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  // Mark admin messages as read (untuk admin baca pesan dari user)
  Future<void> markAdminMessagesAsRead(String userId) async {
    try {
      // Mark messages FROM USER TO ADMIN as read (pesan yang diterima admin dari user)
      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_from_user', true) // Pesan dari user
          .eq('is_read', false);

      // Update local messages
      _messages = _messages.map((msg) {
        if (msg.isFromUser && !msg.isRead) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('Error marking admin messages as read: $e');
    }
  }

  // Get unread count
  int getUnreadCount() {
    final count = _messages
        .where((msg) => !msg.isFromUser && !msg.isRead)
        .length;
    debugPrint(
      'USER UNREAD COUNT: $count (Total messages: ${_messages.length})',
    );
    return count;
  }

  // Clear unread badge untuk user - langsung update local state
  void clearUserUnreadBadge() {
    // Update local messages langsung (optimistic update)
    _messages = _messages.map((msg) {
      if (!msg.isFromUser && !msg.isRead) {
        return msg.copyWith(isRead: true);
      }
      return msg;
    }).toList();
    notifyListeners();
  }

  // Mark as read untuk user (update database + local)
  Future<void> markUserMessagesAsReadInDb(String userId) async {
    try {
      // Update database
      await _supabase
          .from('chat_messages')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_from_user', false)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error updating read status in db: $e');
    }
  }

  // Load all conversations for admin
  Future<void> loadAllConversations() async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // Get all messages
      final messagesResponse = await _supabase
          .from('chat_messages')
          .select('user_id, message, created_at, is_read, is_from_user')
          .order('created_at', ascending: false);

      // Group by user_id and get latest message
      final Map<String, dynamic> userChats = {};
      final List<dynamic> messages = messagesResponse as List;

      for (var msg in messages) {
        final userId = msg['user_id'] as String;

        if (!userChats.containsKey(userId)) {
          try {
            // Get user profile
            final profileResponse = await _supabase
                .from('profiles')
                .select('nama_lengkap, email')
                .eq('id', userId)
                .maybeSingle();

            if (profileResponse != null) {
              // Count unread messages from this user
              final unreadCount = messages
                  .where(
                    (m) =>
                        m['user_id'] == userId &&
                        m['is_from_user'] == true &&
                        m['is_read'] == false,
                  )
                  .length;

              userChats[userId] = {
                'user_id': userId,
                'user_name': profileResponse['nama_lengkap'] ?? 'User',
                'user_email': profileResponse['email'] ?? '',
                'last_message': msg['message'],
                'last_message_time': msg['created_at'],
                'unread_count': unreadCount,
              };
            }
          } catch (e) {
            debugPrint('Error fetching profile for user $userId: $e');
            // Skip this user if profile not found
            continue;
          }
        }
      }

      _conversations = userChats.values
          .map((json) => ChatConversation.fromJson(json))
          .toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat conversations: $e';
      debugPrint('Error loading conversations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Clear unread badge (untuk admin saat masuk tab chat)
  void clearUnreadBadge() {
    _conversations = _conversations.map((conv) {
      return ChatConversation(
        userId: conv.userId,
        userName: conv.userName,
        userEmail: conv.userEmail,
        lastMessage: conv.lastMessage,
        lastMessageTime: conv.lastMessageTime,
        unreadCount: 0, // Reset ke 0
      );
    }).toList();
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

  @override
  void dispose() {
    _messageChannel?.unsubscribe();
    super.dispose();
  }
}
