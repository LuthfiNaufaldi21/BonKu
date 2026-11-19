# BonKu

Aplikasi pencatat pengeluaran otomatis. Pengguna memotret struk atau memilih gambar resi digital, lalu AI membaca isinya per item, mengelompokkannya ke kategori, dan menyiapkan form konfirmasi. Riwayat pengeluaran bisa dievaluasi lewat grafik bulanan dan **Monthly Wrapped** bergaya story.

Tugas kelompok **JD Team** — Mata Kuliah Pemrograman Mobile, Universitas Sumatera Utara.

| Anggota | NIM |
|---|---|
| Ahmad Fazri Berutu | 241401015 |
| Luthfi Naufaldi | 241401036 |
| Argha Niqie Wijaksono | 241401096 |

## Fitur

- **Catat resi** dengan tiga cara: scan kamera, pilih dari galeri (resi digital atau tangkapan layar), atau input manual.
- **Pembacaan struk oleh AI** (Gemini lewat Firebase AI Logic): mengekstrak toko, tanggal, item, dan harga; mengabaikan Tarik Tunai dan Top-Up; item tak dikenal masuk "Lain-lain / Belum Dikategorikan".
- **Form konfirmasi** untuk memeriksa, mengedit, atau mengubah kategori sebelum disimpan; ada peringatan jika keluar sebelum menyimpan.
- **Kelola resi**: daftar dengan pencarian dan filter sumber, detail, edit, hapus dengan konfirmasi.
- **Kelola kategori**: tambah, ubah, hapus. Kategori yang masih dipakai resi tidak bisa dihapus.
- **Statistik**: grafik batang atau garis per bulan (rentang 3, 6, 12 bulan, atau semua), rincian per kategori, dan transaksi terbesar.
- **Monthly Wrapped**: 7 slide interaktif (total, kategori teratas, transaksi terbesar, hari paling boros, perbandingan dengan bulan lalu, ringkasan).
- **Akun**: daftar, masuk, lupa kata sandi, dan keluar (Firebase Authentication). Data tiap akun terpisah.
- **Profil, pengingat, dan tema** (terang/gelap), serta notifikasi di dalam aplikasi yang dibentuk dari data nyata.
- **Mode demo** di Pengaturan: simulasi gagal, kosongkan data, pulihkan data contoh, dan pemindai simulasi.

## Teknologi

- Flutter (Dart `^3.13.3`), state management **Provider**
- Firebase: Authentication, Cloud Firestore, AI Logic (Gemini), App Check
- `image_picker`, `shared_preferences`

## Arsitektur

```
Layar (screens)  ->  Provider  ->  Repository (antarmuka)  ->  Implementasi
                                                              |- Firestore (dipakai aplikasi)
                                                              |- In-Memory (simulasi, untuk uji)
```

Layar hanya berbicara dengan Provider. Provider bergantung pada antarmuka repository, sehingga sumber data bisa ditukar tanpa mengubah layar. Pemindai struk dibuat dengan pola yang sama (`ReceiptScanner`: Gemini atau simulasi).

## Struktur folder

```
lib/
├── main.dart                 titik masuk, inisialisasi Firebase dan App Check, daftar Provider
├── routes.dart               rute bernama dan halaman "tidak ditemukan"
├── firebase_options.dart     konfigurasi Firebase (dibuat flutterfire)
├── models/                   Transaksi, ItemTransaksi, Kategori, Pengguna, HasilScan
├── providers/                Auth, Transaksi, Kategori, Scan, Preferensi, Theme
├── repositories/             antarmuka + implementasi Firestore dan In-Memory
├── services/                 pemindai struk (Gemini dan simulasi)
├── screens/                  layar aplikasi
├── widgets/                  komponen bersama (loading/kosong/gagal, dialog, kartu, grafik)
├── utils/                    format, ringkasan data, pembuat ID
└── data/seed_data.dart       kategori bawaan dan data contoh 12 bulan
firestore.rules               aturan keamanan Firestore
```

## Data di Firestore

```
users/{uid}/kategori/{id}     nama, warna, urutan
users/{uid}/transaksi/{id}    toko, tanggal, sumber, catatan, imagePath, total, items[]
```

Item disimpan di dalam dokumen transaksinya (array `items`) karena selalu dibaca dan ditulis bersama. Gambar struk **tidak diunggah**; hanya path-nya yang disimpan. Aturan keamanan: pengguna hanya boleh membaca dan menulis data miliknya sendiri.

## Persona dan alur pengguna

**Persona utama:** *Rani, mahasiswa semester 5.* Uang bulanannya campuran transfer dan e-wallet, sering belanja di minimarket dan pesan makanan online. Struknya jarang dicatat sehingga di akhir bulan ia tidak tahu uangnya habis ke mana. Ia ingin mencatat dengan sekali foto, tanpa mengetik.

| Alur | Layar yang dilalui | Hasil akhir |
|---|---|---|
| 1. Mencatat pengeluaran | Beranda, tombol +, Scan/Galeri/Manual, Form konfirmasi | Resi muncul di Beranda dan Semua Resi |
| 2. Mengelola data | Semua Resi, Detail, Edit/Hapus, Kelola Kategori | Data dan statistik ikut berubah |
| 3. Evaluasi bulanan | Statistik, Monthly Wrapped | Tren pengeluaran antarbulan terlihat |
| 4. Preferensi | Profil, Edit Profil, Pengaturan | Pengingat dan tema tersimpan selama sesi |

## Cara menjalankan

**Prasyarat:** Flutter SDK dengan Dart 3.13.3 atau lebih baru, Android Studio atau VS Code, dan HP Android asli (disarankan). Proyek memakai Firebase `bonku-jdteam`; konfigurasinya sudah ada di repo.

```bash
git clone https://github.com/LuthfiNaufaldi21/BonKu.git
cd BonKu
flutter pub get
flutter run
```

Lalu daftar akun baru di layar Masuk. Akun baru mulai dengan data kosong. Untuk mengisi data contoh, buka **Pengaturan → Mode Demo → Pulihkan Data Awal**.

### Scan struk

| Cara | Kapan dipakai | Yang diperlukan |
|---|---|---|
| **Pemindai Simulasi** | Pengembangan, emulator, dan demo hemat kuota | Aktifkan di Pengaturan → Mode Demo. Tidak butuh pengaturan apa pun |
| **Gemini asli** | Pemakaian normal | HP Android **asli** (emulator tidak lolos pemeriksaan perangkat) dan SHA-256 sertifikat penandatangan laptop yang membangun aplikasi sudah terdaftar di Firebase |

Mendaftarkan SHA-256 (sekali per laptop):

```bash
cd android
./gradlew signingReport        # Windows: .\gradlew signingReport
```

Salin baris **SHA-256** pada `Variant: debug`, lalu tambahkan di Firebase Console: **Project settings → Your apps → bonku_app (android) → Add fingerprint**. Perubahan bisa butuh beberapa menit untuk berlaku.

Catatan:
- Firebase App Check wajib untuk Firebase AI Logic. Aplikasi memakai **Play Integrity** di semua mode. Pengaturan App Check di console: distribusi "di luar Google Play" dengan PLAY_RECOGNIZED tidak diwajibkan.
- Kuota Gemini gratis terbatas dan dipakai bersama seluruh tim. Gunakan Pemindai Simulasi untuk pekerjaan tampilan.
- Untuk membagikan APK: `flutter build apk` dari laptop yang SHA-256-nya sudah terdaftar. APK itu bisa dipasang di HP mana pun tanpa pengaturan tambahan.

### Menjalankan di Chrome

```bash
flutter run -d chrome
```

Scan Gemini tidak berjalan di web (gunakan Pemindai Simulasi), dan foto profil belum didukung di web. Rute dengan ID bisa dibuka langsung, misalnya `/#/resi/<id>`; alamat yang tidak dikenal menampilkan halaman "tidak ditemukan".

## Pengujian

```bash
flutter analyze
flutter test
```

Kondisi tampilan bisa diuji lewat Mode Demo: **Simulasi Gagal** (loading, gagal, Coba lagi), **Kosongkan Semua Resi** (tampilan kosong), dan **Pulihkan Data Awal**. Skenario uji lengkap akan ditambahkan di folder `test/`.

## Pemetaan terhadap SRS

| Kebutuhan | Status |
|---|---|
| FR-01 Terima gambar lewat Share | Belum. Gambar resi digital bisa dipilih dari galeri sebagai pengganti |
| FR-02 Scan struk dengan kamera | Selesai |
| FR-03 Ekstraksi AI, kategori otomatis, abaikan non-pengeluaran | Selesai |
| FR-04 Form konfirmasi sebelum simpan | Selesai |
| FR-05 Monthly Wrapped dengan tren bulanan | Selesai |
| FR-06 Pengingat terjadwal | Sebagian: pengaturan jadwal dan notifikasi di dalam aplikasi sudah ada; notifikasi sistem saat aplikasi tertutup belum |
| NFR-01 Hasil scan dalam 5-7 detik | Belum diukur; bergantung pada model dan koneksi |
| NFR-02 UI responsif, Dark Mode, hanya path gambar | Selesai |
| NFR-03 Data transaksi terenkripsi lokal | Belum sesuai: data berada di Firestore dengan cache offline bawaan, tanpa enkripsi lokal tambahan |

Perbedaan dari rancangan awal: aplikasi memakai Flutter (bukan komponen Android native Activity/Service/BroadcastReceiver) dan Firestore (bukan Room/SQLite).

## Batasan yang diketahui

- Gambar struk tidak diunggah. Path foto kamera bersifat sementara, sehingga pratinjau struk lama tidak dijamin muncul lagi.
- Profil (nama, telepon, bio, foto) tersimpan di perangkat selama sesi dan belum masuk ke Firestore.
- Saat offline, penyimpanan menampilkan pesan koneksi setelah 10 detik; Firestore tetap mengirim perubahannya saat kembali online.
- Kuota Gemini gratis bisa habis. Aplikasi menampilkan pesan dan menawarkan input manual atau hasil simulasi.