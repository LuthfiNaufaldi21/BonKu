import '../models/transaksi.dart';

class Ringkasan {
  static DateTime? bulanTerbaru(List<Transaksi> data) {
    if (data.isEmpty) return null;
    var terbaru = data.first.tanggal;
    for (final t in data) {
      if (t.tanggal.isAfter(terbaru)) terbaru = t.tanggal;
    }
    return DateTime(terbaru.year, terbaru.month);
  }

  static List<Transaksi> pada(List<Transaksi> data, DateTime bulan) => data
      .where((t) => t.tanggal.year == bulan.year && t.tanggal.month == bulan.month)
      .toList();

  static int total(List<Transaksi> data) =>
      data.fold(0, (sum, t) => sum + t.total);

  static List<MapEntry<String, int>> totalPerKategori(List<Transaksi> data) {
    final peta = <String, int>{};
    for (final t in data) {
      for (final i in t.items) {
        peta[i.kategoriId] = (peta[i.kategoriId] ?? 0) + i.harga;
      }
    }
    final hasil = peta.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return hasil;
  }
}