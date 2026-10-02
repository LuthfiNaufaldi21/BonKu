import 'dart:io';
import 'package:flutter/material.dart';

import '../models/transaksi.dart';
import 'confirmation_screen.dart';
import 'home_screen.dart';
import 'notifikasi_screen.dart';
import 'pengaturan_screen.dart';
import 'profil_screen.dart';
import 'semua_resi_screen.dart';
import 'statistik_screen.dart';
import '../providers/preferensi_provider.dart';
import 'package:provider/provider.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages = [
    HomeScreen(onViewAllPressed: () => _changeTab(2)),
    const StatistikScreen(),
    const SemuaResiScreen(),
    const ProfilScreen(),
  ];

  void _bukaForm(SumberResi sumber) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmationScreen(sumber: sumber)),
    );
  }

  void _pilihSumber() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Pilih Sumber Struk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('Ambil Foto Struk Fisik'),
                subtitle: const Text('Gunakan kamera perangkat'),
                onTap: () => _bukaForm(SumberResi.kamera),
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.teal),
                title: const Text('Pilih dari Galeri'),
                subtitle: const Text('Impor tangkapan layar'),
                onTap: () => _bukaForm(SumberResi.share),
              ),
              ListTile(
                leading: const Icon(Icons.edit_note_rounded, color: Colors.teal),
                title: const Text('Input Manual'),
                subtitle: const Text('Isi data pengeluaran tanpa scan'),
                onTap: () => _bukaForm(SumberResi.manual),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pref = context.watch<PreferensiProvider>(); // Tambahkan ini

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        toolbarHeight: 75,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              backgroundImage: pref.fotoProfil != null && pref.fotoProfil!.isNotEmpty
                  ? (pref.fotoProfil!.startsWith('http')
                      ? NetworkImage(pref.fotoProfil!) as ImageProvider
                      : FileImage(File(pref.fotoProfil!)))
                  : null,
              child: pref.fotoProfil == null 
                  ? Icon(Icons.person_outline_rounded, color: colorScheme.primary) 
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Halo, ${pref.nama.split(" ")[0]} 👋',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Siap memindai struk?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PengaturanScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildNavItem(Icons.home_rounded, 'Beranda', 0, theme)),
              Expanded(child: _buildNavItem(Icons.pie_chart_rounded, 'Statistik', 1, theme)),
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: _pilihSumber,
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(child: _buildNavItem(Icons.receipt_long_rounded, 'Semua Resi', 2, theme)),
              Expanded(child: _buildNavItem(Icons.person_rounded, 'Profil', 3, theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, ThemeData theme) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => _changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}