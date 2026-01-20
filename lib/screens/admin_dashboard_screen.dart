import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/wisata_provider.dart';
import '../providers/pesanan_provider.dart';
import 'admin_form_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.supabase.auth.currentSession?.accessToken;
    if (token != null) {
      await Future.wait([
        context.read<WisataProvider>().loadWisata(clearFilters: true),
        context.read<PesananProvider>().loadAllPesanan(token),
      ]);
    }
  }

  Future<void> _deleteWisata(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Wisata'),
        content: const Text('Apakah Anda yakin ingin menghapus wisata ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final token = context
          .read<AuthProvider>()
          .supabase
          .auth
          .currentSession
          ?.accessToken;
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
        return;
      }

      final success = await context.read<WisataProvider>().deleteWisata(
        id,
        token,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Wisata berhasil dihapus' : 'Gagal menghapus wisata',
            ),
            backgroundColor: success
                ? AppTheme.accentGreen
                : AppTheme.accentRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAdmin) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Akses ditolak. Hanya admin yang dapat mengakses halaman ini.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              authProvider.currentProfile?.namaLengkap ?? 'Admin',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryBlue),
            onPressed: _loadData,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.textPrimary),
            itemBuilder: (context) => <PopupMenuEntry>[
              PopupMenuItem(
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                child: const Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppTheme.accentRed),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppTheme.accentRed)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.place), text: 'Wisata'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Pesanan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDashboardTab(), _buildWisataTab(), _buildPesananTab()],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminFormScreen(),
                  ),
                ).then((_) => _loadData());
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Wisata'),
              backgroundColor: AppTheme.primaryBlue,
            )
          : null,
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer2<WisataProvider, PesananProvider>(
        builder: (context, wisataProvider, pesananProvider, _) {
          final totalWisata = wisataProvider.allWisata.length;
          final totalPesanan = pesananProvider.totalPesanan;
          final confirmedCount = pesananProvider.confirmedCount;
          final totalPendapatan = pesananProvider.totalPendapatan;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Wisata',
                        totalWisata.toString(),
                        Icons.place,
                        AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Sedang Diproses',
                        confirmedCount.toString(),
                        Icons.receipt_long,
                        AppTheme.accentBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Pesanan',
                        totalPesanan.toString(),
                        Icons.shopping_bag,
                        AppTheme.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Pendapatan',
                        'Rp ${NumberFormat.compact(locale: 'id_ID').format(totalPendapatan)}',
                        Icons.attach_money,
                        AppTheme.accentGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickAction(
                        'Tambah Wisata',
                        Icons.add_location,
                        AppTheme.primaryBlue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AdminFormScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickAction(
                        'Lihat Pesanan',
                        Icons.receipt_long,
                        AppTheme.primaryBlue,
                        () {
                          _tabController.animateTo(2);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWisataTab() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: Consumer<WisataProvider>(
        builder: (context, wisataProvider, _) {
          if (wisataProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wisataProvider.errorMessage != null) {
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
            );
          }

          if (wisataProvider.filteredWisata.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_location_alt_outlined,
                    size: 80,
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada data wisata',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminFormScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Wisata'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wisataProvider.filteredWisata.length,
            itemBuilder: (context, index) {
              final wisata = wisataProvider.filteredWisata[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: Image.network(
                      wisata.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: AppTheme.backgroundColor,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    wisata.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        wisata.kategori,
                        style: const TextStyle(
                          color: AppTheme.primaryBlue,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            wisata.rating?.toString() ?? '-',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppTheme.primaryBlue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AdminFormScreen(wisata: wisata),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppTheme.accentRed,
                        ),
                        onPressed: () => wisata.id != null
                            ? _deleteWisata(wisata.id!)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPesananTab() {
    return Column(
      children: [
        // Filter Status
        Container(
          padding: const EdgeInsets.all(16),
          child: Consumer<PesananProvider>(
            builder: (context, pesananProvider, _) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Semua', pesananProvider),
                    const SizedBox(width: 8),
                    _buildFilterChip('confirmed', 'Diproses', pesananProvider),
                    const SizedBox(width: 8),
                    _buildFilterChip('completed', 'Selesai', pesananProvider),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      'cancelled',
                      'Dibatalkan',
                      pesananProvider,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
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
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.accentRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          pesananProvider.errorMessage!,
                          style: const TextStyle(color: AppTheme.accentRed),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                if (pesananProvider.allPesanan.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada pesanan',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: pesananProvider.allPesanan.length,
                  itemBuilder: (context, index) {
                    final pesanan = pesananProvider.allPesanan[index];
                    return _buildPesananCard(pesanan);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    PesananProvider provider,
  ) {
    final isSelected = provider.filterStatus == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        provider.setFilterStatus(value);
      },
      selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.2),
      checkmarkColor: AppTheme.primaryBlue,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPesananCard(pesanan) {
    Color statusColor;
    IconData statusIcon;

    switch (pesanan.status) {
      case 'confirmed':
        statusColor = AppTheme.accentBlue;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = AppTheme.accentGreen;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        statusColor = AppTheme.accentRed;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: InkWell(
        onTap: () => _showPesananDetail(pesanan),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      pesanan.namaWisata,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          pesanan.statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    pesanan.namaPemesan,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                      'id_ID',
                    ).format(pesanan.tanggalKunjungan),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.confirmation_number,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${pesanan.jumlahTiket} tiket',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(pesanan.totalHarga),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  if (pesanan.status == 'confirmed')
                    TextButton.icon(
                      onPressed: () => _updateStatus(pesanan.id!, 'completed'),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Selesai'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.supabase.auth.currentSession?.accessToken;
    if (token == null) return;

    final success = await context.read<PesananProvider>().updateStatus(
      id,
      status,
      token,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status pesanan berhasil diupdate'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal update status pesanan'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  Future<void> _deletePesanan(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pesanan'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pesanan ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.accentRed),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.supabase.auth.currentSession?.accessToken;
    if (token == null) return;

    final success = await context.read<PesananProvider>().deletePesanan(
      id,
      token,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dihapus'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
      await _loadData(); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus pesanan'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  void _showPesananDetail(pesanan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailRow('Wisata', pesanan.namaWisata),
                    const Divider(height: 32),
                    _buildDetailRow('Nama Pemesan', pesanan.namaPemesan),
                    const Divider(height: 32),
                    _buildDetailRow('Email', pesanan.email),
                    const Divider(height: 32),
                    _buildDetailRow('No. HP', pesanan.noHp),
                    const Divider(height: 32),
                    _buildDetailRow(
                      'Tanggal Kunjungan',
                      DateFormat(
                        'dd MMMM yyyy',
                        'id_ID',
                      ).format(pesanan.tanggalKunjungan),
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                      'Jumlah Tiket',
                      '${pesanan.jumlahTiket} tiket',
                    ),
                    const Divider(height: 32),
                    _buildDetailRow(
                      'Total Harga',
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(pesanan.totalHarga),
                    ),
                    const Divider(height: 32),
                    _buildDetailRow('Status', pesanan.statusText),
                    const SizedBox(height: 32),
                    if (pesanan.status == 'confirmed')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _updateStatus(pesanan.id!, 'completed');
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Tandai Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Delete button untuk semua status
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _deletePesanan(pesanan.id!);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Hapus Pesanan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentRed,
                        side: const BorderSide(color: AppTheme.accentRed),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
