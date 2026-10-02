enum LoadStatus { initial, loading, success, error }

class IdGenerator {
  static int _seq = 0;

  static String next(String prefix) =>
      '$prefix-${DateTime.now().millisecondsSinceEpoch}-${_seq++}';
}