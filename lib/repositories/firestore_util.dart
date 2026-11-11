import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

CollectionReference<Map<String, dynamic>> koleksiPengguna(
  String nama, {
  FirebaseFirestore? db,
  FirebaseAuth? auth,
}) {
  final uid = (auth ?? FirebaseAuth.instance).currentUser?.uid;
  if (uid == null) throw Exception('Belum masuk. Silakan masuk terlebih dulu.');
  return (db ?? FirebaseFirestore.instance).collection('users').doc(uid).collection(nama);
}

Future<T> lindungi<T>(Future<T> Function() aksi, {Duration? batas}) async {
  try {
    final proses = aksi();
    return batas == null ? await proses : await proses.timeout(batas);
  } on TimeoutException {
    throw Exception('Koneksi lambat atau terputus. Perubahan disinkronkan saat kembali online.');
  } on FirebaseException catch (e) {
    throw Exception(_pesan(e.code));
  }
}

String _pesan(String kode) {
  switch (kode) {
    case 'permission-denied':
      return 'Tidak punya izin mengakses data. Coba keluar lalu masuk lagi.';
    case 'unauthenticated':
      return 'Sesi berakhir. Silakan masuk ulang.';
    case 'unavailable':
      return 'Server tidak dapat dijangkau. Periksa koneksi internet.';
    case 'not-found':
      return 'Data tidak ditemukan';
    default:
      return 'Gagal mengakses data ($kode).';
  }
}

Future<void> tulisBatch(
  FirebaseFirestore db,
  List<void Function(WriteBatch batch)> operasi,
) async {
  const ukuran = 400;
  for (var i = 0; i < operasi.length; i += ukuran) {
    final batch = db.batch();
    for (final op in operasi.skip(i).take(ukuran)) {
      op(batch);
    }
    await batch.commit();
  }
}