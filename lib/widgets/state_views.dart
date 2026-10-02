import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String pesan;

  const LoadingView({super.key, this.pesan = 'Memuat data...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            pesan,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  final IconData icon;
  final String judul;
  final String pesan;
  final String? labelAksi;
  final VoidCallback? onAksi;

  const EmptyView({
    super.key,
    required this.icon,
    required this.judul,
    required this.pesan,
    this.labelAksi,
    this.onAksi,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(
              judul,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              pesan,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            if (labelAksi != null && onAksi != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAksi, child: Text(labelAksi!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String pesan;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.pesan, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return EmptyView(
      icon: Icons.cloud_off_rounded,
      judul: 'Gagal memuat data',
      pesan: pesan,
      labelAksi: 'Coba lagi',
      onAksi: onRetry,
    );
  }
}