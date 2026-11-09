import '../models/transaksi.dart';

/// Kontrak sumber data transaksi. Provider hanya bergantung pada kelas ini,
/// sehingga implementasinya bisa ditukar tanpa mengubah layar:
/// - InMemoryTransaksiRepository  : data simulasi di memori (sekarang)
/// - FirestoreTransaksiRepository : data di Firebase (tahap berikutnya)
abstract class TransaksiRepository {
  Future<List<Transaksi>> getAll();

  /// Mengembalikan null jika ID tidak ditemukan.
  Future<Transaksi?> getById(String id);

  Future<void> tambah(Transaksi t);

  Future<void> ubah(Transaksi t);

  Future<void> hapus(String id);

  /// Fitur demo: hapus semua transaksi.
  Future<void> kosongkan();

  /// Fitur demo: kembalikan ke data awal.
  Future<void> pulihkan();
}