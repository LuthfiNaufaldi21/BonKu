import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GambarDibagikan {
  const GambarDibagikan({required this.gambar, required this.path, required this.mime});

  final Uint8List gambar;
  final String path;
  final String mime;
}

class ShareIntake {
  ShareIntake._();
  static final ShareIntake instance = ShareIntake._();

  static const _saluran = MethodChannel('bonku/share');

  final ValueNotifier<GambarDibagikan?> tertunda = ValueNotifier(null);

  Future<void> mulai() async {
    if (kIsWeb) return;
    _saluran.setMethodCallHandler((call) async {
      if (call.method == 'gambarDibagikan') await _terima(call.arguments);
    });
    try {
      await _terima(await _saluran.invokeMethod<dynamic>('ambilAwal'));
    } catch (_) {
      // Bukan Android atau tidak ada kiriman: tidak ada yang perlu dilakukan.
    }
  }

  Future<void> _terima(dynamic data) async {
    if (data is! Map) return;
    final path = data['path'] as String?;
    if (path == null) return;
    try {
      final bytes = await File(path).readAsBytes();
      tertunda.value = GambarDibagikan(
        gambar: bytes,
        path: path,
        mime: _tebakMime(bytes, data['mime'] as String?),
      );
    } catch (_) {
    }
  }

  static String _tebakMime(Uint8List b, String? dariAndroid) {
    if (dariAndroid != null && dariAndroid.startsWith('image/') && !dariAndroid.contains('*')) {
      return dariAndroid;
    }
    if (b.length > 3 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) {
      return 'image/png';
    }
    if (b.length > 11 && b[8] == 0x57 && b[9] == 0x45 && b[10] == 0x42 && b[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}