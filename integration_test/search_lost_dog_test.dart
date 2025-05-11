import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fernandovidal/services/search_lost_dog_screen.dart';

void main() {
  testWidgets('🧪 UI de Buscar un Perro Perdido', (WidgetTester tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchLostDogScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('🐾 Raza'), findsOneWidget);
    expect(find.text('🎨 Color'), findsOneWidget);
    expect(find.text('Estado'), findsOneWidget);
    expect(find.text('Fecha desde'), findsOneWidget);
    expect(find.text('Fecha hasta'), findsOneWidget);
    expect(find.text('Obtener mi ubicación'), findsOneWidget);
    expect(find.text('🔎 Buscar'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  });
}
