import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/preferensi_provider.dart';
import '../repositories/profil_repository.dart';
import '../widgets/dialogs.dart';

class ProfilEditScreen extends StatefulWidget {
  const ProfilEditScreen({super.key});

  @override
  State<ProfilEditScreen> createState() => _ProfilEditScreenState();
}

class _ProfilEditScreenState extends State<ProfilEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late final TextEditingController _emailC;
  late final TextEditingController _teleponC;
  late final TextEditingController _bioC;
  
  Uint8List? _foto;
  bool _menyimpan = false;

  bool get _berubah {
    final p = context.read<PreferensiProvider>();
    return _namaC.text.trim() != p.nama ||
        _emailC.text.trim() != p.email ||
        _teleponC.text.trim() != p.telepon ||
        _bioC.text.trim() != p.bio ||
        !identical(_foto, p.fotoBytes);
  }
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final p = context.read<PreferensiProvider>();
    _namaC = TextEditingController(text: p.nama);
    _emailC = TextEditingController(text: p.email);
    _teleponC = TextEditingController(text: p.telepon);
    _bioC = TextEditingController(text: p.bio);
    _foto = p.fotoBytes;
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _teleponC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  ImageProvider? _gambarFoto() => _foto == null ? null : MemoryImage(_foto!);

  /// Mengambil foto dan memperkecilnya (maks. 400 px, JPEG) agar muat disimpan
  /// di database tanpa membebani koneksi.
  Future<void> _ambilFoto(ImageSource sumber) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final berkas = await _picker.pickImage(
        source: sumber,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 75,
      );
      if (berkas == null) return;
      final bytes = await berkas.readAsBytes();
      if (bytes.length > ProfilData.maksBytesFoto) {
        messenger.showSnackBar(const SnackBar(content: Text('Foto terlalu besar. Pilih foto lain.')));
        return;
      }
      if (mounted) setState(() => _foto = bytes);
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Foto tidak bisa dibuka. Coba lagi.')));
    }
  }

  Future<void> _pilihFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Pilih Foto Profil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Ambil dari Kamera'),
              onTap: () async {
                Navigator.pop(context);
                await _ambilFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Pilih dari Galeri'),
              onTap: () async {
                Navigator.pop(context);
                await _ambilFoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _wajib(String? v, String label, {int min = 2, int maks = 60}) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return '$label wajib diisi';
    if (s.length < min) return '$label minimal $min karakter';
    if (s.length > maks) return '$label maksimal $maks karakter';
    return null;
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false) || _menyimpan) return;
    final provider = context.read<PreferensiProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _menyimpan = true);
    final kesalahan = await provider.ubahProfil(
      nama: _namaC.text,
      email: _emailC.text,
      telepon: _teleponC.text,
      bio: _bioC.text,
      fotoBytes: _foto,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          kesalahan == null
              ? 'Profil berhasil diperbarui.'
              : 'Profil diperbarui di perangkat, tetapi belum tersimpan ke database: $kesalahan',
        ),
      ),
    );
    if (mounted) navigator.pop();
  }

  InputDecoration _dekor(String label, IconData icon) {
    final cs = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // keputusan keluar diambil di _saatKembali, saat tombol ditekan
      onPopInvokedWithResult: _saatKembali,
      child: _bangun(context),
    );
  }

  Future<void> _saatKembali(bool didPop, Object? hasil) async {
    if (didPop) return;
    if (!(_berubah)) {
      Navigator.of(context).pop(); // tidak ada yang perlu dibuang
      return;
    }
    final ya = await konfirmasiBuangPerubahan(context);
    if (ya && mounted) Navigator.of(context).pop();
  }

  Widget _bangun(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage: _gambarFoto(),
                    child: _foto == null ? Icon(Icons.person, size: 50, color: cs.primary) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pilihFoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primary, 
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                        child: Icon(Icons.edit_rounded, size: 18, color: cs.onPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _namaC,
              maxLength: 40,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: _dekor('Nama Lengkap', Icons.person_outline_rounded),
              validator: (v) => _wajib(v, 'Nama', maks: 40),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _dekor('Email', Icons.email_outlined),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Email wajib diisi';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) return 'Masukkan email yang valid';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _teleponC,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _dekor('Nomor Telepon', Icons.phone_outlined),
              validator: (v) => _wajib(v, 'Nomor telepon', min: 10, maks: 15),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioC,
              maxLength: 60,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.sentences,
              decoration: _dekor('Bio Singkat', Icons.info_outline_rounded),
              validator: (v) => _wajib(v, 'Bio'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _menyimpan ? null : _simpan,
                icon: _menyimpan
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_menyimpan ? 'Menyimpan...' : 'Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}