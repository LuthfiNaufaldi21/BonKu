import 'package:flutter/material.dart';

import 'screens/auth_screen.dart';
import 'screens/kategori_list_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/monthly_wrapped_screen.dart';
import 'screens/notifikasi_screen.dart';
import 'screens/pengaturan_screen.dart';
import 'screens/resi_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/state_views.dart';

class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const beranda = '/beranda';
  static const kategori = '/kategori';
  static const pengaturan = '/pengaturan';
  static const notifikasi = '/notifikasi';
  static const wrapped = '/wrapped';

  static String resi(String id) => '/resi/$id';

  static Route<dynamic> generate(RouteSettings settings) {
    final nama = settings.name ?? '/';
    final segmen = Uri.parse(nama).pathSegments;

    Widget? halaman;
    if (segmen.isEmpty) {
      halaman = const SplashScreen();
    } else if (segmen.length == 1) {
      switch (segmen.first) {
        case 'auth':
          halaman = const AuthScreen();
        case 'beranda':
          halaman = const MainNavScreen();
        case 'kategori':
          halaman = const KategoriListScreen();
        case 'pengaturan':
          halaman = const PengaturanScreen();
        case 'notifikasi':
          halaman = const NotifikasiScreen();
        case 'wrapped':
          halaman = const MonthlyWrappedScreen();
      }
    } else if (segmen.length == 2 && segmen.first == 'resi' && segmen[1].isNotEmpty) {
      halaman = ResiDetailScreen(transaksiId: segmen[1]);
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => halaman ?? NotFoundScreen(rute: nama),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  final String rute;

  const NotFoundScreen({super.key, required this.rute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tidak Ditemukan')),
      body: SafeArea(
        child: EmptyView(
          icon: Icons.explore_off_rounded,
          judul: 'Halaman tidak ditemukan',
          pesan: 'Alamat "$rute" tidak tersedia di BonKu.',
          labelAksi: 'Ke Beranda',
          onAksi: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.beranda,
            (route) => false,
          ),
        ),
      ),
    );
  }
}