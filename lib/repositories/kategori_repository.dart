import '../data/seed_data.dart';
import '../models/kategori.dart';

class KategoriRepository {
  KategoriRepository({List<Kategori>? seed})
      : _data = List.of(seed ?? SeedData.kategori());

  final List<Kategori> _data;
  static const _jeda = Duration(milliseconds: 500);

  List<Kategori> get snapshot => List.of(_data);

  Future<void> _simulasi(bool gagal, String aksi) async {
    await Future<void>.delayed(_jeda);
    if (gagal) throw Exception('Simulasi gagal $aksi data');
  }

  Future<List<Kategori>> getAll({bool simulateError = false}) async {
    await _simulasi(simulateError, 'memuat');
    return snapshot;
  }

  Future<void> tambah(Kategori k, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'menyimpan');
    _data.add(k);
  }

  Future<void> ubah(Kategori k, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'menyimpan');
    final index = _data.indexWhere((e) => e.id == k.id);
    if (index == -1) throw Exception('Data tidak ditemukan');
    _data[index] = k;
  }

  Future<void> hapus(String id, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'menghapus');
    final sebelum = _data.length;
    _data.removeWhere((e) => e.id == id);
    if (_data.length == sebelum) throw Exception('Data tidak ditemukan');
  }
}