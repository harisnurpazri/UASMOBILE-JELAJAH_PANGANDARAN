---
layout: default
title: JEPANG — Jelajah Pangandaran
description: Aplikasi mobile Flutter untuk eksplorasi wisata Pangandaran dengan UI modern, peta interaktif, dan REST API
---

<p align="center">
  <img src="assets/images/logo.png" width="150" alt="JEPANG Logo"/>
</p>

<h1 align="center">🇯🇵 JEPANG</h1>
<h3 align="center">Jelajah Pangandaran dalam Satu Genggaman</h3>

<p align="center">
  <b>Aplikasi Mobile Flutter untuk Eksplorasi Wisata Pangandaran</b><br/>
  Informasi Terpusat • UI Modern • Peta Interaktif • REST API
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.x-blue?logo=dart"/>
  <img src="https://img.shields.io/badge/REST%20API-Integrated-success"/>
  <img src="https://img.shields.io/badge/Status-Portfolio-orange"/>
</p>

---

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

JEPANG dikembangkan dengan visi utama **digitalisasi informasi wisata lokal** melalui pendekatan desain dan teknologi modern.

| Nilai | Implementasi |
|------|-------------|
| 🧭 Kemudahan Akses | Informasi wisata dalam satu aplikasi |
| 🎨 UI/UX Modern | Desain bersih, responsif, dan konsisten |
| 🔄 Data Dinamis | Integrasi REST API |
| ❤️ Personalisasi | Favorit & wishlist pengguna |
| ⚡ Efisiensi | Cache data untuk performa lebih cepat |

---

## 🚀 Fitur Utama

JEPANG menyediakan fitur-fitur inti yang dirancang untuk memberikan pengalaman eksplorasi terbaik:

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

<p align="center">
  <img src="assets/images/screenshots/home.png" width="240"/>
  <img src="assets/images/screenshots/detail.png" width="240"/>
  <img src="assets/images/screenshots/map.png" width="240"/>
</p>

<p align="center">
  <i>Cuplikan antarmuka aplikasi JEPANG yang menampilkan halaman utama, detail wisata, dan peta lokasi.</i>
</p>

---

## 🧱 Arsitektur & Teknologi

Aplikasi ini dibangun dengan arsitektur yang terstruktur dan siap dikembangkan lebih lanjut.

**Teknologi Utama**
- Flutter & Dart
- REST API
- Provider / ChangeNotifier
- Google Maps API (opsional)

**Struktur Proyek**
lib/
├── main.dart
├── config/
│ └── api.dart
├── models/
├── services/
├── providers/
├── screens/
└── widgets/
assets/
└── images/screenshots/


---

## 🔗 Integrasi REST API

JEPANG menggunakan REST API sebagai sumber data utama untuk destinasi wisata.

**Contoh Endpoint**
- `GET /places` → daftar tempat wisata
- `GET /places/{id}` → detail wisata
- `POST /favorites` → simpan favorit
- `GET /search` → pencarian destinasi

**Contoh Pemanggilan API**
```dart
final response = await http.get(
  Uri.parse('$API_BASE_URL/places'),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
}
⚠️ Konfigurasi API disimpan di lib/config/api.dart
Jangan menyimpan API key langsung ke repository publik.

🎥 Demo Video Aplikasi
<p align="center"> <a href="https://youtu.be/your-demo-video-id"> <img src="https://img.youtube.com/vi/your-demo-video-id/0.jpg" width="500"/> </a> </p> <p align="center"> <i>Klik gambar untuk melihat demo penggunaan aplikasi.</i> </p>
⚙️ Instalasi & Menjalankan Aplikasi
flutter pub get
flutter run
Build APK release:

flutter build apk --release
📌 Roadmap Pengembangan
 UI & layout utama

 Integrasi REST API

 Peta & lokasi

 Autentikasi pengguna

 Booking & pembayaran

 Mode offline penuh

👨‍💻 Tentang Pengembang
Haris Nurpazri
Mahasiswa Teknik Informatika
Mobile & Web Developer

Proyek ini dikembangkan sebagai:

Portofolio pengembangan aplikasi mobile

Proyek akademik / UAS

Media eksplorasi teknologi Flutter

📄 Lisensi
MIT License
Bebas digunakan untuk pembelajaran dan pengembangan lanjutan.

<p align="center"> <b>JEPANG — Jelajah Pangandaran</b><br/> Portfolio Project • Flutter Mobile Application<br/> © 2026 </p> ```
