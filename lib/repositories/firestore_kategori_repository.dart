import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/seed_data.dart';
import '../models/kategori.dart';
import 'firestore_util.dart';
import 'kategori_repository.dart';

/// Akun baru otomatis mendapat kategori bawaan saat pertama kali memuat.
class FirestoreKategoriRepository implements KategoriRepository {
  FirestoreKategoriRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const _tulis = Duration(seconds: 10);

  CollectionReference<Map<String, dynamic>> get _koleksi =>
      koleksiPengguna('kategori', db: _db, auth: _auth);

  Kategori _dariDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    return Kategori(
      id: d.id,
      nama: (m['nama'] as String?) ?? 'Tanpa nama',
      warna: (m['warna'] as num?)?.toInt() ?? 0xFF757575,
    );
  }

  @override
  Future<List<Kategori>> getAll() => lindungi(() async {
        final snap = await _koleksi.orderBy('urutan').get();
        if (snap.docs.isNotEmpty) return snap.docs.map(_dariDoc).toList();

        // Akun baru: isi kategori bawaan.
        final bawaan = SeedData.kategori();
        await tulisBatch(_db, [
          for (var i = 0; i < bawaan.length; i++)
            (batch) => batch.set(_koleksi.doc(bawaan[i].id), {
                  'nama': bawaan[i].nama,
                  'warna': bawaan[i].warna,
                  'urutan': i,
                }),
        ]);
        return bawaan;
      });

  @override
  Future<void> tambah(Kategori k) => lindungi(
        () => _koleksi.doc(k.id).set({
          'nama': k.nama,
          'warna': k.warna,
          'urutan': DateTime.now().millisecondsSinceEpoch,
        }),
        batas: _tulis,
      );

  @override
  Future<void> ubah(Kategori k) => lindungi(
        () => _koleksi.doc(k.id).update({'nama': k.nama, 'warna': k.warna}),
        batas: _tulis,
      );

  @override
  Future<void> hapus(String id) => lindungi(
        () => _koleksi.doc(id).delete(),
        batas: _tulis,
      );
}