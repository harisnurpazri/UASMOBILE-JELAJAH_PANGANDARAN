---
layout: default
title: JEPANG — Jelajah Pangandaran
description: Aplikasi mobile Flutter untuk eksplorasi wisata Pangandaran dengan UI modern, peta interaktif, dan REST API
---

<div align="center">

<img src="assets/images/logo.png" width="150" alt="JEPANG Logo"/>

# 🇯🇵 JEPANG
### Jelajah Pangandaran

**Aplikasi Mobile Flutter untuk Eksplorasi Wisata Pangandaran**  
Informasi Terpusat • UI Modern • Peta Interaktif • REST API

<img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter"/>  
<img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart"/>  
<img src="https://img.shields.io/badge/REST%20API-Integrated-success"/>  
<img src="https://img.shields.io/badge/Status-Portfolio-orange"/>

</div>

---

<div align="left">

## 🌴 Gambaran Umum

**JEPANG (JElajah PANGAndaran)** adalah aplikasi mobile berbasis **Flutter** yang dirancang sebagai **platform panduan wisata digital modern** untuk kawasan Pangandaran.

Aplikasi ini menghadirkan pengalaman eksplorasi wisata yang:
- Informatif
- Visual
- Interaktif
- Mudah digunakan

Dengan menggabungkan **daftar destinasi**, **peta interaktif**, **galeri visual**, serta **data dinamis dari REST API**, JEPANG menjadi solusi digital untuk wisatawan yang ingin menjelajah Pangandaran secara efisien dan menyenangkan.

Proyek ini dikembangkan sebagai **produk portofolio**, **media pembelajaran Flutter**, sekaligus **contoh penerapan arsitektur aplikasi mobile modern**.

---

## 🎯 Tujuan & Nilai Produk

| Nilai | Implementasi |
|------|-------------|
| 🧭 Kemudahan Akses | Informasi wisata dalam satu aplikasi |
| 🎨 UI/UX Modern | Desain bersih, responsif, dan konsisten |
| 🔄 Data Dinamis | Integrasi REST API |
| ❤️ Personalisasi | Favorit & wishlist pengguna |
| ⚡ Efisiensi | Cache data untuk performa lebih cepat |

---

## 🚀 Fitur Utama

- 🏝️ **Eksplor Destinasi Wisata**  
  Daftar tempat wisata dengan thumbnail, kategori, dan ringkasan informasi.

- 📍 **Detail Wisata Lengkap**  
  Galeri foto, deskripsi, jam operasional, alamat, dan kontak.

- 🗺️ **Peta Interaktif & Lokasi**  
  Marker lokasi wisata, integrasi GPS, dan navigasi arah.

- ❤️ **Favorit & Wishlist**  
  Menyimpan destinasi favorit secara lokal maupun sinkron ke server.

- 🔎 **Pencarian & Filter**  
  Autocomplete, filter kategori, dan pencarian spesifik.

- 🖼️ **Galeri Visual**  
  Tampilan foto destinasi dengan layout modern.

- 💳 **(Opsional)** Booking & integrasi pembayaran.

---

## 🎨 Preview Tampilan Aplikasi

<div align="center">
<img src="assets/images/screenshots/home.png" width="240"/>
<img src="assets/images/screenshots/detail.png" width="240"/>
<img src="assets/images/screenshots/map.png" width="240"/>
</div>

---

## 🧱 Arsitektur & Teknologi

**Teknologi Utama**
- Flutter & Dart
- REST API
- Provider / ChangeNotifier
- Google Maps API (opsional)

**Struktur Proyek**
```
lib/
├── main.dart
├── config/
│   └── api.dart
├── models/
├── services/
├── providers/
├── screens/
└── widgets/
assets/
└── images/screenshots/
```

---

## 🔗 Integrasi REST API

**Contoh Endpoint**
- `GET /places`
- `GET /places/{id}`
- `POST /favorites`
- `GET /search`

**Contoh Pemanggilan API**
```dart
final response = await http.get(
  Uri.parse('$API_BASE_URL/places'),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
}
```

⚠️ Konfigurasi API disimpan di `lib/config/api.dart`

---

## 📌 Roadmap Pengembangan

- [x] UI & layout utama  
- [x] Integrasi REST API  
- [x] Peta & lokasi  
- [ ] Autentikasi pengguna  
- [ ] Booking & pembayaran  
- [ ] Mode offline penuh

---

## 👨‍💻 Tentang Pengembang

**Haris Nurpazri**  
Mahasiswa Teknik Informatika  
Mobile & Web Developer

Proyek ini dikembangkan sebagai:
- Portofolio pengembangan aplikasi mobile
- Proyek akademik / UAS
- Media eksplorasi teknologi Flutter

---

## 📄 Lisensi

MIT License  
Bebas digunakan untuk pembelajaran dan pengembangan lanjutan.

---

<div align="center">
<b>JEPANG — Jelajah Pangandaran</b><br/>
Portfolio Project • Flutter Mobile Application<br/>
© 2026
</div>

</div>
