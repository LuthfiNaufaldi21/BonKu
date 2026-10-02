import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/seed_data.dart';
import '../models/kategori.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../widgets/dialogs.dart';
import '../widgets/state_views.dart';
import 'kategori_form_screen.dart';

class KategoriListScreen extends StatefulWidget {
  const KategoriListScreen({super.key});

  @override
  State<KategoriListScreen> createState() => _KategoriListScreenState();
}

class _KategoriListScreenState extends State<KategoriListScreen> {
  static const _dilindungi = {SeedData.katLain};

  int _jumlahPakai(String kategoriId) {
    final trx = context.read<TransaksiProvider>();
    return trx.items.fold(
      0,
      (sum, t) => sum + t.items.where((i) => i.kategoriId == kategoriId).length,
    );
  }

  void _bukaForm([Kategori? kategori]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => KategoriFormScreen(kategori: kategori)),
    );
  }

  Future<void> _hapus(Kategori k) async {
    final provider = context.read<KategoriProvider>();
    final dipakai = _jumlahPakai(k.id);

    if (dipakai > 0) {
      await tampilkanInfo(
        context,
        judul: 'Kategori sedang dipakai',
        pesan: '"${k.nama}" dipakai oleh $dipakai item resi. '
            'Ubah kategori item tersebut terlebih dulu sebelum menghapusnya.',
      );
      return;
    }

    final ya = await konfirmasiHapus(
      context,
      judul: 'Hapus kategori?',
      pesan: '"${k.nama}" akan dihapus permanen.',
    );
    if (!ya || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.hapus(k.id);
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? 'Kategori dihapus.' : (provider.errorMessage ?? 'Gagal menghapus.')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kategori = context.watch<KategoriProvider>();
    context.watch<TransaksiProvider>();

    Widget body;
    switch (kategori.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        body = const LoadingView(pesan: 'Memuat kategori...');
      case LoadStatus.error:
        body = ErrorView(
          pesan: kategori.errorMessage ?? 'Terjadi kesalahan.',
          onRetry: kategori.muat,
        );
      case LoadStatus.success:
        body = kategori.isEmpty
            ? EmptyView(
                icon: Icons.category_rounded,
                judul: 'Belum ada kategori',
                pesan: 'Tambahkan kategori untuk mengelompokkan pengeluaran.',
                labelAksi: 'Tambah Kategori',
                onAksi: _bukaForm,
              )
            : _buildList(kategori);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Kategori')),
      body: SafeArea(child: body),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaForm,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _buildList(KategoriProvider kategori) {
    final cs = Theme.of(context).colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: kategori.items.length,
      itemBuilder: (context, index) {
        final k = kategori.items[index];
        final warna = Color(k.warna);
        final dipakai = _jumlahPakai(k.id);
        final bawaan = _dilindungi.contains(k.id);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Format.ikonKategori(k.id), color: warna),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      k.nama,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bawaan ? '$dipakai item • Kategori bawaan' : '$dipakai item',
                      style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _bukaForm(k),
              ),
              if (!bawaan)
                IconButton(
                  tooltip: 'Hapus',
                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                  onPressed: kategori.isSubmitting ? null : () => _hapus(k),
                ),
            ],
          ),
        );
      },
    );
  }
}