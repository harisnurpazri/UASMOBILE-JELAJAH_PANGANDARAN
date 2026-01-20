import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../models/wisata_model.dart';
import '../providers/wisata_provider.dart';
import '../providers/auth_provider.dart';

class AdminFormScreen extends StatefulWidget {
  final WisataModel? wisata;

  const AdminFormScreen({super.key, this.wisata});

  @override
  State<AdminFormScreen> createState() => _AdminFormScreenState();
}

class _AdminFormScreenState extends State<AdminFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _jamBukaController = TextEditingController();
  final _jamTutupController = TextEditingController();
  final _hargaTiketController = TextEditingController();

  String _selectedCategory = 'Pantai';
  double _rating = 4.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.wisata != null) {
      _namaController.text = widget.wisata!.nama;
      _deskripsiController.text = widget.wisata!.deskripsi;
      _lokasiController.text = widget.wisata!.lokasi;
      _latitudeController.text = widget.wisata!.latitude?.toString() ?? '';
      _longitudeController.text = widget.wisata!.longitude?.toString() ?? '';
      _imageUrlController.text = widget.wisata!.imageUrl;
      _jamBukaController.text = widget.wisata!.jamBuka ?? '';
      _jamTutupController.text = widget.wisata!.jamTutup ?? '';
      _hargaTiketController.text = widget.wisata!.hargaTiket?.toString() ?? '0';
      _selectedCategory = widget.wisata!.kategori;
      _rating = widget.wisata!.rating ?? 4.0;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    _jamBukaController.dispose();
    _jamTutupController.dispose();
    _hargaTiketController.dispose();
    super.dispose();
  }

  Future<void> _saveWisata() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = context
        .read<AuthProvider>()
        .supabase
        .auth
        .currentSession
        ?.accessToken;
    if (token == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
      return;
    }

    final wisata = WisataModel(
      id: widget.wisata?.id,
      nama: _namaController.text,
      deskripsi: _deskripsiController.text,
      kategori: _selectedCategory,
      lokasi: _lokasiController.text,
      latitude: _latitudeController.text.isNotEmpty
          ? double.tryParse(_latitudeController.text)
          : null,
      longitude: _longitudeController.text.isNotEmpty
          ? double.tryParse(_longitudeController.text)
          : null,
      imageUrl: _imageUrlController.text,
      rating: _rating,
      jamBuka: _jamBukaController.text,
      jamTutup: _jamTutupController.text,
      hargaTiket: int.tryParse(_hargaTiketController.text) ?? 0,
      createdAt: widget.wisata?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      bool success;
      if (widget.wisata == null) {
        success = await context.read<WisataProvider>().createWisata(
          wisata,
          token,
        );
      } else {
        success = await context.read<WisataProvider>().updateWisata(
          wisata.id!,
          wisata,
          token,
        );
      }

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.wisata == null
                    ? 'Wisata berhasil ditambahkan'
                    : 'Wisata berhasil diperbarui',
              ),
              backgroundColor: AppTheme.accentGreen,
            ),
          );
          Navigator.pop(context);
        } else {
          final errorMsg =
              context.read<WisataProvider>().errorMessage ?? 'Gagal menyimpan';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppTheme.accentRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppTheme.accentRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wisata == null ? 'Tambah Wisata' : 'Edit Wisata'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Wisata',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama wisata harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _deskripsiController,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              items: AppConstants.adminWisataCategories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Kategori harus dipilih';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _lokasiController,
              decoration: InputDecoration(
                labelText: 'Lokasi',
                hintText: 'Contoh: Jl. Merdeka No. 123, Pangandaran',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lokasi harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Latitude & Longitude
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      hintText: '-7.6839',
                      prefixIcon: const Icon(Icons.my_location, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Latitude: -90 s/d 90';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      hintText: '108.6500',
                      prefixIcon: const Icon(Icons.location_on, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) {
                          return 'Longitude: -180 s/d 180';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Cari koordinat di Google Maps → klik kanan lokasi → pilih koordinat untuk copy',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // URL Gambar
            TextFormField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'URL Gambar',
                hintText: 'https://example.com/image.jpg',
                prefixIcon: const Icon(Icons.image),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'URL gambar harus diisi';
                }
                if (!value.startsWith('http://') &&
                    !value.startsWith('https://')) {
                  return 'URL harus dimulai dengan http:// atau https://';
                }
                return null;
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 8),

            // Preview gambar
            if (_imageUrlController.text.isNotEmpty &&
                (_imageUrlController.text.startsWith('http://') ||
                    _imageUrlController.text.startsWith('https://')))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview Gambar:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      child: Image.network(
                        _imageUrlController.text,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 120,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 120,
                            color: Colors.red[50],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.accentRed,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Gambar tidak dapat dimuat',
                                  style: TextStyle(
                                    color: AppTheme.accentRed,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    'Pastikan URL valid dan dapat diakses',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jamBukaController,
                    decoration: InputDecoration(
                      labelText: 'Jam Buka (mis: 08:00)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jam buka harus diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _jamTutupController,
                    decoration: InputDecoration(
                      labelText: 'Jam Tutup (mis: 17:00)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jam tutup harus diisi';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _hargaTiketController,
              decoration: InputDecoration(
                labelText: 'Harga Tiket',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                filled: true,
                fillColor: AppTheme.backgroundColor,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Harga tiket harus diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'Harga harus berupa angka';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rating: ${_rating.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Slider(
                  value: _rating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _rating.toStringAsFixed(1),
                  activeColor: AppTheme.primaryBlue,
                  onChanged: (value) {
                    setState(() => _rating = value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _saveWisata,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      widget.wisata == null
                          ? 'Tambah Wisata'
                          : 'Simpan Perubahan',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
