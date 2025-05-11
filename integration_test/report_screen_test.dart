import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fernandovidal/services/report_lost_dog_screen.dart';
void main() {
  testWidgets('🧪 ReportLostDogScreen muestra campos y botones', (tester) async {

    await tester.pumpWidget(
      const MaterialApp(
        home: ReportLostDogScreen(),
      ),
    );
    await tester.pumpAndSettle();


    final nombreField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Nombre',
      description: 'TextField con label "Nombre"',
    );
    final razaField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Raza',
      description: 'TextField con label "Raza"',
    );
    final colorField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Color',
      description: 'TextField con label "Color"',
    );
    final detallesField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == 'Detalles',
      description: 'TextField con label "Detalles"',
    );

    expect(nombreField, findsOneWidget);
    expect(razaField, findsOneWidget);
    expect(colorField, findsOneWidget);
    expect(detallesField, findsOneWidget);

    expect(
      find.widgetWithText(ElevatedButton, '📷 Agregar Imágenes'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(ElevatedButton, '📍 Obtener Ubicación'),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(ElevatedButton, '📤 Enviar Reporte'),
      findsOneWidget,
    );


    await tester.tap(
      find.widgetWithText(ElevatedButton, '📷 Agregar Imágenes'),
    );
    await tester.pumpAndSettle();
  });
}
