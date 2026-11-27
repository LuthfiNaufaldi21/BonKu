import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../utils/ringkasan.dart';
import '../widgets/state_views.dart';
import '../widgets/transaksi_card.dart';
import 'monthly_wrapped_screen.dart';
import 'resi_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onViewAllPressed;

  /// Membuka pilihan sumber resi (scan, galeri, manual); dipakai tombol di empty state.
  final VoidCallback onTambahPressed;

  const HomeScreen({
    super.key,
    required this.onViewAllPressed,
    required this.onTambahPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = context.watch<TransaksiProvider>();
    final kategori = context.watch<KategoriProvider>();

    // Spinner layar penuh hanya untuk muat pertama; saat tarik-untuk-memuat-ulang
    // isi lama tetap tampil dan indikator tarik yang berputar.
    if ((trx.status == LoadStatus.initial || trx.status == LoadStatus.loading) && trx.isEmpty) {
      return const LoadingView(pesan: 'Memuat ringkasan...');
    }
    if (trx.status == LoadStatus.error) {
      return ErrorView(
        pesan: trx.errorMessage ?? 'Terjadi kesalahan.',
        onRetry: trx.muat,
      );
    }
    if (trx.isEmpty) {
      return EmptyView(
        icon: Icons.receipt_long_rounded,
        judul: 'Belum ada resi',
        pesan: 'Catat pengeluaran pertamamu dengan scan struk atau isi manual.',
        labelAksi: 'Catat Resi Pertama',
        onAksi: onTambahPressed,
      );
    }

    final bulan = Ringkasan.bulanTerbaru(trx.items)!;
    final dataBulan = Ringkasan.pada(trx.items, bulan);
    final total = Ringkasan.total(dataBulan);
    final perKategori = Ringkasan.totalPerKategori(dataBulan).take(3).toList();
    final terbaru = trx.items.take(3).toList();
    final bulanLalu = DateTime(bulan.year, bulan.month - 1);
    final dataLalu = Ringkasan.pada(trx.items, bulanLalu);
    final totalLalu = dataLalu.isEmpty ? null : Ringkasan.total(dataLalu);

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<TransaksiProvider>().muat(),
          context.read<KategoriProvider>().muat(),
        ]);
      },
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildBalanceCard(theme, bulan, total, dataBulan.length, totalLalu, bulanLalu),
                const SizedBox(height: 24),
                _buildTopCategories(theme, kategori, perKategori, total),
                const SizedBox(height: 24),
                _buildMonthlyWrappedBanner(context, theme, bulan),
                const SizedBox(height: 32),
                _buildRecentReceiptsHeader(theme),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final t = terbaru[index];
                return TransaksiCard(
                  transaksi: t,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ResiDetailScreen(transaksiId: t.id)),
                  ),
                );
              },
              childCount: terbaru.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
      ),
    );
  }

  Widget _buildBalanceCard(
    ThemeData theme,
    DateTime bulan,
    int total,
    int jumlah,
    int? totalLalu,
    DateTime bulanLalu,
  ) {
    final cs = theme.colorScheme;
    final hsl = HSLColor.fromColor(cs.primary);
    final warnaAkhir = hsl.withLightness((hsl.lightness - 0.10).clamp(0.0, 1.0)).toColor();
    final teksUtama = cs.onPrimary;
    final teksRedup = cs.onPrimary.withValues(alpha: 0.75);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary, warnaAkhir],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Pengeluaran ${Format.bulanTahun(bulan)}',
            style: theme.textTheme.titleSmall?.copyWith(
              color: teksRedup,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Format.rupiah(total),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: teksUtama,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('$jumlah transaksi', style: TextStyle(color: teksRedup, fontSize: 12)),
          if (totalLalu != null && totalLalu > 0) ...[
            const SizedBox(height: 12),
            _buildSelisih(cs.onPrimary, total, totalLalu, bulanLalu),
          ],
        ],
      ),
    );
  }

  /// Perbandingan dengan bulan sebelumnya (Month-over-Month).
  Widget _buildSelisih(Color warna, int total, int totalLalu, DateTime bulanLalu) {
    final selisih = total - totalLalu;
    final persen = (selisih.abs() * 100 / totalLalu).round();
    final nama = Format.bulanTahun(bulanLalu);
    final IconData ikon;
    final String teks;
    if (persen == 0) {
      ikon = Icons.trending_flat_rounded;
      teks = 'Hampir sama dengan $nama';
    } else if (selisih > 0) {
      ikon = Icons.trending_up_rounded;
      teks = 'Naik $persen% dari $nama';
    } else {
      ikon = Icons.trending_down_rounded;
      teks = 'Turun $persen% dari $nama';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 16, color: warna),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              teks,
              style: TextStyle(color: warna, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(
    ThemeData theme,
    KategoriProvider kategori,
    List<MapEntry<String, int>> data,
    int total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Terbesar',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < data.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(
                child: _buildCategoryChip(
                  Format.ikonKategori(data[i].key),
                  kategori.namaDari(data[i].key),
                  total == 0 ? '0%' : '${(data[i].value * 100 / total).round()}%',
                  Color(kategori.byId(data[i].key)?.warna ?? 0xFF757575),
                  theme,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    IconData icon,
    String label,
    String percentage,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  percentage,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Wrapped dianggap "siap" untuk bulan yang sudah berakhir atau pada 3 hari
  /// terakhir bulan berjalan (FR-05: ditampilkan di akhir bulan). Sebelum itu
  /// tetap bisa dibuka, tetapi diberi label pratinjau.
  bool _wrappedSiap(DateTime bulan) {
    final sekarang = DateTime.now();
    final bulanIni = DateTime(sekarang.year, sekarang.month);
    if (DateTime(bulan.year, bulan.month).isBefore(bulanIni)) return true;
    final hariTerakhir = DateTime(bulan.year, bulan.month + 1, 0).day;
    return sekarang.day >= hariTerakhir - 2;
  }

  Widget _buildMonthlyWrappedBanner(BuildContext context, ThemeData theme, DateTime bulan) {
    final siap = _wrappedSiap(bulan);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MonthlyWrappedScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      siap ? 'Monthly Wrapped Siap!' : 'Monthly Wrapped Bulan Ini',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      siap
                          ? 'Evaluasi tren pengeluaran ${Format.bulanTahun(bulan)}.'
                          : 'Pratinjau ${Format.bulanTahun(bulan)}, bulan ini belum berakhir.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReceiptsHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Riwayat Struk',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onViewAllPressed,
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }
}