class ItemTransaksi {
  final String id;
  final String transaksiId;
  final String nama;
  final String kategoriId;
  final int harga;

  const ItemTransaksi({
    required this.id,
    required this.transaksiId,
    required this.nama,
    required this.kategoriId,
    required this.harga,
  });

  ItemTransaksi copyWith({String? nama, String? kategoriId, int? harga}) =>
      ItemTransaksi(
        id: id,
        transaksiId: transaksiId,
        nama: nama ?? this.nama,
        kategoriId: kategoriId ?? this.kategoriId,
        harga: harga ?? this.harga,
      );
}