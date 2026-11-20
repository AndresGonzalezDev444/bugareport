// components/incidents/DuplicatesPanel.jsx
// HU8 - Panel de gestion de incidentes duplicados
// Se renderiza dentro del IncidentDrawer cuando se detectan posibles duplicados.

import { IconAlert, IconCheck, IconX, IconLocation } from '../ui/Icons.jsx';
import { CategoryBadge, StatusBadge } from '../ui/Badge.jsx';
import { incidentId, timeAgo } from '../../utils/statusHelpers.js';

export default function DuplicatesPanel({ duplicados = [], onMarcarDuplicado, onDescartarDuplicado }) {
  if (duplicados.length === 0) return null;

  return (
    <div style={{
      background: 'rgba(134, 82, 27, 0.06)',
      border: '1px solid rgba(134, 82, 27, 0.25)',
      borderRadius: 'var(--radius-lg)',
      margin: '0 -12px',
      padding: '12px 16px',
    }}>
      {/* Encabezado */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10 }}>
        <div style={{
          width: 28, height: 28, borderRadius: '50%',
          background: 'rgba(134, 82, 27, 0.12)',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          flexShrink: 0,
        }}>
          <IconAlert size={13} style={{ color: 'var(--color-warning)' }} />
        </div>
        <div>
          <div style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-warning)' }}>
            {duplicados.length} posible{duplicados.length > 1 ? 's' : ''} duplicado{duplicados.length > 1 ? 's' : ''} detectado{duplicados.length > 1 ? 's' : ''}
          </div>
          <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)' }}>
            Misma categoria, ubicacion cercana y fecha proxima
          </div>
        </div>
      </div>

      {/* Lista de duplicados */}
      <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
        {duplicados.map(dup => (
          <div key={dup.id} style={{
            background: 'var(--bg-card)',
            border: '1px solid var(--border-soft)',
            borderRadius: 'var(--radius-md)',
            padding: '8px 10px',
          }}>
            {/* Fila superior */}
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8, marginBottom: 4 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, flexWrap: 'wrap' }}>
                <span style={{
                  fontFamily: 'JetBrains Mono, monospace',
                  fontWeight: 700, fontSize: '0.6875rem', color: 'var(--color-primary)',
                }}>
                  {incidentId(dup.id)}
                </span>
                <CategoryBadge category={dup.category} />
                <StatusBadge status={dup.status} />
              </div>
              <span style={{ fontSize: '0.5625rem', color: 'var(--color-text-muted)', whiteSpace: 'nowrap', flexShrink: 0 }}>
                {timeAgo(dup.created_at)}
              </span>
            </div>

            {/* Titulo */}
            <div style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--color-navy)', marginBottom: 4 }}>
              {dup.title}
            </div>

            {/* Metricas de similitud */}
            <div style={{ display: 'flex', gap: 12, marginBottom: 8 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.625rem', color: 'var(--color-text-muted)' }}>
                <IconLocation size={9} />
                <span>{dup._distanciaMetros}m de distancia</span>
              </div>
              <span style={{ fontSize: '0.625rem', color: 'var(--color-text-muted)' }}>
                {dup._diffDias === 0 ? 'Mismo dia' : `${dup._diffDias} dia${dup._diffDias > 1 ? 's' : ''} de diferencia`}
              </span>
            </div>

            {/* Acciones */}
            <div style={{ display: 'flex', gap: 6 }}>
              <button
                onClick={() => onMarcarDuplicado?.(dup.id)}
                style={{
                  flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5,
                  padding: '4px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600,
                  background: 'rgba(134, 82, 27, 0.1)', border: '1px solid rgba(134, 82, 27, 0.3)',
                  color: 'var(--color-warning)', cursor: 'pointer',
                }}
              >
                <IconAlert size={10} />
                Marcar duplicado
              </button>
              <button
                onClick={() => onDescartarDuplicado?.(dup.id)}
                style={{
                  flex: 1, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5,
                  padding: '4px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600,
                  background: 'rgba(22, 163, 74, 0.08)', border: '1px solid rgba(22, 163, 74, 0.25)',
                  color: 'var(--color-success)', cursor: 'pointer',
                }}
              >
                <IconX size={10} />
                Descartar
              </button>
            </div>
          </div>
        ))}
      </div>

      <div style={{ marginTop: 8, fontSize: '0.5625rem', color: 'var(--color-text-muted)' }}>
        Los reportes relacionados conservan su informacion original. Las decisiones quedan registradas en el historial.
      </div>
    </div>
  );
}

