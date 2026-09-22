import 'package:flutter/material.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Profil Pengguna',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileCard(theme),
                    const SizedBox(height: 24),
                    Text('Pengaturan Aplikasi', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: _buildProfileMenuList(theme),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.person_rounded, size: 36, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User JD Team',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'mahasiswa@example.com',
                  style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuList(ThemeData theme) {
    final menuItems = [
      {'icon': Icons.notifications_active_rounded, 'title': 'Pengingat Pencatatan', 'subtitle': 'Atur notifikasi harian & bulanan (FR-06)'},
      {'icon': Icons.security_rounded, 'title': 'Privasi & Enkripsi Lokal', 'subtitle': 'Keamanan data offline-first (NFR-03)'},
      {'icon': Icons.dark_mode_rounded, 'title': 'Tema Tampilan', 'subtitle': 'Mendukung Dark Mode & Light Mode (NFR-02)'},
      {'icon': Icons.help_outline_rounded, 'title': 'Pusat Bantuan', 'subtitle': 'Panduan penggunaan fitur scan AI & Share Intent'},
      {'icon': Icons.info_outline_rounded, 'title': 'Tentang Aplikasi', 'subtitle': 'BonKu v1.0.0 - Mobile Programming'},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final menu = menuItems[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(menu['icon'] as IconData, color: theme.colorScheme.primary, size: 20),
                ),
                title: Text(menu['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text(menu['subtitle'] as String, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {},
              ),
            ),
          );
        },
        childCount: menuItems.length,
      ),
    );
  }
}