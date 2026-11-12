import 'dart:typed_data';

/// Satu item hasil pembacaan struk (sebelum dikonfirmasi pengguna).
class ItemScan {
  final String nama;
  final String kategoriId;
  final int harga;

  const ItemScan({required this.nama, required this.kategoriId, required this.harga});
}

/// Hasil pembacaan struk oleh pemindai (AI atau simulasi).
class HasilScan {
  final String toko;
  final DateTime? tanggal;
  final List<ItemScan> items;
  final Uint8List? gambar; // untuk pratinjau di form
  final String? imagePath; // yang disimpan hanya path (NFR-02)
  final bool simulasi;

  const HasilScan({
    this.toko = '',
    this.tanggal,
    this.items = const [],
    this.gambar,
    this.imagePath,
    this.simulasi = false,
  });

  HasilScan denganGambar({Uint8List? gambar, String? imagePath}) => HasilScan(
        toko: toko,
        tanggal: tanggal,
        items: items,
        gambar: gambar,
        imagePath: imagePath,
        simulasi: simulasi,
      );
}