import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Pastikan import ini sesuai dengan nama project kamu (bonku_app)
import 'package:bonku_app/main.dart'; 

void main() {
  testWidgets('BonKuApp smoke test', (WidgetTester tester) async {
    // Build aplikasi BonKu
    await tester.pumpWidget(const BonKuApp());

    // Verifikasi bahwa teks 'BonKu' dari Splash Screen berhasil dimuat
    expect(find.text('BonKu'), findsWidgets);
    
    // Verifikasi ikon receipt_long_rounded dari Splash Screen juga dimuat
    expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
  });
}