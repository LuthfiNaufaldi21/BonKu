import 'package:flutter/material.dart';

Future<bool> konfirmasiHapus(
  BuildContext context, {
  required String judul,
  required String pesan,
  String labelHapus = 'Hapus',
}) async {
  final hasil = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 32),
        title: Text(judul),
        content: Text(pesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(labelHapus),
          ),
        ],
      );
    },
  );
  return hasil ?? false;
}

Future<void> tampilkanInfo(
  BuildContext context, {
  required String judul,
  required String pesan,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.info_outline_rounded, size: 32),
      title: Text(judul),
      content: Text(pesan),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Mengerti'),
        ),
      ],
    ),
  );
}