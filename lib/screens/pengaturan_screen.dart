import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Sesuaikan path jika letak folder providers berbeda

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          _buildSectionTitle(theme, 'Preferensi'),
          _buildSettingItem(
            theme, 
            icon: Icons.dark_mode_rounded, 
            title: 'Tema Tampilan', 
            subtitle: themeProvider.isDarkMode ? 'Mode Gelap Aktif' : 'Mode Terang Aktif', 
            iconColor: Colors.indigo,
            trailing: Switch(
              value: themeProvider.isDarkMode, 
              onChanged: (val) {
                themeProvider.toggleTheme(val);
              },
              activeColor: theme.colorScheme.primary,
            ),
          ),
          _buildSettingItem(
            theme, 
            icon: Icons.notifications_active_rounded, 
            title: 'Pengingat Pencatatan', 
            subtitle: 'Notifikasi harian & bulanan', 
            iconColor: Colors.orange,
            trailing: Switch(value: true, onChanged: (val){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(val ? 'Pengingat diaktifkan' : 'Pengingat dimatikan')),
                );
              },
            activeColor: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle(theme, 'Keamanan & Data'),
          _buildSettingItem(
            theme, 
            icon: Icons.security_rounded, 
            title: 'Privasi & Keamanan', 
            subtitle: 'Enkripsi data offline-first', 
            iconColor: Colors.green,
            onTap: () {},
          ),
          _buildSettingItem(
            theme, 
            icon: Icons.backup_rounded, 
            title: 'Cadangkan Data', 
            subtitle: 'Simpan riwayat struk', 
            iconColor: Colors.blue,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          
          _buildSectionTitle(theme, 'Lainnya'),
          _buildSettingItem(
            theme, 
            icon: Icons.help_outline_rounded, 
            title: 'Pusat Bantuan', 
            subtitle: 'Panduan scan & keluhan', 
            iconColor: Colors.teal,
            onTap: () {},
          ),
          _buildSettingItem(
            theme, 
            icon: Icons.info_outline_rounded, 
            title: 'Tentang BonKu', 
            subtitle: 'Versi 1.0.0', 
            iconColor: Colors.grey,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          
          // Tombol Keluar (Logout)
          _buildLogoutButton(theme),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          subtitle: Text(
            subtitle, 
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            // TODO: Logika logout
          },
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              'Keluar Akun',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}