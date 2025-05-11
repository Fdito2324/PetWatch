// integration_test/app_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
// Ajusta aquí el import si tu paquete se llama distinto
import 'package:fernandovidal/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('🧪 Login y navegación a Reportar Perro', (tester) async {
    // 1) Arranca la app
    app.main();
    await tester.pumpAndSettle();

    // 2) Localiza los TextField por su decoration.labelText
    final emailField = find.byWidgetPredicate(
      (widget) =>
        widget is TextField &&
        widget.decoration?.labelText == 'Correo Electrónico',
      description: 'TextField con label "Correo Electrónico"',
    );
    final passwordField = find.byWidgetPredicate(
      (widget) =>
        widget is TextField &&
        widget.decoration?.labelText == 'Contraseña',
      description: 'TextField con label "Contraseña"',
    );

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);

    // 3) Rellena credenciales
    await tester.enterText(emailField, 'usuario@correo.com');
    await tester.enterText(passwordField, 'contrasena123');
    await tester.pumpAndSettle();

    // 4) Pulsa el botón "Iniciar Sesión"
    final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
    expect(loginButton, findsOneWidget);
    await tester.tap(loginButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 5) Verifica que llegaste al Home
    expect(find.text('Selecciona una opción:'), findsOneWidget);

    // 6) Navega a "Reportar un Perro Perdido"
    final reportButton = find.widgetWithText(ElevatedButton, '🐾 Reportar un Perro Perdido');
    expect(reportButton, findsOneWidget);
    await tester.tap(reportButton);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 7) Comprueba los campos en la pantalla de reporte
    final nameField = find.byWidgetPredicate(
      (widget) =>
        widget is TextField &&
        widget.decoration?.labelText == 'Nombre',
      description: 'TextField con label "Nombre"',
    );
    final detailsField = find.byWidgetPredicate(
      (widget) =>
        widget is TextField &&
        widget.decoration?.labelText == 'Detalles',
      description: 'TextField con label "Detalles"',
    );

    expect(nameField, findsOneWidget);
    expect(detailsField, findsOneWidget);
  });
}
