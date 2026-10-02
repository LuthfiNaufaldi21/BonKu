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

  const HomeScreen({super.key, required this.onViewAllPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = context.watch<TransaksiProvider>();
    final kategori = context.watch<KategoriProvider>();

    if (trx.status == LoadStatus.initial || trx.status == LoadStatus.loading) {
      return const LoadingView(pesan: 'Memuat ringkasan...');
    }
    if (trx.status == LoadStatus.error) {
      return ErrorView(
        pesan: trx.errorMessage ?? 'Terjadi kesalahan.',
        onRetry: trx.muat,
      );
    }
    if (trx.isEmpty) {
      return const EmptyView(
        icon: Icons.receipt_long_rounded,
        judul: 'Belum ada transaksi',
        pesan: 'Tekan tombol scan di tengah untuk mencatat pengeluaran pertama.',
      );
    }

    final bulan = Ringkasan.bulanTerbaru(trx.items)!;
    final dataBulan = Ringkasan.pada(trx.items, bulan);
    final total = Ringkasan.total(dataBulan);
    final perKategori = Ringkasan.totalPerKategori(dataBulan).take(3).toList();
    final terbaru = trx.items.take(3).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildBalanceCard(theme, bulan, total, dataBulan.length),
                const SizedBox(height: 24),
                _buildTopCategories(theme, kategori, perKategori, total),
                const SizedBox(height: 24),
                _buildMonthlyWrappedBanner(context, theme),
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
    );
  }

  Widget _buildBalanceCard(ThemeData theme, DateTime bulan, int total, int jumlah) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withBlue(180)],
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
              color: Colors.white70,
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
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('$jumlah transaksi', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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

  Widget _buildMonthlyWrappedBanner(BuildContext context, ThemeData theme) {
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
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.insights_rounded, color: Colors.deepPurple, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Wrapped Siap!',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Evaluasi tren pengeluaran bulan lalu.',
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