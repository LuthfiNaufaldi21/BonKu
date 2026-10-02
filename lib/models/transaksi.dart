import 'item_transaksi.dart';

enum SumberResi { kamera, share, manual }

class Transaksi {
  final String id;
  final String toko;
  final DateTime tanggal;
  final SumberResi sumber;
  final String catatan;
  final String? imagePath; 
  final List<ItemTransaksi> items;

  const Transaksi({
    required this.id,
    required this.toko,
    required this.tanggal,
    required this.sumber,
    this.catatan = '',
    this.imagePath,
    this.items = const [],
  });

  int get total => items.fold(0, (sum, item) => sum + item.harga);

  Transaksi copyWith({
    String? toko,
    DateTime? tanggal,
    SumberResi? sumber,
    String? catatan,
    String? imagePath,
    List<ItemTransaksi>? items,
  }) =>
      Transaksi(
        id: id,
        toko: toko ?? this.toko,
        tanggal: tanggal ?? this.tanggal,
        sumber: sumber ?? this.sumber,
        catatan: catatan ?? this.catatan,
        imagePath: imagePath ?? this.imagePath,
        items: items ?? this.items,
      );
}