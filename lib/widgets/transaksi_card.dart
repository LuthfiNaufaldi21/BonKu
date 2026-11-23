import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/kategori_provider.dart';
import '../utils/format.dart';

class TransaksiCard extends StatelessWidget {
  final Transaksi transaksi;
  final VoidCallback onTap;

  const TransaksiCard({super.key, required this.transaksi, required this.onTap});

  /// Kategori dengan total harga terbesar pada resi ini; dipakai sebagai logo
  /// kartu. Null jika resi belum punya item.
  String? get _kategoriUtama {
    if (transaksi.items.isEmpty) return null;
    final total = <String, int>{};
    for (final i in transaksi.items) {
      total[i.kategoriId] = (total[i.kategoriId] ?? 0) + i.harga;
    }
    return total.entries.reduce((a, b) => b.value > a.value ? b : a).key;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final warnaSumber = Format.warnaSumber(transaksi.sumber);

    // Logo kartu mengikuti kategori utama resi; tanpa item, pakai ikon sumber.
    final kategoriId = _kategoriUtama;
    final kategori = context.watch<KategoriProvider>();
    final warnaLogo = kategoriId == null
        ? warnaSumber
        : Color(kategori.byId(kategoriId)?.warna ?? 0xFF757575);
    final ikonLogo = kategoriId == null
        ? Format.ikonSumber(transaksi.sumber)
        : Format.ikonKategori(kategoriId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: warnaLogo.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(ikonLogo, color: warnaLogo),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaksi.toko,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaksi.items.length} item • ${Format.tanggalJam(transaksi.tanggal)}',
                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${Format.rupiah(transaksi.total)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Format.labelSumber(transaksi.sumber),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: warnaSumber,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}