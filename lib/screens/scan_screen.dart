import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/hasil_scan.dart';
import '../models/transaksi.dart';
import '../providers/kategori_provider.dart';
import '../providers/scan_provider.dart';
import '../services/izin_perangkat.dart';
import '../services/receipt_scanner.dart';
import '../services/share_intake.dart';
import '../widgets/state_views.dart';
import 'confirmation_screen.dart';
import 'kamera_screen.dart';

enum _Tahap { memilih, memindai, gagal }

/// Alur scan: pilih foto (kamera/galeri) -> dibaca AI -> form konfirmasi.
class ScanScreen extends StatefulWidget {
  final SumberResi sumber;
  final GambarDibagikan? gambarAwal;

  const ScanScreen({super.key, required this.sumber, this.gambarAwal});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  _Tahap _tahap = _Tahap.memilih;
  Uint8List? _gambar;
  String? _path;
  String _mime = 'image/jpeg';
  String? _pesan;
  bool _kuotaHabis = false;
  String? _detail;
  bool _butuhIzin = false;
  bool _izinPermanen = false;

  bool get _kamera => widget.sumber == SumberResi.kamera;

  bool get _kameraDalam => _kamera && !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    final awal = widget.gambarAwal;
    if (awal != null) {
      _gambar = awal.gambar;
      _path = awal.path;
      _mime = awal.mime;
      _tahap = _Tahap.memindai;
      WidgetsBinding.instance.addPostFrameCallback((_) => _pindai());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pilihGambar());
    }
  }

  String _tebakMime(XFile f) {
    final m = f.mimeType;
    if (m != null && m.startsWith('image/')) return m;
    final n = f.name.toLowerCase();
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.heic')) return 'image/heic';
    if (n.endsWith('.heif')) return 'image/heif';
    return 'image/jpeg';
  }

  Future<void> _pilihGambar() async {
    setState(() {
      _tahap = _Tahap.memilih;
      _butuhIzin = false;
      _izinPermanen = false;
    });
    final izin = _kamera ? await IzinPerangkat.kamera(context) : await IzinPerangkat.galeri(context);
    if (!mounted) return;
    if (izin == HasilIzin.dibatalkan) {
      Navigator.of(context).pop();
      return;
    }
    if (izin != HasilIzin.diberikan) {
      final permanen = izin == HasilIzin.ditolakPermanen;
      setState(() {
        _tahap = _Tahap.gagal;
        _butuhIzin = true;
        _izinPermanen = permanen;
        _pesan = permanen
            ? 'Izin kamera dimatikan. Buka Pengaturan, pilih Izin, lalu aktifkan Kamera untuk BonKu.'
            : 'BonKu memerlukan izin kamera untuk memotret struk.';
        _kuotaHabis = false;
        _detail = null;
      });
      return;
    }
    try {
      final XFile? file = _kameraDalam
          ? await Navigator.of(context).push<XFile>(
              MaterialPageRoute(builder: (_) => const KameraScreen()),
            )
          : await ImagePicker().pickImage(
              source: _kamera ? ImageSource.camera : ImageSource.gallery,
              maxWidth: 1600,
              imageQuality: 80,
            );
      if (!mounted) return;
      if (file == null) {
        Navigator.of(context).pop();
        return;
      }
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      _gambar = bytes;
      _path = kIsWeb ? null : file.path;
      _mime = _tebakMime(file);
      await _pindai();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tahap = _Tahap.gagal;
        _pesan = _kamera
            ? 'Kamera tidak dapat dibuka. Periksa izin kamera lalu coba lagi.'
            : 'Galeri tidak dapat dibuka. Coba lagi.';
        _kuotaHabis = false;
      });
    }
  }

  Future<void> _pindai({bool simulasi = false}) async {
    setState(() {
      _tahap = _Tahap.memindai;
      _pesan = null;
      _kuotaHabis = false;
      _detail = null;
    });
    final scan = context.read<ScanProvider>();
    final kategori = context.read<KategoriProvider>().items;

    try {
      final hasil = await scan.pindai(
        gambar: _gambar!,
        mimeType: _mime,
        kategori: kategori,
        paksaSimulasi: simulasi,
      );
      if (!mounted) return;
      _bukaForm(hasil.denganGambar(gambar: _gambar, imagePath: _path));
    } on ScanException catch (e) {
      if (!mounted) return;
      setState(() {
        _tahap = _Tahap.gagal;
        _pesan = e.pesan;
        _kuotaHabis = e.kuotaHabis;
        _detail = e.detail;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tahap = _Tahap.gagal;
        _pesan = 'Terjadi kesalahan saat membaca struk. Coba lagi.';
        _kuotaHabis = false;
      });
    }
  }

  void _bukaForm(HasilScan hasil) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(sumber: widget.sumber, hasilScan: hasil),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gambarAwal != null
            ? 'Resi Digital'
            : (_kamera ? 'Scan Struk' : 'Pilih Resi Digital')),
      ),
      body: SafeArea(child: _isi(context)),
    );
  }

  Widget _isi(BuildContext context) {
    switch (_tahap) {
      case _Tahap.memilih:
        return LoadingView(pesan: _kamera ? 'Membuka kamera...' : 'Membuka galeri...');
      case _Tahap.memindai:
        return _buildMemindai(context);
      case _Tahap.gagal:
        return _buildGagal(context);
    }
  }

  Widget _buildMemindai(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, c) {
        final tinggiGambar = math.min(320.0, math.max(80.0, c.maxHeight - 150));
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_gambar != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: tinggiGambar,
                      child: Image.memory(_gambar!, fit: BoxFit.contain),
                    ),
                  ),
                const SizedBox(height: 24),
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Membaca struk dengan AI...',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Biasanya 5-10 detik',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGagal(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: cs.error),
            const SizedBox(height: 16),
            Text(
              _butuhIzin ? 'Izin diperlukan' : 'Struk belum terbaca',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _pesan ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            if (kDebugMode && _detail != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  'Detail teknis (hanya tampil di mode debug):\n$_detail',
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_izinPermanen) ...[
              FilledButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings_rounded),
                label: const Text('Buka Pengaturan'),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              onPressed: _gambar != null ? () => _pindai() : _pilihGambar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba lagi'),
            ),
            if (!_butuhIzin) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pilihGambar,
                icon: Icon(_kamera ? Icons.camera_alt_rounded : Icons.photo_library_rounded),
                label: Text(_kamera ? 'Foto ulang' : 'Pilih gambar lain'),
              ),
            ],
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _bukaForm(HasilScan(gambar: _gambar, imagePath: _path)),
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Isi manual'),
            ),
            if (_kuotaHabis && _gambar != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _pindai(simulasi: true),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Pakai hasil simulasi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}