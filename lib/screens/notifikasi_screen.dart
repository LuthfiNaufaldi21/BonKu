import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kategori_provider.dart';
import '../providers/preferensi_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../utils/ringkasan.dart';
import '../widgets/state_views.dart';
import 'monthly_wrapped_screen.dart';
import 'resi_detail_screen.dart';

class _Notif {
  final String id;
  final String judul;
  final String isi;
  final String waktu;
  final IconData ikon;
  final Color warna;
  final VoidCallback? aksi;

  const _Notif({
    required this.id,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.ikon,
    required this.warna,
    this.aksi,
  });
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  final Set<String> _dibaca = {};

  List<_Notif> _susun(
    BuildContext context,
    PreferensiProvider pref,
    TransaksiProvider trx,
    KategoriProvider kategori,
  ) {
    final daftar = <_Notif>[];

    if (pref.pengingatAktif) {
      final harian = pref.frekuensi == FrekuensiPengingat.harian;
      daftar.add(_Notif(
        id: 'pengingat',
        judul: harian ? 'Waktunya Catat Pengeluaran!' : 'Waktunya Rekap Bulanan!',
        isi: 'Pengingat ${pref.jadwalTeks}. Yuk scan struk agar keuanganmu tetap terkontrol.',
        waktu: harian ? 'Hari ini, ${pref.jamTeks}' : 'Akhir bulan',
        ikon: Icons.notifications_active_rounded,
        warna: Colors.orange,
      ));
    }

    final bulan = Ringkasan.bulanTerbaru(trx.items);
    if (bulan != null) {
      final dataBulan = Ringkasan.pada(trx.items, bulan);
      final total = Ringkasan.total(dataBulan);

      daftar.add(_Notif(
        id: 'wrapped-${bulan.year}-${bulan.month}',
        judul: 'Monthly Wrapped ${Format.bulanTahun(bulan)} Siap 🎉',
        isi: 'Evaluasi tren pengeluaranmu sudah bisa dilihat. Ketuk untuk membukanya.',
        waktu: Format.bulanTahun(bulan),
        ikon: Icons.insights_rounded,
        warna: Colors.deepPurple,
        aksi: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MonthlyWrappedScreen(bulan: bulan)),
        ),
      ));

      final perKategori = Ringkasan.totalPerKategori(dataBulan);
      if (perKategori.isNotEmpty && total > 0) {
        final top = perKategori.first;
        final persen = (top.value * 100 / total).round();
        if (persen >= 30) {
          daftar.add(_Notif(
            id: 'kategori-${top.key}-${bulan.year}-${bulan.month}',
            judul: 'Peringatan Kategori ${kategori.namaDari(top.key)}',
            isi: 'Kategori ini sudah $persen% dari total pengeluaran ${Format.bulanTahun(bulan)} '
                '(${Format.rupiah(top.value)}).',
            waktu: Format.bulanTahun(bulan),
            ikon: Icons.warning_rounded,
            warna: Colors.redAccent,
          ));
        }
      }
    }

    for (final t in trx.items.take(3)) {
      daftar.add(_Notif(
        id: 'resi-${t.id}',
        judul: 'Resi ${t.toko} berhasil dicatat',
        isi: '${Format.rupiah(t.total)} • ${t.items.length} item via ${Format.labelSumber(t.sumber)}.',
        waktu: Format.tanggalJam(t.tanggal),
        ikon: Icons.check_circle_rounded,
        warna: Colors.green,
        aksi: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResiDetailScreen(transaksiId: t.id)),
        ),
      ));
    }

    return daftar;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pref = context.watch<PreferensiProvider>();
    final trx = context.watch<TransaksiProvider>();
    final kategori = context.watch<KategoriProvider>();

    Widget body;
    List<_Notif> daftar = const [];
    if (trx.status == LoadStatus.error) {
      body = ErrorView(
        pesan: trx.errorMessage ?? 'Terjadi kesalahan.',
        onRetry: trx.muat,
      );
    } else if (trx.status != LoadStatus.success) {
      body = const LoadingView(pesan: 'Memuat notifikasi...');
    } else {
      daftar = _susun(context, pref, trx, kategori);
      body = daftar.isEmpty
          ? const EmptyView(
              icon: Icons.notifications_off_rounded,
              judul: 'Belum ada notifikasi',
              pesan: 'Aktifkan pengingat di Pengaturan atau catat pengeluaran pertamamu.',
            )
          : _buildList(cs, daftar);
    }

    final adaBelumDibaca = daftar.any((n) => !_dibaca.contains(n.id));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: adaBelumDibaca
                ? () => setState(() => _dibaca.addAll(daftar.map((n) => n.id)))
                : null,
            child: const Text('Tandai Dibaca', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: SafeArea(child: body),
    );
  }

  Widget _buildList(ColorScheme cs, List<_Notif> daftar) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        final n = daftar[index];
        final belumDibaca = !_dibaca.contains(n.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: belumDibaca
                ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                : cs.surfaceContainerHighest.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: belumDibaca
                    ? cs.primary.withValues(alpha: 0.3)
                    : cs.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                setState(() => _dibaca.add(n.id));
                n.aksi?.call();
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: n.warna.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(n.ikon, color: n.warna, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  n.judul,
                                  style: TextStyle(
                                    fontWeight: belumDibaca ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (belumDibaca)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 8,
                                  width: 8,
                                  decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            n.isi,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            n.waktu,
                            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}