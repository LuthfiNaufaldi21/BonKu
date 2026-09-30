import 'package:flutter/material.dart';

class SemuaResiScreen extends StatefulWidget {
  const SemuaResiScreen({super.key});

  @override
  State<SemuaResiScreen> createState() => _SemuaResiScreenState();
}

class _SemuaResiScreenState extends State<SemuaResiScreen> {
  // 1. Kita buat master data mentah (Dummy Data)
  final List<Map<String, dynamic>> _allReceipts = [
    {
      'title': 'Struk Supermarket',
      'subtitle': '12 Item • Hari ini, 19:30',
      'amount': '-Rp 345.000',
      'isSupermarket': true,
    },
    {
      'title': 'Resi M-Banking / E-Wallet',
      'subtitle': '1 Item • Kemarin, 14:15',
      'amount': '-Rp 150.000',
      'isSupermarket': false,
    },
    {
      'title': 'Struk Minimarket',
      'subtitle': '3 Item • 27 Sep, 08:00',
      'amount': '-Rp 45.000',
      'isSupermarket': true,
    },
    {
      'title': 'Top Up E-Wallet',
      'subtitle': '1 Item • 25 Sep, 10:20',
      'amount': '-Rp 200.000',
      'isSupermarket': false,
    },
    {
      'title': 'Struk Toko Buku',
      'subtitle': '2 Item • 23 Sep, 16:45',
      'amount': '-Rp 120.000',
      'isSupermarket': true,
    },
  ];

  // 2. Variabel ini yang akan ditampilkan di layar (hasil filter)
  List<Map<String, dynamic>> _filteredReceipts = [];

  @override
  void initState() {
    super.initState();
    // Saat layar pertama dibuka, tampilkan semua resi
    _filteredReceipts = _allReceipts;
  }

  // 3. Fungsi ini akan dipanggil setiap kali kita mengetik sesuatu
  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allReceipts; // Kalau kosong, tampilkan semua
    } else {
      // Filter berdasarkan judul (title) atau nominal (amount)
      results = _allReceipts.where((receipt) {
        final titleMatch = receipt['title'].toLowerCase().contains(enteredKeyword.toLowerCase());
        final amountMatch = receipt['amount'].toLowerCase().contains(enteredKeyword.toLowerCase());
        return titleMatch || amountMatch;
      }).toList();
    }

    // Refresh UI dengan data baru
    setState(() {
      _filteredReceipts = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semua Resi & Transaksi',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Riwayat otomatis dari scan kamera & share intent',
                      style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildSearchBar(theme),
                    
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            
            // 4. Jika hasil pencarian kosong, tampilkan pesan. Jika ada, tampilkan list.
            _filteredReceipts.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Center(
                        child: Text(
                          'Pencarian tidak ditemukan 🥲',
                          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    sliver: _buildEnhancedReceiptList(theme),
                  ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), 
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.3)),
      ),
      child: TextField(
        style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari nama toko atau nominal...',
          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
          border: InputBorder.none,
          icon: Icon(
            Icons.search_rounded, 
            color: theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
        // Panggil fungsi filter saat ada ketikan baru
        onChanged: (value) => _runFilter(value),
      ),
    );
  }

  Widget _buildEnhancedReceiptList(ThemeData theme) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Ambil data dari _filteredReceipts, bukan dari index statis lagi
          final item = _filteredReceipts[index];
          
          bool isSupermarket = item['isSupermarket'];
          String title = item['title'];
          String subtitle = item['subtitle'];
          String amount = item['amount'];
          IconData iconData = isSupermarket ? Icons.receipt_long_rounded : Icons.share_rounded;
          Color accentColor = isSupermarket ? Colors.orange : Colors.blue;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      iconData,
                      color: accentColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Berhasil',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        // Jumlah item sekarang dinamis sesuai hasil pencarian
        childCount: _filteredReceipts.length,
      ),
    );
  }
}