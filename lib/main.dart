import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/kategori_provider.dart';
import 'providers/preferensi_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaksi_provider.dart';
import 'repositories/in_memory_kategori_repository.dart';
import 'repositories/in_memory_transaksi_repository.dart';
import 'routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PreferensiProvider()),
        ChangeNotifierProvider(
          create: (_) => KategoriProvider(InMemoryKategoriRepository())..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransaksiProvider(InMemoryTransaksiRepository())..muat(),
        ),
      ],
      child: const BonKuApp(),
    ),
  );
}

class BonKuApp extends StatelessWidget {
  const BonKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'BonKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      // Tablet/desktop/web (sisi terpendek >= 600 dp): isi dibatasi 720 dp dan
      // dipusatkan. HP, termasuk landscape, tetap memakai layar penuh.
      builder: (context, child) {
        final isi = child ?? const SizedBox.shrink();
        if (MediaQuery.sizeOf(context).shortestSide < 600) return isi;
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: isi,
            ),
          ),
        );
      },
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generate,
      onGenerateInitialRoutes: (nama) => [
        AppRoutes.generate(RouteSettings(name: nama)),
      ],
    );
  }
}