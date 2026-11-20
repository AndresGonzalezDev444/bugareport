// components/incidents/HistoryTimeline.jsx
// HU2 - Timeline visual del historial de seguimiento de un incidente
// Se renderiza dentro del IncidentDrawer.

import { IconCheck, IconValidate, IconAlert, IconLocation, IconSquad, IconUser } from '../ui/Icons.jsx';

const ACTION_CONFIG = {
  estado_pendiente:    { label: 'Devuelto a pendiente',       color: '#86521B', Icon: IconAlert    },
  estado_en_proceso:   { label: 'Validado — En gestion',     color: '#2B5C8F', Icon: IconValidate },
  estado_resuelto:     { label: 'Marcado como resuelto',      color: '#16A34A', Icon: IconCheck    },
  cuadrante_asignado:  { label: 'Cuadrante asignado',         color: '#4B4ECC', Icon: IconLocation },
  personal_asignado:   { label: 'Personal asignado',          color: '#2E5D4B', Icon: IconSquad    },
  personal_removido:   { label: 'Personal removido',          color: '#86521B', Icon: IconUser     },
  duplicado_marcado:   { label: 'Marcado como duplicado',     color: '#5B0510', Icon: IconAlert    },
  duplicado_descartado:{ label: 'Duplicado descartado',       color: '#2E5D4B', Icon: IconCheck    },
};

function formatHora(isoStr) {
  if (!isoStr) return '—';
  const d = new Date(isoStr);
  return d.toLocaleString('es-CO', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit',
  });
}

function EntradaHistorial({ entrada }) {
  const cfg = ACTION_CONFIG[entrada.action] || {
    label: entrada.action,
    color: 'var(--color-text-muted)',
    Icon: IconCheck,
  };
  const { Icon } = cfg;

  return (
    <div style={{
      display: 'flex',
      gap: 10,
      alignItems: 'flex-start',
      paddingBottom: 12,
      position: 'relative',
    }}>
      {/* Icono con linea vertical */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', flexShrink: 0 }}>
        <div style={{
          width: 28, height: 28, borderRadius: '50%',
          background: cfg.color + '1A',
          border: `2px solid ${cfg.color}`,
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          flexShrink: 0,
        }}>
          <Icon size={12} style={{ color: cfg.color }} />
        </div>
      </div>

      {/* Contenido */}
      <div style={{ flex: 1, paddingTop: 2 }}>
        <div style={{
          display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8,
        }}>
          <div style={{ fontWeight: 700, fontSize: '0.75rem', color: cfg.color }}>
            {cfg.label}
          </div>
          <span style={{ fontSize: '0.625rem', color: 'var(--color-text-muted)', whiteSpace: 'nowrap', flexShrink: 0 }}>
            {formatHora(entrada.createdAt)}
          </span>
        </div>

        {(entrada.oldValue || entrada.newValue) && (
          <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', marginTop: 2 }}>
            {entrada.oldValue && (
              <span style={{ textDecoration: 'line-through', marginRight: 6 }}>{entrada.oldValue}</span>
            )}
            {entrada.newValue && (
              <span style={{ color: 'var(--color-text-dark)', fontWeight: 600 }}>{entrada.newValue}</span>
            )}
          </div>
        )}

        {entrada.notes && (
          <div style={{
            marginTop: 4, fontSize: '0.6875rem', color: 'var(--color-text-dark)',
            fontStyle: 'italic', background: 'var(--bg-header)',
            border: '1px solid var(--border-soft)', borderRadius: 4,
            padding: '3px 7px',
          }}>
            {entrada.notes}
          </div>
        )}

        <div style={{ fontSize: '0.5625rem', color: 'var(--color-text-muted)', marginTop: 3 }}>
          Por {entrada.adminName || 'Admin'}
        </div>
      </div>
    </div>
  );
}

export default function HistoryTimeline({ historial = [] }) {
  if (historial.length === 0) {
    return (
      <div style={{
        fontSize: '0.75rem', color: 'var(--color-text-muted)',
        fontStyle: 'italic', textAlign: 'center', padding: '8px 0',
      }}>
        Sin modificaciones registradas aun.
      </div>
    );
  }

  return (
    <div style={{ position: 'relative' }}>
      {/* Linea vertical conectora */}
      {historial.length > 1 && (
        <div style={{
          position: 'absolute', left: 13, top: 28, bottom: 12,
          width: 2, background: 'var(--border-soft)',
        }} />
      )}
      {historial.map(entrada => (
        <EntradaHistorial key={entrada.id} entrada={entrada} />
      ))}
    </div>
  );
}

