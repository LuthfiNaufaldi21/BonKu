import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/kategori_provider.dart';
import 'providers/preferensi_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaksi_provider.dart';
import 'repositories/kategori_repository.dart';
import 'repositories/transaksi_repository.dart';
import 'routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PreferensiProvider()),
        ChangeNotifierProvider(
          create: (_) => KategoriProvider(KategoriRepository())..muat(),
        ),
        ChangeNotifierProvider(
          create: (_) => TransaksiProvider(TransaksiRepository())..muat(),
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
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generate,
      onGenerateInitialRoutes: (nama) => [
        AppRoutes.generate(RouteSettings(name: nama)),
      ],
    );
  }
}