import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/dummy_animations.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/pesanan_provider.dart';
import '../models/pesanan_model.dart';
import 'ticket_screen.dart';

class RiwayatBookingScreen extends StatefulWidget {
  const RiwayatBookingScreen({super.key});

  @override
  State<RiwayatBookingScreen> createState() => _RiwayatBookingScreenState();
}

class _RiwayatBookingScreenState extends State<RiwayatBookingScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    debugPrint('🚀 Starting _loadBookings...');

    final authProvider = context.read<AuthProvider>();
    final pesananProvider = context.read<PesananProvider>();

    final userId = authProvider.currentProfile?.id;
    final token = authProvider.supabase.auth.currentSession?.accessToken;

    debugPrint('👤 User ID: $userId');
    debugPrint('🔑 Token exists: ${token != null}');

    if (userId != null && token != null) {
      try {
        debugPrint('📞 Calling loadUserPesanan...');
        await pesananProvider.loadUserPesanan(userId, token);
        debugPrint('✅ loadUserPesanan completed');
      } catch (e, stackTrace) {
        debugPrint('❌ Error in _loadBookings: $e');
        debugPrint('📍 Stack trace: $stackTrace');
      }
    } else {
      debugPrint('⚠️ userId or token is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Booking'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Status
          _buildFilterChips(),
          
          // Booking List
          Expanded(
            child: Consumer<PesananProvider>(
              builder: (context, pesananProvider, _) {
                if (pesananProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (pesananProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'Gagal memuat data',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          pesananProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadBookings,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final bookings = _getFilteredBookings(pesananProvider.userPesanan);

                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _filterStatus == 'all'
                              ? 'Belum ada booking'
                              : 'Tidak ada booking $_filterStatus',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return FadeInUp(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        child: _buildBookingCard(bookings[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Semua', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Sedang Diproses', 'confirmed'),
            const SizedBox(width: 8),
            _buildFilterChip('Selesai', 'completed'),
            const SizedBox(width: 8),
            _buildFilterChip('Dibatalkan', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = status;
        });
      },
      selectedColor: AppTheme.primaryTeal.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryTeal,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryTeal : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  List<PesananModel> _getFilteredBookings(List<PesananModel>? bookings) {
    try {
      if (bookings == null) return [];
      if (_filterStatus == 'all') return bookings;
      return bookings.where((b) => b.status == _filterStatus).toList();
    } catch (e) {
      debugPrint('Error filtering bookings: $e');
      return [];
    }
  }

  // (Removed unused safe-format helpers; code uses intl directly where needed)

  Widget _buildBookingCard(PesananModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBookingDetail(booking),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.namaWisata,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(booking.status),
                ],
              ),
              const SizedBox(height: 12),
              
              // Booking Info
              _buildInfoRow(
                Icons.calendar_today,
                'Tanggal Kunjungan',
                DateFormat('dd MMMM yyyy', 'id_ID').format(booking.tanggalKunjungan),
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.confirmation_number,
                'Jumlah Tiket',
                '${booking.jumlahTiket} tiket',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.person,
                'Nama Pemesan',
                booking.namaPemesan,
              ),
              
              const Divider(height: 24),
              
              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${NumberFormat('#,###', 'id_ID').format(booking.totalHarga)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                    ],
                  ),
                  if (booking.createdAt != null)
                    Text(
                      DateFormat('dd/MM/yyyy').format(booking.createdAt!),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
              
              // Show ticket button for completed bookings
              if (booking.status == 'completed' && booking.kodeBooking != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketScreen(pesanan: booking),
                        ),
                      );
                    },
                    icon: const Icon(Icons.confirmation_number, size: 18),
                    label: const Text(
                      'Lihat Tiket',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'confirmed':
        backgroundColor = Colors.blue.withValues(alpha: 0.2);
        textColor = Colors.blue;
        label = 'Sedang Diproses';
        break;
      case 'completed':
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green;
        label = 'Selesai';
        break;
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red;
        label = 'Dibatalkan';
        break;
      default:
        backgroundColor = Colors.grey.withValues(alpha: 0.2);
        textColor = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _showBookingDetail(PesananModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Booking',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusBadge(booking.status),
                ],
              ),
              const SizedBox(height: 24),
              
              // Booking Details
              _buildDetailRow('Destinasi', booking.namaWisata),
              const Divider(height: 24),
              _buildDetailRow('Nama Pemesan', booking.namaPemesan),
              const Divider(height: 24),
              _buildDetailRow('Email', booking.email),
              const Divider(height: 24),
              _buildDetailRow('No. HP', booking.noHp),
              const Divider(height: 24),
              _buildDetailRow(
                'Tanggal Kunjungan',
                DateFormat('dd MMMM yyyy', 'id_ID').format(booking.tanggalKunjungan),
              ),
              const Divider(height: 24),
              _buildDetailRow('Jumlah Tiket', '${booking.jumlahTiket} tiket'),
              const Divider(height: 24),
              _buildDetailRow(
                'Total Pembayaran',
                'Rp ${NumberFormat('#,###', 'id_ID').format(booking.totalHarga)}',
              ),
              if (booking.createdAt != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'Tanggal Booking',
                  DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(booking.createdAt!),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
