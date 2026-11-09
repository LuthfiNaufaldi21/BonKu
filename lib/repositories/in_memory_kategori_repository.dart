import '../data/seed_data.dart';
import '../models/kategori.dart';
import 'kategori_repository.dart';

/// Sumber data kategori simulasi (di memori).
class InMemoryKategoriRepository implements KategoriRepository {
  InMemoryKategoriRepository({
    List<Kategori>? seed,
    this.jeda = const Duration(milliseconds: 500),
  }) : _data = List.of(seed ?? SeedData.kategori());

  final Duration jeda;
  final List<Kategori> _data;

  Future<void> _tunda() => Future<void>.delayed(jeda);

  @override
  Future<List<Kategori>> getAll() async {
    await _tunda();
    return List.of(_data);
  }

  @override
  Future<void> tambah(Kategori k) async {
    await _tunda();
    _data.add(k);
  }

  @override
  Future<void> ubah(Kategori k) async {
    await _tunda();
    final index = _data.indexWhere((e) => e.id == k.id);
    if (index == -1) throw Exception('Data tidak ditemukan');
    _data[index] = k;
  }

  @override
  Future<void> hapus(String id) async {
    await _tunda();
    final sebelum = _data.length;
    _data.removeWhere((e) => e.id == id);
    if (_data.length == sebelum) throw Exception('Data tidak ditemukan');
  }
}