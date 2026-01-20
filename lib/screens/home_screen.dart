import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/dummy_animations.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wisata_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/wisata_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final weatherProvider = context.read<WeatherProvider>();
    final wisataProvider = context.read<WisataProvider>();

    // Reload profile to get latest role
    await authProvider.loadProfile();

    // Load weather data dari lokasi saat ini (auto-detect)
    await weatherProvider.loadCurrentLocationWeather();

    // Load wisata data
    await wisataProvider.loadWisata();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    if (category == 'Semua') {
      context.read<WisataProvider>().loadWisata();
    } else {
      context.read<WisataProvider>().filterByCategory(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildHomeContent());
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryOrange,
      child: CustomScrollView(
        slivers: [
          // Modern Header without AppBar
          SliverToBoxAdapter(
            child: SafeArea(
              child: FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Row(
                        children: [
                          // Avatar dengan gradient orange
                          Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryOrange.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              radius: 24,
                              child: Text(
                                authProvider.currentProfile?.namaLengkap
                                        .substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Greeting
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Halo,',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  authProvider.currentProfile?.namaLengkap
                                          .split(' ')[0] ??
                                      'User',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Notification Icon
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            color: AppTheme.textPrimary,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Tidak ada notifikasi baru'),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Banner as background: combine search + weather into a single card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/banner.png'),
                      fit: BoxFit.cover,
                    ),
                    color: Theme.of(context).cardColor,
                  ),
                  child: Container(
                    // overlay gradient to improve text contrast
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.black.withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field inside banner
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            readOnly: true,
                            onTap: () {
                              // Navigate to search view if available
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari destinasi wisata...',
                              hintStyle: TextStyle(color: Colors.grey[700]),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppTheme.primaryOrange,
                                size: 22,
                              ),
                              suffixIcon: Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryOrange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.search, color: Colors.white),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Weather summary inside banner
                        Consumer<WeatherProvider>(
                          builder: (context, weatherProvider, _) {
                            final temp = weatherProvider.temperatureCelsius;
                            final condition = weatherProvider.description;
                            final location = weatherProvider.currentWeather?.cityName ?? '';
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, size: 14, color: Colors.white70),
                                            const SizedBox(width: 6),
                                            Text(
                                              location.isNotEmpty ? location : 'Lokasi',
                                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          temp,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          condition,
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Simple weather icon placeholder
                                  Container(
                                    width: 64,
                                    height: 64,
                                    alignment: Alignment.center,
                                    child: _buildWeatherIcon(condition),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Search Bar - Modern dengan shadow orange
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryOrange.withValues(
                              alpha: 0.08,
                            ),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        readOnly: true,
                        onTap: () {
                          // Navigate to search via main navigation
                          // DefaultTabController.of(context).animateTo(1);
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari tempat wisata...',
                          hintStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 15,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppTheme.primaryOrange,
                            size: 24,
                          ),
                          suffixIcon: const Icon(
                            Icons.tune_rounded,
                            color: AppTheme.accentOrange,
                            size: 22,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Categories horizontal scroll
                  FadeInLeft(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 200),
                    child: SizedBox(
                      height: 50,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCategoryButton('All', 'Semua', Icons.apps),
                          const SizedBox(width: 10),
                          _buildCategoryButton(
                            'Pantai',
                            'Pantai',
                            Icons.beach_access,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryButton(
                            'Gunung',
                            'Gunung',
                            Icons.terrain,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryButton(
                            'Kuliner',
                            'Kuliner',
                            Icons.restaurant,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryButton(
                            'Budaya',
                            'Budaya',
                            Icons.museum,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Destinasi Terbaik Section
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Destinasi Terbaik',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to search/see all
                            // DefaultTabController.of(context).animateTo(1);
                          },
                          child: const Text(
                            'Lihat Semua',
                            style: TextStyle(
                              color: AppTheme.primaryOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Wisata List
          Consumer<WisataProvider>(
            builder: (context, wisataProvider, _) {
              if (wisataProvider.isLoading) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (wisataProvider.errorMessage != null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.accentRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          wisataProvider.errorMessage!,
                          style: const TextStyle(color: AppTheme.accentRed),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (wisataProvider.filteredWisata.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.explore_off,
                          size: 64,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada destinasi wisata',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final wisata = wisataProvider.filteredWisata[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WisataCard(wisata: wisata, index: index),
                      );
                    }, childCount: wisataProvider.filteredWisata.length),
                  ),
                ),
              );
            },
          ),

          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(String label, String value, IconData icon) {
    final isSelected = _selectedCategory == value;
    return GestureDetector(
      onTap: () => _onCategorySelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          color: isSelected ? null : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryOrange.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppTheme.primaryOrange,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  // Return an icon widget based on a simple condition string match.
  Widget _buildWeatherIcon(String condition) {
    final c = condition.toLowerCase();
    IconData icon = Icons.wb_sunny;

    if (c.contains('rain') || c.contains('hujan') || c.contains('rintik') || c.contains('drizzle')) {
      icon = Icons.beach_access; // umbrella-like
    } else if (c.contains('cloud') || c.contains('awan') || c.contains('cloudy')) {
      icon = Icons.cloud;
    } else if (c.contains('thunder') || c.contains('petir') || c.contains('badai')) {
      icon = Icons.flash_on;
    } else if (c.contains('snow') || c.contains('salju')) {
      icon = Icons.ac_unit;
    } else if (c.contains('fog') || c.contains('kabut') || c.contains('mist')) {
      icon = Icons.blur_on;
    }

    return Icon(icon, size: 48, color: Colors.white);
  }
