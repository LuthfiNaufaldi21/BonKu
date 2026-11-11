import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/seed_data.dart';
import '../models/item_transaksi.dart';
import '../models/transaksi.dart';
import 'firestore_util.dart';
import 'transaksi_repository.dart';

class FirestoreTransaksiRepository implements TransaksiRepository {
  FirestoreTransaksiRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const _tulis = Duration(seconds: 10);

  CollectionReference<Map<String, dynamic>> get _koleksi =>
      koleksiPengguna('transaksi', db: _db, auth: _auth);

  Map<String, dynamic> _keMap(Transaksi t) => {
        'toko': t.toko,
        'tanggal': Timestamp.fromDate(t.tanggal),
        'sumber': t.sumber.name,
        'catatan': t.catatan,
        'imagePath': t.imagePath,
        'total': t.total,
        'items': [
          for (final i in t.items)
            {'id': i.id, 'nama': i.nama, 'kategoriId': i.kategoriId, 'harga': i.harga},
        ],
      };

  Transaksi _dariDoc(DocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data() ?? {};
    final mentah = (m['items'] as List<dynamic>?) ?? const [];
    return Transaksi(
      id: d.id,
      toko: (m['toko'] as String?) ?? '',
      tanggal: ((m['tanggal'] as Timestamp?) ?? Timestamp.now()).toDate(),
      sumber: SumberResi.values.firstWhere(
        (s) => s.name == m['sumber'],
        orElse: () => SumberResi.manual,
      ),
      catatan: (m['catatan'] as String?) ?? '',
      imagePath: m['imagePath'] as String?,
      items: [
        for (final r in mentah)
          ItemTransaksi(
            id: (r as Map<String, dynamic>)['id'] as String,
            transaksiId: d.id,
            nama: (r['nama'] as String?) ?? '',
            kategoriId: (r['kategoriId'] as String?) ?? SeedData.katLain,
            harga: (r['harga'] as num?)?.toInt() ?? 0,
          ),
      ],
    );
  }

  @override
  Future<List<Transaksi>> getAll() => lindungi(() async {
        final snap = await _koleksi.orderBy('tanggal', descending: true).get();
        return snap.docs.map(_dariDoc).toList();
      });

  @override
  Future<Transaksi?> getById(String id) => lindungi(() async {
        final d = await _koleksi.doc(id).get();
        return d.exists ? _dariDoc(d) : null;
      });

  @override
  Future<void> tambah(Transaksi t) => lindungi(
        () => _koleksi.doc(t.id).set(_keMap(t)),
        batas: _tulis,
      );

  @override
  Future<void> ubah(Transaksi t) => lindungi(
        () => _koleksi.doc(t.id).update(_keMap(t)),
        batas: _tulis,
      );

  @override
  Future<void> hapus(String id) => lindungi(
        () => _koleksi.doc(id).delete(),
        batas: _tulis,
      );

  @override
  Future<void> kosongkan() => lindungi(() async {
        final snap = await _koleksi.get();
        await tulisBatch(_db, [
          for (final d in snap.docs) (batch) => batch.delete(d.reference),
        ]);
      });

  @override
  Future<void> pulihkan() => lindungi(() async {
        final lama = await _koleksi.get();
        await tulisBatch(_db, [
          for (final d in lama.docs) (batch) => batch.delete(d.reference),
        ]);
        await tulisBatch(_db, [
          for (final t in SeedData.transaksi())
            (batch) => batch.set(_koleksi.doc(t.id), _keMap(t)),
        ]);
      });
}