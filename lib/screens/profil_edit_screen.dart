import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/preferensi_provider.dart';

class ProfilEditScreen extends StatefulWidget {
  const ProfilEditScreen({super.key});

  @override
  State<ProfilEditScreen> createState() => _ProfilEditScreenState();
}

class _ProfilEditScreenState extends State<ProfilEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _namaC;
  late final TextEditingController _emailC;
  late final TextEditingController _prodiC;
  late final TextEditingController _institusiC;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<PreferensiProvider>();
    _namaC = TextEditingController(text: p.nama);
    _emailC = TextEditingController(text: p.email);
    _prodiC = TextEditingController(text: p.programStudi);
    _institusiC = TextEditingController(text: p.institusi);
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _prodiC.dispose();
    _institusiC.dispose();
    super.dispose();
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
    await Future<void>.delayed(const Duration(milliseconds: 500)); // simulasi proses
    provider.ubahProfil(
      nama: _namaC.text,
      email: _emailC.text,
      programStudi: _prodiC.text,
      institusi: _institusiC.text,
    );
    messenger.showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui.')));
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _namaC,
              maxLength: 40,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nama',
                prefixIcon: Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (v) => _wajib(v, 'Nama', maks: 40),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailC,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Email wajib diisi';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                  return 'Masukkan email yang valid';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _prodiC,
              maxLength: 40,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Program Studi',
                prefixIcon: Icon(Icons.school_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => _wajib(v, 'Program studi', maks: 40),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _institusiC,
              maxLength: 60,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Institusi',
                prefixIcon: Icon(Icons.business_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => _wajib(v, 'Institusi'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _menyimpan ? null : _simpan,
                icon: _menyimpan
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
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