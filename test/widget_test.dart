import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pastikan import ini sesuai dengan nama project kamu (bonku_app)
import 'package:bonku_app/main.dart';
import 'package:bonku_app/providers/theme_provider.dart';

void main() {
  testWidgets('BonKuApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    // Build aplikasi BonKu
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const BonKuApp(),
      ),
    );

    // Verifikasi bahwa teks 'BonKu' dari Splash Screen berhasil dimuat
    expect(find.text('BonKu'), findsWidgets);

    // Verifikasi ikon receipt_long_rounded dari Splash Screen juga dimuat
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
  });
}
