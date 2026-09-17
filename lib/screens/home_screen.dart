import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BonKu', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.dashboard_customize, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Riwayat Pengeluaran Belum Tersedia',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
      // Tombol untuk memanggil antarmuka kamera (Sesuai FR-02)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implementasi akses kamera atau image picker di sini
        },
        icon: const Icon(Icons.camera_alt),
        label: const Text('Scan Struk'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}