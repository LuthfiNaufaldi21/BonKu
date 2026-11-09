import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../utils/ringkasan.dart';
import '../widgets/grafik_bulanan.dart';
import '../widgets/state_views.dart';
import '../widgets/transaksi_card.dart';
import 'monthly_wrapped_screen.dart';
import 'resi_detail_screen.dart';

class StatistikScreen extends StatefulWidget {
  const StatistikScreen({super.key});

  @override
  State<StatistikScreen> createState() => _StatistikScreenState();
}

class _StatistikScreenState extends State<StatistikScreen> {
  DateTime? _dipilih; // bulan yang sedang dilihat; null = bulan terbaru
  bool _garis = false; // false = batang, true = garis
  int? _rentang = 6; // jumlah bulan terakhir; null = semua

  /// Deret bulan tanpa celah, dari bulan transaksi pertama sampai terakhir.
  /// Bulan tanpa transaksi tetap muncul (bernilai 0).
  List<DateTime> _deretBulan(List<Transaksi> semua) {
    final ada = Ringkasan.daftarBulan(semua);
    if (ada.isEmpty) return [];
    final hasil = <DateTime>[];
    var b = ada.first;
    while (!b.isAfter(ada.last)) {
      hasil.add(b);
      b = DateTime(b.year, b.month + 1);
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trx = context.watch<TransaksiProvider>();
    final kategori = context.watch<KategoriProvider>();

    Widget isi;
    if (trx.status == LoadStatus.error) {
      isi = ErrorView(
        pesan: trx.errorMessage ?? 'Terjadi kesalahan.',
        onRetry: trx.muat,
      );
    } else if (trx.status != LoadStatus.success) {
      isi = const LoadingView(pesan: 'Memuat statistik...');
    } else if (trx.isEmpty) {
      isi = const EmptyView(
        icon: Icons.bar_chart_rounded,
        judul: 'Belum ada data statistik',
        pesan: 'Catat pengeluaran terlebih dulu agar grafik dan analisis muncul.',
      );
    } else {
      isi = _buildIsi(theme, trx, kategori);
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Text(
                'Statistik Pengeluaran',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(child: isi),
          ],
        ),
      ),
    );
  }

  Widget _buildIsi(ThemeData theme, TransaksiProvider trx, KategoriProvider kategori) {
    final semua = trx.items;
    final deret = _deretBulan(semua);
    final jendela = (_rentang == null || deret.length <= _rentang!)
        ? deret
        : deret.sublist(deret.length - _rentang!);
    final bulan = (_dipilih != null && jendela.contains(_dipilih)) ? _dipilih! : jendela.last;

    final titik = [
      for (final b in jendela) TitikBulan(b, Ringkasan.total(Ringkasan.pada(semua, b))),
    ];

    final dataBulan = Ringkasan.pada(semua, bulan);
    final total = Ringkasan.total(dataBulan);
    final sebelumnya = Ringkasan.total(
      Ringkasan.pada(semua, DateTime(bulan.year, bulan.month - 1)),
    );
    final perKategori = Ringkasan.totalPerKategori(dataBulan);
    final terbesar = [...dataBulan]..sort((a, b) => b.total.compareTo(a.total));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      children: [
        _buildWrappedCard(context, theme, bulan),
        const SizedBox(height: 24),
        Text(
          'Grafik Bulanan',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildKontrolGrafik(theme),
        const SizedBox(height: 8),
        Text(
          '${jendela.length} bulan • ${_ringkasBulan(jendela.first)} – ${_ringkasBulan(jendela.last)}'
          '${jendela.length > 6 ? ' • geser untuk melihat bulan lain' : ''}',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 12),
        GrafikBulanan(
          data: titik,
          dipilih: bulan,
          garis: _garis,
          onPilih: (b) => setState(() => _dipilih = b),
        ),
        const SizedBox(height: 4),
        Text(
          _garis ? 'Ketuk titik untuk melihat bulan lain' : 'Ketuk batang untuk melihat bulan lain',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildTotalBulan(theme, bulan, total, sebelumnya, dataBulan.length),
        const SizedBox(height: 24),
        if (dataBulan.isEmpty)
          _buildBulanKosong(theme, bulan)
        else ...[
          Text(
            'Rincian Kategori',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final e in perKategori) _buildKategoriRow(theme, kategori, e.key, e.value, total),
          const SizedBox(height: 12),
          Text(
            'Transaksi Terbesar',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          for (final t in terbesar.take(3))
            TransaksiCard(
              transaksi: t,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ResiDetailScreen(transaksiId: t.id)),
              ),
            ),
        ],
      ],
    );
  }

  String _ringkasBulan(DateTime b) => '${Format.bulanTahun(b).substring(0, 3)} ${b.year}';

  Widget _buildKontrolGrafik(ThemeData theme) {
    const pilihanRentang = <int?>[3, 6, 12, null];

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: false, icon: Icon(Icons.bar_chart_rounded), label: Text('Batang')),
            ButtonSegment(value: true, icon: Icon(Icons.show_chart_rounded), label: Text('Garis')),
          ],
          selected: {_garis},
          onSelectionChanged: (s) => setState(() => _garis = s.first),
        ),
        Wrap(
          spacing: 8,
          children: [
            for (final r in pilihanRentang)
              ChoiceChip(
                label: Text(r == null ? 'Semua' : '$r bln'),
                selected: _rentang == r,
                onSelected: (_) => setState(() => _rentang = r),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBulanKosong(ThemeData theme, DateTime bulan) {
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.event_busy_rounded, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tidak ada transaksi pada ${Format.bulanTahun(bulan)}.',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrappedCard(BuildContext context, ThemeData theme, DateTime bulan) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Monthly Wrapped Siap!',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Evaluasi tren pengeluaran ${Format.bulanTahun(bulan)} secara interaktif.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MonthlyWrappedScreen(bulan: bulan)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.deepPurple,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Lihat Analisis', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBulan(ThemeData theme, DateTime bulan, int total, int sebelumnya, int jumlah) {
    final cs = theme.colorScheme;
    Widget banding;
    if (sebelumnya == 0) {
      banding = Text(
        'Belum ada data bulan sebelumnya untuk dibandingkan',
        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
      );
    } else {
      final selisih = total - sebelumnya;
      final persen = (selisih.abs() * 100 / sebelumnya).round();
      final naik = selisih > 0;
      final warna = selisih == 0 ? Colors.grey : (naik ? Colors.redAccent : Colors.green);
      banding = Row(
        children: [
          Icon(
            selisih == 0
                ? Icons.drag_handle_rounded
                : (naik ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
            size: 16,
            color: warna,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              selisih == 0 ? 'Sama dengan bulan lalu' : '$persen% dibanding bulan lalu',
              style: TextStyle(color: warna, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total ${Format.bulanTahun(bulan)} • $jumlah transaksi',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Format.rupiah(total),
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          banding,
        ],
      ),
    );
  }

  Widget _buildKategoriRow(
    ThemeData theme,
    KategoriProvider kategori,
    String kategoriId,
    int nilai,
    int total,
  ) {
    final cs = theme.colorScheme;
    final warna = Color(kategori.byId(kategoriId)?.warna ?? 0xFF757575);
    final fraksi = total == 0 ? 0.0 : nilai / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Format.ikonKategori(kategoriId), color: warna, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  kategori.namaDari(kategoriId),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Format.rupiah(nilai), style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '${(fraksi * 100).round()}%',
                    style: TextStyle(color: warna, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraksi),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: warna.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(warna),
              ),
            ),
          ),
        ],
      ),
    );
  }
}