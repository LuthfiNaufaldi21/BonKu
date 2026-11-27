import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firestore_util.dart';
import 'profil_repository.dart';

class FirestoreProfilRepository implements ProfilRepository {
  FirestoreProfilRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const _batas = Duration(seconds: 10);

  DocumentReference<Map<String, dynamic>> get _dokumen =>
      koleksiPengguna('profil', db: _db, auth: _auth).doc('data');

  @override
  Future<ProfilData?> muat() => lindungi(() async {
        final m = (await _dokumen.get()).data();
        if (m == null) return null;
        final foto = m['foto'] as String?;
        return ProfilData(
          nama: (m['nama'] as String?) ?? '',
          telepon: (m['telepon'] as String?) ?? '',
          bio: (m['bio'] as String?) ?? '',
          foto: (foto == null || foto.isEmpty) ? null : base64Decode(foto),
        );
      }, batas: _batas);

  @override
  Future<void> simpan(ProfilData data) => lindungi(
        () => _dokumen.set({
          'nama': data.nama,
          'telepon': data.telepon,
          'bio': data.bio,
          'foto': data.foto == null ? null : base64Encode(data.foto!),
          'diperbarui': FieldValue.serverTimestamp(),
        }),
        batas: _batas,
      );
}