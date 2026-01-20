import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/dummy_animations.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryBlue, AppTheme.lightBlue],
                  ),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    final profile = authProvider.currentProfile;
                    return Padding(
                      padding: const EdgeInsets.only(top: 50, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeInDown(
                            child: CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Text(
                                profile?.name.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          FadeInUp(
                            child: Text(
                              profile?.name ?? 'User',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              profile?.email ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Section
                  _buildSectionTitle(context, 'Akun'),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    child: _buildMenuCard(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Profile',
                      subtitle: 'Ubah informasi profil Anda',
                      onTap: () {
                        // Navigate to edit profile
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Preferences Section
                  _buildSectionTitle(context, 'Preferensi'),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return _buildMenuCard(
                          context,
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle: 'Ubah tema aplikasi',
                          trailing: Switch(
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
                            activeTrackColor: AppTheme.lightBlue,
                            thumbColor: WidgetStateProperty.all(Colors.white),
                          ),
                          onTap: () {
                            themeProvider.toggleTheme();
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifikasi',
                      subtitle: 'Atur notifikasi aplikasi',
                      onTap: () {
                        // Navigate to notifications settings
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 400),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.language_outlined,
                      title: 'Bahasa',
                      subtitle: 'Indonesia',
                      onTap: () {
                        // Navigate to language settings
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Help Section
                  _buildSectionTitle(context, 'Bantuan & Info'),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 500),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.help_outline,
                      title: 'Pusat Bantuan',
                      subtitle: 'FAQ dan dukungan',
                      onTap: () {
                        // Navigate to help center
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 600),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.info_outline,
                      title: 'Tentang Aplikasi',
                      subtitle: 'Versi 1.0.0',
                      onTap: () {
                        _showAboutDialog(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeInLeft(
                    delay: const Duration(milliseconds: 700),
                    child: _buildMenuCard(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privasi & Keamanan',
                      subtitle: 'Kebijakan privasi',
                      onTap: () {
                        // Navigate to privacy policy
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showLogoutDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Keluar'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentRed,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Pangandaran Explore',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.explore, color: Colors.white, size: 32),
      ),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Aplikasi wisata Pangandaran dengan fitur lengkap untuk membantu Anda menjelajahi keindahan Pangandaran.',
        ),
      ],
    );
  }
}
