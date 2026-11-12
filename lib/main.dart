import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/kategori_provider.dart';
import 'providers/preferensi_provider.dart';
import 'providers/scan_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/transaksi_provider.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firestore_kategori_repository.dart';
import 'repositories/firestore_transaksi_repository.dart';
import 'routes.dart';
import 'services/gemini_receipt_scanner.dart';
import 'services/mock_receipt_scanner.dart';

/// Firebase AI Logic (Gemini) sejak 2 November 2026 mewajibkan App Check.
/// Mode debug dipakai saat pengembangan; token debug didaftarkan di Firebase Console.
/// Untuk APK demo: flutter build apk --dart-define=APP_CHECK_DEBUG=true
const _appCheckDebugPaksa = bool.fromEnvironment('APP_CHECK_DEBUG');

Future<void> _aktifkanAppCheck() async {
  final pakaiDebug = kDebugMode || _appCheckDebugPaksa;
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: pakaiDebug
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
      providerWeb: WebDebugProvider(), // hanya untuk uji di Chrome
    );
  } catch (e) {
    debugPrint('App Check gagal diaktifkan: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _aktifkanAppCheck();
  } catch (e) {
    // Biasanya karena konfigurasi Firebase belum lengkap di perangkat ini.
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Gagal memulai Firebase:\n$e', textAlign: TextAlign.center),
          ),
        ),
      ),
    ));
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(FirebaseAuthRepository())),
        ChangeNotifierProvider(create: (_) => PreferensiProvider()),
        ChangeNotifierProvider(
          create: (_) => ScanProvider(
            asli: GeminiReceiptScanner(),
            simulasi: MockReceiptScanner(),
          ),
        ),
        // Data dimuat ulang otomatis setiap kali pengguna masuk/keluar.
        ChangeNotifierProxyProvider<AuthProvider, KategoriProvider>(
          create: (_) => KategoriProvider(FirestoreKategoriRepository()),
          update: (_, auth, provider) {
            provider!.sinkronkanPengguna(auth.pengguna?.uid);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, TransaksiProvider>(
          create: (_) => TransaksiProvider(FirestoreTransaksiRepository()),
          update: (_, auth, provider) {
            provider!.sinkronkanPengguna(auth.pengguna?.uid);
            return provider;
          },
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