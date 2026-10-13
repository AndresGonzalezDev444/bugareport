import 'package:flutter/material.dart';
import 'package:bugareport/config/tema_app.dart';
import 'package:bugareport/servicios/servicio_conectividad.dart';

/// Pastilla reactiva que muestra el estado de conectividad en tiempo real.
///
/// Se auto-suscribe al [ServicioConectividad.estadoConexion] y actualiza
/// su color/texto automáticamente cuando cambia la red, sin necesidad
/// de pasar parámetros desde el padre.
///
/// Punto verde + "En línea" | Punto rojo + "Sin conexión"
class PastillaConexion extends StatelessWidget {
  const PastillaConexion({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ServicioConectividad.instancia.estadoConexion,
      initialData: true,
      builder: (context, instantanea) {
        final enLinea = instantanea.data ?? true;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _PildoraEstado(enLinea: enLinea, key: ValueKey(enLinea)),
        );
      },
    );
  }
}

class _PildoraEstado extends StatelessWidget {
  final bool enLinea;

  const _PildoraEstado({super.key, required this.enLinea});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: enLinea
            ? ColoresApp.conexionPildoraFondo
            : ColoresApp.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Punto de estado con pulso visual cuando está en línea
          _PuntoPulso(enLinea: enLinea),
          const SizedBox(width: 4),
          Text(
            enLinea ? 'En línea' : 'Sin conexión',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: enLinea ? ColoresApp.terciarioOscuro : ColoresApp.error,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Punto animado que pulsa suavemente cuando hay conexión.
class _PuntoPulso extends StatefulWidget {
  final bool enLinea;

  const _PuntoPulso({required this.enLinea});

  @override
  State<_PuntoPulso> createState() => _EstadoPuntoPulso();
}

class _EstadoPuntoPulso extends State<_PuntoPulso>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador;
  late final Animation<double> _animacion;

  @override
  void initState() {
    super.initState();
    _controlador = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animacion = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controlador, curve: Curves.easeInOut),
    );
    if (widget.enLinea) {
      _controlador.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PuntoPulso old) {
    super.didUpdateWidget(old);
    if (widget.enLinea && !_controlador.isAnimating) {
      _controlador.repeat(reverse: true);
    } else if (!widget.enLinea) {
      _controlador.stop();
    }
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.enLinea ? _animacion : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.enLinea ? ColoresApp.terciarioOscuro : ColoresApp.error,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
