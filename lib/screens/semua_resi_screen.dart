import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../widgets/state_views.dart';
import '../widgets/transaksi_card.dart';
import 'resi_detail_screen.dart';

class SemuaResiScreen extends StatefulWidget {
  const SemuaResiScreen({super.key});

  @override
  State<SemuaResiScreen> createState() => _SemuaResiScreenState();
}

class _SemuaResiScreenState extends State<SemuaResiScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  SumberResi? _sumber; // null = semua sumber

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter gabungan: sumber + kata kunci (toko, nama item, atau nominal).
  List<Transaksi> _filter(List<Transaksi> data) {
    final q = _query.trim().toLowerCase();
    final angka = q.replaceAll(RegExp(r'[^0-9]'), '');
    return data.where((t) {
      if (_sumber != null && t.sumber != _sumber) return false;
      if (q.isEmpty) return true;
      return t.toko.toLowerCase().contains(q) ||
          t.items.any((i) => i.nama.toLowerCase().contains(q)) ||
          (angka.isNotEmpty && t.total.toString().contains(angka));
    }).toList();
  }

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _query = '';
      _sumber = null;
    });
  }

  void _bukaDetail(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResiDetailScreen(transaksiId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final trx = context.watch<TransaksiProvider>();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semua Resi & Transaksi',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riwayat otomatis dari scan kamera & share intent',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchBar(theme),
                  const SizedBox(height: 12),
                  _buildSumberChips(),
                ],
              ),
            ),
            Expanded(child: _buildBody(trx, theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(TransaksiProvider trx, ThemeData theme) {
    switch (trx.status) {
      case LoadStatus.initial:
      case LoadStatus.loading:
        return const LoadingView(pesan: 'Memuat resi...');
      case LoadStatus.error:
        return ErrorView(
          pesan: trx.errorMessage ?? 'Terjadi kesalahan.',
          onRetry: trx.muat,
        );
      case LoadStatus.success:
        if (trx.isEmpty) {
          return const EmptyView(
            icon: Icons.receipt_long_rounded,
            judul: 'Belum ada resi',
            pesan: 'Tekan tombol scan di tengah untuk menambahkan resi pertama.',
          );
        }
        final hasil = _filter(trx.items);
        if (hasil.isEmpty) {
          return EmptyView(
            icon: Icons.search_off_rounded,
            judul: 'Resi tidak ditemukan',
            pesan: 'Coba kata kunci lain atau hapus filter yang aktif.',
            labelAksi: 'Reset filter',
            onAksi: _resetFilter,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Menampilkan ${hasil.length} dari ${trx.items.length} resi',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: hasil.length,
                itemBuilder: (context, index) {
                  final t = hasil[index];
                  return TransaksiCard(transaksi: t, onTap: () => _bukaDetail(t.id));
                },
              ),
            ),
          ],
        );
    }
  }

  Widget _buildSearchBar(ThemeData theme) {
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: cs.onSurface, fontSize: 14),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Cari toko, nama barang, atau nominal...',
          hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 22),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Hapus pencarian',
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  Widget _buildSumberChips() {
    Widget chip(String label, SumberResi? nilai) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(label),
            selected: _sumber == nilai,
            onSelected: (_) => setState(() => _sumber = nilai),
          ),
        );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('Semua', null),
          for (final s in SumberResi.values) chip(Format.labelSumber(s), s),
        ],
      ),
    );
  }
}