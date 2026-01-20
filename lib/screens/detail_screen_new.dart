import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/dummy_animations.dart';
import 'package:geolocator/geolocator.dart';
import '../config/theme.dart';
import '../models/wisata_model.dart';
import '../models/review_model.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/review_provider.dart';
import 'booking_screen.dart';
import 'image_gallery_screen.dart';

class DetailScreenNew extends StatefulWidget {
  final WisataModel wisata;
  final int? index;

  const DetailScreenNew({super.key, required this.wisata, this.index});

  @override
  State<DetailScreenNew> createState() => _DetailScreenNewState();
}

class _DetailScreenNewState extends State<DetailScreenNew> {
  String _activeTab = 'overview';

  @override
  void initState() {
    super.initState();
    // Load reviews when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.wisata.id != null) {
        context.read<ReviewProvider>().loadReviews(widget.wisata.id!);
      }
    });
  }

  Future<void> _openMaps() async {
    final lat = widget.wisata.latitude;
    final lng = widget.wisata.longitude;

    if (lat == null || lng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koordinat lokasi tidak tersedia'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
      return;
    }

    // Get current device location
    String origin = '';
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      origin = '${position.latitude},${position.longitude}';
    } catch (e) {
      debugPrint('Error getting location: $e');
      // If location fails, Google Maps will use device's last known location
    }

    // Build Google Maps URL with route from current location to destination
    final googleMapsUrl = origin.isNotEmpty
        ? Uri.parse(
            'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$lat,$lng&travelmode=driving',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
          );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _toggleWishlist() async {
    final authProvider = context.read<AuthProvider>();
    final wishlistProvider = context.read<WishlistProvider>();

    if (authProvider.currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap login terlebih dahulu')),
      );
      return;
    }

    final userId = authProvider.currentProfile!.id;
    if (userId == null) return;

    final wisataId = widget.wisata.id;
    if (wisataId == null) return;

    final isInWishlist = wishlistProvider.isInWishlist(wisataId);

    if (isInWishlist) {
      await wishlistProvider.removeFromWishlist(userId, wisataId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dihapus dari wishlist')));
      }
    } else {
      await wishlistProvider.addToWishlist(userId, wisataId, widget.wisata);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ditambahkan ke wishlist')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Main Image
                    Hero(
                      tag: 'wisata-${widget.wisata.id}-${widget.index ?? 0}',
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(widget.wisata.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                    // Gradient overlay
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),

                    // Back button
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FadeInLeft(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            FadeInRight(
                              child: Consumer<WishlistProvider>(
                                builder: (context, wishlistProvider, _) {
                                  final isInWishlist = wishlistProvider
                                      .isInWishlist(widget.wisata.id ?? 0);
                                  return GestureDetector(
                                    onTap: _toggleWishlist,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        isInWishlist
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isInWishlist
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Route button at bottom of image
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: GestureDetector(
                          onTap: _openMaps,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.navigation,
                                  size: 18,
                                  color: AppTheme.primaryBlue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Route',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          widget.wisata.nama,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info chips
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _buildInfoChip(
                              Icons.location_on,
                              widget.wisata.lokasi,
                              AppTheme.primaryBlue,
                            ),
                            _buildInfoChip(
                              Icons.access_time,
                              '24 hours', // You can add this to your model
                              AppTheme.primaryBlue,
                            ),
                            _buildInfoChip(
                              Icons.thermostat,
                              '29°C', // You can add weather data
                              AppTheme.primaryBlue,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tabs
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildTabButton('overview', 'Overview'),
                              _buildTabButton('detail', 'Detail'),
                              _buildTabButton('reviews', 'Reviews'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tab content
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildTabContent(),
                      ),

                      const SizedBox(height: 24),

                      // Photos section
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Photos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (int i = 0; i < 4; i++)
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ImageGalleryScreen(
                                                  imageUrls: [
                                                    widget.wisata.imageUrl,
                                                  ],
                                                  initialIndex: 0,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              widget.wisata.imageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '+12',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom booking bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            'Rp ${widget.wisata.hargaTiket?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingScreen(wisata: widget.wisata),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxWidth: 200),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String value, String label) {
    final isActive = _activeTab == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeTab = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppTheme.primaryBlue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'overview':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.wisata.deskripsi,
              style: const TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.6,
              ),
            ),
          ],
        );
      case 'detail':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('Kategori', widget.wisata.kategori),
            _buildDetailItem('Lokasi', widget.wisata.lokasi),
            _buildDetailItem(
              'Harga Tiket',
              'Rp ${widget.wisata.hargaTiket?.toStringAsFixed(0) ?? '0'}',
            ),
            _buildDetailItem(
              'Jam Buka',
              widget.wisata.jamBuka ?? 'Tidak tersedia',
            ),
          ],
        );
      case 'reviews':
        return Consumer<ReviewProvider>(
          builder: (context, reviewProvider, _) {
            if (reviewProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = reviewProvider.reviews;
            final authProvider = context.read<AuthProvider>();
            final userId = authProvider.currentProfile?.id;
            final hasReviewed =
                userId != null &&
                widget.wisata.id != null &&
                reviewProvider.hasUserReviewed(userId, widget.wisata.id!);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add Review Button (only if not reviewed yet)
                if (!hasReviewed && userId != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddReviewDialog(context),
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Tulis Review'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Reviews List
                if (reviews.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada review',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...reviews.map((review) {
                    final isOwnReview = userId == review.userId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildReviewItem(
                        review.namaUser,
                        review.rating,
                        review.comment,
                        review.getRelativeTime(),
                        isOwnReview: isOwnReview,
                        onEdit: isOwnReview && review.id != null
                            ? () => _showEditReviewDialog(context, review)
                            : null,
                        onDelete: isOwnReview && review.id != null
                            ? () => _confirmDeleteReview(context, review.id!)
                            : null,
                      ),
                    );
                  }),
              ],
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
    String name,
    int rating,
    String comment,
    String time, {
    bool isOwnReview = false,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isOwnReview
            ? Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isOwnReview) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Anda',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFFA726),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isOwnReview) ...[
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }

  // Show dialog to add new review
  void _showAddReviewDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap login terlebih dahulu')),
      );
      return;
    }

    // Pre-check if user already reviewed
    final reviewProvider = context.read<ReviewProvider>();
    final userId = authProvider.currentProfile!.id!;
    if (reviewProvider.hasUserReviewed(userId, widget.wisata.id!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda sudah memberikan review untuk destinasi ini'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tulis Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rating:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFA726),
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Komentar:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis review Anda...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Komentar tidak boleh kosong'),
                    ),
                  );
                  return;
                }

                final reviewProvider = context.read<ReviewProvider>();
                final success = await reviewProvider.addReview(
                  wisataId: widget.wisata.id!,
                  userId: authProvider.currentProfile!.id!,
                  namaUser: authProvider.currentProfile!.namaLengkap,
                  rating: rating,
                  comment: commentController.text.trim(),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);

                  // Show error message from provider if failed
                  final errorMsg = success
                      ? 'Review berhasil ditambahkan'
                      : reviewProvider.error ?? 'Gagal menambahkan review';

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: success
                          ? Colors.green
                          : AppTheme.accentRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Kirim'),
            ),
          ],
        ),
      ),
    );
  }

  // Show dialog to edit existing review
  void _showEditReviewDialog(BuildContext context, ReviewModel review) {
    int rating = review.rating;
    final commentController = TextEditingController(text: review.comment);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rating:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFA726),
                      size: 32,
                    ),
                    onPressed: () => setState(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Komentar:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tulis review Anda...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Komentar tidak boleh kosong'),
                    ),
                  );
                  return;
                }

                final reviewProvider = context.read<ReviewProvider>();
                final success = await reviewProvider.updateReview(
                  reviewId: review.id!,
                  rating: rating,
                  comment: commentController.text.trim(),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Review berhasil diupdate'
                            : 'Gagal mengupdate review',
                      ),
                      backgroundColor: success
                          ? Colors.green
                          : AppTheme.accentRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  // Confirm before deleting review
  void _confirmDeleteReview(BuildContext context, int reviewId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Review'),
        content: const Text('Apakah Anda yakin ingin menghapus review ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final reviewProvider = context.read<ReviewProvider>();
              final success = await reviewProvider.deleteReview(reviewId);

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Review berhasil dihapus'
                          : 'Gagal menghapus review',
                    ),
                    backgroundColor: success
                        ? Colors.green
                        : AppTheme.accentRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
