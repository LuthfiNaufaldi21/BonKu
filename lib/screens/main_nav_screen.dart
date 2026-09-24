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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        toolbarHeight: 75,
        title: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.person_outline_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 16),
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
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
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
              top: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Memastikan semua item sejajar di tengah
            children: [
              Expanded(child: _buildNavItem(Icons.home_rounded, 'Beranda', 0, theme)),
              Expanded(child: _buildNavItem(Icons.pie_chart_rounded, 'Statistik', 1, theme)),
              
              // Tombol QR dibuat lebih besar (56x56) dan diposisikan pas di tengah
              Expanded(
                child: Center(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConfirmationScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.qr_code_scanner_rounded, 
                        color: colorScheme.onPrimary, 
                        size: 28, // Ukuran ikon diperbesar
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