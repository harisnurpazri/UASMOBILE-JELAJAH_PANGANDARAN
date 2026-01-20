import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/dummy_animations.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import '../models/chat_model.dart';

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllChats();
    });
  }

  Future<void> _loadAllChats() async {
    if (!mounted) return;
    final chatProvider = context.read<ChatProvider>();
    await chatProvider.loadAllConversations();
  }

  Future<void> _loadMessagesForUser(String userId) async {
    final chatProvider = context.read<ChatProvider>();
    // PENTING: Mark pesan dari USER sebagai sudah dibaca DULU
    await chatProvider.markAdminMessagesAsRead(userId);
    // Baru load messages
    await chatProvider.loadMessages(userId);
    // Reload conversations untuk update badge (setelah mark as read)
    await chatProvider.loadAllConversations();
    _scrollToBottom();
  }

  Future<void> _sendMessage(String userId) async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = context.read<ChatProvider>();

    final message = _messageController.text.trim();
    _messageController.clear();

    await chatProvider.sendMessage(
      userId,
      message,
      isFromUser: false, // From admin
    );

    // Reload conversations untuk update badge
    await chatProvider.loadAllConversations();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        title: const Text(
          'Chat Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Row(
        children: [
          // User List - Smaller width for more chat space
          Container(
            width:
                MediaQuery.of(context).size.width *
                0.25, // 25% dari lebar layar
            constraints: const BoxConstraints(minWidth: 250, maxWidth: 320),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                right: BorderSide(
                  color: AppTheme.textSecondary.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: AppTheme.textSecondary.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari pengguna...',
                      hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).scaffoldBackgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      if (chatProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (chatProvider.conversations.isEmpty) {
                        return Center(
                          child: FadeIn(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: AppTheme.textSecondary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pesan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: chatProvider.conversations.length,
                        itemBuilder: (context, index) {
                          final conversation =
                              chatProvider.conversations[index];
                          final timeStr = conversation.lastMessageTime != null
                              ? DateFormat(
                                  'HH:mm',
                                ).format(conversation.lastMessageTime!)
                              : '';

                          return _buildUserChatItem(
                            conversation.userName,
                            conversation.lastMessage ?? 'Belum ada pesan',
                            timeStr,
                            unreadCount: conversation.unreadCount,
                            isSelected: _selectedUserId == conversation.userId,
                            onTap: () async {
                              setState(() {
                                _selectedUserId = conversation.userId;
                              });
                              await _loadMessagesForUser(conversation.userId);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: _selectedUserId == null
                ? Center(
                    child: FadeIn(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            size: 80,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Pilih pengguna untuk memulai chat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      // Find selected conversation
                      final selectedConversation = chatProvider.conversations
                          .firstWhere(
                            (c) => c.userId == _selectedUserId,
                            orElse: () => ChatConversation(
                              userId: _selectedUserId!,
                              userName: 'User',
                              userEmail: '',
                            ),
                          );

                      return Column(
                        children: [
                          // Chat Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppTheme.textSecondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.primaryBlue
                                      .withValues(alpha: 0.2),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedConversation.userName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        selectedConversation.userEmail,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Messages
                          Expanded(
                            child: Consumer<ChatProvider>(
                              builder: (context, chatProvider, _) {
                                if (chatProvider.messages.isEmpty) {
                                  return const Center(
                                    child: Text('Belum ada pesan'),
                                  );
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: chatProvider.messages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        chatProvider.messages[index];
                                    return _buildMessageBubble(message);
                                  },
                                );
                              },
                            ),
                          ),

                          // Input
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Balas pesan...',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Theme.of(
                                        context,
                                      ).scaffoldBackgroundColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 12,
                                          ),
                                    ),
                                    maxLines: null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Material(
                                  color: AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    onTap: () => _sendMessage(_selectedUserId!),
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserChatItem(
    String name,
    String lastMessage,
    String time, {
    int unreadCount = 0,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    // Get first letter of name for avatar
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Material(
      color: isSelected
          ? AppTheme.primaryBlue.withValues(alpha: 0.15)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.textSecondary.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppTheme.primaryBlue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isAdmin = !message.isFromUser;
    final time = DateFormat('HH:mm').format(message.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isAdmin
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isAdmin) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
              child: const Icon(
                Icons.person,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isAdmin ? AppTheme.primaryBlue : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isAdmin ? 18 : 4),
                  topRight: Radius.circular(isAdmin ? 4 : 18),
                  bottomLeft: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: isAdmin ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isAdmin
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppTheme.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryBlue,
              child: const Icon(
                Icons.admin_panel_settings,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
