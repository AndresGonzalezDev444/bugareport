import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bugareport/servicios/servicio_conectividad.dart';
import 'package:bugareport/servicios/servicio_logger.dart';

/// Interceptor global de errores de red y servidor.
///
/// Envuelve cualquier operación async con detección de:
/// - Sin conexión a internet
/// - Timeout de red
/// - Error 500 del servidor
/// - Cualquier excepción de comunicación
///
/// Uso:
/// ```dart
/// final resultado = await InterceptorErroresRed.ejecutar(
///   contexto: context,
///   operacion: () => servicio.crearIncidente(datos),
///   mensajeError: 'No se pudo enviar el reporte',
/// );
/// ```
class InterceptorErroresRed {
  InterceptorErroresRed._();

  /// Ejecuta [operacion] con manejo automático de errores de red.
  ///
  /// - Si no hay red: muestra SnackBar y lanza [ExcepcionRed].
  /// - Si hay timeout: muestra SnackBar y lanza [ExcepcionRed].
  /// - Si hay error de servidor: registra silenciosamente, muestra mensaje amigable.
  /// - Si hay éxito: retorna el resultado.
  static Future<T?> ejecutar<T>({
    required BuildContext contexto,
    required Future<T> Function() operacion,
    String mensajeError = 'No se pudo comunicar con el servidor en este momento',
    String componente = 'InterceptorRed',
  }) async {
    // 1. Verificar conectividad antes de intentar
    final hayConexion = await ServicioConectividad.instancia.tieneConexion();
    if (!hayConexion) {
      if (contexto.mounted) {
        _mostrarSnackBar(
          contexto,
          'Tu dispositivo no tiene conexión a internet.',
          esError: true,
        );
      }
      throw const ExcepcionRed(
        tipo: TipoErrorRed.sinConexion,
        mensaje: 'Sin conexión a internet',
      );
    }

    // 2. Ejecutar la operación con captura de errores
    try {
      return await operacion().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw const ExcepcionRed(
            tipo: TipoErrorRed.timeout,
            mensaje: 'Timeout',
          );
        },
      );
    } on ExcepcionRed {
      rethrow;
    } on SocketException catch (e, traza) {
      ServicioLogger.error(
        'Error de socket: ${e.message}',
        excepcion: e,
        traza: traza,
        componente: componente,
      );
      if (contexto.mounted) {
        _mostrarSnackBar(contexto, mensajeError, esError: true);
      }
      return null;
    } on TimeoutException catch (e, traza) {
      ServicioLogger.error(
        'Timeout al conectar al servidor',
        excepcion: e,
        traza: traza,
        componente: componente,
      );
      if (contexto.mounted) {
        _mostrarSnackBar(
          contexto,
          'El servidor tardó demasiado en responder. Intenta de nuevo.',
          esError: true,
        );
      }
      return null;
    } catch (e, traza) {
      ServicioLogger.error(
        'Error en operación de red: $e',
        excepcion: e,
        traza: traza,
        componente: componente,
      );
      if (contexto.mounted) {
        _mostrarSnackBar(contexto, mensajeError, esError: true);
      }
      return null;
    }
  }

  /// Muestra un SnackBar flotante con mensaje amigable.
  static void mostrarErrorConexion(BuildContext contexto) {
    _mostrarSnackBar(
      contexto,
      'No se pudo comunicar con el servidor en este momento.',
      esError: true,
    );
  }

  static void _mostrarSnackBar(
    BuildContext contexto,
    String mensaje, {
    bool esError = true,
  }) {
    if (!contexto.mounted) return;
    ScaffoldMessenger.of(contexto).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              esError ? Icons.wifi_off : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: esError ? const Color(0xFFBA1A1A) : const Color(0xFF184938),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

/// Tipos de error de red.
enum TipoErrorRed { sinConexion, timeout, servidorNoDisponible, desconocido }

/// Excepción tipada para errores de comunicación.
class ExcepcionRed implements Exception {
  final TipoErrorRed tipo;
  final String mensaje;

  const ExcepcionRed({required this.tipo, required this.mensaje});

  @override
  String toString() => 'ExcepcionRed($tipo): $mensaje';
}
