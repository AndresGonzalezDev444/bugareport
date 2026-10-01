import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bugareport/pantallas/inicio/pantalla_inicio.dart';

void main() {
  testWidgets('PantallaInicio se renderiza sin errores', (WidgetTester tester) async {
    // Nota: Supabase no se inicializa en tests unitarios.
    // Usar integration_test para pruebas completas de extremo a extremo.
    await tester.pumpWidget(
      const MaterialApp(home: PantallaInicio()),
    );
  });
}
