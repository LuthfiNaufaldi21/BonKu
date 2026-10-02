import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/kategori_provider.dart';
import '../providers/preferensi_provider.dart';
import '../providers/transaksi_provider.dart';
import '../utils/format.dart';
import '../utils/helpers.dart';
import '../utils/ringkasan.dart';
import 'profil_edit_screen.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pref = context.watch<PreferensiProvider>();
    final trx = context.watch<TransaksiProvider>();
    final kategori = context.watch<KategoriProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Profil Pengguna',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildProfileCard(theme, pref),
            const SizedBox(height: 16),
            _buildStatistikRingkas(theme, trx, kategori),
            const SizedBox(height: 24),
            Text(
              'Informasi Akademik & Akun',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAccountDetails(theme, pref),
            const SizedBox(height: 24),
            _buildEditProfileButton(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme, PreferensiProvider pref) {
    final cs = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: cs.primary.withValues(alpha: 0.15),
            child: Icon(Icons.person_rounded, size: 36, color: cs.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pref.nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  pref.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikRingkas(ThemeData theme, TransaksiProvider trx, KategoriProvider kategori) {
    final siap = trx.status == LoadStatus.success;
    final bulan = siap ? Ringkasan.bulanTerbaru(trx.items) : null;
    final totalBulan = bulan == null ? 0 : Ringkasan.total(Ringkasan.pada(trx.items, bulan));

    Widget kotak(String nilai, String label, IconData ikon) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ikon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(nilai, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Text(
                  label,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
          ),
        );

    return Row(
      children: [
        kotak(siap ? '${trx.items.length}' : '-', 'Resi tercatat', Icons.receipt_long_rounded),
        const SizedBox(width: 12),
        kotak(
          kategori.status == LoadStatus.success ? '${kategori.items.length}' : '-',
          'Kategori',
          Icons.category_rounded,
        ),
        const SizedBox(width: 12),
        kotak(
          bulan == null ? '-' : Format.ringkas(totalBulan),
          bulan == null ? 'Bulan ini' : Format.bulanTahun(bulan).substring(0, 3),
          Icons.payments_rounded,
        ),
      ],
    );
  }

  Widget _buildAccountDetails(ThemeData theme, PreferensiProvider pref) {
    final garis = Divider(height: 1, color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2));
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          _buildDetailRow(theme, Icons.badge_rounded, 'ID Pengguna', 'BONKU-99281'),
          garis,
          _buildDetailRow(theme, Icons.school_rounded, 'Program Studi', pref.programStudi),
          garis,
          _buildDetailRow(theme, Icons.business_rounded, 'Institusi', pref.institusi),
          garis,
          _buildDetailRow(theme, Icons.calendar_today_rounded, 'Bergabung', 'September 2026'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilEditScreen()),
        ),
        icon: Icon(Icons.edit_rounded, size: 18, color: theme.colorScheme.primary),
        label: Text(
          'Edit Informasi Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: theme.colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        ),
      ),
    );
  }
}