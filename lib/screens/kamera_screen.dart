import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class KameraScreen extends StatefulWidget {
  const KameraScreen({super.key});

  @override
  State<KameraScreen> createState() => _KameraScreenState();
}

class _KameraScreenState extends State<KameraScreen> with WidgetsBindingObserver {
  CameraController? _kontrol;
  String? _galat;
  bool _menyiapkan = false;
  bool _mengambil = false;
  bool _senter = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _siapkan();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _kontrol?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final kontrol = _kontrol;
      if (kontrol == null) return;
      _kontrol = null;
      kontrol.dispose();
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed && _kontrol == null && _galat == null) {
      _siapkan();
    }
  }

  Future<void> _siapkan() async {
    if (_menyiapkan) return;
    _menyiapkan = true;
    try {
      final daftar = await availableCameras();
      if (daftar.isEmpty) {
        _tampilkanGalat('Perangkat ini tidak memiliki kamera.');
        return;
      }
      final belakang = daftar.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => daftar.first,
      );
      final kontrol = CameraController(
        belakang,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await kontrol.initialize();
      await kontrol.setFlashMode(FlashMode.off);
      if (!mounted) {
        await kontrol.dispose();
        return;
      }
      setState(() {
        _kontrol = kontrol;
        _galat = null;
        _senter = false;
      });
    } on CameraException {
      _tampilkanGalat('Kamera tidak dapat dibuka. Periksa izin kamera lalu coba lagi.');
    } catch (_) {
      _tampilkanGalat('Kamera tidak dapat dibuka.');
    } finally {
      _menyiapkan = false;
    }
  }

  void _tampilkanGalat(String pesan) {
    if (!mounted) return;
    setState(() => _galat = pesan);
  }

  Future<void> _ambil() async {
    final kontrol = _kontrol;
    if (kontrol == null || _mengambil || !kontrol.value.isInitialized) return;
    setState(() => _mengambil = true);
    try {
      final foto = await kontrol.takePicture();
      if (!mounted) return;
      Navigator.of(context).pop(foto);
    } on CameraException {
      if (!mounted) return;
      setState(() => _mengambil = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengambil foto. Coba lagi.')),
      );
    }
  }

  Future<void> _gantiSenter() async {
    final kontrol = _kontrol;
    if (kontrol == null) return;
    final berikut = !_senter;
    try {
      await kontrol.setFlashMode(berikut ? FlashMode.torch : FlashMode.off);
      if (!mounted) return;
      setState(() => _senter = berikut);
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kontrol = _kontrol;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Struk'),
        actions: [
          if (kontrol != null)
            IconButton(
              tooltip: 'Senter',
              onPressed: _gantiSenter,
              icon: Icon(_senter ? Icons.flash_on_rounded : Icons.flash_off_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: _galat != null
            ? _tampilanGalat(_galat!)
            : kontrol == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      Expanded(child: Center(child: CameraPreview(kontrol))),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: _tombolAmbil(),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _tampilanGalat(String pesan) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_rounded, color: Colors.white70, size: 56),
            const SizedBox(height: 16),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tombolAmbil() {
    return Semantics(
      button: true,
      label: 'Ambil foto',
      child: GestureDetector(
        onTap: _ambil,
        child: Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _mengambil ? Colors.white54 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}