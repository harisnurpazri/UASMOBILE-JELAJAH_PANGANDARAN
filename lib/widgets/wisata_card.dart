import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/network_image_with_placeholder.dart';
import 'package:animate_do/animate_do.dart';
// shimmer removed (no longer used)
import '../config/theme.dart';
import '../models/wisata_model.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../screens/detail_screen.dart';

class WisataCard extends StatefulWidget {
  final WisataModel wisata;
  final int index;

  const WisataCard({super.key, required this.wisata, this.index = 0});

  @override
  State<WisataCard> createState() => _WisataCardState();
}

class _WisataCardState extends State<WisataCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: 300 + (widget.index * 100)),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  DetailScreen(wisata: widget.wisata, index: widget.index),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    final tween = Tween(
                      begin: 0.0,
                      end: 1.0,
                    ).chain(CurveTween(curve: Curves.easeOut));
                    return FadeTransition(
                      opacity: animation.drive(tween),
                      child: child,
                    );
                  },
            ),
          );
        },
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.cardShadow,
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 200;
                final imageHeight = isCompact ? 120.0 : 180.0;
                final btnVerticalPadding = isCompact ? 8.0 : 10.0;
                final btnFontSize = isCompact ? 12.0 : 14.0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppTheme.radiusLarge),
                          ),
                          child: SizedBox(
                            height: imageHeight,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                NetworkImageWithPlaceholder(
                                  imageUrl: widget.wisata.imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: imageHeight,
                                  placeholderAsset: 'assets/images/banner.png',
                                ),
                                // Gradient overlay
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Category Badge dengan gradient orange
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryOrange.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.wisata.kategori,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                        // Favorite Button
                        if (widget.wisata.id != null)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Consumer2<WishlistProvider, AuthProvider>(
                              builder: (context, wishlistProvider, authProvider, _) {
                                final isInWishlist = wishlistProvider.isInWishlist(
                                  widget.wisata.id!,
                                );
                                final userId = authProvider.currentProfile?.id;

                                return GestureDetector(
                                  onTap: () async {
                                    if (userId == null) {
                                      // Show login required message
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Silakan login terlebih dahulu untuk menggunakan wishlist',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await wishlistProvider
                                        .toggleWishlist(
                                          userId,
                                          widget.wisata.id!,
                                          widget.wisata,
                                        );

                                    if (!success &&
                                        wishlistProvider.errorMessage != null) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            wishlistProvider.errorMessage!,
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      shape: BoxShape.circle,
                                      boxShadow: AppTheme.cardShadow,
                                    ),
                                    child: Icon(
                                      isInWishlist
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isInWishlist
                                          ? AppTheme.accentRed
                                          : AppTheme.textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Price badge (bottom-right on image)
                        if (widget.wisata.hargaTiket != null)
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryOrange.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Rp ${_formatPrice(widget.wisata.hargaTiket!)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                            ),
                          ),
                        // Compact overlay button for small cards (home grid)
                        if (isCompact)
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: SizedBox(
                              height: 32,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailScreen(wisata: widget.wisata, index: widget.index),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  'Lihat Detail',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Card Content
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            widget.wisata.nama,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Location with icon
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: AppTheme.primaryOrange,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  widget.wisata.lokasi,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Lihat Detail button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailScreen(wisata: widget.wisata, index: widget.index),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: btnVerticalPadding),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                              ),
                              child: Text(
                                'Lihat Detail',
                                style: TextStyle(fontSize: btnFontSize, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Rating and Price Row
                          Row(
                            children: [
                              // Rating dengan warna orange
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentAmber.withValues(
                                    alpha: 0.15,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: AppTheme.accentAmber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.wisata.rating?.toStringAsFixed(1) ??
                                          '4.0',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              // Price (hide if already shown on image)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
