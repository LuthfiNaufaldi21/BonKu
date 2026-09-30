import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart'; // Sesuaikan path jika folder providers berbeda
import 'screens/splash_screen.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const BonKuApp(),
    ),
  );
}

class BonKuApp extends StatelessWidget {
  const BonKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Mendengarkan perubahan tema dari ThemeProvider secara dinamis
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'BonKu',
      debugShowCheckedModeBanner: false,
      
      // Tema Terang (Light Theme)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      
      // Tema Gelap (Dark Theme)
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      
      // Menggunakan themeMode dari provider (bukan lagi ThemeMode.system statis)
      themeMode: themeProvider.themeMode, 
      
      home: const SplashScreen(),
    );
  }
}