import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: colorScheme.background,
              elevation: 0,
              pinned: true,
              toolbarHeight: 70,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(Icons.person_outline_rounded, color: colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildBalanceCard(theme),
                    const SizedBox(height: 24),
                    
                    _buildTopCategories(theme),
                    const SizedBox(height: 24),
                    
                    _buildMonthlyWrappedBanner(theme),
                    const SizedBox(height: 32),
                    
                    _buildRecentReceiptsHeader(theme),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: _buildReceiptList(theme),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)), 
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        elevation: 4,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.camera_alt_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: theme.colorScheme.surface,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavIcon(Icons.home_rounded, 'Beranda', true, theme),
            _buildBottomNavIcon(Icons.pie_chart_rounded, 'Statistik', false, theme),
            const SizedBox(width: 40),
            _buildBottomNavIcon(Icons.receipt_long_rounded, 'Semua Resi', false, theme),
            _buildBottomNavIcon(Icons.person_rounded, 'Profil', false, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withBlue(180),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Pengeluaran Bulan Ini',
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Rp 3.150.000',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategories(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori Terbesar',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCategoryChip(Icons.fastfood_rounded, 'Makanan', '45%', Colors.orange, theme),
            _buildCategoryChip(Icons.directions_car_rounded, 'Transport', '30%', Colors.blue, theme),
            _buildCategoryChip(Icons.shopping_bag_rounded, 'Belanja', '15%', Colors.purple, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(IconData icon, String label, String percentage, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(percentage, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyWrappedBanner(ThemeData theme) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.insights_rounded, color: Colors.deepPurple, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Wrapped Siap!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Evaluasi tren pengeluaran bulan lalu.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReceiptsHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Riwayat Struk', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
          child: const Text('Lihat Semua'),
        ),
      ],
    );
  }

  Widget _buildReceiptList(ThemeData theme) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      index == 0 ? Icons.receipt_long_rounded : Icons.share_rounded, 
                      color: theme.colorScheme.onSurfaceVariant
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          index == 0 ? 'Struk Supermarket' : 'Resi M-Banking',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          index == 0 ? '12 Item • Hari ini, 19:30' : '1 Item • Kemarin, 14:15',
                          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    index == 0 ? '-Rp 345.000' : '-Rp 150.000',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.redAccent),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: 3, 
      ),
    );
  }

  Widget _buildBottomNavIcon(IconData icon, String label, bool isActive, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}