import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 

void main() {
  runApp(const BonKuApp());
}

class BonKuApp extends StatelessWidget {
  const BonKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BonKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system, 
      home: const SplashScreen(),
    );
  }
}