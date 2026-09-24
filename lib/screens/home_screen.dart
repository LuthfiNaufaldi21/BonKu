import 'package:flutter/material.dart';
import 'monthly_wrapped_screen.dart'; // Menambahkan import layar temanmu

class HomeScreen extends StatelessWidget {
  final VoidCallback onViewAllPressed;

  const HomeScreen({super.key, required this.onViewAllPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildBalanceCard(theme),
                const SizedBox(height: 24),
                
                _buildTopCategories(theme),
                const SizedBox(height: 24),
                
                _buildMonthlyWrappedBanner(context, theme), // Memasukkan context untuk navigasi
                const SizedBox(height: 32),
                
                _buildRecentReceiptsHeader(theme),
                const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
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
          children: [
            Expanded(child: _buildCategoryChip(Icons.fastfood_rounded, 'Makanan', '45%', Colors.orange, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryChip(Icons.directions_car_rounded, 'Transport', '30%', Colors.blue, theme)),
            const SizedBox(width: 12),
            Expanded(child: _buildCategoryChip(Icons.shopping_bag_rounded, 'Belanja', '15%', Colors.purple, theme)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(IconData icon, String label, String percentage, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label, 
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  percentage, 
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyWrappedBanner(BuildContext context, ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigasi aktif menuju MonthlyWrappedScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MonthlyWrappedScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
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
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Evaluasi tren pengeluaran bulan lalu.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
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
          onPressed: onViewAllPressed,
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
          final isSupermarket = index == 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isSupermarket ? Icons.receipt_long_rounded : Icons.share_rounded, 
                    color: isSupermarket ? Colors.orange : Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSupermarket ? 'Struk Supermarket' : 'Resi M-Banking / E-Wallet',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSupermarket ? '12 Item • Hari ini, 19:30' : '1 Item • Kemarin, 14:15',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12), 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isSupermarket ? '-Rp 345.000' : '-Rp 150.000',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Berhasil', 
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        childCount: 3, 
      ),
    );
  }
}