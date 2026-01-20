import 'dart:developer' as developer;

class PesananModel {
  final int? id;
  final String userId;
  final int wisataId;
  final String namaWisata;
  final String namaPemesan;
  final String email;
  final String noHp;
  final DateTime tanggalKunjungan;
  final int jumlahTiket;
  final double totalHarga; // ubah dari int ke double
  final String status;
  final String? metodePembayaran;
  final String? kodeBooking;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PesananModel({
    this.id,
    required this.userId,
    required this.wisataId,
    required this.namaWisata,
    required this.namaPemesan,
    required this.email,
    required this.noHp,
    required this.tanggalKunjungan,
    required this.jumlahTiket,
    required this.totalHarga,
    this.status = 'confirmed',
    this.metodePembayaran,
    this.kodeBooking,
    this.createdAt,
    this.updatedAt,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('  🔍 fromJson received: $json', name: 'PesananModel');
      
      // Helper untuk parse yang aman
      double parseTotalHarga(dynamic value) {
        developer.log('    💰 Parsing total_harga: $value (${value.runtimeType})', name: 'PesananModel');
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? 0.0;
        return (value as num).toDouble();
      }
      
      int parseInteger(dynamic value, String fieldName) {
        developer.log('    🔢 Parsing $fieldName: $value (${value.runtimeType})', name: 'PesananModel');
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return (value as num).toInt();
      }
      
      final result = PesananModel(
        id: json['id'] == null ? null : parseInteger(json['id'], 'id'),
        userId: json['user_id'] as String,
        wisataId: parseInteger(json['wisata_id'], 'wisata_id'),
        namaWisata: json['nama_wisata'] as String? ?? '',
        namaPemesan: json['nama_pemesan'] as String,
        email: json['email'] as String,
        noHp: json['no_hp'] as String,
        tanggalKunjungan: DateTime.parse(json['tanggal_kunjungan'] as String),
        jumlahTiket: parseInteger(json['jumlah_tiket'], 'jumlah_tiket'),
        totalHarga: parseTotalHarga(json['total_harga']),
        status: json['status'] as String? ?? 'pending',
        metodePembayaran: json['metode_pembayaran'] as String?,
        kodeBooking: json['kode_booking'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );
      
      developer.log('  ✅ Successfully created PesananModel: id=${result.id}, totalHarga=${result.totalHarga}', name: 'PesananModel');
      return result;
      
    } catch (e, stackTrace) {
      developer.log('  ❌ ERROR in PesananModel.fromJson', name: 'PesananModel');
      developer.log('     Error: $e', name: 'PesananModel');
      developer.log('     Stack trace: $stackTrace', name: 'PesananModel');
      developer.log('     JSON: $json', name: 'PesananModel');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'wisata_id': wisataId,
      'nama_wisata': namaWisata,
      'nama_pemesan': namaPemesan,
      'email': email,
      'no_hp': noHp,
      'tanggal_kunjungan': tanggalKunjungan.toIso8601String(),
      'jumlah_tiket': jumlahTiket,
      'total_harga': totalHarga,
      'status': status,
      if (metodePembayaran != null) 'metode_pembayaran': metodePembayaran,
      if (kodeBooking != null) 'kode_booking': kodeBooking,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  PesananModel copyWith({
    int? id,
    String? userId,
    int? wisataId,
    String? namaWisata,
    String? namaPemesan,
    String? email,
    String? noHp,
    DateTime? tanggalKunjungan,
    int? jumlahTiket,
    double? totalHarga, // ubah ke double
    String? status,
    String? metodePembayaran,
    String? kodeBooking,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PesananModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      wisataId: wisataId ?? this.wisataId,
      namaWisata: namaWisata ?? this.namaWisata,
      namaPemesan: namaPemesan ?? this.namaPemesan,
      email: email ?? this.email,
      noHp: noHp ?? this.noHp,
      tanggalKunjungan: tanggalKunjungan ?? this.tanggalKunjungan,
      jumlahTiket: jumlahTiket ?? this.jumlahTiket,
      totalHarga: totalHarga ?? this.totalHarga,
      status: status ?? this.status,
      metodePembayaran: metodePembayaran ?? this.metodePembayaran,
      kodeBooking: kodeBooking ?? this.kodeBooking,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get statusText {
    switch (status) {
      case 'confirmed':
        return 'Sedang Diproses';
      case 'cancelled':
        return 'Dibatalkan';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }
}