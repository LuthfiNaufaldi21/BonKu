import '../data/seed_data.dart';
import '../models/transaksi.dart';

class TransaksiRepository {
  TransaksiRepository({List<Transaksi>? seed})
      : _seed = List.of(seed ?? SeedData.transaksi()) {
    _data = List.of(_seed);
  }

  final List<Transaksi> _seed; 
  late final List<Transaksi> _data;
  static const _jeda = Duration(milliseconds: 700);

  List<Transaksi> get snapshot {
    final hasil = List.of(_data);
    hasil.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return hasil;
  }

  Future<void> _simulasi(bool gagal, String aksi) async {
    await Future<void>.delayed(_jeda);
    if (gagal) throw Exception('Simulasi gagal $aksi data');
  }

  Future<List<Transaksi>> getAll({bool simulateError = false}) async {
    await _simulasi(simulateError, 'memuat');
    return snapshot;
  }

  Future<Transaksi?> getById(String id, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'memuat');
    for (final t in _data) {
      if (t.id == id) return t;
    }
    return null;
  }

  Future<void> tambah(Transaksi t, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'menyimpan');
    _data.add(t);
  }

  Future<void> ubah(Transaksi t, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'menyimpan');
    final index = _data.indexWhere((e) => e.id == t.id);
    if (index == -1) throw Exception('Data tidak ditemukan');
    _data[index] = t;
  }

  Future<void> hapus(String id, {bool simulateError = false}) async {
    await _simulasi(simulateError, 'menghapus');
    final sebelum = _data.length;
    _data.removeWhere((e) => e.id == id);
    if (_data.length == sebelum) throw Exception('Data tidak ditemukan');
  }

  Future<void> kosongkan({bool simulateError = false}) async {
    await _simulasi(simulateError, 'menghapus');
    _data.clear();
  }

  Future<void> pulihkan({bool simulateError = false}) async {
    await _simulasi(simulateError, 'memulihkan');
    _data
      ..clear()
      ..addAll(_seed);
  }
}