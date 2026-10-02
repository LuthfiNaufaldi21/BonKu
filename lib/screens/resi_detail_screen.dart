import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../widgets/state_views.dart';

/// Detail satu resi. Menerima ID (bukan objek) agar selalu membaca data terbaru
/// dan bisa menangani ID yang tidak valid.
class ResiDetailScreen extends StatelessWidget {
  final String transaksiId;

  const ResiDetailScreen({super.key, required this.transaksiId});

  @override
  Widget build(BuildContext context) {
    final trx = context.watch<TransaksiProvider>();
    final t = trx.byId(transaksiId);

    Widget body;
    if (t == null && trx.status == LoadStatus.loading) {
      body = const LoadingView();
    } else if (t == null) {
      body = EmptyView(
        icon: Icons.search_off_rounded,
        judul: 'Resi tidak ditemukan',
        pesan: 'Data mungkin sudah dihapus atau ID tidak valid.',
        labelAksi: 'Kembali',
        onAksi: () => Navigator.of(context).maybePop(),
      );
    } else {
      body = _Isi(transaksi: t);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Resi')),
      body: SafeArea(child: body),
    );
  }
}

class _Isi extends StatelessWidget {
  final Transaksi transaksi;

  const _Isi({required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final kategori = context.watch<KategoriProvider>();
    final warnaSumber = Format.warnaSumber(transaksi.sumber);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Format.ikonSumber(transaksi.sumber), color: warnaSumber, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    Format.labelSumber(transaksi.sumber),
                    style: TextStyle(color: warnaSumber, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                transaksi.toko,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${Format.tanggalPanjang(transaksi.tanggal)} • ${Format.jam(transaksi.tanggal)}',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text('Total', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              Text(
                Format.rupiah(transaksi.total),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        if (transaksi.catatan.trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Catatan', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(transaksi.catatan),
        ],
        const SizedBox(height: 24),
        Text(
          'Rincian Item (${transaksi.items.length})',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (transaksi.items.isEmpty)
          Text('Belum ada item pada resi ini.', style: TextStyle(color: cs.onSurfaceVariant))
        else
          for (final item in transaksi.items)
            Builder(builder: (context) {
              final k = kategori.byId(item.kategoriId);
              final warna = Color(k?.warna ?? 0xFF757575);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: warna.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Format.ikonKategori(item.kategoriId), color: warna, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.nama,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            kategori.namaDari(item.kategoriId),
                            style: TextStyle(color: warna, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Format.rupiah(item.harga),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }
}