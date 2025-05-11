import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fernandovidal/auth_screen.dart';
void main() {
  testWidgets('🧪 AuthScreen: toggle entre Iniciar Sesión y Crear Cuenta',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AuthScreen()),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<bool>(true)), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Correo Electrónico'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<bool>(false)), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Nombre y Apellido'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Correo Electrónico'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Contraseña'), findsOneWidget);
    expect(find.text('¿Ya tienes cuenta? Inicia sesión'), findsOneWidget);
  });
}