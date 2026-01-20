import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/wisata_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlist();
    });
  }

  Future<void> _loadWishlist() async {
    final userId = context.read<AuthProvider>().currentProfile?.id;
    if (userId != null) {
      await context.read<WishlistProvider>().loadWishlist(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadWishlist,
        child: Consumer<WishlistProvider>(
          builder: (context, wishlistProvider, _) {
            if (wishlistProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (wishlistProvider.errorMessage != null) {
              return Center(
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
                      wishlistProvider.errorMessage!,
                      style: const TextStyle(color: AppTheme.accentRed),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadWishlist,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            if (wishlistProvider.wishlistWisata.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 80,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada wishlist',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tambahkan destinasi favorit Anda',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistProvider.wishlistWisata.length,
              itemBuilder: (context, index) {
                final wisata = wishlistProvider.wishlistWisata[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: WisataCard(wisata: wisata, index: index),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
