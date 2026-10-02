import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/kategori_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../utils/ringkasan.dart';
import '../widgets/state_views.dart';

const _namaHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _singkatHari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

class _WrappedData {
  final DateTime bulan;
  final int total;
  final int jumlah;
  final List<MapEntry<String, int>> perKategori;
  final Transaksi terbesar;
  final List<int> perHari; 
  final int hariBoros;
  final int? totalSebelumnya;

  const _WrappedData({
    required this.bulan,
    required this.total,
    required this.jumlah,
    required this.perKategori,
    required this.terbesar,
    required this.perHari,
    required this.hariBoros,
    required this.totalSebelumnya,
  });

  static _WrappedData? dari(List<Transaksi> semua, DateTime bulan) {
    final data = Ringkasan.pada(semua, bulan);
    if (data.isEmpty) return null;
    final perKategori = Ringkasan.totalPerKategori(data);
    if (perKategori.isEmpty) return null; 

    final perHari = List<int>.filled(7, 0);
    for (final t in data) {
      perHari[t.tanggal.weekday - 1] += t.total;
    }
    var hari = 0;
    for (var i = 1; i < 7; i++) {
      if (perHari[i] > perHari[hari]) hari = i;
    }

    final sebelumnya = Ringkasan.pada(semua, DateTime(bulan.year, bulan.month - 1));

    return _WrappedData(
      bulan: bulan,
      total: Ringkasan.total(data),
      jumlah: data.length,
      perKategori: perKategori,
      terbesar: data.reduce((a, b) => a.total >= b.total ? a : b),
      perHari: perHari,
      hariBoros: hari,
      totalSebelumnya: sebelumnya.isEmpty ? null : Ringkasan.total(sebelumnya),
    );
  }
}

class MonthlyWrappedScreen extends StatelessWidget {
  final DateTime? bulan;

  const MonthlyWrappedScreen({super.key, this.bulan});

  Widget _gelap(Widget child) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Theme(data: ThemeData.dark(useMaterial3: true), child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trx = context.watch<TransaksiProvider>();
    final kategori = context.watch<KategoriProvider>();

    if (trx.status == LoadStatus.error) {
      return _gelap(ErrorView(
        pesan: trx.errorMessage ?? 'Terjadi kesalahan.',
        onRetry: trx.muat,
      ));
    }
    if (trx.status != LoadStatus.success) {
      return _gelap(const LoadingView(pesan: 'Menyiapkan Wrapped...'));
    }

    final pilih = bulan ?? Ringkasan.bulanTerbaru(trx.items);
    final data = pilih == null ? null : _WrappedData.dari(trx.items, pilih);
    if (data == null) {
      return _gelap(EmptyView(
        icon: Icons.insights_rounded,
        judul: 'Belum ada data untuk Wrapped',
        pesan: 'Catat pengeluaran terlebih dulu agar ringkasan bulananmu bisa dibuat.',
        labelAksi: 'Kembali',
        onAksi: () => Navigator.of(context).maybePop(),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: _WrappedPlayer(slides: _susunSlide(data, kategori)),
    );
  }

  List<Widget> _susunSlide(_WrappedData d, KategoriProvider kategori) {
    final bagian = Format.bulanTahun(d.bulan).split(' ');
    final topKategori = d.perKategori.first;
    final namaTop = kategori.namaDari(topKategori.key);
    final warnaTop = Color(kategori.byId(topKategori.key)?.warna ?? 0xFF757575);
    final persenTop = d.total == 0 ? 0 : (topKategori.value * 100 / d.total).round();
    final top3 = d.perKategori.take(3).toList();
    final maksTop = top3.first.value;

    final intro = _Frame(
      warna: const [Color(0xFF5B2EFF), Color(0xFFE91E63)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Reveal(child: Icon(Icons.auto_awesome_rounded, color: Colors.yellowAccent, size: 40)),
          const SizedBox(height: 24),
          const _Reveal(delay: Duration(milliseconds: 150), child: _Label('BONKU WRAPPED')),
          const SizedBox(height: 12),
          _Reveal(
            delay: const Duration(milliseconds: 300),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                bagian.first,
                style: const TextStyle(
                  color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -2,
                ),
              ),
            ),
          ),
          _Reveal(
            delay: const Duration(milliseconds: 420),
            child: Text(
              bagian.last,
              style: const TextStyle(
                color: Colors.yellowAccent, fontSize: 64, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _Reveal(
            delay: Duration(milliseconds: 650),
            child: Text(
              'Yuk lihat ke mana saja uangmu pergi bulan ini.',
              style: TextStyle(color: Colors.white70, fontSize: 18, height: 1.3),
            ),
          ),
          const SizedBox(height: 32),
          const _Reveal(
            delay: Duration(milliseconds: 900),
            child: Text('Ketuk untuk lanjut  →', style: TextStyle(color: Colors.white54, fontSize: 12)),
          ),
        ],
      ),
    );

    final totalSlide = _Frame(
      warna: const [Color(0xFF1E3C72), Color(0xFF2A9D8F)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Reveal(child: _Label('TOTAL PENGELUARAN')),
          const SizedBox(height: 12),
          const _Reveal(delay: Duration(milliseconds: 150), child: _Judul('Bulan ini kamu\nmenghabiskan')),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 400),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: d.total.toDouble()),
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Format.rupiah(v.round()),
                  style: const TextStyle(
                    color: Colors.yellowAccent, fontSize: 56, fontWeight: FontWeight.w900, height: 1.1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _Reveal(
            delay: const Duration(milliseconds: 900),
            child: Text(
              'dari ${d.jumlah} transaksi • rata-rata ${Format.rupiah((d.total / d.jumlah).round())} per transaksi',
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.3),
            ),
          ),
        ],
      ),
    );

    final kategoriSlide = _Frame(
      warna: const [Color(0xFFFF8008), Color(0xFFD32F2F)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Reveal(child: _Label('KATEGORI TERATAS')),
          const SizedBox(height: 12),
          const _Reveal(delay: Duration(milliseconds: 150), child: _Judul('Uangmu paling banyak\nlari ke...')),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 400),
            child: Row(
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Format.ikonKategori(topKategori.key), color: warnaTop, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    namaTop,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _Reveal(
            delay: const Duration(milliseconds: 600),
            child: Text(
              '$persenTop% dari total pengeluaranmu',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const SizedBox(height: 24),
          for (var i = 0; i < top3.length; i++)
            _Reveal(
              delay: Duration(milliseconds: 800 + i * 150),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text('${i + 1}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w900)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            kategori.namaDari(top3[i].key),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Format.rupiah(top3[i].value),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _BatangMendatar(fraksi: maksTop == 0 ? 0 : top3[i].value / maksTop),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    final item = d.terbesar.items.isEmpty
        ? null
        : d.terbesar.items.reduce((a, b) => a.harga >= b.harga ? a : b);
    final terbesarSlide = _Frame(
      warna: const [Color(0xFFD81B60), Color(0xFF4527A0)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Reveal(child: _Label('PENGELUARAN TERBESAR')),
          const SizedBox(height: 12),
          const _Reveal(delay: Duration(milliseconds: 150), child: _Judul('Satu transaksi yang\npaling menguras...')),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 400),
            child: Text(
              d.terbesar.toko,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, height: 1.1),
            ),
          ),
          const SizedBox(height: 8),
          _Reveal(
            delay: const Duration(milliseconds: 600),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Format.rupiah(d.terbesar.total),
                style: const TextStyle(
                  color: Colors.yellowAccent, fontSize: 52, fontWeight: FontWeight.w900, height: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Reveal(
            delay: const Duration(milliseconds: 850),
            child: Text(
              '${Format.tanggalPanjang(d.terbesar.tanggal)} • ${d.terbesar.items.length} item'
              '${item == null ? '' : '\nTermahal: ${item.nama} (${Format.rupiah(item.harga)})'}',
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );

    final maksHari = d.perHari.fold<int>(0, (m, v) => v > m ? v : m);
    final hariSlide = _Frame(
      warna: const [Color(0xFF00897B), Color(0xFF1565C0)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Reveal(child: _Label('HARI PALING BOROS')),
          const SizedBox(height: 12),
          const _Reveal(delay: Duration(milliseconds: 150), child: _Judul('Dompetmu paling sering\nterkuras di hari...')),
          const SizedBox(height: 16),
          _Reveal(
            delay: const Duration(milliseconds: 400),
            child: Text(
              _namaHari[d.hariBoros],
              style: const TextStyle(
                color: Colors.yellowAccent, fontSize: 56, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _Reveal(
            delay: const Duration(milliseconds: 600),
            child: Text(
              '${Format.rupiah(d.perHari[d.hariBoros])} habis di hari ini',
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _BatangVertikal(
                            fraksi: maksHari == 0 ? 0 : d.perHari[i] / maksHari,
                            tinggiMaks: 100,
                            warna: i == d.hariBoros ? Colors.yellowAccent : Colors.white.withValues(alpha: 0.45),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _singkatHari[i],
                            style: TextStyle(
                              color: i == d.hariBoros ? Colors.yellowAccent : Colors.white70,
                              fontSize: 11,
                              fontWeight: i == d.hariBoros ? FontWeight.w900 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    final sebelumnya = d.totalSebelumnya;
    late final Widget bandingSlide;
    if (sebelumnya == null) {
      bandingSlide = const _Frame(
        warna: [Color(0xFF1565C0), Color(0xFF00ACC1)],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Reveal(child: _Label('VS BULAN LALU')),
            SizedBox(height: 12),
            _Reveal(delay: Duration(milliseconds: 150), child: _Judul('Belum ada\npembanding')),
            SizedBox(height: 20),
            _Reveal(
              delay: Duration(milliseconds: 400),
              child: Text(
                'Catat pengeluaran di bulan sebelumnya agar tren naik-turunnya bisa kita bandingkan.',
                style: TextStyle(color: Colors.white70, fontSize: 17, height: 1.4),
              ),
            ),
          ],
        ),
      );
    } else {
      final selisih = d.total - sebelumnya;
      final persen = (selisih.abs() * 100 / sebelumnya).round();
      final naik = selisih > 0;
      final sama = selisih == 0;
      final maks = d.total > sebelumnya ? d.total : sebelumnya;
      final bulanLalu = DateTime(d.bulan.year, d.bulan.month - 1);
      bandingSlide = _Frame(
        warna: sama
            ? const [Color(0xFF1565C0), Color(0xFF00ACC1)]
            : (naik
                ? const [Color(0xFFEF6C00), Color(0xFFC62828)]
                : const [Color(0xFF2E7D32), Color(0xFF9CCC65)]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Reveal(child: _Label('VS BULAN LALU')),
            const SizedBox(height: 12),
            _Reveal(
              delay: const Duration(milliseconds: 150),
              child: _Judul(sama ? 'Pengeluaranmu\nsama persis' : (naik ? 'Pengeluaranmu\nnaik' : 'Pengeluaranmu\nturun')),
            ),
            const SizedBox(height: 12),
            if (!sama)
              _Reveal(
                delay: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    Icon(
                      naik ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$persen%',
                      style: const TextStyle(
                        color: Colors.yellowAccent, fontSize: 64, fontWeight: FontWeight.w900, height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _KolomBanding(
                      label: Format.bulanTahun(bulanLalu).substring(0, 3),
                      nilai: sebelumnya,
                      fraksi: maks == 0 ? 0 : sebelumnya / maks,
                      warna: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _KolomBanding(
                      label: Format.bulanTahun(d.bulan).substring(0, 3),
                      nilai: d.total,
                      fraksi: maks == 0 ? 0 : d.total / maks,
                      warna: Colors.yellowAccent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _Reveal(
              delay: const Duration(milliseconds: 900),
              child: Text(
                sama
                    ? 'Konsisten banget. Pertahankan ritmenya!'
                    : (naik
                        ? 'Yuk atur lagi anggaran bulan depan.'
                        : 'Kabar baik! Pertahankan ya.'),
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    Widget baris(IconData ikon, String label, String nilai) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(ikon, color: Colors.white70, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white70)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nilai,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );

    final akhir = _Frame(
      warna: const [Color(0xFF1A1A2E), Color(0xFF6A1B9A)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Reveal(child: _Label('RINGKASAN')),
          const SizedBox(height: 12),
          _Reveal(
            delay: const Duration(milliseconds: 150),
            child: _Judul('${Format.bulanTahun(d.bulan)},\nsecara singkat'),
          ),
          const SizedBox(height: 20),
          _Reveal(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  baris(Icons.payments_rounded, 'Total', Format.rupiah(d.total)),
                  baris(Icons.receipt_long_rounded, 'Transaksi', '${d.jumlah} resi'),
                  baris(Icons.category_rounded, 'Kategori teratas', namaTop),
                  baris(Icons.event_rounded, 'Hari terboros', _namaHari[d.hariBoros]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _Reveal(
            delay: Duration(milliseconds: 800),
            child: Text(
              'Terima kasih sudah mencatat! 💜',
              style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
            ),
          ),
        ],
      ),
    );

    return [intro, totalSlide, kategoriSlide, terbesarSlide, hariSlide, bandingSlide, akhir];
  }
}

class _WrappedPlayer extends StatefulWidget {
  final List<Widget> slides;

  const _WrappedPlayer({required this.slides});

  @override
  State<_WrappedPlayer> createState() => _WrappedPlayerState();
}

class _WrappedPlayerState extends State<_WrappedPlayer> with SingleTickerProviderStateMixin {
  final PageController _page = PageController();
  late final AnimationController _progress;
  int _index = 0;

  int get _jumlah => widget.slides.length;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..addStatusListener((status) {
        // Hapus pengecekan kondisi agar _lanjut() dipanggil di semua slide
        if (status == AnimationStatus.completed) {
          _lanjut(); 
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _progress.dispose();
    _page.dispose();
    super.dispose();
  }

  void _lanjut() {
    if (_index < _jumlah - 1) {
      _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _kembali() {
    if (_index > 0) {
      _page.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      _progress.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final atas = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        PageView(
          controller: _page,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) {
            setState(() => _index = i);
            _progress.forward(from: 0);
          },
          children: widget.slides,
        ),
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, c) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => d.localPosition.dx < c.maxWidth / 3 ? _kembali() : _lanjut(),
              onLongPressStart: (_) => _progress.stop(),
              onLongPressEnd: (_) => _progress.forward(),
              onHorizontalDragEnd: (d) {
                final v = d.primaryVelocity ?? 0;
                if (v < -300) {
                  _lanjut();
                } else if (v > 300) {
                  _kembali();
                }
              },
            ),
          ),
        ),
        Positioned(
          top: atas + 12,
          left: 12,
          right: 12,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) => Row(
                children: [
                  for (var i = 0; i < _jumlah; i++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: i < _index ? 1 : (i == _index ? _progress.value : 0),
                            minHeight: 4,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: atas + 18,
          right: 4,
          child: IconButton(
            tooltip: 'Tutup',
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}

class _Frame extends StatelessWidget {
  final List<Color> warna;
  final Widget child;

  const _Frame({required this.warna, required this.child});

  @override
  Widget build(BuildContext context) {
    final atas = MediaQuery.of(context).padding.top;
    final bawah = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: warna,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -90, right: -70, child: _Bulat(ukuran: 260, alpha: 0.08)),
          Positioned(bottom: -110, left: -80, child: _Bulat(ukuran: 300, alpha: 0.06)),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.fromLTRB(28, atas + 64, 28, bawah + 32),
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: Align(alignment: Alignment.centerLeft, child: child),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bulat extends StatelessWidget {
  final double ukuran;
  final double alpha;

  const _Bulat({required this.ukuran, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ukuran,
      width: ukuran,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _Reveal extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _Reveal({required this.child, this.delay = Duration.zero});

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kurva = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: kurva,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(kurva),
        child: widget.child,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String teks;

  const _Label(this.teks);

  @override
  Widget build(BuildContext context) {
    return Text(
      teks,
      style: const TextStyle(
        color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2.5,
      ),
    );
  }
}

class _Judul extends StatelessWidget {
  final String teks;

  const _Judul(this.teks);

  @override
  Widget build(BuildContext context) {
    return Text(
      teks,
      style: const TextStyle(
        color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.8,
      ),
    );
  }
}

class _BatangMendatar extends StatelessWidget {
  final double fraksi;

  const _BatangMendatar({required this.fraksi});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraksi.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: v,
          minHeight: 8,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          valueColor: const AlwaysStoppedAnimation(Colors.white),
        ),
      ),
    );
  }
}

class _BatangVertikal extends StatelessWidget {
  final double fraksi;
  final double tinggiMaks;
  final Color warna;

  const _BatangVertikal({required this.fraksi, required this.tinggiMaks, required this.warna});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: fraksi.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        width: double.infinity,
        height: 4 + (tinggiMaks - 4) * v,
        decoration: BoxDecoration(
          color: warna,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    );
  }
}

class _KolomBanding extends StatelessWidget {
  final String label;
  final int nilai;
  final double fraksi;
  final Color warna;

  const _KolomBanding({
    required this.label,
    required this.nilai,
    required this.fraksi,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          Format.ringkas(nilai),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 4),
        _BatangVertikal(fraksi: fraksi, tinggiMaks: 96, warna: warna),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}