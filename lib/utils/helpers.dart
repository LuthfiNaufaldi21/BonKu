/// Status pemuatan data untuk layar (loading / berhasil / gagal).
enum LoadStatus { initial, loading, success, error }


class IdGenerator {
  static int _seq = 0;

  static String next(String prefix) {
    final n = DateTime.now();
    String d(int nilai, [int lebar = 2]) => nilai.toString().padLeft(lebar, '0');
    final waktu = '${n.year}${d(n.month)}${d(n.day)}-'
        '${d(n.hour)}${d(n.minute)}${d(n.second)}-${d(n.millisecond, 3)}';
    return '$prefix-$waktu-${_seq++}';
  }
}