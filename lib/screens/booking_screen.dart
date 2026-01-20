import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/wisata_model.dart';
import '../models/pesanan_model.dart';
import '../providers/auth_provider.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final WisataModel wisata;

  const BookingScreen({super.key, required this.wisata});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaPemesanController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _kuponController = TextEditingController();

  DateTime? _tanggalKunjungan;
  int _jumlahTiket = 1;
  final bool _isLoading = false;
  String? _appliedKupon;
  double _diskon = 0;

  // Daftar kupon yang valid
  final Map<String, Map<String, dynamic>> _validKupons = {
    'PROMO20': {'diskon': 0.20, 'minHarga': 100000, 'nama': 'Diskon 20%'},
  };

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().currentProfile;
    if (profile != null) {
      _namaPemesanController.text = profile.namaLengkap;
      _emailController.text = profile.email;
    }
  }

  @override
  void dispose() {
    _namaPemesanController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _kuponController.dispose();
    super.dispose();
  }

  // Getter harus return double
  double get _totalHarga {
    final hargaAwal = (widget.wisata.hargaTiket ?? 0) * _jumlahTiket;
    final potongan = hargaAwal * _diskon;
    return hargaAwal - potongan; // return double
  }

  void _applyKupon() {
    final kuponCode = _kuponController.text.trim().toUpperCase();

    if (kuponCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan kode kupon'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_validKupons.containsKey(kuponCode)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode kupon tidak valid'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final kupon = _validKupons[kuponCode]!;
    final hargaTiket = widget.wisata.hargaTiket ?? 0;

    if (hargaTiket < kupon['minHarga']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kupon hanya berlaku untuk destinasi dengan harga minimal Rp ${kupon['minHarga'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
          ),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    setState(() {
      _appliedKupon = kuponCode;
      _diskon = kupon['diskon'];
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${kupon['nama']} berhasil diterapkan!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeKupon() {
    setState(() {
      _appliedKupon = null;
      _diskon = 0;
      _kuponController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalKunjungan) {
      setState(() {
        _tanggalKunjungan = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tanggalKunjungan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal kunjungan'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated || authProvider.currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda harus login terlebih dahulu'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    // Create pesanan object to pass to payment screen
    final pesanan = PesananModel(
      userId: authProvider.currentProfile!.id ?? '',
      wisataId: widget.wisata.id!,
      namaWisata: widget.wisata.nama,
      namaPemesan: _namaPemesanController.text,
      email: _emailController.text,
      noHp: _noHpController.text,
      tanggalKunjungan: _tanggalKunjungan!,
      jumlahTiket: _jumlahTiket,
      totalHarga: _totalHarga.toDouble(),
      status: 'confirmed',
    );

    // Navigate to payment screen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PaymentScreen(pesanan: pesanan)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesan Tiket'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wisata Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      child: Image.network(
                        widget.wisata.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.backgroundColor,
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.wisata.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.wisata.kategori,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(widget.wisata.hargaTiket)} / orang',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              const Text(
                'Data Pemesan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _namaPemesanController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email harus diisi';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noHpController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'No. HP',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No. HP harus diisi';
                  }
                  if (value.length < 10) {
                    return 'No. HP minimal 10 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Detail Pemesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Tanggal Kunjungan
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _tanggalKunjungan == null
                                ? 'Pilih Tanggal Kunjungan'
                                : DateFormat(
                                    'dd MMMM yyyy',
                                    'id_ID',
                                  ).format(_tanggalKunjungan!),
                            style: TextStyle(
                              color: _tanggalKunjungan == null
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jumlah Tiket
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.confirmation_number,
                          color: AppTheme.primaryBlue,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Jumlah Tiket',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _jumlahTiket > 1
                              ? () => setState(() => _jumlahTiket--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.primaryBlue,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusSmall,
                            ),
                          ),
                          child: Text(
                            _jumlahTiket.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _jumlahTiket < 10
                              ? () => setState(() => _jumlahTiket++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppTheme.primaryBlue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kupon Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.card_giftcard,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Punya Kupon Diskon?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _kuponController,
                            enabled: _appliedKupon == null,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kode kupon',
                              hintStyle: const TextStyle(fontSize: 14),
                              prefixIcon: const Icon(Icons.discount, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _appliedKupon == null
                              ? _applyKupon
                              : _removeKupon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _appliedKupon == null
                                ? AppTheme.primaryBlue
                                : AppTheme.accentRed,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusSmall,
                              ),
                            ),
                          ),
                          child: Text(
                            _appliedKupon == null ? 'Pakai' : 'Hapus',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_appliedKupon != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusSmall,
                          ),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Kupon "$_appliedKupon" aktif - Diskon ${(_diskon * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    const Text(
                      'Kupon berlaku untuk destinasi dengan harga minimal Rp 100.000',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Total Harga
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  children: [
                    if (_diskon > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Harga Normal',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'id_ID',
                              symbol: 'Rp ',
                              decimalDigits: 0,
                            ).format(
                              (widget.wisata.hargaTiket ?? 0) * _jumlahTiket,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Diskon ${(_diskon * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '- ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format((widget.wisata.hargaTiket ?? 0) * _jumlahTiket * _diskon)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: 'id_ID',
                            symbol: 'Rp ',
                            decimalDigits: 0,
                          ).format(_totalHarga),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.radiusMedium,
                      ),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Konfirmasi Pemesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
}
