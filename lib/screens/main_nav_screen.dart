import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'statistik_screen.dart';
import 'semua_resi_screen.dart';
import 'profil_screen.dart';
import 'confirmation_screen.dart';

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  // Fungsi untuk mengubah index tab secara langsung
  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _pages = [
    HomeScreen(
      onViewAllPressed: () => _changeTab(3), // Berpindah ke tab Semua Resi (Index 3) saat diklik
    ),
    const StatistikScreen(),
    const SizedBox(), // Index 2 untuk tombol kamera
    const SemuaResiScreen(),
    const ProfilScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) return;
    _changeTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person_outline_rounded, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Halo, User 👋',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Siap memindai struk?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Pengaturan',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Pengingat Pencatatan',
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
          );
        },
        child: const Icon(Icons.camera_alt_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: "Statistik"),
          BottomNavigationBarItem(icon: Icon(Icons.camera, color: Colors.transparent), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: "Semua Resi"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profil"),
        ],
      ),
    );
  }
}