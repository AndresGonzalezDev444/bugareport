import { useState } from 'react';
import {
  IconClose, IconLocation, IconClock, IconCamera,
  IconExif, IconLink, IconSquad, IconValidate, IconX, IconAlert
} from '../ui/Icons.jsx';
import { StatusBadge, SeverityBadge, CategoryBadge } from '../ui/Badge.jsx';
import {
  CATEGORY_LABELS, formatDateTime, timeAgo, incidentId
} from '../../utils/statusHelpers.js';

const CUADRILLAS = {
  hueco_via:          { nombre: 'Cuadrilla 03 - Vías y Bacheo', operarios: '3 operarios · Camión Volqueta #08', dist: '1.2 km' },
  servicios_publicos: { nombre: 'Cuadrilla 07 - Redes y Alumbrado', operarios: '2 operarios · Camioneta #03', dist: '0.8 km' },
  comunitario:        { nombre: 'Cuadrilla 11 - Gestión Social', operarios: '2 gestores · Vehículo #12', dist: '2.1 km' },
  aseo_parques:       { nombre: 'Cuadrilla 02 - Aseo Urbano', operarios: '4 operarios · Camión compactador #05', dist: '0.5 km' },
};

export default function IncidentDrawer({ incident, onClose, onUpdateStatus }) {
  const [updating, setUpdating] = useState(false);
  const [feedback, setFeedback] = useState(null);

  if (!incident) return null;

  const repId     = incidentId(incident.id);
  const cuadrilla = CUADRILLAS[incident.category] || CUADRILLAS.hueco_via;
  const gpsStr    = `Lat: ${incident.latitude?.toFixed(4)}, Lon: ${incident.longitude?.toFixed(4)}`;
  const mapsUrl   = `https://maps.google.com/?q=${incident.latitude},${incident.longitude}`;

  async function handleStatus(newStatus) {
    setUpdating(true);
    setFeedback(null);
    const result = await onUpdateStatus(incident.id, newStatus);
    setFeedback(result.success ? 'success' : 'error');
    setUpdating(false);
    setTimeout(() => setFeedback(null), 2500);
  }

  return (
    <>
      <div className="drawer-overlay" onClick={onClose} />
      <aside className="drawer">
        {/* Cabecera del drawer */}
        <div className="drawer-header">
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="flex items-center gap-2" style={{ gap: 8, marginBottom: 6, flexWrap: 'wrap' }}>
              <span style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 700, fontSize: '0.75rem', color: 'var(--color-primary)' }}>
                {repId}
              </span>
              <CategoryBadge category={incident.category} />
              <SeverityBadge severity={incident.severity} />
              <StatusBadge status={incident.status} />
            </div>
            <div style={{ fontFamily: 'Montserrat, sans-serif', fontWeight: 700, fontSize: '1rem', color: 'var(--color-navy)', lineHeight: 1.3 }}>
              {incident.title}
            </div>
          </div>
          <button className="btn btn-ghost btn-icon" onClick={onClose} aria-label="Cerrar">
            <IconClose size={16} />
          </button>
        </div>

        {/* Cuerpo scrollable */}
        <div className="drawer-body">

          {/* 1. Fotografía y metadatos EXIF */}
          <div className="drawer-section" style={{ paddingTop: 12, paddingBottom: 0 }}>
            <div className="drawer-section-title">Evidencia fotográfica</div>
            <div className="photo-exif-wrapper">
              {incident.photo_url ? (
                <img src={incident.photo_url} alt="Evidencia" className="photo-main" />
              ) : (
                <div className="photo-no-image">
                  <IconCamera size={28} style={{ opacity: 0.3 }} />
                  <span>Sin fotografía adjunta</span>
                </div>
              )}
              <div className="exif-overlay">
                <span className="exif-chip">EXIF</span>
                <span className="exif-value">{formatDateTime(incident.created_at)} (estimado)</span>
                <span className="exif-value" style={{ fontFamily: 'JetBrains Mono, monospace' }}>
                  {incident.latitude?.toFixed(4)}, {incident.longitude?.toFixed(4)}
                </span>
              </div>
            </div>

            {/* Detalles EXIF */}
            <div style={{ background: 'var(--color-purple-light)', borderRadius: 'var(--radius-sm)', padding: '7px 10px', marginTop: 8, display: 'flex', gap: 16, flexWrap: 'wrap' }}>
              <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-main)' }}>
                <strong>Precisión GPS:</strong> ~8 metros
              </span>
              <span style={{ fontSize: '0.6875rem', color: 'var(--color-text-main)' }}>
                <strong>Fuente:</strong> GPS App + EXIF
              </span>
            </div>
          </div>

          {/* 2. Geolocalización */}
          <div className="drawer-section">
            <div className="drawer-section-title flex items-center gap-2" style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
              <IconLocation size={11} />
              Coordenadas GPS
            </div>

            <div style={{
              background: 'var(--bg-header)', border: '1px solid var(--border-soft)',
              borderRadius: 'var(--radius-sm)', padding: '6px 10px', marginBottom: 8
            }}>
              <span className="mono" style={{ color: 'var(--color-navy)' }}>{gpsStr}</span>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 4, marginBottom: 8 }}>
              <span style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)' }}>Dirección aproximada:</span>
              <span style={{ fontSize: '0.8125rem', fontWeight: 600, color: 'var(--color-text-dark)' }}>
                {incident.address || 'Dirección no disponible'}
              </span>
            </div>

            <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
              <a href={mapsUrl} target="_blank" rel="noreferrer"
                style={{ display: 'flex', alignItems: 'center', gap: 4, fontSize: '0.75rem', fontWeight: 600, color: 'var(--color-primary)', textDecoration: 'none' }}>
                <IconLink size={12} />
                Ver en Google Maps
              </a>
              <span style={{ color: 'var(--border-medium)', fontSize: '0.75rem' }}>|</span>
              <span style={{ fontSize: '0.75rem', fontWeight: 600, color: 'var(--color-primary)', cursor: 'pointer' }}>
                Ver en Geoportal Municipal
              </span>
            </div>
          </div>

          {/* 3. Cuadrante */}
          <div className="drawer-section">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <span style={{ fontSize: '0.75rem', fontWeight: 500, color: 'var(--color-text-main)' }}>Cuadrante y Sector</span>
              <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--color-navy)' }}>
                {incident.quadrant || 'Sin asignar'} · {incident.address?.split(',')[0] || '—'}
              </span>
            </div>
          </div>

          {/* 4. Tiempo transcurrido */}
          <div className="drawer-section" style={{ borderTop: '1px solid var(--border-soft)' }}>
            <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
              <div>
                <div className="drawer-section-title">Reportado</div>
                <div style={{ fontSize: '0.8125rem', fontWeight: 600, color: 'var(--color-text-dark)', marginTop: 2 }}>
                  {formatDateTime(incident.created_at)}
                </div>
                <div style={{ fontSize: '0.6875rem', color: 'var(--color-text-muted)', marginTop: 1 }}>
                  {timeAgo(incident.created_at)}
                </div>
              </div>
              <div>
                <div className="drawer-section-title">Última actualización</div>
                <div style={{ fontSize: '0.8125rem', fontWeight: 600, color: 'var(--color-text-dark)', marginTop: 2 }}>
                  {formatDateTime(incident.updated_at)}
                </div>
              </div>
            </div>
          </div>

          {/* 5. Descripción del ciudadano */}
          <div className="drawer-section">
            <div className="drawer-section-title">Descripción del ciudadano</div>
            <div style={{
              background: 'var(--bg-card)', border: '1px solid var(--border-purple)',
              borderRadius: 'var(--radius-sm)', padding: '10px 12px',
              fontStyle: 'italic', fontSize: '0.875rem', lineHeight: 1.65,
              color: 'var(--color-text-dark)'
            }}>
              {incident.description || 'El ciudadano no proporcionó descripción adicional.'}
            </div>
          </div>

          {/* 6. Cuadrilla operativa */}
          <div className="drawer-section" style={{
            background: 'var(--color-success-pale)',
            border: '1px solid rgba(159, 209, 186, 0.4)',
            borderRadius: 'var(--radius-lg)',
            margin: '0 -12px',
            padding: '12px 16px'
          }}>
            <div className="flex items-center gap-2" style={{ gap: 8, marginBottom: 10 }}>
              <IconSquad size={14} style={{ color: 'var(--color-success)' }} />
              <span style={{ fontWeight: 700, fontSize: '0.8125rem', color: 'var(--color-success)' }}>
                Cuadrilla Operativa Recomendada
              </span>
            </div>
            <div style={{
              display: 'flex', alignItems: 'center', justifyContent: 'space-between',
              background: 'var(--bg-card)', border: '1px solid rgba(159, 209, 186, 0.5)',
              borderRadius: 'var(--radius-md)', padding: '10px 12px', flexWrap: 'wrap', gap: 8
            }}>
              <div>
                <div style={{ fontWeight: 600, fontSize: '0.8125rem', color: 'var(--color-navy)' }}>
                  {cuadrilla.nombre}
                </div>
                <div style={{ fontSize: '0.75rem', color: 'var(--color-text-muted)', marginTop: 2 }}>
                  {cuadrilla.operarios}
                </div>
              </div>
              <span style={{
                background: 'var(--color-success-lighter)', color: 'var(--color-success)',
                padding: '3px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.6875rem', fontWeight: 600
              }}>
                Disponible en {incident.quadrant || 'Q-??'} (a {cuadrilla.dist})
              </span>
            </div>
          </div>

          {/* Feedback */}
          {feedback && (
            <div className="drawer-section">
              <div style={{
                display: 'flex', alignItems: 'center', gap: 8, padding: '8px 12px',
                borderRadius: 'var(--radius-md)',
                background: feedback === 'success' ? 'var(--color-success-light)' : 'var(--color-primary-light)',
                color: feedback === 'success' ? 'var(--color-success-mid)' : 'var(--color-primary-muted)',
                fontSize: '0.75rem', fontWeight: 600
              }}>
                {feedback === 'success' ? <IconValidate size={13} /> : <IconAlert size={13} />}
                {feedback === 'success' ? 'Estado actualizado correctamente' : 'Error al actualizar — intenta de nuevo'}
              </div>
            </div>
          )}
        </div>

        {/* Footer — acciones */}
        <div className="drawer-footer">
          <div className="drawer-actions-primary">
            <button
              className="btn btn-blue btn-lg"
              onClick={() => handleStatus('en_proceso')}
              disabled={updating || incident.status === 'en_proceso'}
            >
              <IconValidate size={13} />
              Validar reporte
            </button>
            <button
              className="btn btn-success btn-lg"
              onClick={() => handleStatus('resuelto')}
              disabled={updating || incident.status === 'resuelto'}
            >
              <IconSquad size={13} />
              Asignar cuadrilla
            </button>
          </div>
          <div className="drawer-actions-secondary">
            <button className="btn btn-outline">
              <IconCamera size={12} />
              Seleccionar evidencia
            </button>
            <button className="btn btn-danger" onClick={() => handleStatus('pendiente')} disabled={updating}>
              <IconX size={11} />
              Rechazar / Duplicado
            </button>
          </div>
        </div>
      </aside>
    </>
  );
}
