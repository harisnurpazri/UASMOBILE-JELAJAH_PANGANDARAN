import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../utils/dummy_animations.dart';
import '../config/theme.dart';
import '../providers/chat_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_chat_screen.dart';
import 'profile_screen.dart';

class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load conversations untuk admin
      _refreshBadge();
    });
  }

  Future<void> _refreshBadge() async {
    await context.read<ChatProvider>().loadAllConversations();
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Saat masuk ke tab chat, clear badge dulu
    if (index == 1) {
      // Masuk ke chat, clear semua unread count
      final chatProvider = context.read<ChatProvider>();
      // Reset conversations dengan unread count 0
      chatProvider.clearUnreadBadge();
    } else if (_currentIndex == 1) {
      // Keluar dari chat, refresh badge
      Future.microtask(() => _refreshBadge());
    }
  }

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminChatScreen(),
    const ProfileScreen(),
  ];

  List<NavigationItem> _getNavItems(int unreadCount) {
    return [
      NavigationItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard',
      ),
      NavigationItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Chat User',
        showBadge: unreadCount > 0,
        badgeCount: unreadCount,
      ),
      NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
      ),
    ];
  }

  int _getTotalUnreadCount(ChatProvider chatProvider) {
    // Hitung total pesan belum dibaca dari semua user
    try {
      if (chatProvider.conversations.isEmpty) {
        return 0;
      }
      return chatProvider.conversations.fold<int>(
        0,
        (sum, conversation) => sum + conversation.unreadCount,
      );
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          final unreadCount = _getTotalUnreadCount(chatProvider);
          return _buildModernBottomNav(unreadCount);
        },
      ),
    );
  }

  Widget _buildModernBottomNav(int unreadCount) {
    final navItems = _getNavItems(unreadCount);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navItems.length,
              (index) => _buildNavItem(index, navItems),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, List<NavigationItem> navItems) {
    final item = navItems[index];
    final isActive = _currentIndex == index;
    final color = isActive
        ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
        : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with badge
              ZoomIn(
                duration: const Duration(milliseconds: 200),
                child: item.showBadge
                    ? badges.Badge(
                        badgeContent: Text(
                          '${item.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                        badgeStyle: const badges.BadgeStyle(
                          badgeColor: AppTheme.accentRed,
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: color,
                          size: isActive ? 28 : 24,
                        ),
                      )
                    : Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: color,
                        size: isActive ? 28 : 24,
                      ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                item.label,
                style: TextStyle(
                  fontSize: isActive ? 12 : 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
              ),
              // Active indicator
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 3,
                width: isActive ? 20 : 0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool showBadge;
  final int badgeCount;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showBadge = false,
    this.badgeCount = 0,
  });
}
