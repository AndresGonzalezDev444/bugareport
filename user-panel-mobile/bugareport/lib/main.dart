import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/tema_app.dart';
import 'config/rutas_app.dart';
import 'pantallas/splash/pantalla_splash.dart';
import 'pantallas/legal/pantalla_terminos.dart';
import 'pantallas/autenticacion/pantalla_login.dart';
import 'pantallas/autenticacion/pantalla_registro.dart';
import 'pantallas/autenticacion/pantalla_recuperacion.dart';
import 'pantallas/autenticacion/pantalla_nueva_contrasena.dart';
import 'pantallas/inicio/pantalla_inicio.dart';
import 'pantallas/mapa/pantalla_mapa.dart';
import 'pantallas/ajustes/pantalla_ajustes.dart';
import 'pantallas/reportar/pantalla_nuevo_reporte.dart';
import 'servicios/servicio_notificaciones.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carga el archivo .env (está en .gitignore — nunca llega a GitHub)
  await dotenv.load(fileName: '.env');

  // Inicializa Supabase con las credenciales del .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Inicializa el plugin de notificaciones locales (sin Firebase, $0)
  await ServicioNotificaciones.instancia.inicializar();

  runApp(const AplicacionBugaReport());
}

class AplicacionBugaReport extends StatelessWidget {
  const AplicacionBugaReport({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BugaReport',
      debugShowCheckedModeBanner: false,
      theme: TemaApp.temaClaro,

      // ── Ruta inicial: el splash decide a dónde ir ──
      initialRoute: RutasApp.splash,

      // ── Mapa de rutas nombradas ──
      routes: {
        RutasApp.splash: (_) => const PantallaSplash(),
        RutasApp.terminos: (_) => const PantallaTerminos(),
        RutasApp.login: (_) => const PantallaLogin(),
        RutasApp.registro: (_) => const PantallaRegistro(),
        RutasApp.recuperacion: (_) => const PantallaRecuperacion(),
        RutasApp.nuevaContrasena: (_) => const PantallaNuevaContrasena(),
        RutasApp.inicio: (_) => const PantallaInicio(),
        RutasApp.mapa: (_) => const PantallaMapa(),
        RutasApp.ajustes: (_) => const PantallaAjustes(),
        RutasApp.nuevoReporte: (_) => const PantallaNuevoReporte(),
      },

      // ── Ruta de fallback para rutas desconocidas ──
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const PantallaSplash(),
      ),
    );
  }
}
