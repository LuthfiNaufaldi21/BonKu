import 'package:flutter/services.dart';

/// Memformat angka saat diketik dengan titik pemisah ribuan,
/// mis. 25000 menjadi 25.000. Kursor tetap berada di tempat yang wajar.
class RupiahInputFormatter extends TextInputFormatter {
  const RupiahInputFormatter();

  /// Batas jumlah digit yang bisa diketik (angka lebih panjang ditolak).
  static const _maksDigit = 10;

  static final _bukanDigit = RegExp(r'[^0-9]');

  /// Mengambil angka murni dari teks berformat ("25.000" menjadi 25000).
  /// Mengembalikan null jika tidak ada digit.
  static int? parse(String teks) {
    final digit = teks.replaceAll(_bukanDigit, '');
    return digit.isEmpty ? null : int.tryParse(digit);
  }

  /// Mengubah angka menjadi teks berpemisah ribuan ("25000" menjadi "25.000").
  static String format(int nilai) {
    final s = nilai.abs().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue lama, TextEditingValue baru) {
    final mentah = baru.text;
    final digit = mentah.replaceAll(_bukanDigit, '');
    if (digit.isEmpty) return const TextEditingValue();

    // Buang nol di depan ("007" menjadi "7").
    final bersih = digit.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (bersih.length > _maksDigit) return lama;

    final teks = format(int.parse(bersih));

    // Hitung berapa digit yang ada di kiri kursor, lalu letakkan kursor
    // setelah digit yang sama pada teks berformat.
    final posisiAsli = baru.selection.baseOffset.clamp(0, mentah.length);
    final nolDibuang = digit.length - bersih.length;
    var digitDiKiri =
        mentah.substring(0, posisiAsli).replaceAll(_bukanDigit, '').length - nolDibuang;
    if (digitDiKiri < 0) digitDiKiri = 0;

    var kursor = 0;
    var terhitung = 0;
    while (kursor < teks.length && terhitung < digitDiKiri) {
      if (teks[kursor] != '.') terhitung++;
      kursor++;
    }

    return TextEditingValue(
      text: teks,
      selection: TextSelection.collapsed(offset: kursor),
    );
  }
}