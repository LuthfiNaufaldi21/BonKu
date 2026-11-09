import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/format.dart';

/// Satu titik data: total pengeluaran pada satu bulan.
class TitikBulan {
  final DateTime bulan; // tanggal 1 pada bulan tersebut
  final int total;

  const TitikBulan(this.bulan, this.total);
}

String _namaBulan(DateTime d) => Format.bulanTahun(d).substring(0, 3);

/// Indeks titik yang merupakan awal tahun baru (untuk garis pemisah tahun).
List<int> _batasTahun(List<TitikBulan> data) => [
      for (var i = 1; i < data.length; i++)
        if (data[i].bulan.year != data[i - 1].bulan.year) i,
    ];

/// Grafik pengeluaran per bulan, bisa berbentuk batang atau garis.
/// Jika titik terlalu banyak untuk lebar layar, grafik bisa digeser ke samping
/// dan otomatis berhenti di bulan terbaru. Tahun ditandai dengan strip di bawah
/// grafik dan garis pemisah putus-putus di pergantian tahun.
class GrafikBulanan extends StatefulWidget {
  final List<TitikBulan> data;
  final DateTime dipilih;
  final bool garis;
  final ValueChanged<DateTime> onPilih;

  const GrafikBulanan({
    super.key,
    required this.data,
    required this.dipilih,
    required this.garis,
    required this.onPilih,
  });

  @override
  State<GrafikBulanan> createState() => _GrafikBulananState();
}

class _GrafikBulananState extends State<GrafikBulanan> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _keAkhir();
  }

  @override
  void didUpdateWidget(GrafikBulanan lama) {
    super.didUpdateWidget(lama);
    if (lama.garis != widget.garis || lama.data.length != widget.data.length) {
      _keAkhir();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _keAkhir() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final minPerTitik = widget.garis ? 56.0 : 48.0;

    return Container(
      height: 248,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final lebar = math.max(c.maxWidth, widget.data.length * minPerTitik);
          final slot = lebar / widget.data.length;
          return SingleChildScrollView(
            controller: _scroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: lebar,
              height: c.maxHeight,
              child: Column(
                children: [
                  Expanded(
                    child: widget.garis
                        ? _GrafikGaris(data: widget.data, dipilih: widget.dipilih, onPilih: widget.onPilih)
                        : _GrafikBatang(data: widget.data, dipilih: widget.dipilih, onPilih: widget.onPilih),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(height: 20, child: _StripTahun(data: widget.data, slot: slot)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Strip tahun: "── 2025 ──" di bawah bulan-bulan tahun tersebut
// ---------------------------------------------------------------------
class _StripTahun extends StatelessWidget {
  final List<TitikBulan> data;
  final double slot;

  const _StripTahun({required this.data, required this.slot});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Kelompokkan bulan berurutan yang tahunnya sama.
    final kelompok = <MapEntry<int, int>>[]; // tahun -> jumlah bulan
    for (final t in data) {
      if (kelompok.isNotEmpty && kelompok.last.key == t.bulan.year) {
        kelompok[kelompok.length - 1] = MapEntry(t.bulan.year, kelompok.last.value + 1);
      } else {
        kelompok.add(MapEntry(t.bulan.year, 1));
      }
    }

    final garis = Container(height: 1.5, decoration: BoxDecoration(
      color: cs.outlineVariant,
      borderRadius: BorderRadius.circular(1),
    ));
    final gaya = TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 0.5);

    return Row(
      children: [
        for (final k in kelompok)
          SizedBox(
            width: slot * k.value,
            child: slot * k.value < 60
                ? Center(child: Text('${k.key}', style: gaya)) // terlalu sempit untuk garis
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      children: [
                        Expanded(child: garis),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('${k.key}', style: gaya),
                        ),
                        Expanded(child: garis),
                      ],
                    ),
                  ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// Batang
// ---------------------------------------------------------------------
class _GrafikBatang extends StatelessWidget {
  final List<TitikBulan> data;
  final DateTime dipilih;
  final ValueChanged<DateTime> onPilih;

  const _GrafikBatang({required this.data, required this.dipilih, required this.onPilih});

  // Tinggi area non-batang: label nilai (16) + jarak (4) + jarak (6) + label bulan (18).
  static const _tinggiLain = 44.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maks = math.max(1, data.fold<int>(0, (m, t) => math.max(m, t.total)));
    final semuaNilai = data.length <= 6;
    final batas = _batasTahun(data);

    return LayoutBuilder(
      builder: (context, c) {
        final slot = c.maxWidth / data.length;
        final tinggiMaks = math.min(220.0, math.max(40.0, c.maxHeight - _tinggiLain - 2));
        final lebarBatang = math.min(28.0, slot * 0.6);

        return Stack(
          fit: StackFit.expand,
          children: [
            // Garis pemisah tahun (putus-putus halus)
            for (final i in batas)
              Positioned(
                left: slot * i - 0.5,
                top: 8,
                bottom: 0,
                child: CustomPaint(
                  size: const Size(1, double.infinity),
                  painter: _PemisahPutus(cs.outlineVariant),
                ),
              ),
            Row(
              children: [
                for (var i = 0; i < data.length; i++)
                  SizedBox(
                    width: slot,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onPilih(data[i].bulan),
                      child: Builder(builder: (context) {
                        final terpilih = data[i].bulan == dipilih;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              height: 16,
                              child: (semuaNilai || terpilih)
                                  ? FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        Format.ringkas(data[i].total),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 4),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: data[i].total / maks),
                              duration: const Duration(milliseconds: 700),
                              curve: Curves.easeOutCubic,
                              builder: (context, v, _) => Container(
                                width: lebarBatang,
                                height: 4 + (tinggiMaks - 4) * v,
                                decoration: BoxDecoration(
                                  color: terpilih ? cs.primary : cs.primary.withValues(alpha: 0.35),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // FittedBox: label menyusut sendiri jika font perangkat lebih besar.
                            SizedBox(
                              height: 18,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _namaBulan(data[i].bulan),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
                                    color: terpilih ? cs.primary : cs.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Garis vertikal putus-putus untuk batas tahun pada grafik batang.
class _PemisahPutus extends CustomPainter {
  final Color warna;

  _PemisahPutus(this.warna);

  @override
  void paint(Canvas canvas, Size size) {
    final cat = Paint()
      ..color = warna
      ..strokeWidth = 1;
    var y = 0.0;
    while (y < size.height) {
      canvas.drawLine(Offset(0.5, y), Offset(0.5, math.min(y + 4, size.height)), cat);
      y += 8;
    }
  }

  @override
  bool shouldRepaint(covariant _PemisahPutus lama) => lama.warna != warna;
}

// ---------------------------------------------------------------------
// Garis
// ---------------------------------------------------------------------
class _GrafikGaris extends StatelessWidget {
  final List<TitikBulan> data;
  final DateTime dipilih;
  final ValueChanged<DateTime> onPilih;

  const _GrafikGaris({required this.data, required this.dipilih, required this.onPilih});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final indeksDipilih = data.indexWhere((t) => t.bulan == dipilih);
    final tanda = '${data.length}-${data.first.bulan}-${data.fold<int>(0, (s, t) => s + t.total)}';

    return LayoutBuilder(
      builder: (context, c) {
        final slot = c.maxWidth / data.length;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) {
            final i = (d.localPosition.dx / slot).floor().clamp(0, data.length - 1);
            onPilih(data[i].bulan);
          },
          child: TweenAnimationBuilder<double>(
            key: ValueKey(tanda), // animasi diputar ulang saat data berubah
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, progres, _) => CustomPaint(
              size: Size(c.maxWidth, c.maxHeight),
              painter: _GarisPainter(
                data: data,
                batasTahun: _batasTahun(data),
                indeksDipilih: indeksDipilih,
                progres: progres,
                warna: cs.primary,
                warnaTeks: cs.onSurfaceVariant,
                warnaGrid: cs.outlineVariant.withValues(alpha: 0.4),
                warnaPemisah: cs.outlineVariant,
                warnaLatar: cs.surface,
                warnaTeksTerpilih: cs.onPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GarisPainter extends CustomPainter {
  final List<TitikBulan> data;
  final List<int> batasTahun;
  final int indeksDipilih;
  final double progres;
  final Color warna;
  final Color warnaTeks;
  final Color warnaGrid;
  final Color warnaPemisah;
  final Color warnaLatar;
  final Color warnaTeksTerpilih;

  _GarisPainter({
    required this.data,
    required this.batasTahun,
    required this.indeksDipilih,
    required this.progres,
    required this.warna,
    required this.warnaTeks,
    required this.warnaGrid,
    required this.warnaPemisah,
    required this.warnaLatar,
    required this.warnaTeksTerpilih,
  });

  static const _atas = 30.0;
  static const _bawah = 22.0;

  TextPainter _tp(String teks, TextStyle gaya) =>
      TextPainter(text: TextSpan(text: teks, style: gaya), textDirection: TextDirection.ltr)..layout();

  void _teksTengah(Canvas canvas, String teks, Offset pusat, TextStyle gaya) {
    final tp = _tp(teks, gaya);
    tp.paint(canvas, pusat - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = data.length;
    final tinggi = size.height - _atas - _bawah;
    final slot = size.width / n;
    final maks = math.max(1, data.fold<int>(0, (m, t) => math.max(m, t.total)));

    Offset titik(int i) =>
        Offset(slot * (i + 0.5), _atas + tinggi * (1 - data[i].total / maks));

    // Garis bantu horizontal
    final grid = Paint()
      ..color = warnaGrid
      ..strokeWidth = 1;
    for (var k = 0; k <= 2; k++) {
      final y = _atas + tinggi * k / 2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    // Pemisah tahun (putus-putus)
    final pemisah = Paint()
      ..color = warnaPemisah
      ..strokeWidth = 1;
    for (final i in batasTahun) {
      final x = slot * i;
      var y = 8.0;
      while (y < size.height) {
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + 4, size.height)), pemisah);
        y += 8;
      }
    }

    // Jalur garis (kurva halus tanpa overshoot)
    final jalur = Path()..moveTo(titik(0).dx, titik(0).dy);
    for (var i = 1; i < n; i++) {
      final a = titik(i - 1);
      final b = titik(i);
      final tengah = (a.dx + b.dx) / 2;
      jalur.cubicTo(tengah, a.dy, tengah, b.dy, b.dx, b.dy);
    }

    final xAwal = titik(0).dx;
    final xAkhir = titik(n - 1).dx;
    final xKlip = xAwal + (xAkhir - xAwal) * progres;

    // Area + garis muncul dari kiri ke kanan
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, xKlip + 0.5, size.height));
    if (n > 1) {
      final area = Path.from(jalur)
        ..lineTo(xAkhir, _atas + tinggi)
        ..lineTo(xAwal, _atas + tinggi)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [warna.withValues(alpha: 0.28), warna.withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(0, _atas, size.width, tinggi)),
      );
      canvas.drawPath(
        jalur,
        Paint()
          ..color = warna
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.restore();

    // Titik, nilai, dan label bulan
    for (var i = 0; i < n; i++) {
      final p = titik(i);
      final terpilih = i == indeksDipilih;
      final tampil = p.dx <= xKlip + 0.5;

      if (tampil) {
        if (terpilih) {
          canvas.drawCircle(p, 8, Paint()..color = warna.withValues(alpha: 0.25));
          canvas.drawCircle(p, 5, Paint()..color = warna);
          canvas.drawCircle(
            p,
            5,
            Paint()
              ..color = warnaLatar
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        } else {
          canvas.drawCircle(p, 4, Paint()..color = warnaLatar);
          canvas.drawCircle(
            p,
            4,
            Paint()
              ..color = warna
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
        }

        if (terpilih) {
          // Gelembung nilai untuk titik terpilih
          final tp = _tp(
            Format.ringkas(data[i].total),
            TextStyle(color: warnaTeksTerpilih, fontSize: 11, fontWeight: FontWeight.bold),
          );
          final lebar = tp.width + 14;
          final kiri = math.min(math.max(0.0, p.dx - lebar / 2), math.max(0.0, size.width - lebar));
          final kotak = RRect.fromRectAndRadius(
            Rect.fromLTWH(kiri, p.dy - 32, lebar, 20),
            const Radius.circular(10),
          );
          canvas.drawRRect(kotak, Paint()..color = warna);
          tp.paint(canvas, Offset(kiri + 7, p.dy - 32 + (20 - tp.height) / 2));
        } else if (n <= 6) {
          _teksTengah(
            canvas,
            Format.ringkas(data[i].total),
            Offset(p.dx, p.dy - 14),
            TextStyle(color: warnaTeks, fontSize: 10),
          );
        }
      }

      // Label bulan
      _teksTengah(
        canvas,
        _namaBulan(data[i].bulan),
        Offset(p.dx, size.height - _bawah + 10),
        TextStyle(
          color: terpilih ? warna : warnaTeks,
          fontSize: 11,
          fontWeight: terpilih ? FontWeight.bold : FontWeight.normal,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GarisPainter lama) => true;
}