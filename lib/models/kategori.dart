class Kategori {
  final String id;
  final String nama;
  final int warna;

  const Kategori({required this.id, required this.nama, required this.warna});

  Kategori copyWith({String? nama, int? warna}) =>
      Kategori(id: id, nama: nama ?? this.nama, warna: warna ?? this.warna);
}