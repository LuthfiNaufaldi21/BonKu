import '../data/seed_data.dart';
import '../models/transaksi.dart';
import 'transaksi_repository.dart';

/// Sumber data simulasi (di memori) dengan jeda untuk meniru jaringan.
class InMemoryTransaksiRepository implements TransaksiRepository {
  InMemoryTransaksiRepository({
    List<Transaksi>? seed,
    this.jeda = const Duration(milliseconds: 700),
  }) : _seed = List.of(seed ?? SeedData.transaksi()) {
    _data = List.of(_seed);
  }

  /// Lama jeda simulasi; atur ke Duration.zero pada pengujian.
  final Duration jeda;
  final List<Transaksi> _seed; // data awal, untuk fitur pulihkan
  late final List<Transaksi> _data;

  Future<void> _tunda() => Future<void>.delayed(jeda);

  @override
  Future<List<Transaksi>> getAll() async {
    await _tunda();
    return List.of(_data);
  }

  @override
  Future<Transaksi?> getById(String id) async {
    await _tunda();
    for (final t in _data) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  Future<void> tambah(Transaksi t) async {
    await _tunda();
    _data.add(t);
  }

  @override
  Future<void> ubah(Transaksi t) async {
    await _tunda();
    final index = _data.indexWhere((e) => e.id == t.id);
    if (index == -1) throw Exception('Data tidak ditemukan');
    _data[index] = t;
  }

  @override
  Future<void> hapus(String id) async {
    await _tunda();
    final sebelum = _data.length;
    _data.removeWhere((e) => e.id == id);
    if (_data.length == sebelum) throw Exception('Data tidak ditemukan');
  }

  @override
  Future<void> kosongkan() async {
    await _tunda();
    _data.clear();
  }

  @override
  Future<void> pulihkan() async {
    await _tunda();
    _data
      ..clear()
      ..addAll(_seed);
  }
}