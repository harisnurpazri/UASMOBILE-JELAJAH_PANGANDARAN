import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
// CachedNetworkImage is used via `NetworkImageWithPlaceholder` widget.
// Direct import removed to satisfy analyzer (unused import).
import '../widgets/network_image_with_placeholder.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wisata_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/wishlist_provider.dart';
import 'detail_screen_new.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final wisataProvider = context.read<WisataProvider>();
      final weatherProvider = context.read<WeatherProvider>();
      final wishlistProvider = context.read<WishlistProvider>();

      // Load data with error handling
      await Future.wait([
        authProvider.loadProfile().catchError((e) {
          debugPrint('Error loading profile: $e');
          return null;
        }),
        wisataProvider.loadWisata(clearFilters: true).catchError((e) {
          debugPrint('Error loading wisata: $e');
          return null;
        }),
        weatherProvider.loadCurrentLocationWeather().catchError((e) {
          debugPrint('Error loading weather: $e');
          return null;
        }),
      ]);

      // Load wishlist if user is logged in
      if (authProvider.currentProfile != null) {
        await wishlistProvider
            .loadWishlist(authProvider.currentProfile!.id!)
            .catchError((e) {
              debugPrint('Error loading wishlist: $e');
              return null;
            });
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return 'Gratis';
    final value = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return value.toString().replaceAllMapped(
      RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
      (Match m) => '${m[1]}.' ,
    );
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
      _searchQuery = ''; // Reset search when category changes
      _searchController.clear();
    });
    if (category == 'Semua') {
      // Clear filter untuk menampilkan semua wisata
      context.read<WisataProvider>().filterByCategory(null);
    } else {
      context.read<WisataProvider>().filterByCategory(category);
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _showPremiumDestinations(BuildContext context) {
    // Filter destinasi dengan harga > 100rb
    final wisataProvider = context.read<WisataProvider>();
    final premiumWisata = wisataProvider.filteredWisata.where((wisata) {
      return wisata.hargaTiket != null && wisata.hargaTiket! > 100000;
    }).toList();

    if (premiumWisata.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada destinasi premium tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Tampilkan dialog dengan list destinasi premium
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Destinasi Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Destinasi dengan harga di atas Rp 100.000',
                style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: premiumWisata.length,
                  itemBuilder: (ctx, index) {
                    final wisata = premiumWisata[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: NetworkImageWithPlaceholder(
                            imageUrl: wisata.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            placeholderAsset: 'assets/images/banner.png',
                          ),
                        ),
                        title: Text(
                          wisata.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Rp ${_formatPrice(wisata.hargaTiket)}',
                          style: const TextStyle(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreenNew(wisata: wisata),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  List<dynamic> _getFilteredWisata(WisataProvider wisataProvider) {
    var wisataList = wisataProvider.filteredWisata;

    if (_searchQuery.isNotEmpty) {
      wisataList = wisataList.where((wisata) {
        return wisata.nama.toLowerCase().contains(_searchQuery) ||
            wisata.lokasi.toLowerCase().contains(_searchQuery) ||
            wisata.deskripsi.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    return wisataList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppTheme.primaryTeal,
        child: CustomScrollView(
          slivers: [
            // Header dengan lokasi dan avatar
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      children: [
                        // Top bar dengan lokasi dan avatar
                        FadeInDown(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: AppTheme.accentOrange,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Indonesia, Pangandaran',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Mau kemana\nhari ini?',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                              // Removed profile initial box; use a compact action icon
                              Container(
                                width: 44,
                                height: 44,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.person_outline,
                                    color: AppTheme.accentOrange,
                                  ),
                                  onPressed: () {
                                    // Open profile / menu later
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Banner card: gunakan assets/images/banner.png sebagai background,
                        // dan satukan kolom pencarian + ringkasan cuaca di dalam satu overlay.
                        FadeInUp(
                          delay: const Duration(milliseconds: 100),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 220,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/images/banner.png'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      // slightly darker overlay to improve contrast
                                      Colors.black.withValues(alpha: 0.48),
                                      Colors.black.withValues(alpha: 0.08),
                                    ],
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                        // Top row: lokasi + avatar
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Add a small dark pill behind the location to
                                        // guarantee legibility on bright banner images.
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.36),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Indonesia, Pangandaran',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                      color: Colors.black45,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Replace profile initial with a compact action icon
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(
                                              Icons.person_outline,
                                              color: AppTheme.accentOrange,
                                            ),
                                            onPressed: () {
                                              // placeholder for profile action
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Search field (di dalam banner) — elevated, rounded, modern
                                    Material(
                                      elevation: 6,
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white.withValues(alpha: 0.96),
                                      child: TextField(
                                        controller: _searchController,
                                        onChanged: _onSearchChanged,
                                        decoration: InputDecoration(
                                          hintText: 'Cari destinasi wisata...',
                                          hintStyle: TextStyle(color: Colors.grey[600]),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.only(left: 12, right: 8),
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [AppTheme.primaryTeal, AppTheme.accentOrange],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppTheme.primaryTeal.withValues(alpha: 0.18),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.search_rounded, color: Colors.white),
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryOrange,
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.primaryOrange.withValues(alpha: 0.30),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Weather summary (di banner)
                                    ConstrainedBox(
                                      // keep a reasonable max so the summary doesn't grow too large
                                      constraints: const BoxConstraints(maxHeight: 44),
                                      child: Consumer<WeatherProvider>(
                                        builder: (context, weatherProvider, _) {
                                          final temp = weatherProvider.temperatureCelsius;
                                          final condition = weatherProvider.description;
                                          final location = weatherProvider.currentWeather?.cityName ?? '';

                                          // Use LayoutBuilder to adapt font/icon sizes based on the
                                          // actual allocated height (prevents overflow on very
                                          // tight layouts such as 32-40 px).
                                          return LayoutBuilder(
                                            builder: (context, constraints) {
                                              final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 44.0;
                                              // Choose compact sizes when height is small
                                              final small = h < 40.0;
                                              final verticalPadding = small ? 2.0 : 4.0;
                                              final tempFont = small ? 14.0 : 16.0;
                                              final iconFont = small ? 20.0 : 24.0;
                                              final iconBoxSize = small ? 36.0 : 40.0;

                                              return ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: verticalPadding + 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.12),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withValues(alpha: 0.14),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 4),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '${location.isNotEmpty ? location : 'Lokasi'} • $temp • $condition',
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: tempFont + 1,
                                                              fontWeight: FontWeight.w700,
                                                              shadows: const [
                                                                Shadow(
                                                                  offset: Offset(0, 1),
                                                                  blurRadius: 4,
                                                                  color: Colors.black45,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        Container(
                                                          width: iconBoxSize,
                                                          height: iconBoxSize,
                                                          decoration: BoxDecoration(
                                                            gradient: const LinearGradient(
                                                              colors: [
                                                                AppTheme.primaryTeal,
                                                                AppTheme.accentOrange,
                                                              ],
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                            ),
                                                            borderRadius: BorderRadius.circular(12),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withValues(alpha: 0.18),
                                                                blurRadius: 6,
                                                                offset: const Offset(0, 4),
                                                              ),
                                                            ],
                                                          ),
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            weatherProvider.currentWeather?.weatherIcon ?? '☀️',
                                                            style: TextStyle(fontSize: iconFont, color: Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Promotions banner
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Promo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Filter by category pantai untuk melihat semua pantai
                                      _onCategorySelected('Pantai');
                                      // Scroll to destinations
                                    },
                                    child: const Text(
                                      'Lihat semua',
                                      style: TextStyle(
                                        color: AppTheme.accentOrange,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Show promo dialog untuk klaim kupon
                                        _showPromoDialog(
                                          context,
                                          'Diskon 20% Destinasi Premium',
                                          'Dapatkan diskon 20% untuk destinasi wisata premium!\n\nSyarat & Ketentuan:\n• Berlaku untuk destinasi dengan harga minimal Rp 100.000\n• Diskon berlaku untuk 1x pemesanan\n• Promo berlaku hingga akhir bulan\n• Tidak dapat digabung dengan promo lain\n\nGunakan kode kupon saat checkout untuk mendapatkan diskon.',
                                          'PROMO20',
                                          const Color(0xFF4A90E2),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.10),
                                              blurRadius: 10,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Diskon 20%\nDestinasi Premium',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.2,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _showPromoDialog(
                                                        context,
                                                        'Diskon 20% Destinasi Premium',
                                                        'Dapatkan diskon 20% untuk destinasi wisata premium!\n\nSyarat & Ketentuan:\n• Berlaku untuk destinasi dengan harga minimal Rp 100.000\n• Diskon berlaku untuk 1x pemesanan\n• Promo berlaku hingga akhir bulan\n• Tidak dapat digabung dengan promo lain\n\nGunakan kode kupon saat checkout untuk mendapatkan diskon.',
                                                        'PROMO20',
                                                        const Color(0xFF4A90E2),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          'Ambil Kupon',
                                                          style: TextStyle(
                                                            color: Color(0xFF357ABD),
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(Icons.local_offer, color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Filter destinasi premium
                                        _showPremiumDestinations(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF2C3E50), Color(0xFF1A252F)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.10),
                                              blurRadius: 10,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Destinasi Premium\nDi Atas 100rb',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.2,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      _showPremiumDestinations(context);
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: const Center(
                                                        child: Text(
                                                          'Lihat Destinasi',
                                                          style: TextStyle(
                                                            color: Color(0xFF1A252F),
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white24,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: const Icon(Icons.shield_moon, color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Category horizontal scroll
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kategori',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildCategoryChip('Semua', '🌏'),
                                    _buildCategoryChip('Pantai', '🏖️'),
                                    _buildCategoryChip('Alam', '🌳'),
                                    _buildCategoryChip('Wahana', '🎢'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Destinasi grid
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
              sliver: Consumer<WisataProvider>(
                builder: (context, wisataProvider, _) {
                  if (wisataProvider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final filteredWisata = _getFilteredWisata(wisataProvider);

                  if (filteredWisata.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isNotEmpty
                                  ? Icons.search_off
                                  : Icons.explore_off,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                                  : 'Tidak ada destinasi',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Show count of destinations
                  return SliverMainAxisGroup(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            '${filteredWisata.length} Destinasi',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final wisata = filteredWisata[index];
                            return FadeInUp(
                              delay: Duration(milliseconds: 100 * (index % 4)),
                              child: Consumer<WishlistProvider>(
                                builder: (context, wishlistProvider, _) {
                                  final isInWishlist = wishlistProvider.isInWishlist(wisata.id);

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreenNew(wisata: wisata, index: index),
                                        ),
                                      );
                                    },
                                    child: LayoutBuilder(
                                      builder: (context, itemConstraints) {
                                        final itemWidth = itemConstraints.maxWidth;
                                        final imageHeight = (itemWidth * 0.55).clamp(64.0, 220.0);

                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.08),
                                                blurRadius: 16,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Image area
                                              ClipRRect(
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(24),
                                                  topRight: Radius.circular(24),
                                                ),
                                                child: SizedBox(
                                                  height: imageHeight,
                                                  width: double.infinity,
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      NetworkImageWithPlaceholder(
                                                        imageUrl: wisata.imageUrl,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: imageHeight,
                                                        placeholderAsset: 'assets/images/banner.png',
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter,
                                                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1)],
                                                          ),
                                                        ),
                                                      ),
                                                      // Category badge
                                                      Positioned(
                                                        top: 10,
                                                        left: 10,
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(colors: [AppTheme.primaryTeal, AppTheme.primaryTeal.withValues(alpha: 0.8)]),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Text(wisata.kategori, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                                                        ),
                                                      ),
                                                      // Wishlist button
                                                      if (wisata.id != null)
                                                        Positioned(
                                                          top: 10,
                                                          right: 10,
                                                          child: GestureDetector(
                                                            onTap: () async {
                                                              final authProvider = context.read<AuthProvider>();
                                                              if (authProvider.currentProfile == null) {
                                                                if (!mounted) return;
                                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login untuk menambahkan ke wishlist'), backgroundColor: AppTheme.accentRed));
                                                                return;
                                                              }

                                                              final success = await wishlistProvider.toggleWishlist(authProvider.currentProfile!.id!, wisata.id!, wisata);
                                                              if (!success && wishlistProvider.errorMessage != null) {
                                                                if (!context.mounted) return;
                                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(wishlistProvider.errorMessage!)));
                                                              }
                                                            },
                                                            child: Container(
                                                              padding: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
                                                              child: Icon(isInWishlist ? Icons.favorite : Icons.favorite_border, color: isInWishlist ? AppTheme.accentRed : AppTheme.textSecondary, size: 20),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Content
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(wisata.nama, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                                    const SizedBox(height: 4),
                                                    Row(children: [const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.primaryOrange), const SizedBox(width: 4), Expanded(child: Text(wisata.lokasi, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)))]),
                                                    const SizedBox(height: 8),
                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)), child: Row(children: const [Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFA726)), SizedBox(width: 4), Text('4.8', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFFFA726)))])), Text(wisata.hargaTiket != null ? 'Rp ${_formatPrice(wisata.hargaTiket)}' : 'Gratis', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primaryTeal))]),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: filteredWisata.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPromoDialog(
    BuildContext context,
    String title,
    String description,
    String promoCode,
    Color themeColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon promo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_offer_rounded,
                  size: 48,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),

              // Promo code box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: themeColor.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kode Promo',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promoCode,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // Copy to clipboard
                        Clipboard.setData(ClipboardData(text: promoCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Kode promo "$promoCode" berhasil disalin!',
                            ),
                            backgroundColor: AppTheme.primaryTeal,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.copy_rounded, color: themeColor),
                      tooltip: 'Salin kode',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Button Tutup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String emoji) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _onCategorySelected(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.accentOrange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentOrange
                  : Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
