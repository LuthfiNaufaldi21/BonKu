import 'package:flutter/material.dart';

class MonthlyWrappedScreen extends StatefulWidget {
  const MonthlyWrappedScreen({super.key});

  @override
  State<MonthlyWrappedScreen> createState() => _MonthlyWrappedScreenState();
}

class _MonthlyWrappedScreenState extends State<MonthlyWrappedScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final int _totalPages = 4;

  void _nextPage() {
    if (_currentIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context); // Selesai, kembali ke beranda
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Slides (PageView)
            PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe manual, pakai tap
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: [
                _buildSlide(
                  colors: [Colors.deepPurpleAccent, Colors.pink],
                  title: 'Bulan ini cukup liar,\ntapi kamu berhasil\nmelewatinya.',
                  subtitle: 'Siap melihat seberapa jauh dompetmu berjuang?',
                ),
                _buildSlide(
                  colors: [Colors.blue.shade800, Colors.teal],
                  title: 'Total pengeluaranmu\nbulan ini mencapai...',
                  subtitle: 'Rp 3.150.000',
                  isNumberHuge: true,
                ),
                _buildSlide(
                  colors: [Colors.orange.shade800, Colors.redAccent],
                  title: 'Ternyata, uangmu\npaling banyak habis di...',
                  subtitle: '🍔 Konsumsi',
                  isNumberHuge: true,
                ),
                _buildSlide(
                  colors: [Colors.green.shade800, Colors.lightGreen],
                  title: 'Kabar baiknya!',
                  subtitle: 'Pengeluaranmu turun 15% dibandingkan bulan lalu. Pertahankan!',
                ),
              ],
            ),

            // Bar Indikator Progres (Mirip Story Spotify/IG)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: List.generate(_totalPages, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentIndex
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Sensor Sentuhan Layar (Kiri untuk Prev, Kanan untuk Next)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _previousPage,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _nextPage,
                    behavior: HitTestBehavior.opaque,
                  ),
                ),
              ],
            ),
            
            // Tombol Skip (Opsional)
            Positioned(
              top: 32,
              right: 16,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Builder untuk Setiap Halaman
  Widget _buildSlide({
    required List<Color> colors,
    required String title,
    required String subtitle,
    bool isNumberHuge = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: isNumberHuge ? 48 : 20,
              fontWeight: isNumberHuge ? FontWeight.w900 : FontWeight.w500,
              color: isNumberHuge ? Colors.yellowAccent : Colors.white70,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}