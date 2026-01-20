class WisataModel {
  final int? id;
  final String nama;
  final String deskripsi;
  final String kategori;
  final String lokasi;
  final double? latitude;
  final double? longitude;
  final String imageUrl;
  final double? rating;
  final String? jamBuka;
  final String? jamTutup;
  final int? hargaTiket;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WisataModel({
    this.id,
    required this.nama,
    required this.deskripsi,
    required this.kategori,
    required this.lokasi,
    this.latitude,
    this.longitude,
    required this.imageUrl,
    this.rating,
    this.jamBuka,
    this.jamTutup,
    this.hargaTiket,
    this.createdAt,
    this.updatedAt,
  });

  // From JSON
  factory WisataModel.fromJson(Map<String, dynamic> json) {
    return WisataModel(
      id: json['id'] as int?,
      nama: json['nama'] as String? ?? '',
      deskripsi: json['deskripsi'] as String? ?? '',
      kategori: json['kategori'] as String? ?? '',
      lokasi: json['lokasi'] as String? ?? '',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      imageUrl: json['image_url'] as String? ?? '',
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      jamBuka: json['jam_buka'] as String?,
      jamTutup: json['jam_tutup'] as String?,
      hargaTiket: json['harga_tiket'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'lokasi': lokasi,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'image_url': imageUrl,
      if (rating != null) 'rating': rating,
      if (jamBuka != null) 'jam_buka': jamBuka,
      if (jamTutup != null) 'jam_tutup': jamTutup,
      if (hargaTiket != null) 'harga_tiket': hargaTiket,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // CopyWith method
  WisataModel copyWith({
    int? id,
    String? nama,
    String? deskripsi,
    String? kategori,
    String? lokasi,
    double? latitude,
    double? longitude,
    String? imageUrl,
    double? rating,
    String? jamBuka,
    String? jamTutup,
    int? hargaTiket,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WisataModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      deskripsi: deskripsi ?? this.deskripsi,
      kategori: kategori ?? this.kategori,
      lokasi: lokasi ?? this.lokasi,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      jamBuka: jamBuka ?? this.jamBuka,
      jamTutup: jamTutup ?? this.jamTutup,
      hargaTiket: hargaTiket ?? this.hargaTiket,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
