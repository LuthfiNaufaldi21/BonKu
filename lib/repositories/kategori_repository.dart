import '../models/kategori.dart';

/// Kontrak sumber data kategori (data referensi). Lihat TransaksiRepository.
abstract class KategoriRepository {
  Future<List<Kategori>> getAll();

  Future<void> tambah(Kategori k);

  Future<void> ubah(Kategori k);

  Future<void> hapus(String id);
}