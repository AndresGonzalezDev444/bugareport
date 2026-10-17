import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:bugareport/servicios/servicio_logger.dart';

/// Servicio de notificaciones locales para BugaReport.
///
/// Usa [flutter_local_notifications] — gratis, sin Firebase, sin costo.
/// Solo funciona con la app abierta o en segundo plano (no push con app cerrada).
///
/// Canal Android: 'bugareport_reportes'
/// Categoría iOS: 'REPORTE_ESTADO'
class ServicioNotificaciones {
  ServicioNotificaciones._();
  static final ServicioNotificaciones instancia = ServicioNotificaciones._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _inicializado = false;

  // ── Detalles de canal Android ──
  static const _canalId = 'bugareport_reportes';
  static const _canalNombre = 'Estado de mis reportes';
  static const _canalDescripcion =
      'Alertas cuando cambia el estado de tus reportes ciudadanos';

  // Color no puede ser const en este contexto — usamos getter
  static AndroidNotificationDetails get _detallesAndroid =>
      const AndroidNotificationDetails(
    _canalId,
    _canalNombre,
    channelDescription: _canalDescripcion,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    color: Color(0xFF7A1E23),
  );

  static const DarwinNotificationDetails _detallesIos =
      DarwinNotificationDetails(
    categoryIdentifier: 'REPORTE_ESTADO',
    threadIdentifier: 'bugareport',
  );

  static NotificationDetails get _detalles => NotificationDetails(
    android: _detallesAndroid,
    iOS: _detallesIos,
  );

  // ── Inicialización ──

  /// Inicializar el plugin al arrancar la app.
  /// Llamar desde [main()] antes de [runApp()].
  Future<void> inicializar() async {
    if (_inicializado) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _inicializado = true;
    ServicioLogger.info('Plugin de notificaciones inicializado', componente: 'Notificaciones');
  }

  // ── Permisos ──

  /// Solicita permiso de notificaciones al usuario (Android 13+ / iOS).
  Future<bool> solicitarPermiso() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final concedido = await androidPlugin?.requestNotificationsPermission();
    return concedido ?? false;
  }

  // ── Envío de notificaciones ──

  /// Muestra una notificación de cambio de estado de reporte.
  Future<void> notificarCambioEstadoReporte({
    required String idReporte,
    required String titulo,
    required String nuevoEstado,
  }) async {
    if (!_inicializado) await inicializar();

    final etiquetaEstado = switch (nuevoEstado) {
      'en_proceso' => 'está siendo atendido',
      'resuelto' => 'fue resuelto ✓',
      _ => 'fue actualizado',
    };

    await _plugin.show(
      idReporte.hashCode,
      'Tu reporte: $titulo',
      'El incidente $etiquetaEstado por la Alcaldía de Buga.',
      _detalles,
    );
    ServicioLogger.info(
      'Notificación enviada: $titulo → $nuevoEstado',
      componente: 'Notificaciones',
    );
  }

  /// Cancela todas las notificaciones pendientes (al desactivar en ajustes).
  Future<void> cancelarTodas() async {
    await _plugin.cancelAll();
    ServicioLogger.info('Todas las notificaciones canceladas', componente: 'Notificaciones');
  }
}
