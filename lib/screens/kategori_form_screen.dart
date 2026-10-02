import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/kategori.dart';
import '../providers/kategori_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';

class KategoriFormScreen extends StatefulWidget {
  final Kategori? kategori;

  const KategoriFormScreen({super.key, this.kategori});

  @override
  State<KategoriFormScreen> createState() => _KategoriFormScreenState();
}

class _KategoriFormScreenState extends State<KategoriFormScreen> {
  static const _palet = [
    0xFFEF6C00, 0xFF1E88E5, 0xFF8E24AA, 0xFFE53935, 0xFF43A047,
    0xFF00897B, 0xFFD81B60, 0xFF3949AB, 0xFF6D4C41, 0xFF757575,
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late int _warna;

  bool get _edit => widget.kategori != null;

  @override
  void initState() {
    super.initState();
    _namaC = TextEditingController(text: widget.kategori?.nama ?? '');
    _warna = widget.kategori?.warna ?? _palet.first;
  }

  @override
  void dispose() {
    _namaC.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final provider = context.read<KategoriProvider>();
    if (provider.isSubmitting) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final data = Kategori(
      id: widget.kategori?.id ?? IdGenerator.next('kat'),
      nama: _namaC.text.trim(),
      warna: _warna,
    );
    final ok = _edit ? await provider.ubah(data) : await provider.tambah(data);

    if (ok) {
      messenger.showSnackBar(
        SnackBar(content: Text(_edit ? 'Kategori diperbarui.' : 'Kategori ditambahkan.')),
      );
      if (mounted) navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Gagal menyimpan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<KategoriProvider>();
    final menyimpan = provider.isSubmitting;
    final warna = Color(_warna);
    final namaPratinjau = _namaC.text.trim().isEmpty ? 'Nama kategori' : _namaC.text.trim();

    return Scaffold(
      appBar: AppBar(title: Text(_edit ? 'Edit Kategori' : 'Tambah Kategori')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: warna.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.kategori == null
                        ? Icons.category_rounded
                        : Format.ikonKategori(widget.kategori!.id),
                    color: warna,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      namaPratinjau,
                      style: TextStyle(fontWeight: FontWeight.w600, color: warna),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _namaC,
              maxLength: 30,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                prefixIcon: Icon(Icons.category_outlined, color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: cs.primary, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Nama kategori wajib diisi';
                if (s.length < 2) return 'Nama kategori minimal 2 karakter';
                if (s.length > 30) return 'Nama kategori maksimal 30 karakter';
                if (provider.namaTerpakai(s, kecualiId: widget.kategori?.id)) {
                  return 'Nama kategori sudah dipakai';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Text('Warna', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final w in _palet)
                  InkWell(
                    onTap: () => setState(() => _warna = w),
                    customBorder: const CircleBorder(),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Color(w),
                        shape: BoxShape.circle,
                        border: _warna == w ? Border.all(color: cs.onSurface, width: 3) : null,
                      ),
                      child: _warna == w
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: menyimpan ? null : _simpan,
                icon: menyimpan
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(menyimpan ? 'Menyimpan...' : (_edit ? 'Simpan Perubahan' : 'Simpan Kategori')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}